package com.kavya.project_toji

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class TojiDailyOverviewWidget : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        try {
            appWidgetIds.forEach { widgetId ->
                try {
                    val options = appWidgetManager.getAppWidgetOptions(widgetId)
                    val minWidth = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 140) ?: 140

                    val layoutId = if (minWidth >= 220) {
                        R.layout.widget_medium_4x2
                    } else {
                        R.layout.widget_small_2x2
                    }

                    val views = RemoteViews(context.packageName, layoutId)

                    val workoutName = widgetData.getString("today_workout_name", "Today's Workout") ?: "Today's Workout"
                    val workoutStatus = widgetData.getString("today_workout_status", "Not started") ?: "Not started"
                    val streak = widgetData.getInt("current_streak", 0)
                    val completionPct = widgetData.getInt("today_completion_pct", 0)
                    val todayDate = widgetData.getString("today_date", "Today") ?: "Today"

                    views.setTextViewText(R.id.widget_workout_name, workoutName)
                    views.setTextViewText(R.id.widget_workout_status, workoutStatus)
                    views.setProgressBar(R.id.widget_progress_bar, 100, completionPct, false)

                    // Setup Streak
                    if (layoutId == R.layout.widget_medium_4x2) {
                        views.setTextViewText(R.id.widget_today_date, todayDate)
                        views.setTextViewText(R.id.widget_streak_count, "$streak days")

                        val reminderTitle = widgetData.getString("next_reminder_title", "No upcoming alerts") ?: "No upcoming alerts"
                        val reminderTime = widgetData.getString("next_reminder_time", "") ?: ""

                        views.setTextViewText(R.id.widget_reminder_title, reminderTitle)
                        views.setTextViewText(R.id.widget_reminder_time, reminderTime)

                        val reminderIntent = HomeWidgetLaunchIntent.getActivity(
                            context,
                            MainActivity::class.java,
                            Uri.parse("toji://reminder")
                        )
                        views.setOnClickPendingIntent(R.id.widget_reminder_container, reminderIntent)
                    } else {
                        views.setTextViewText(R.id.widget_streak_count, streak.toString())
                    }

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

                    // Quick Add Note -> toji://add_note
                    val addNoteIntent = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("toji://add_note")
                    )
                    views.setOnClickPendingIntent(R.id.widget_action_add_note, addNoteIntent)

                    appWidgetManager.updateAppWidget(widgetId, views)
                } catch (e: Throwable) {
                    Log.e("TojiDailyOverview", "Error updating widgetId: $widgetId", e)
                }
            }
        } catch (e: Throwable) {
            Log.e("TojiDailyOverview", "Error in onUpdate", e)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle?
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        try {
            onUpdate(context, appWidgetManager, intArrayOf(appWidgetId))
        } catch (e: Throwable) {
            Log.e("TojiDailyOverview", "Error in onAppWidgetOptionsChanged", e)
        }
    }
}
