"""
Haneul AI Agent - Obsidian Router
API endpoints for Obsidian vault integration and file management
"""

from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks, Query
from sqlalchemy.orm import Session
from typing import List, Optional, Dict, Any
import json

from app.database import get_db, TaskModel, parse_tags_from_db
from app.models.schemas import (
    ObsidianNote, ObsidianSync, Task, APIResponse
)
from app.services.obsidian_service import ObsidianService
from app.services.ai_service import AIService
from loguru import logger

router = APIRouter()


@router.get("/vault/stats")
async def get_vault_stats(
    obsidian_service: ObsidianService = Depends(ObsidianService)
):
    """
    Obsidian vault 통계 정보를 조회합니다.
    """
    try:
        stats = obsidian_service.get_vault_stats()
        
        return {
            "success": True,
            "message": "Vault 통계 조회 완료",
            "data": stats
        }
        
    except Exception as e:
        logger.error(f"Vault stats retrieval failed: {e}")
        raise HTTPException(status_code=500, detail="Vault 통계 조회 중 오류가 발생했습니다")


@router.get("/vault/scan", response_model=List[ObsidianNote])
async def scan_vault(
    obsidian_service: ObsidianService = Depends(ObsidianService)
):
    """
    Obsidian vault를 스캔하여 모든 작업 관련 노트를 조회합니다.
    """
    try:
        notes = obsidian_service.scan_vault_for_tasks()
        
        logger.info(f"Scanned vault and found {len(notes)} notes")
        return notes
        
    except Exception as e:
        logger.error(f"Vault scanning failed: {e}")
        raise HTTPException(status_code=500, detail="Vault 스캔 중 오류가 발생했습니다")


@router.get("/notes/{file_path:path}", response_model=ObsidianNote)
async def get_note(
    file_path: str,
    obsidian_service: ObsidianService = Depends(ObsidianService)
):
    """
    특정 Obsidian 노트를 조회합니다.
    
    - **file_path**: 노트 파일 경로
    """
    try:
        note = obsidian_service.read_note(file_path)
        
        if not note:
            raise HTTPException(status_code=404, detail="노트를 찾을 수 없습니다")
        
        return note
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Note retrieval failed: {e}")
        raise HTTPException(status_code=500, detail="노트 조회 중 오류가 발생했습니다")


@router.post("/sync/import")
async def import_from_obsidian(
    background_tasks: BackgroundTasks,
    folder_filter: Optional[List[str]] = Query(None, description="스캔할 폴더 목록"),
    create_tasks: bool = Query(True, description="작업 자동 생성 여부"),
    db: Session = Depends(get_db),
    obsidian_service: ObsidianService = Depends(ObsidianService),
    ai_service: AIService = Depends(AIService)
):
    """
    Obsidian vault에서 노트들을 가져와서 작업으로 변환합니다.
    
    - **folder_filter**: 스캔할 특정 폴더들 (선택사항)
    - **create_tasks**: AI 분석을 통해 작업 자동 생성 여부
    """
    try:
        # Vault 스캔
        all_notes = obsidian_service.scan_vault_for_tasks()
        
        # 폴더 필터 적용
        if folder_filter:
            filtered_notes = []
            for note in all_notes:
                for folder in folder_filter:
                    if folder in note.file_path:
                        filtered_notes.append(note)
                        break
            notes_to_process = filtered_notes
        else:
            notes_to_process = all_notes
        
        created_tasks = []
        
        if create_tasks:
            for note in notes_to_process:
                try:
                    # 이미 작업으로 생성된 노트는 건너뛰기
                    if 'task_id' in note.front_matter:
                        continue
                    
                    # AI 우선순위 분석
                    analysis = await ai_service.analyze_priority(
                        content=note.content,
                        context=f"제목: {note.title}, 태그: {', '.join(note.tags)}"
                    )
                    
                    # 데이터베이스에 작업 생성
                    from app.database import TaskModel, calculate_priority_score, format_tags_for_db
                    
                    db_task = TaskModel(
                        title=note.title,
                        content=note.content,
                        urgency=analysis.urgency,
                        importance=analysis.importance,
                        priority_score=calculate_priority_score(analysis.urgency, analysis.importance),
                        tags=format_tags_for_db(note.tags + analysis.suggested_tags),
                        estimated_time=analysis.estimated_time,
                        obsidian_file_path=note.file_path,
                        ai_reasoning=analysis.reasoning,
                        status="inbox"
                    )
                    
                    db.add(db_task)
                    db.commit()
                    db.refresh(db_task)
                    
                    # 백그라운드에서 Obsidian 노트 메타데이터 업데이트
                    background_tasks.add_task(
                        obsidian_service.update_note_metadata,
                        note.file_path,
                        {
                            'task_id': db_task.id,
                            'priority_score': db_task.priority_score,
                            'ai_analyzed': True
                        }
                    )
                    
                    created_tasks.append({
                        'task_id': db_task.id,
                        'title': db_task.title,
                        'priority_score': db_task.priority_score,
                        'file_path': note.file_path
                    })
                    
                except Exception as task_error:
                    logger.warning(f"Failed to create task from note {note.file_path}: {task_error}")
                    continue
        
        return {
            "success": True,
            "message": f"Obsidian 동기화 완료: {len(notes_to_process)}개 노트 스캔, {len(created_tasks)}개 작업 생성",
            "data": {
                "scanned_notes": len(notes_to_process),
                "created_tasks": len(created_tasks),
                "task_details": created_tasks
            }
        }
        
    except Exception as e:
        logger.error(f"Obsidian import failed: {e}")
        db.rollback()
        raise HTTPException(status_code=500, detail="Obsidian 동기화 중 오류가 발생했습니다")


