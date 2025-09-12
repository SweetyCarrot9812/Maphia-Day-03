"""
Haneul AI Agent - Notifications Router
API endpoints for email and calendar notification management
"""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
import json
from datetime import datetime

from app.database import get_db, TaskModel
from app.models.schemas import (
    Task, NotificationSettings, NotificationContent, 
    APIResponse
)
from app.services.notification_service import NotificationService
from loguru import logger

router = APIRouter()


@router.post("/send-daily-summary")
async def send_daily_summary(
    user_id: str = "default",
    notification_service: NotificationService = Depends(NotificationService)
):
    """
    일일 요약 이메일을 즉시 발송합니다.
    
    - **user_id**: 사용자 ID (기본값: default)
    """
    try:
        success = await notification_service.send_daily_summary_email(user_id)
        
        if success:
            return {
                "success": True,
                "message": "일일 요약 이메일이 성공적으로 발송되었습니다"
            }
        else:
            raise HTTPException(status_code=500, detail="이메일 발송 중 오류가 발생했습니다")
            
    except Exception as e:
        logger.error(f"Daily summary sending failed: {e}")
        raise HTTPException(status_code=500, detail="일일 요약 발송 중 오류가 발생했습니다")


@router.post("/add-to-calendar")
async def add_tasks_to_calendar(
    task_ids: List[int],
    db: Session = Depends(get_db),
    notification_service: NotificationService = Depends(NotificationService)
):
    """
    선택된 작업들을 Google Calendar에 일정으로 추가합니다.
    
    - **task_ids**: 캘린더에 추가할 작업 ID 목록
    """
    try:
        # 작업 조회
        tasks_db = (
            db.query(TaskModel)
            .filter(TaskModel.id.in_(task_ids))
            .all()
        )
        
        if not tasks_db:
            raise HTTPException(status_code=404, detail="선택된 작업을 찾을 수 없습니다")
        
        # Task 객체로 변환
        tasks = []
        for task_db in tasks_db:
            task = Task(
                id=task_db.id,
                title=task_db.title,
                content=task_db.content,
                urgency=task_db.urgency,
                importance=task_db.importance,
                priority_score=task_db.priority_score,
                status=task_db.status,
                tags=json.loads(task_db.tags) if task_db.tags else [],
                estimated_time=task_db.estimated_time,
                obsidian_file_path=task_db.obsidian_file_path,
                ai_reasoning=task_db.ai_reasoning,
                created_at=task_db.created_at,
                updated_at=task_db.updated_at
            )
            tasks.append(task)
        
        # 캘린더 이벤트 생성
        created_events = await notification_service.create_calendar_events(tasks)
        
        if created_events:
            return {
                "success": True,
                "message": f"{len(created_events)}개의 일정이 캘린더에 추가되었습니다",
                "data": {
                    "created_events": created_events,
                    "tasks_processed": len(tasks)
                }
            }
        else:
            raise HTTPException(status_code=500, detail="캘린더 일정 생성 중 오류가 발생했습니다")
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Calendar event creation failed: {e}")
        raise HTTPException(status_code=500, detail="캘린더 일정 추가 중 오류가 발생했습니다")


@router.get("/add-to-calendar")
async def add_tasks_to_calendar_get(
    tasks: str = Query(..., description="파이프(|)로 구분된 작업 ID 목록"),
    db: Session = Depends(get_db),
    notification_service: NotificationService = Depends(NotificationService)
):
    """
    GET 방식으로 작업들을 캘린더에 추가합니다. (이메일 링크용)
    
    - **tasks**: 파이프(|)로 구분된 작업 ID 문자열 (예: "1|2|3")
    """
    try:
        # 작업 ID 파싱
        task_ids = [int(task_id.strip()) for task_id in tasks.split('|') if task_id.strip()]
        
        if not task_ids:
            raise HTTPException(status_code=400, detail="유효한 작업 ID가 없습니다")
        
        # POST 메서드 재사용
        return await add_tasks_to_calendar(task_ids, db, notification_service)
        
    except ValueError:
        raise HTTPException(status_code=400, detail="잘못된 작업 ID 형식입니다")
    except Exception as e:
        logger.error(f"GET calendar event creation failed: {e}")
        raise HTTPException(status_code=500, detail="캘린더 일정 추가 중 오류가 발생했습니다")


@router.get("/settings", response_model=NotificationSettings)
async def get_notification_settings(
    user_id: str = "default",
    notification_service: NotificationService = Depends(NotificationService)
):
    """
    사용자의 알림 설정을 조회합니다.
    
    - **user_id**: 사용자 ID (기본값: default)
    """
    try:
        settings = await notification_service.get_notification_settings(user_id)
        return settings
        
    except Exception as e:
        logger.error(f"Get notification settings failed: {e}")
        raise HTTPException(status_code=500, detail="알림 설정 조회 중 오류가 발생했습니다")


