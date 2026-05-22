package me.cubevlmu.gxnutool

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class TodayCoursesLargeWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetIds: IntArray,
    widgetData: SharedPreferences,
  ) {
    appWidgetIds.forEach { widgetId ->
      val views = RemoteViews(context.packageName, R.layout.today_courses_large_widget).apply {
        setOnClickPendingIntent(
          R.id.widget_root,
          HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
        )
        setOnClickPendingIntent(
          R.id.refresh_button,
          HomeWidgetBackgroundIntent.getBroadcast(
            context,
            Uri.parse("classtool://refresh"),
          ),
        )

        val state = widgetData.getString("state", "idle") ?: "idle"
        val headlineText = widgetData.getString("headlineText", "今日课程") ?: "今日课程"
        val weekText = widgetData.getString("weekText", "--") ?: "--"
        val updatedAtText = widgetData.getString("updatedAtText", "") ?: ""
        val courseCount = widgetData.getInt("courseCount", 0)
        val coursesJson = widgetData.getString("coursesJson", "[]") ?: "[]"
        val hasCourses = courseCount > 0 && coursesJson.length > 2

        setTextViewText(R.id.headline_text, headlineText)
        setTextViewText(R.id.week_text, weekText)
        setTextViewText(R.id.updated_at_text, updatedAtText)

        val isLoading = state == "loading"
        setViewVisibility(R.id.refresh_button, if (isLoading) View.GONE else View.VISIBLE)
        setViewVisibility(R.id.refresh_progress, if (isLoading) View.VISIBLE else View.GONE)

        val showEmpty = !hasCourses
        setViewVisibility(R.id.empty_text, if (showEmpty) View.VISIBLE else View.GONE)
        setViewVisibility(R.id.course_list, if (showEmpty) View.GONE else View.VISIBLE)
        if (showEmpty) {
          val emptyText = when (state) {
            "loggedOut" -> "登录后可查看今日课程"
            "error" -> "刷新失败，请点击右上角重试"
            "loading" -> "正在同步今日课程"
            else -> "今天没有课程安排"
          }
          setTextViewText(R.id.empty_text, emptyText)
        }

        val serviceIntent = Intent(context, TodayCoursesWidgetRemoteViewsService::class.java).apply {
          putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
          data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
        }
        setRemoteAdapter(R.id.course_list, serviceIntent)
        setEmptyView(R.id.course_list, R.id.empty_text)
      }

      appWidgetManager.updateAppWidget(widgetId, views)
      appWidgetManager.notifyAppWidgetViewDataChanged(widgetId, R.id.course_list)
    }
  }
}
