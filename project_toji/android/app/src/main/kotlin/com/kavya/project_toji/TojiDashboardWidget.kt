package com.kavya.project_toji

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class TojiDashboardWidget : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_large_4x4)

            val todayDate = widgetData.getString("today_date", "Today") ?: "Today"
            val workoutName = widgetData.getString("today_workout_name", "No Workout") ?: "No Workout"
            val workoutStatus = widgetData.getString("today_workout_status", "Rest day") ?: "Rest day"
            val streak = widgetData.getInt("current_streak", 0)
            val completionPct = widgetData.getInt("today_completion_pct", 0)
            val weeklyProgressText = widgetData.getString("weekly_progress_text", "0 of 5 Done") ?: "0 of 5 Done"
            val weeklyCompletionPct = widgetData.getInt("weekly_completion_pct", 0)
            val reminderTitle = widgetData.getString("next_reminder_title", "No upcoming alerts") ?: "No upcoming alerts"
            val reminderTime = widgetData.getString("next_reminder_time", "") ?: ""

            views.setTextViewText(R.id.widget_today_date, todayDate)
            views.setTextViewText(R.id.widget_streak_count, "$streak days")
            views.setTextViewText(R.id.widget_workout_name, workoutName)
            views.setTextViewText(R.id.widget_workout_status, workoutStatus)
            views.setTextViewText(R.id.widget_workout_percent, "$completionPct%")
            views.setProgressBar(R.id.widget_progress_bar, 100, completionPct, false)

            views.setTextViewText(R.id.widget_weekly_progress_text, weeklyProgressText)
            views.setProgressBar(R.id.widget_weekly_progress_bar, 100, weeklyCompletionPct, false)

            views.setTextViewText(R.id.widget_reminder_title, reminderTitle)
            views.setTextViewText(R.id.widget_reminder_time, reminderTime)

            // 1. Workout Section click -> toji://workout
            val workoutIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("toji://workout")
            )
            views.setOnClickPendingIntent(R.id.widget_workout_container, workoutIntent)

            // 2. Streak click -> toji://streak
            val streakIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("toji://streak")
            )
            views.setOnClickPendingIntent(R.id.widget_streak_container, streakIntent)

            // 3. Weekly progress click -> toji://progress
            val progressIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("toji://progress")
            )
            views.setOnClickPendingIntent(R.id.widget_progress_container, progressIntent)

            // 4. Reminder click -> toji://reminder
            val reminderIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("toji://reminder")
            )
            views.setOnClickPendingIntent(R.id.widget_reminder_container, reminderIntent)

            // 5. Open Gym -> toji://gym
            val gymIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("toji://gym")
            )
            views.setOnClickPendingIntent(R.id.widget_action_gym, gymIntent)

            // 6. Quick Add Note -> toji://add_note
            val addNoteIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("toji://add_note")
            )
            views.setOnClickPendingIntent(R.id.widget_action_add_note, addNoteIntent)

            // 7. Open Notes -> toji://notes
            val notesIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("toji://notes")
            )
            views.setOnClickPendingIntent(R.id.widget_action_notes, notesIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
