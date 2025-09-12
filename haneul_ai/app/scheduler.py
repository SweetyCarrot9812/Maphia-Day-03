"""
Haneul AI Agent - Task Scheduler
Automated scheduling for daily notifications and background tasks
"""

import schedule
import time
import threading
from datetime import datetime, timedelta
from typing import Optional
import asyncio
from loguru import logger

from app.config.settings import get_settings
from app.services.notification_service import NotificationService
from app.database import get_db_direct, UserSettingsModel

settings = get_settings()


class TaskScheduler:
    """Background task scheduler for automated notifications"""
    
    def __init__(self):
        """Initialize task scheduler"""
        self.running = False
        self.scheduler_thread: Optional[threading.Thread] = None
        self.notification_service = NotificationService()
        
        # Setup scheduled tasks
        self._setup_scheduled_tasks()
    
    def _setup_scheduled_tasks(self):
        """Setup all scheduled tasks"""
        try:
            # Get user notification settings
            db = get_db_direct()
            user_settings = db.query(UserSettingsModel).filter(
                UserSettingsModel.user_id == "default"
            ).first()
            db.close()
            
            if user_settings and user_settings.email_enabled:
                notification_time = user_settings.notification_time
                frequency = user_settings.notification_frequency
                
                # Schedule based on frequency
                if frequency == "daily":
                    schedule.every().day.at(notification_time).do(self._send_daily_notification)
                    logger.info(f"Daily notification scheduled at {notification_time}")
                    
                elif frequency == "twice":
                    # Morning and evening notifications
                    morning_time = notification_time
                    evening_hour = int(notification_time.split(':')[0]) + 8
                    evening_time = f"{evening_hour:02d}:{notification_time.split(':')[1]}"
                    
                    schedule.every().day.at(morning_time).do(self._send_daily_notification)
                    schedule.every().day.at(evening_time).do(self._send_daily_notification)
                    logger.info(f"Twice daily notifications scheduled at {morning_time} and {evening_time}")
                    
                elif frequency == "weekly":
                    # Weekly on Monday
                    schedule.every().monday.at(notification_time).do(self._send_daily_notification)
                    logger.info(f"Weekly notification scheduled on Monday at {notification_time}")
            else:
                logger.info("Email notifications are disabled")
            
            # Schedule other background tasks
            schedule.every().hour.do(self._cleanup_old_logs)
            schedule.every().day.at("02:00").do(self._database_maintenance)
            
            logger.info("All scheduled tasks configured successfully")
            
        except Exception as e:
            logger.error(f"Failed to setup scheduled tasks: {e}")
    
    def _send_daily_notification(self):
        """Send daily summary notification"""
        try:
            logger.info("Executing scheduled daily notification")
            
            # Run async function in sync context
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            
            result = loop.run_until_complete(
                self.notification_service.send_daily_summary_email("default")
            )
            
            loop.close()
            
            if result:
                logger.info("Scheduled daily notification sent successfully")
            else:
                logger.error("Scheduled daily notification failed")
                
        except Exception as e:
            logger.error(f"Scheduled notification error: {e}")
    
    def _cleanup_old_logs(self):
        """Clean up old notification logs"""
        try:
            logger.info("Executing scheduled log cleanup")
            
            db = get_db_direct()
            
            # Delete logs older than 30 days
            cutoff_date = datetime.now() - timedelta(days=30)
            
            from app.database import NotificationLogModel, ActivityLogModel
            
            # Clean notification logs
            old_notification_logs = db.query(NotificationLogModel).filter(
                NotificationLogModel.sent_at < cutoff_date
            ).count()
            
            if old_notification_logs > 0:
                db.query(NotificationLogModel).filter(
                    NotificationLogModel.sent_at < cutoff_date
                ).delete()
                
                logger.info(f"Cleaned up {old_notification_logs} old notification logs")
            
            # Clean activity logs
            old_activity_logs = db.query(ActivityLogModel).filter(
                ActivityLogModel.timestamp < cutoff_date
            ).count()
            
            if old_activity_logs > 0:
                db.query(ActivityLogModel).filter(
                    ActivityLogModel.timestamp < cutoff_date
                ).delete()
                
                logger.info(f"Cleaned up {old_activity_logs} old activity logs")
            
            db.commit()
            db.close()
            
            logger.info("Log cleanup completed")
            
        except Exception as e:
            logger.error(f"Log cleanup error: {e}")
    
    def _database_maintenance(self):
        """Perform database maintenance tasks"""
        try:
            logger.info("Executing scheduled database maintenance")
            
            db = get_db_direct()
            
            # SQLite VACUUM for better performance
            if "sqlite" in settings.database_url:
                db.execute("VACUUM")
                logger.info("SQLite VACUUM completed")
            
            # Update statistics
            from app.database import TaskModel
            
            total_tasks = db.query(TaskModel).count()
            completed_tasks = db.query(TaskModel).filter(
                TaskModel.status == "completed"
            ).count()
            
            logger.info(f"Database stats - Total tasks: {total_tasks}, Completed: {completed_tasks}")
            
            db.close()
            logger.info("Database maintenance completed")
            
        except Exception as e:
            logger.error(f"Database maintenance error: {e}")
    
    def start(self):
        """Start the background scheduler"""
        if self.running:
            logger.warning("Scheduler is already running")
            return
        
        self.running = True
        self.scheduler_thread = threading.Thread(target=self._run_scheduler, daemon=True)
        self.scheduler_thread.start()
        
        logger.info("Task scheduler started successfully")
    
    def stop(self):
        """Stop the background scheduler"""
        if not self.running:
            logger.warning("Scheduler is not running")
            return
        
        self.running = False
        
        if self.scheduler_thread and self.scheduler_thread.is_alive():
            self.scheduler_thread.join(timeout=5)
        
        # Clear all scheduled jobs
        schedule.clear()
        
        logger.info("Task scheduler stopped successfully")
    
    def _run_scheduler(self):
        """Run the scheduler in background thread"""
        logger.info("Scheduler thread started")
        
        while self.running:
            try:
                schedule.run_pending()
                time.sleep(60)  # Check every minute
                
            except Exception as e:
                logger.error(f"Scheduler thread error: {e}")
                time.sleep(60)  # Continue running even if there's an error
        
        logger.info("Scheduler thread stopped")
    
    def get_scheduled_jobs(self) -> list:
        """Get list of currently scheduled jobs"""
        jobs = []
        
        for job in schedule.jobs:
            jobs.append({
                'job_func': job.job_func.__name__ if hasattr(job.job_func, '__name__') else str(job.job_func),
                'next_run': job.next_run.isoformat() if job.next_run else None,
                'interval': str(job.interval),
                'unit': job.unit,
                'start_day': job.start_day
            })
        
        return jobs
    
    def reschedule_notifications(self):
        """Reschedule notifications based on updated settings"""
        try:
            # Clear existing notification schedules
            schedule.clear()
            
            # Reload settings and reschedule
            self._setup_scheduled_tasks()
            
            logger.info("Notifications rescheduled successfully")
            
        except Exception as e:
            logger.error(f"Failed to reschedule notifications: {e}")
    
    def trigger_immediate_notification(self, user_id: str = "default"):
        """Trigger immediate notification (for testing)"""
        try:
            logger.info(f"Triggering immediate notification for user {user_id}")
            
            # Run in background thread to avoid blocking
            thread = threading.Thread(
                target=self._send_immediate_notification,
                args=(user_id,),
                daemon=True
            )
            thread.start()
            
        except Exception as e:
            logger.error(f"Failed to trigger immediate notification: {e}")
    
    def _send_immediate_notification(self, user_id: str):
        """Send immediate notification in background"""
        try:
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            
            result = loop.run_until_complete(
                self.notification_service.send_daily_summary_email(user_id)
            )
            
            loop.close()
            
            logger.info(f"Immediate notification {'sent' if result else 'failed'} for user {user_id}")
            
        except Exception as e:
            logger.error(f"Immediate notification error: {e}")