@router.put("/tasks/{task_id}/sync")
async def sync_task_to_obsidian(
    task_id: int,
    db: Session = Depends(get_db),
    obsidian_service: ObsidianService = Depends(ObsidianService)
):
    """
    특정 작업을 Obsidian 노트와 동기화합니다.
    
    - **task_id**: 동기화할 작업 ID
    """
    try:
        # 작업 조회
        task_db = db.query(TaskModel).filter(TaskModel.id == task_id).first()
        if not task_db:
            raise HTTPException(status_code=404, detail="작업을 찾을 수 없습니다")
        
        # 기존 노트가 있는지 확인
        if task_db.obsidian_file_path:
            # 기존 노트 업데이트
            success = obsidian_service.update_note_metadata(
                task_db.obsidian_file_path,
                {
                    'task_id': task_db.id,
                    'priority_score': task_db.priority_score,
                    'urgency': task_db.urgency,
                    'importance': task_db.importance,
                    'status': task_db.status,
                    'updated_at': task_db.updated_at.isoformat()
                }
            )
            
            if success:
                # 상태에 따라 노트 이동
                new_path = obsidian_service.move_note(task_db.obsidian_file_path, task_db.status)
                if new_path:
                    task_db.obsidian_file_path = new_path
                    db.commit()
        else:
            # 새 노트 생성
            file_path = await obsidian_service.create_note_from_task(task_db)
            if file_path:
                task_db.obsidian_file_path = file_path
                db.commit()
        
        return {
            "success": True,
            "message": "작업이 Obsidian과 동기화되었습니다",
            "data": {
                "task_id": task_id,
                "file_path": task_db.obsidian_file_path
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Task sync to Obsidian failed: {e}")
        db.rollback()
        raise HTTPException(status_code=500, detail="Obsidian 동기화 중 오류가 발생했습니다")


@router.post("/tasks/bulk-sync")
async def bulk_sync_tasks_to_obsidian(
    task_ids: List[int],
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db),
    obsidian_service: ObsidianService = Depends(ObsidianService)
):
    """
    여러 작업을 일괄적으로 Obsidian과 동기화합니다.
    
    - **task_ids**: 동기화할 작업 ID 목록
    """
    try:
        # 작업들 조회
        tasks_db = (
            db.query(TaskModel)
            .filter(TaskModel.id.in_(task_ids))
            .all()
        )
        
        if not tasks_db:
            raise HTTPException(status_code=404, detail="선택된 작업들을 찾을 수 없습니다")
        
        # 백그라운드에서 동기화 처리
        sync_results = []
        
        for task_db in tasks_db:
            try:
                if task_db.obsidian_file_path:
                    # 기존 노트 업데이트
                    background_tasks.add_task(
                        obsidian_service.update_note_metadata,
                        task_db.obsidian_file_path,
                        {
                            'task_id': task_db.id,
                            'priority_score': task_db.priority_score,
                            'status': task_db.status
                        }
                    )
                else:
                    # 새 노트 생성
                    background_tasks.add_task(
                        obsidian_service.create_note_from_task,
                        task_db
                    )
                
                sync_results.append({
                    'task_id': task_db.id,
                    'title': task_db.title,
                    'action': 'updated' if task_db.obsidian_file_path else 'created'
                })
                
            except Exception as task_error:
                logger.warning(f"Failed to sync task {task_db.id}: {task_error}")
                continue
        
        return {
            "success": True,
            "message": f"{len(sync_results)}개 작업의 Obsidian 동기화를 시작했습니다",
            "data": {
                "processed_tasks": len(sync_results),
                "sync_details": sync_results
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Bulk sync to Obsidian failed: {e}")
        raise HTTPException(status_code=500, detail="일괄 Obsidian 동기화 중 오류가 발생했습니다")


@router.get("/health")
async def obsidian_health_check(
    obsidian_service: ObsidianService = Depends(ObsidianService)
):
    """
    Obsidian 서비스 상태를 확인합니다.
    """
    try:
        health_status = obsidian_service.health_check()
        vault_stats = obsidian_service.get_vault_stats()
        
        return {
            "success": True,
            "message": "Obsidian 서비스 상태 조회 완료",
            "data": {
                "service_healthy": health_status,
                "vault_stats": vault_stats
            }
        }
        
    except Exception as e:
        logger.error(f"Obsidian health check failed: {e}")
        raise HTTPException(status_code=500, detail="Obsidian 서비스 상태 확인 중 오류가 발생했습니다")


@router.delete("/notes/{file_path:path}")
async def delete_note(
    file_path: str,
    obsidian_service: ObsidianService = Depends(ObsidianService)
):
    """
    Obsidian 노트를 삭제합니다.
    
    - **file_path**: 삭제할 노트 파일 경로
    """
    try:
        import os
        
        if os.path.exists(file_path):
            os.remove(file_path)
            logger.info(f"Deleted Obsidian note: {file_path}")
            
            return {
                "success": True,
                "message": "노트가 성공적으로 삭제되었습니다",
                "file_path": file_path
            }
        else:
            raise HTTPException(status_code=404, detail="노트를 찾을 수 없습니다")
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Note deletion failed: {e}")
        raise HTTPException(status_code=500, detail="노트 삭제 중 오류가 발생했습니다")