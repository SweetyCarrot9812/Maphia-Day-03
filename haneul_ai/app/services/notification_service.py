"""
Haneul AI Agent - Notification Service
Gmail and Google Calendar integration for task notifications
"""

import smtplib
import json
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from typing import List, Dict, Any, Optional
from datetime import datetime, timedelta
from loguru import logger

# Google API imports
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

from app.config.settings import get_settings
from app.config.prompts import EMAIL_NOTIFICATION_TEMPLATE
from app.models.schemas import Task, NotificationContent, NotificationSettings
from app.database import get_db_direct, NotificationLogModel, UserSettingsModel

settings = get_settings()

# Google API scopes
GMAIL_SCOPES = ['https://www.googleapis.com/auth/gmail.send']
CALENDAR_SCOPES = ['https://www.googleapis.com/auth/calendar']


class NotificationService:
    """Service for email and calendar notifications"""
    
    def __init__(self):
        """Initialize notification service"""
        self.gmail_service = None
        self.calendar_service = None
        self.credentials_file = "credentials.json"
        self.token_file = "token.json"
        
        # Initialize Google services
        self._init_google_services()
    
    def _init_google_services(self):
        """Initialize Google API services"""
        try:
            creds = self._get_google_credentials()
            if creds:
                self.gmail_service = build('gmail', 'v1', credentials=creds)
                self.calendar_service = build('calendar', 'v3', credentials=creds)
                logger.info("Google services initialized successfully")
            else:
                logger.warning("Google credentials not available - notifications will be disabled")
                
        except Exception as e:
            logger.error(f"Failed to initialize Google services: {e}")
    
    def _get_google_credentials(self) -> Optional[Credentials]:
        """Get Google API credentials"""
        creds = None
        
        # Load existing token
        try:
            if os.path.exists(self.token_file):
                creds = Credentials.from_authorized_user_file(self.token_file, GMAIL_SCOPES + CALENDAR_SCOPES)
        except Exception as e:
            logger.warning(f"Could not load existing credentials: {e}")
        
        # If there are no (valid) credentials available, let the user log in
        if not creds or not creds.valid:
            if creds and creds.expired and creds.refresh_token:
                try:
                    creds.refresh(Request())
                except Exception as e:
                    logger.error(f"Could not refresh credentials: {e}")
                    creds = None
            
            if not creds:
                try:
                    if os.path.exists(self.credentials_file):
                        flow = InstalledAppFlow.from_client_secrets_file(
                            self.credentials_file, GMAIL_SCOPES + CALENDAR_SCOPES)
                        creds = flow.run_local_server(port=0)
                    else:
                        logger.warning("No credentials.json file found")
                        return None
                except Exception as e:
                    logger.error(f"OAuth flow failed: {e}")
                    return None
            
            # Save the credentials for the next run
            if creds:
                try:
                    with open(self.token_file, 'w') as token:
                        token.write(creds.to_json())
                except Exception as e:
                    logger.warning(f"Could not save credentials: {e}")
        
        return creds
    
    async def send_daily_summary_email(self, user_id: str = "default") -> bool:
        """
        Send daily summary email with top priority tasks
        
        Args:
            user_id: User identifier
            
        Returns:
            Success status
        """
        try:
            if not self.gmail_service:
                logger.error("Gmail service not initialized")
                return False
            
            # Get user settings
            db = get_db_direct()
            user_settings = db.query(UserSettingsModel).filter(
                UserSettingsModel.user_id == user_id
            ).first()
            
            if not user_settings or not user_settings.email_enabled:
                logger.info(f"Email notifications disabled for user {user_id}")
                db.close()
                return True
            
            # Get top priority tasks
            from app.database import TaskModel
            
            top_tasks = (
                db.query(TaskModel)
                .filter(TaskModel.status.in_(["todo", "in_progress"]))
                .filter(TaskModel.priority_score >= user_settings.priority_threshold)
                .order_by(TaskModel.priority_score.desc())
                .limit(3)
                .all()
            )
            
            if not top_tasks:
                logger.info("No high-priority tasks found for notification")
                db.close()
                return True
            
            # Format tasks for email
            task_list = []
            for i, task in enumerate(top_tasks, 1):
                task_info = f"""
{i}. **[{task.priority_score}점] {task.title}**
   - 예상시간: {task.estimated_time or '미정'}
   - 태그: {', '.join(json.loads(task.tags) if task.tags else [])}
   - 생성일: {task.created_at.strftime('%Y-%m-%d')}
"""
                task_list.append(task_info.strip())
            
            # Create email content
            email_body = EMAIL_NOTIFICATION_TEMPLATE.format(
                top_tasks='\n\n'.join(task_list),
                calendar_link=f"http://localhost:8000/api/notifications/add-to-calendar?tasks={'|'.join([str(t.id) for t in top_tasks])}",
                settings_link="http://localhost:8000/api/notifications/settings"
            )
            
            # Send email
            success = await self._send_gmail(
                to_email=user_settings.email_address,
                subject=f"🌟 Haneul AI - 오늘의 우선순위 작업 ({len(top_tasks)}개)",
                body=email_body
            )
            
            # Log notification
            log_entry = NotificationLogModel(
                user_id=user_id,
                notification_type="email",
                subject=f"Daily summary - {len(top_tasks)} tasks",
                task_count=len(top_tasks),
                success=success,
                error_message=None if success else "Email sending failed"
            )
            db.add(log_entry)
            db.commit()
            db.close()
            
            logger.info(f"Daily summary email {'sent' if success else 'failed'} to {user_settings.email_address}")
            return success
            
        except Exception as e:
            logger.error(f"Daily summary email failed: {e}")
            return False
    
    async def _send_gmail(self, to_email: str, subject: str, body: str) -> bool:
        """
        Send email via Gmail API
        
        Args:
            to_email: Recipient email address
            subject: Email subject
            body: Email body (can include HTML)
            
        Returns:
            Success status
        """
        try:
            if not self.gmail_service:
                return False
            
            # Create message
            message = MIMEMultipart('alternative')
            message['To'] = to_email
            message['Subject'] = subject
            
            # Add body (HTML format for better formatting)
            html_body = body.replace('\n', '<br>\n').replace('**', '<strong>').replace('**', '</strong>')
            html_part = MIMEText(html_body, 'html')
            message.attach(html_part)
            
            # Encode message
            raw_message = {'raw': base64.urlsafe_b64encode(message.as_bytes()).decode()}
            
            # Send message
            result = self.gmail_service.users().messages().send(
                userId='me',
                body=raw_message
            ).execute()
            
            logger.info(f"Email sent successfully: {result['id']}")
            return True
            
        except HttpError as error:
            logger.error(f"Gmail API error: {error}")
            return False
        except Exception as e:
            logger.error(f"Email sending failed: {e}")
            return False
    
    async def create_calendar_events(self, tasks: List[Task]) -> List[Dict[str, Any]]:
        """
        Create Google Calendar events for tasks
        
        Args:
            tasks: List of tasks to create events for
            
        Returns:
            List of created event information
        """
        try:
            if not self.calendar_service:
                logger.error("Calendar service not initialized")
                return []
            
            created_events = []
            
            for task in tasks:
                # Calculate event time (next available slot)
                start_time = self._get_next_available_slot()
                
                # Determine duration based on estimated time
                duration = self._parse_duration(task.estimated_time or "1시간")
                end_time = start_time + duration
                
                # Create event
                event = {
                    'summary': f"[우선순위 {task.priority_score}] {task.title}",
                    'description': f"""
우선순위: {task.priority_score}/20 (시급성: {task.urgency}, 중요도: {task.importance})
태그: {', '.join(task.tags)}
예상시간: {task.estimated_time or '미정'}

내용:
{task.content}

AI 분석: {task.ai_reasoning or 'N/A'}
""".strip(),
                    'start': {
                        'dateTime': start_time.isoformat(),
                        'timeZone': 'Asia/Seoul',
                    },
                    'end': {
                        'dateTime': end_time.isoformat(),
                        'timeZone': 'Asia/Seoul',
                    },
                    'reminders': {
                        'useDefault': False,
                        'overrides': [
                            {'method': 'popup', 'minutes': 10},
                        ],
                    },
                }
                
                # Insert event
                created_event = self.calendar_service.events().insert(
                    calendarId='primary',
                    body=event
                ).execute()
                
                created_events.append({
                    'task_id': task.id,
                    'event_id': created_event['id'],
                    'event_link': created_event.get('htmlLink'),
                    'start_time': start_time.isoformat(),
                    'end_time': end_time.isoformat()
                })
                
                logger.info(f"Calendar event created for task: {task.title}")
            
            return created_events
            
        except HttpError as error:
            logger.error(f"Calendar API error: {error}")
            return []
        except Exception as e:
            logger.error(f"Calendar event creation failed: {e}")
            return []
    
    def _get_next_available_slot(self) -> datetime:
        """Get next available time slot for calendar event"""
        now = datetime.now()
        
        # If it's working hours (9 AM - 6 PM), start from next hour
        if 9 <= now.hour < 18:
            start_time = now.replace(minute=0, second=0, microsecond=0) + timedelta(hours=1)
        else:
            # Schedule for next day 9 AM
            tomorrow = now + timedelta(days=1)
            start_time = tomorrow.replace(hour=9, minute=0, second=0, microsecond=0)
        
        return start_time
    
    def _parse_duration(self, time_str: str) -> timedelta:
        """Parse time string to timedelta"""
        try:
            # Simple parsing - can be enhanced
            if "시간" in time_str:
                hours = int(re.search(r'(\d+)시간', time_str).group(1))
                return timedelta(hours=hours)
            elif "분" in time_str:
                minutes = int(re.search(r'(\d+)분', time_str).group(1))
                return timedelta(minutes=minutes)
            elif "일" in time_str:
                days = int(re.search(r'(\d+)일', time_str).group(1))
                return timedelta(days=days)
            else:
                # Default to 1 hour
                return timedelta(hours=1)
        except:
            return timedelta(hours=1)
    
    async def get_notification_settings(self, user_id: str = "default") -> NotificationSettings:
        """Get user notification settings"""
        try:
            db = get_db_direct()
            user_settings = db.query(UserSettingsModel).filter(
                UserSettingsModel.user_id == user_id
            ).first()
            db.close()
            
            if user_settings:
                return NotificationSettings(
                    email_enabled=user_settings.email_enabled,
                    email_address=user_settings.email_address,
                    notification_time=user_settings.notification_time,
                    frequency=user_settings.notification_frequency,
                    priority_threshold=user_settings.priority_threshold,
                    include_calendar=user_settings.include_calendar
                )
            else:
                # Return default settings
                return NotificationSettings(
                    email_enabled=True,
                    email_address=settings.email_address,
                    notification_time=settings.notification_time,
                    frequency="daily",
                    priority_threshold=settings.priority_threshold,
                    include_calendar=True
                )
                
        except Exception as e:
            logger.error(f"Failed to get notification settings: {e}")
            # Return default settings
            return NotificationSettings(
                email_enabled=True,
                email_address=settings.email_address,
                notification_time=settings.notification_time,
                frequency="daily",
                priority_threshold=settings.priority_threshold,
                include_calendar=True
            )
    
    async def update_notification_settings(
        self, 
        settings_data: NotificationSettings, 
        user_id: str = "default"
    ) -> bool:
        """Update user notification settings"""
        try:
            db = get_db_direct()
            user_settings = db.query(UserSettingsModel).filter(
                UserSettingsModel.user_id == user_id
            ).first()
            
            if user_settings:
                # Update existing settings
                user_settings.email_enabled = settings_data.email_enabled
                user_settings.email_address = settings_data.email_address
                user_settings.notification_time = settings_data.notification_time
                user_settings.notification_frequency = settings_data.frequency
                user_settings.priority_threshold = settings_data.priority_threshold
                user_settings.include_calendar = settings_data.include_calendar
            else:
                # Create new settings
                user_settings = UserSettingsModel(
                    user_id=user_id,
                    email_enabled=settings_data.email_enabled,
                    email_address=settings_data.email_address,
                    notification_time=settings_data.notification_time,
                    notification_frequency=settings_data.frequency,
                    priority_threshold=settings_data.priority_threshold,
                    include_calendar=settings_data.include_calendar,
                    obsidian_vault_path=settings.obsidian_vault_path
                )
                db.add(user_settings)
            
            db.commit()
            db.close()
            
            logger.info(f"Notification settings updated for user {user_id}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to update notification settings: {e}")
            return False
    
    def health_check(self) -> Dict[str, bool]:
        """Check notification service health"""
        return {
            "gmail_service": self.gmail_service is not None,
            "calendar_service": self.calendar_service is not None,
            "credentials_available": os.path.exists(self.token_file) or os.path.exists(self.credentials_file)
        }


# Import required modules for email encoding
import base64
import os
import re