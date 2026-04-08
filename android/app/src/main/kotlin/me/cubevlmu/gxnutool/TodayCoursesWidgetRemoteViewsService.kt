package me.cubevlmu.gxnutool

import android.content.Context
import android.content.Intent
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
    val item = items[position]
    return RemoteViews(context.packageName, R.layout.today_courses_widget_item).apply {
      setTextViewText(R.id.course_time, item.timeText)
      setTextViewText(R.id.course_title, item.titleText)
      setTextViewText(R.id.course_room, item.roomText)
    }
  }

  override fun getLoadingView(): RemoteViews? = null

  override fun getViewTypeCount(): Int = 1

  override fun getItemId(position: Int): Long = position.toLong()

  override fun hasStableIds(): Boolean = true

  private fun loadItems() {
    items.clear()
    val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
    val raw = prefs.getString("coursesJson", "[]") ?: "[]"
    val array = runCatching { JSONArray(raw) }.getOrElse { JSONArray() }
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
  }
}

private data class TodayCourseWidgetItem(
  val timeText: String,
  val titleText: String,
  val roomText: String,
)
