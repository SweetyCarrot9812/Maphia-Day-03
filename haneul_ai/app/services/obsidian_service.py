"""
Haneul AI Agent - Obsidian Service
File management and synchronization with Obsidian vault
"""

import os
import json
import yaml
from datetime import datetime
from typing import Dict, List, Optional, Any
from pathlib import Path
import re
from loguru import logger

from app.config.settings import get_settings
from app.config.prompts import OBSIDIAN_NOTE_TEMPLATE
from app.models.schemas import ObsidianNote, Task

settings = get_settings()


class ObsidianService:
    """Service for Obsidian vault integration"""
    
    def __init__(self):
        """Initialize Obsidian service"""
        self.vault_path = Path(settings.obsidian_vault_path)
        self.inbox_folder = settings.obsidian_inbox_folder
        self.todo_folder = settings.obsidian_todo_folder
        self.completed_folder = settings.obsidian_completed_folder
        
        # Create folders if they don't exist
        self._ensure_folders_exist()
    
    def _ensure_folders_exist(self):
        """Ensure required Obsidian folders exist"""
        try:
            folders = [
                self.vault_path / self.inbox_folder,
                self.vault_path / self.todo_folder,
                self.vault_path / self.completed_folder
            ]
            
            for folder in folders:
                folder.mkdir(parents=True, exist_ok=True)
                
            logger.info("Obsidian folders initialized")
            
        except Exception as e:
            logger.error(f"Failed to create Obsidian folders: {e}")
    
    def _sanitize_filename(self, title: str) -> str:
        """Sanitize title for filename"""
        # Remove invalid characters for filenames
        sanitized = re.sub(r'[<>:"/\\|?*]', '', title)
        # Limit length
        sanitized = sanitized[:100] if len(sanitized) > 100 else sanitized
        # Remove extra spaces
        sanitized = ' '.join(sanitized.split())
        return sanitized.strip() or "Untitled"
    
    def _parse_front_matter(self, content: str) -> tuple[Dict[str, Any], str]:
        """Parse YAML front matter from markdown content"""
        if not content.startswith('---\n'):
            return {}, content
        
        try:
            # Find end of front matter
            end_match = re.search(r'\n---\n', content[4:])
            if not end_match:
                return {}, content
            
            front_matter_end = end_match.start() + 4
            front_matter_text = content[4:front_matter_end]
            body = content[front_matter_end + 5:]  # +5 for '\n---\n'
            
            front_matter = yaml.safe_load(front_matter_text)
            return front_matter or {}, body
            
        except Exception as e:
            logger.warning(f"Failed to parse front matter: {e}")
            return {}, content
    
    def _create_front_matter(self, metadata: Dict[str, Any]) -> str:
        """Create YAML front matter from metadata"""
        if not metadata:
            return ""
        
        try:
            yaml_content = yaml.dump(metadata, default_flow_style=False, allow_unicode=True)
            return f"---\n{yaml_content}---\n\n"
        except Exception as e:
            logger.warning(f"Failed to create front matter: {e}")
            return ""
    
    async def create_note_from_task(self, task) -> Optional[str]:
        """
        Create Obsidian note from task
        
        Args:
            task: Task database model or Task schema
            
        Returns:
            Path to created file or None if failed
        """
        try:
            # Extract task data
            if hasattr(task, 'id'):  # Database model
                task_data = {
                    'id': task.id,
                    'title': task.title,
                    'content': task.content,
                    'urgency': task.urgency,
                    'importance': task.importance,
                    'priority_score': task.priority_score,
                    'status': task.status,
                    'tags': json.loads(task.tags) if task.tags else [],
                    'estimated_time': task.estimated_time,
                    'ai_reasoning': task.ai_reasoning,
                    'created_at': task.created_at,
                    'updated_at': task.updated_at
                }
            else:  # Pydantic model
                task_data = task.dict()
            
            # Determine target folder based on status
            if task_data['status'] in ['completed', 'archived']:
                target_folder = self.vault_path / self.completed_folder
            elif task_data['status'] in ['todo', 'in_progress']:
                target_folder = self.vault_path / self.todo_folder
            else:
                target_folder = self.vault_path / self.inbox_folder
            
            # Create filename
            sanitized_title = self._sanitize_filename(task_data['title'])
            timestamp = datetime.now().strftime("%Y%m%d_%H%M")
            filename = f"{timestamp}_{sanitized_title}.md"
            file_path = target_folder / filename
            
            # Prepare metadata
            metadata = {
                'task_id': task_data['id'],
                'priority_score': task_data['priority_score'],
                'urgency': task_data['urgency'],
                'importance': task_data['importance'],
                'status': task_data['status'],
                'tags': task_data['tags'],
                'estimated_time': task_data['estimated_time'],
                'created_at': task_data['created_at'].isoformat() if task_data.get('created_at') else datetime.now().isoformat(),
                'ai_generated': True
            }
            
            # Create note content using template
            note_content = OBSIDIAN_NOTE_TEMPLATE.format(
                title=task_data['title'],
                created_date=datetime.now().strftime("%Y-%m-%d %H:%M"),
                priority_score=task_data['priority_score'],
                urgency=task_data['urgency'],
                importance=task_data['importance'],
                tags=' '.join([f'#{tag}' for tag in task_data['tags']]),
                estimated_time=task_data['estimated_time'] or '미정',
                content=task_data['content'],
                ai_reasoning=task_data.get('ai_reasoning') or 'AI 분석 없음',
                next_action=f"작업 시작하기: {task_data['title']}"
            )
            
            # Add front matter
            full_content = self._create_front_matter(metadata) + note_content
            
            # Write file
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(full_content)
            
            logger.info(f"Created Obsidian note: {filename}")
            return str(file_path)
            
        except Exception as e:
            logger.error(f"Failed to create Obsidian note: {e}")
            return None
    
    def read_note(self, file_path: str) -> Optional[ObsidianNote]:
        """
        Read Obsidian note from file
        
        Args:
            file_path: Path to the note file
            
        Returns:
            ObsidianNote object or None if failed
        """
        try:
            path = Path(file_path)
            if not path.exists():
                return None
            
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Parse front matter
            front_matter, body = self._parse_front_matter(content)
            
            # Extract title from filename or content
            title = path.stem
            if body.startswith('# '):
                first_line = body.split('\n')[0]
                title = first_line[2:].strip()
            
            # Extract tags from content and front matter
            tags = []
            if 'tags' in front_matter:
                if isinstance(front_matter['tags'], list):
                    tags.extend(front_matter['tags'])
                else:
                    tags.append(str(front_matter['tags']))
            
            # Find hashtags in content
            hashtag_matches = re.findall(r'#(\w+)', body)
            tags.extend(hashtag_matches)
            
            # Remove duplicates
            tags = list(set(tags))
            
            return ObsidianNote(
                title=title,
                content=body,
                file_path=str(path),
                created_date=datetime.fromtimestamp(path.stat().st_ctime),
                modified_date=datetime.fromtimestamp(path.stat().st_mtime),
                tags=tags,
                front_matter=front_matter
            )
            
        except Exception as e:
            logger.error(f"Failed to read note {file_path}: {e}")
            return None
    
    def scan_vault_for_tasks(self) -> List[ObsidianNote]:
        """
        Scan Obsidian vault for task-related notes
        
        Returns:
            List of ObsidianNote objects
        """
        try:
            notes = []
            
            # Scan relevant folders
            folders_to_scan = [
                self.vault_path / self.inbox_folder,
                self.vault_path / self.todo_folder,
                self.vault_path / self.completed_folder
            ]
            
            for folder in folders_to_scan:
                if not folder.exists():
                    continue
                
                for md_file in folder.glob('*.md'):
                    note = self.read_note(str(md_file))
                    if note:
                        notes.append(note)
            
            logger.info(f"Scanned vault and found {len(notes)} notes")
            return notes
            
        except Exception as e:
            logger.error(f"Failed to scan vault: {e}")
            return []
    
    def move_note(self, current_path: str, new_status: str) -> Optional[str]:
        """
        Move note to appropriate folder based on status
        
        Args:
            current_path: Current file path
            new_status: New task status
            
        Returns:
            New file path or None if failed
        """
        try:
            current = Path(current_path)
            if not current.exists():
                return None
            
            # Determine target folder
            if new_status in ['completed', 'archived']:
                target_folder = self.vault_path / self.completed_folder
            elif new_status in ['todo', 'in_progress']:
                target_folder = self.vault_path / self.todo_folder
            else:
                target_folder = self.vault_path / self.inbox_folder
            
            # Create new path
            new_path = target_folder / current.name
            
            # Move file
            current.rename(new_path)
            
            logger.info(f"Moved note from {current_path} to {new_path}")
            return str(new_path)
            
        except Exception as e:
            logger.error(f"Failed to move note: {e}")
            return None
    
    def update_note_metadata(self, file_path: str, metadata: Dict[str, Any]) -> bool:
        """
        Update note metadata (front matter)
        
        Args:
            file_path: Path to the note file
            metadata: Metadata to update
            
        Returns:
            Success status
        """
        try:
            path = Path(file_path)
            if not path.exists():
                return False
            
            # Read current content
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Parse existing front matter
            current_front_matter, body = self._parse_front_matter(content)
            
            # Update metadata
            current_front_matter.update(metadata)
            current_front_matter['updated_at'] = datetime.now().isoformat()
            
            # Write back
            new_content = self._create_front_matter(current_front_matter) + body
            
            with open(path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            
            logger.info(f"Updated note metadata: {file_path}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to update note metadata: {e}")
            return False
    
    def get_vault_stats(self) -> Dict[str, Any]:
        """Get Obsidian vault statistics"""
        try:
            stats = {
                'vault_path': str(self.vault_path),
                'vault_exists': self.vault_path.exists(),
                'folders': {
                    'inbox': len(list((self.vault_path / self.inbox_folder).glob('*.md'))) if (self.vault_path / self.inbox_folder).exists() else 0,
                    'todo': len(list((self.vault_path / self.todo_folder).glob('*.md'))) if (self.vault_path / self.todo_folder).exists() else 0,
                    'completed': len(list((self.vault_path / self.completed_folder).glob('*.md'))) if (self.vault_path / self.completed_folder).exists() else 0
                },
                'total_notes': 0
            }
            
            stats['total_notes'] = sum(stats['folders'].values())
            
            return stats
            
        except Exception as e:
            logger.error(f"Failed to get vault stats: {e}")
            return {
                'vault_path': str(self.vault_path),
                'vault_exists': False,
                'error': str(e)
            }
    
    def health_check(self) -> bool:
        """Check if Obsidian service is healthy"""
        try:
            # Check if vault path exists and is accessible
            if not self.vault_path.exists():
                return False
            
            # Try to create a test file
            test_file = self.vault_path / '.haneul_health_check'
            test_file.write_text('test')
            test_file.unlink()
            
            return True
            
        except Exception as e:
            logger.error(f"Obsidian service health check failed: {e}")
            return False