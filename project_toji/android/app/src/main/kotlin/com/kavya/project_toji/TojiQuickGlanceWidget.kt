package com.kavya.project_toji

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class TojiQuickGlanceWidget : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val options = appWidgetManager.getAppWidgetOptions(widgetId)
            val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 110)

            val layoutId = if (minWidth < 90) {
                R.layout.widget_tiny_1x1
            } else {
                R.layout.widget_compact_2x1
            }

            val views = RemoteViews(context.packageName, layoutId)

            val workoutName = widgetData.getString("today_workout_name", "No Workout") ?: "No Workout"
            val workoutStatus = widgetData.getString("today_workout_status", "Rest day") ?: "Rest day"
            val streak = widgetData.getInt("current_streak", 0)
            val completionPct = widgetData.getInt("today_completion_pct", 0)

            if (layoutId == R.layout.widget_tiny_1x1) {
                views.setTextViewText(R.id.widget_tiny_text, if (workoutName == "No Workout") "TOJI" else workoutName)
                views.setTextViewText(R.id.widget_tiny_status, if (completionPct > 0) "$completionPct%" else "${streak}d")

                val appIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("toji://workout")
                )
                views.setOnClickPendingIntent(R.id.widget_tiny_container, appIntent)
            } else {
                views.setTextViewText(R.id.widget_workout_name, workoutName)
                views.setTextViewText(R.id.widget_workout_status, workoutStatus)
                views.setTextViewText(R.id.widget_streak_count, streak.toString())
                views.setProgressBar(R.id.widget_progress_bar, 100, completionPct, false)

                // Streak click -> toji://streak
                val streakIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("toji://streak")
                )
                views.setOnClickPendingIntent(R.id.widget_streak_container, streakIntent)

                // Workout click -> toji://workout
                val workoutIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("toji://workout")
                )
                views.setOnClickPendingIntent(R.id.widget_workout_container, workoutIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle?
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        onUpdate(context, appWidgetManager, intArrayOf(appWidgetId))
    }
}
