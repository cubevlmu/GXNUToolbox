package me.cubevlmu.gxnutool

import android.Manifest
import android.content.ContentValues
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.CalendarContract
import android.provider.MediaStore
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.TimeZone

class MainActivity : FlutterActivity() {
  private val channelName = "me.cubevlmu.gxnutool/native"
  private val imagePermissionRequest = 4216
  private val calendarPermissionRequest = 4217
  private var pendingImageBytes: ByteArray? = null
  private var pendingImageName: String? = null
  private var pendingImageResult: MethodChannel.Result? = null
  private var pendingCalendarEvents: List<Map<String, Any?>>? = null
  private var pendingCalendarResult: MethodChannel.Result? = null

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler {
      call,
      result ->
      when (call.method) {
        "saveImageToGallery" -> {
          val bytes = call.argument<ByteArray>("bytes")
          val displayName = call.argument<String>("displayName")
          if (bytes == null || displayName.isNullOrBlank()) {
            result.error("bad_args", "图片数据不可用", null)
            return@setMethodCallHandler
          }
          if (!hasImageSavePermission()) {
            pendingImageBytes = bytes
            pendingImageName = displayName
            pendingImageResult = result
            ActivityCompat.requestPermissions(
              this,
              arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
              imagePermissionRequest,
            )
            return@setMethodCallHandler
          }
          runCatching { saveImageToGallery(bytes, displayName) }
            .onSuccess { result.success(it) }
            .onFailure { result.error("save_failed", it.message ?: "保存图片失败", null) }
        }

        "addCalendarEvents" -> {
          val rawEvents = call.argument<List<Map<String, Any?>>>("events") ?: emptyList()
          if (rawEvents.isEmpty()) {
            result.success(0)
            return@setMethodCallHandler
          }
          if (hasCalendarPermission()) {
            runCatching { addCalendarEvents(rawEvents) }
              .onSuccess { result.success(it) }
              .onFailure { result.error("calendar_failed", it.message ?: "导入日历失败", null) }
          } else {
            pendingCalendarEvents = rawEvents
            pendingCalendarResult = result
            ActivityCompat.requestPermissions(
              this,
              arrayOf(Manifest.permission.READ_CALENDAR, Manifest.permission.WRITE_CALENDAR),
              calendarPermissionRequest,
            )
          }
        }

        "canRequestPackageInstalls" -> {
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            result.success(packageManager.canRequestPackageInstalls())
          } else {
            result.success(true)
          }
        }

        "openInstallPermissionSettings" -> {
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val intent = Intent(
              Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
              Uri.parse("package:$packageName"),
            ).apply {
              addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
          }
          result.success(true)
        }

        "installApk" -> {
          val filePath = call.argument<String>("filePath")
          if (filePath.isNullOrBlank()) {
            result.error("bad_args", "安装包路径为空", null)
            return@setMethodCallHandler
          }
          runCatching { installApk(filePath) }
            .onSuccess { result.success(true) }
            .onFailure { result.error("install_failed", it.message ?: "无法打开安装包", null) }
        }

        else -> result.notImplemented()
      }
    }
  }

  override fun onRequestPermissionsResult(
    requestCode: Int,
    permissions: Array<out String>,
    grantResults: IntArray,
  ) {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    if (requestCode == imagePermissionRequest) {
      val result = pendingImageResult ?: return
      val bytes = pendingImageBytes
      val name = pendingImageName
      pendingImageResult = null
      pendingImageBytes = null
      pendingImageName = null

      if (!hasImageSavePermission() || bytes == null || name == null) {
        result.error("permission_denied", "未授予存储权限，无法保存到系统图库", null)
        return
      }

      runCatching { saveImageToGallery(bytes, name) }
        .onSuccess { result.success(it) }
        .onFailure { result.error("save_failed", it.message ?: "保存图片失败", null) }
      return
    }

    if (requestCode != calendarPermissionRequest) return

    val result = pendingCalendarResult ?: return
    val events = pendingCalendarEvents ?: emptyList()
    pendingCalendarResult = null
    pendingCalendarEvents = null

    if (!hasCalendarPermission()) {
      result.error("permission_denied", "未授予日历权限，无法批量导入", null)
      return
    }

    runCatching { addCalendarEvents(events) }
      .onSuccess { result.success(it) }
      .onFailure { result.error("calendar_failed", it.message ?: "导入日历失败", null) }
  }

  private fun saveImageToGallery(bytes: ByteArray, displayName: String): String {
    val resolver = contentResolver
    val safeName = if (displayName.endsWith(".png", ignoreCase = true)) displayName else "$displayName.png"
    val values = ContentValues().apply {
      put(MediaStore.Images.Media.DISPLAY_NAME, safeName)
      put(MediaStore.Images.Media.MIME_TYPE, "image/png")
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/GXNU Class Tool")
        put(MediaStore.Images.Media.IS_PENDING, 1)
      }
    }

    val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
      ?: throw IllegalStateException("无法创建图库文件")
    try {
      resolver.openOutputStream(uri)?.use { it.write(bytes) }
        ?: throw IllegalStateException("无法写入图库文件")
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        values.clear()
        values.put(MediaStore.Images.Media.IS_PENDING, 0)
        resolver.update(uri, values, null, null)
      }
      return uri.toString()
    } catch (error: Throwable) {
      resolver.delete(uri, null, null)
      throw error
    }
  }

  private fun hasImageSavePermission(): Boolean {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) return true
    return ContextCompat.checkSelfPermission(
      this,
      Manifest.permission.WRITE_EXTERNAL_STORAGE,
    ) == PackageManager.PERMISSION_GRANTED
  }

  private fun hasCalendarPermission(): Boolean {
    val readGranted = ContextCompat.checkSelfPermission(
      this,
      Manifest.permission.READ_CALENDAR,
    ) == PackageManager.PERMISSION_GRANTED
    val writeGranted = ContextCompat.checkSelfPermission(
      this,
      Manifest.permission.WRITE_CALENDAR,
    ) == PackageManager.PERMISSION_GRANTED
    return readGranted && writeGranted
  }

  private fun addCalendarEvents(events: List<Map<String, Any?>>): Int {
    val calendarId = resolveCalendarId()
      ?: throw IllegalStateException("未找到可写入的系统日历")
    var added = 0
    for (event in events) {
      val title = event["title"]?.toString()?.takeIf { it.isNotBlank() } ?: "课程"
      val startMillis = (event["startMillis"] as? Number)?.toLong() ?: continue
      val endMillis = (event["endMillis"] as? Number)?.toLong() ?: continue
      val description = event["description"]?.toString() ?: ""
      val location = event["location"]?.toString() ?: ""
      val normalizedEndMillis = if (endMillis > startMillis) endMillis else startMillis + 45 * 60 * 1000
      if (calendarEventExists(calendarId, title, description, location, startMillis, normalizedEndMillis)) {
        continue
      }
      val values = ContentValues().apply {
        put(CalendarContract.Events.CALENDAR_ID, calendarId)
        put(CalendarContract.Events.TITLE, title)
        put(CalendarContract.Events.DESCRIPTION, description)
        put(CalendarContract.Events.EVENT_LOCATION, location)
        put(CalendarContract.Events.DTSTART, startMillis)
        put(CalendarContract.Events.DTEND, normalizedEndMillis)
        put(CalendarContract.Events.EVENT_TIMEZONE, TimeZone.getDefault().id)
      }
      val uri = contentResolver.insert(CalendarContract.Events.CONTENT_URI, values)
      if (uri != null) {
        added += 1
      }
    }
    return added
  }

  private fun calendarEventExists(
    calendarId: Long,
    title: String,
    description: String,
    location: String,
    startMillis: Long,
    endMillis: Long,
  ): Boolean {
    val marker = Regex("class_tool_[A-Za-z0-9_\\-]+=[^\\s]+").find(description)?.value
    val projection = arrayOf(CalendarContract.Events._ID)
    val selection: String
    val args: Array<String>
    if (marker != null) {
      selection =
        "${CalendarContract.Events.CALENDAR_ID}=? AND ${CalendarContract.Events.DESCRIPTION} LIKE ?"
      args = arrayOf(calendarId.toString(), "%$marker%")
    } else {
      selection =
        "${CalendarContract.Events.CALENDAR_ID}=? AND ${CalendarContract.Events.TITLE}=? AND ${CalendarContract.Events.DTSTART}=? AND ${CalendarContract.Events.DTEND}=? AND ${CalendarContract.Events.EVENT_LOCATION}=?"
      args = arrayOf(
        calendarId.toString(),
        title,
        startMillis.toString(),
        endMillis.toString(),
        location,
      )
    }
    contentResolver.query(
      CalendarContract.Events.CONTENT_URI,
      projection,
      selection,
      args,
      null,
    )?.use { cursor ->
      return cursor.moveToFirst()
    }
    return false
  }

  private fun resolveCalendarId(): Long? {
    val projection = arrayOf(
      CalendarContract.Calendars._ID,
      CalendarContract.Calendars.IS_PRIMARY,
      CalendarContract.Calendars.VISIBLE,
    )
    val uri = CalendarContract.Calendars.CONTENT_URI
    contentResolver.query(
      uri,
      projection,
      "${CalendarContract.Calendars.VISIBLE}=1",
      null,
      null,
    )?.use { cursor ->
      var firstVisible: Long? = null
      while (cursor.moveToNext()) {
        val id = cursor.getLong(0)
        val primary = cursor.getInt(1)
        if (firstVisible == null) firstVisible = id
        if (primary == 1) return id
      }
      return firstVisible
    }
    return null
  }

  private fun installApk(filePath: String) {
    val file = File(filePath)
    if (!file.exists()) {
      throw IllegalStateException("安装包文件不存在")
    }
    val uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", file)
    val intent = Intent(Intent.ACTION_VIEW).apply {
      setDataAndType(uri, "application/vnd.android.package-archive")
      addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
    }
    startActivity(intent)
  }
}
