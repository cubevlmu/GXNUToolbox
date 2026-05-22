package me.cubevlmu.gxnutool

import android.content.Context
import android.content.Intent
import android.util.Log
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONArray

class TodayCoursesWidgetRemoteViewsService : RemoteViewsService() {
  override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
    return TodayCoursesWidgetRemoteViewsFactory(applicationContext)
  }
}

private class TodayCoursesWidgetRemoteViewsFactory(
  private val context: Context,
) : RemoteViewsService.RemoteViewsFactory {

  private val items = mutableListOf<TodayCourseWidgetItem>()

  override fun onCreate() {
    loadItems()
  }

  override fun onDataSetChanged() {
    loadItems()
  }

  override fun onDestroy() {
    items.clear()
  }

  override fun getCount(): Int = items.size

  override fun getViewAt(position: Int): RemoteViews {
    val item = items.getOrNull(position)
    Log.d("TodayCoursesWidget", "getViewAt position=$position count=${items.size}")
    return RemoteViews(context.packageName, R.layout.today_courses_widget_item).apply {
      if (item == null) {
        setTextViewText(R.id.course_time, "--:--")
        setTextViewText(R.id.course_title, "课程信息不可用")
        setTextViewText(R.id.course_room, "")
        return@apply
      }
      setTextViewText(R.id.course_time, item.timeText.ifBlank { "--:--" })
      setTextViewText(R.id.course_title, item.titleText.ifBlank { "课程待定" })
      setTextViewText(R.id.course_room, item.roomText.ifBlank { "教室待定" })
    }
  }

  override fun getLoadingView(): RemoteViews {
    return RemoteViews(context.packageName, R.layout.today_courses_widget_item).apply {
      setTextViewText(R.id.course_time, "--:--")
      setTextViewText(R.id.course_title, "正在同步课程")
      setTextViewText(R.id.course_room, "请稍候")
    }
  }

  override fun getViewTypeCount(): Int = 1

  override fun getItemId(position: Int): Long = position.toLong()

  override fun hasStableIds(): Boolean = true

  private fun loadItems() {
    items.clear()
    val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
    val raw = prefs.getString("coursesJson", "[]") ?: "[]"
    Log.d("TodayCoursesWidget", "loadItems count=${items.size} raw=$raw")
    val array = runCatching { JSONArray(raw) }.getOrElse { JSONArray() }
    items.clear()
    for (index in 0 until array.length()) {
      val objectData = array.optJSONObject(index) ?: continue
      items.add(
        TodayCourseWidgetItem(
          timeText = objectData.optString("time", "--:--"),
          titleText = objectData.optString("title", "课程待定"),
          roomText = objectData.optString("room", "教室待定"),
        ),
      )
    }
    Log.d("TodayCoursesWidget", "loadItems count=${items.size}")
  }
}

data class TodayCourseWidgetItem(
  val timeText: String,
  val titleText: String,
  val roomText: String,
)