@router.put("/settings")
async def update_notification_settings(
    settings_data: NotificationSettings,
    user_id: str = "default",
    notification_service: NotificationService = Depends(NotificationService)
):
    """
    사용자의 알림 설정을 업데이트합니다.
    
    - **settings_data**: 새로운 알림 설정
    - **user_id**: 사용자 ID (기본값: default)
    """
    try:
        success = await notification_service.update_notification_settings(settings_data, user_id)
        
        if success:
            return {
                "success": True,
                "message": "알림 설정이 성공적으로 업데이트되었습니다",
                "data": settings_data.dict()
            }
        else:
            raise HTTPException(status_code=500, detail="알림 설정 업데이트 중 오류가 발생했습니다")
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Update notification settings failed: {e}")
        raise HTTPException(status_code=500, detail="알림 설정 업데이트 중 오류가 발생했습니다")


@router.get("/test-email")
async def test_email_notification(
    email: Optional[str] = Query(None, description="테스트 이메일 주소 (기본값: 설정된 이메일)"),
    user_id: str = "default",
    notification_service: NotificationService = Depends(NotificationService)
):
    """
    테스트 이메일을 발송합니다.
    
    - **email**: 테스트할 이메일 주소 (선택사항)
    - **user_id**: 사용자 ID (기본값: default)
    """
    try:
        # 임시로 설정을 변경하여 테스트 이메일 발송
        if email:
            # 임시 설정으로 테스트
            from app.database import get_db_direct, UserSettingsModel
            db = get_db_direct()
            
            # 기존 설정 백업
            user_settings = db.query(UserSettingsModel).filter(
                UserSettingsModel.user_id == user_id
            ).first()
            
            original_email = user_settings.email_address if user_settings else None
            
            # 임시로 이메일 변경
            if user_settings:
                user_settings.email_address = email
                db.commit()
            
            # 테스트 이메일 발송
            success = await notification_service.send_daily_summary_email(user_id)
            
            # 원래 설정 복원
            if user_settings and original_email:
                user_settings.email_address = original_email
                db.commit()
            
            db.close()
        else:
            success = await notification_service.send_daily_summary_email(user_id)
        
        if success:
            return {
                "success": True,
                "message": f"테스트 이메일이 {'지정된 주소' if email else '설정된 주소'}로 발송되었습니다",
                "email": email or "설정된 이메일 주소"
            }
        else:
            raise HTTPException(status_code=500, detail="테스트 이메일 발송에 실패했습니다")
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Test email failed: {e}")
        raise HTTPException(status_code=500, detail="테스트 이메일 발송 중 오류가 발생했습니다")


@router.get("/history")
async def get_notification_history(
    user_id: str = "default",
    limit: int = Query(20, ge=1, le=100),
    notification_type: Optional[str] = Query(None, description="알림 타입 필터 (email, calendar)"),
    db: Session = Depends(get_db)
):
    """
    알림 전송 기록을 조회합니다.
    
    - **user_id**: 사용자 ID
    - **limit**: 조회할 기록 수 (최대 100)
    - **notification_type**: 알림 타입 필터
    """
    try:
        from app.database import NotificationLogModel
        
        query = db.query(NotificationLogModel).filter(
            NotificationLogModel.user_id == user_id
        )
        
        if notification_type:
            query = query.filter(NotificationLogModel.notification_type == notification_type)
        
        logs = (
            query
            .order_by(NotificationLogModel.sent_at.desc())
            .limit(limit)
            .all()
        )
        
        history = []
        for log in logs:
            history.append({
                "id": log.id,
                "notification_type": log.notification_type,
                "subject": log.subject,
                "task_count": log.task_count,
                "sent_at": log.sent_at.isoformat(),
                "success": log.success,
                "error_message": log.error_message
            })
        
        return {
            "success": True,
            "message": f"{len(history)}개의 알림 기록을 조회했습니다",
            "data": history
        }
        
    except Exception as e:
        logger.error(f"Get notification history failed: {e}")
        raise HTTPException(status_code=500, detail="알림 기록 조회 중 오류가 발생했습니다")


@router.get("/health")
async def notification_health_check(
    notification_service: NotificationService = Depends(NotificationService)
):
    """
    알림 서비스 상태를 확인합니다.
    """
    try:
        health_status = notification_service.health_check()
        
        overall_health = all(health_status.values())
        
        return {
            "success": True,
            "message": "알림 서비스 상태 조회 완료",
            "data": {
                "overall_health": overall_health,
                "services": health_status
            }
        }
        
    except Exception as e:
        logger.error(f"Notification health check failed: {e}")
        raise HTTPException(status_code=500, detail="알림 서비스 상태 확인 중 오류가 발생했습니다")