# Global scheduler instance
_scheduler_instance: Optional[TaskScheduler] = None


def get_scheduler() -> TaskScheduler:
    """Get global scheduler instance"""
    global _scheduler_instance
    
    if _scheduler_instance is None:
        _scheduler_instance = TaskScheduler()
    
    return _scheduler_instance


def start_scheduler():
    """Start the global scheduler"""
    scheduler = get_scheduler()
    scheduler.start()


def stop_scheduler():
    """Stop the global scheduler"""
    global _scheduler_instance
    
    if _scheduler_instance:
        _scheduler_instance.stop()
        _scheduler_instance = None


# Scheduler API endpoints helper functions
async def get_scheduler_status():
    """Get scheduler status for API"""
    scheduler = get_scheduler()
    
    return {
        "running": scheduler.running,
        "scheduled_jobs": scheduler.get_scheduled_jobs(),
        "thread_alive": scheduler.scheduler_thread.is_alive() if scheduler.scheduler_thread else False
    }


async def reschedule_notifications():
    """Reschedule notifications for API"""
    scheduler = get_scheduler()
    scheduler.reschedule_notifications()
    
    return {
        "success": True,
        "message": "알림이 재설정되었습니다",
        "scheduled_jobs": scheduler.get_scheduled_jobs()
    }