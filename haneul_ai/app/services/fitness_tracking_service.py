"""
Fitness Tracking Service for Haneul AI Agent
Comprehensive workout logging, progress analysis, and performance tracking
"""

import json
import sqlite3
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass, asdict
from loguru import logger


@dataclass
class WorkoutSession:
    """운동 세션 데이터 클래스"""
    id: Optional[int] = None
    user_id: str = "default"
    date: str = ""
    session_type: str = "strength"  # strength, cardio, flexibility, sports
    duration_minutes: int = 0
    total_volume: float = 0.0  # 총 운동량 (kg)
    calories_burned: int = 0
    exercises: List[Dict[str, Any]] = None
    notes: str = ""
    rating: int = 5  # 1-10 운동 만족도
    created_at: str = ""
    
    def __post_init__(self):
        if self.exercises is None:
            self.exercises = []
        if not self.date:
            self.date = datetime.now().strftime("%Y-%m-%d")
        if not self.created_at:
            self.created_at = datetime.now().isoformat()


@dataclass 
class Exercise:
    """개별 운동 데이터 클래스"""
    name: str
    category: str  # compound, isolation, cardio, flexibility
    sets: List[Dict[str, Any]]  # [{"reps": 10, "weight": 50, "rest": 60}]
    target_muscles: List[str] = None
    notes: str = ""
    
    def __post_init__(self):
        if self.target_muscles is None:
            self.target_muscles = []


@dataclass
class ProgressMetrics:
    """진행 상황 지표"""
    period: str  # week, month, quarter, year
    total_sessions: int = 0
    total_volume: float = 0.0
    avg_session_duration: float = 0.0
    consistency_rate: float = 0.0
    strength_gains: Dict[str, float] = None
    body_measurements: Dict[str, float] = None
    
    def __post_init__(self):
        if self.strength_gains is None:
            self.strength_gains = {}
        if self.body_measurements is None:
            self.body_measurements = {}


class FitnessTrackingService:
    """헬스 운동 기록 및 분석 서비스"""
    
    def __init__(self, db_path: str = "fitness_tracking.db"):
        self.db_path = db_path
        self.init_database()
        
        # 운동별 칼로리 계산 기준 (분당 칼로리, 평균 체중 70kg 기준)
        self.calorie_rates = {
            "strength_training": 6.0,
            "cardio": 10.0,
            "hiit": 12.0,
            "yoga": 3.0,
            "pilates": 4.0,
            "running": 11.0,
            "cycling": 8.0,
            "swimming": 11.0
        }
        
        # 근육 그룹 매핑
        self.muscle_groups = {
            "chest": ["벤치프레스", "푸시업", "딥스", "인클라인프레스"],
            "back": ["풀업", "랫풀다운", "로우", "데드리프트"],
            "legs": ["스쿼트", "레그프레스", "런지", "레그컬"],
            "shoulders": ["오버헤드프레스", "레터럴레이즈", "리어델트"],
            "arms": ["바이셉컬", "트라이셉스익스텐션", "해머컬"]
        }

    def init_database(self):
        """데이터베이스 초기화"""
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                
                # 운동 세션 테이블
                cursor.execute("""
                    CREATE TABLE IF NOT EXISTS workout_sessions (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        user_id TEXT NOT NULL,
                        date TEXT NOT NULL,
                        session_type TEXT NOT NULL,
                        duration_minutes INTEGER,
                        total_volume REAL,
                        calories_burned INTEGER,
                        exercises TEXT,  -- JSON 문자열
                        notes TEXT,
                        rating INTEGER DEFAULT 5,
                        created_at TEXT,
                        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
                    )
                """)
                
                # 개별 운동 기록 테이블 (상세 분석용)
                cursor.execute("""
                    CREATE TABLE IF NOT EXISTS exercise_records (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        session_id INTEGER,
                        exercise_name TEXT NOT NULL,
                        category TEXT,
                        sets_data TEXT,  -- JSON 문자열
                        target_muscles TEXT,  -- JSON 문자열
                        max_weight REAL,
                        total_reps INTEGER,
                        notes TEXT,
                        FOREIGN KEY (session_id) REFERENCES workout_sessions (id)
                    )
                """)
                
                # 신체 측정 기록 테이블
                cursor.execute("""
                    CREATE TABLE IF NOT EXISTS body_measurements (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        user_id TEXT NOT NULL,
                        date TEXT NOT NULL,
                        weight REAL,
                        body_fat_percentage REAL,
                        muscle_mass REAL,
                        chest REAL,
                        waist REAL,
                        hip REAL,
                        arm REAL,
                        thigh REAL,
                        notes TEXT,
                        created_at TEXT DEFAULT CURRENT_TIMESTAMP
                    )
                """)
                
                # 1RM 기록 테이블
                cursor.execute("""
                    CREATE TABLE IF NOT EXISTS one_rep_max (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        user_id TEXT NOT NULL,
                        exercise_name TEXT NOT NULL,
                        weight REAL NOT NULL,
                        date TEXT NOT NULL,
                        estimated BOOLEAN DEFAULT FALSE,
                        notes TEXT,
                        created_at TEXT DEFAULT CURRENT_TIMESTAMP
                    )
                """)
                
                conn.commit()
                logger.info("Fitness tracking database initialized successfully")
                
        except Exception as e:
            logger.error(f"Database initialization failed: {e}")
            raise

    def log_workout_session(self, session: WorkoutSession) -> int:
        """운동 세션 기록"""
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                
                # 칼로리 계산 (미입력 시)
                if session.calories_burned == 0:
                    session.calories_burned = self._calculate_calories(
                        session.session_type, session.duration_minutes
                    )
                
                # 총 볼륨 계산 (미입력 시)
                if session.total_volume == 0.0 and session.exercises:
                    session.total_volume = self._calculate_total_volume(session.exercises)
                
                cursor.execute("""
                    INSERT INTO workout_sessions 
                    (user_id, date, session_type, duration_minutes, total_volume, 
                     calories_burned, exercises, notes, rating, created_at)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """, (
                    session.user_id, session.date, session.session_type,
                    session.duration_minutes, session.total_volume,
                    session.calories_burned, json.dumps(session.exercises, ensure_ascii=False),
                    session.notes, session.rating, session.created_at
                ))
                
                session_id = cursor.lastrowid
                
                # 개별 운동 기록도 저장
                for exercise_data in session.exercises:
                    self._log_exercise_record(cursor, session_id, exercise_data)
                
                conn.commit()
                logger.info(f"Workout session logged: ID {session_id}")
                return session_id
                
        except Exception as e:
            logger.error(f"Failed to log workout session: {e}")
            raise

    def _log_exercise_record(self, cursor: sqlite3.Cursor, session_id: int, exercise_data: Dict[str, Any]):
        """개별 운동 상세 기록"""
        exercise_name = exercise_data.get("name", "Unknown")
        category = exercise_data.get("category", "unknown")
        sets_data = exercise_data.get("sets", [])
        target_muscles = exercise_data.get("target_muscles", [])
        notes = exercise_data.get("notes", "")
        
        # 최대 중량 및 총 반복수 계산
        max_weight = 0
        total_reps = 0
        
        for set_data in sets_data:
            weight = set_data.get("weight", 0)
            reps = set_data.get("reps", 0)
            if weight > max_weight:
                max_weight = weight
            total_reps += reps
        
        cursor.execute("""
            INSERT INTO exercise_records 
            (session_id, exercise_name, category, sets_data, target_muscles, 
             max_weight, total_reps, notes)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            session_id, exercise_name, category,
            json.dumps(sets_data, ensure_ascii=False),
            json.dumps(target_muscles, ensure_ascii=False),
            max_weight, total_reps, notes
        ))

    def get_workout_history(self, user_id: str, days: int = 30) -> List[Dict[str, Any]]:
        """운동 기록 조회"""
        try:
            start_date = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")
            
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    SELECT * FROM workout_sessions 
                    WHERE user_id = ? AND date >= ?
                    ORDER BY date DESC
                """, (user_id, start_date))
                
                columns = [description[0] for description in cursor.description]
                sessions = []
                
                for row in cursor.fetchall():
                    session_dict = dict(zip(columns, row))
                    if session_dict["exercises"]:
                        session_dict["exercises"] = json.loads(session_dict["exercises"])
                    sessions.append(session_dict)
                
                return sessions
                
        except Exception as e:
            logger.error(f"Failed to get workout history: {e}")
            return []

    def analyze_progress(self, user_id: str, period: str = "month") -> ProgressMetrics:
        """운동 진행 상황 분석"""
        
        # 기간 설정
        if period == "week":
            days = 7
        elif period == "month":
            days = 30
        elif period == "quarter":
            days = 90
        else:  # year
            days = 365
        
        history = self.get_workout_history(user_id, days)
        
        if not history:
            return ProgressMetrics(period=period)
        
        # 기본 통계
        total_sessions = len(history)
        total_volume = sum(session.get("total_volume", 0) for session in history)
        total_duration = sum(session.get("duration_minutes", 0) for session in history)
        avg_session_duration = total_duration / total_sessions if total_sessions > 0 else 0
        
        # 일관성 계산 (목표 주 3회 기준)
        expected_sessions = (days // 7) * 3
        consistency_rate = min(100, (total_sessions / expected_sessions) * 100) if expected_sessions > 0 else 0
        
        # 근력 향상 분석
        strength_gains = self._analyze_strength_gains(user_id, days)
        
        return ProgressMetrics(
            period=period,
            total_sessions=total_sessions,
            total_volume=total_volume,
            avg_session_duration=avg_session_duration,
            consistency_rate=consistency_rate,
            strength_gains=strength_gains
        )

    def _analyze_strength_gains(self, user_id: str, days: int) -> Dict[str, float]:
        """근력 향상 분석"""
        try:
            start_date = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")
            mid_date = (datetime.now() - timedelta(days=days//2)).strftime("%Y-%m-%d")
            
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                
                # 주요 운동별 최대 중량 비교
                cursor.execute("""
                    SELECT exercise_name, max_weight, date
                    FROM exercise_records er
                    JOIN workout_sessions ws ON er.session_id = ws.id
                    WHERE ws.user_id = ? AND ws.date >= ?
                    ORDER BY exercise_name, ws.date
                """, (user_id, start_date))
                
                results = cursor.fetchall()
                exercise_progress = {}
                
                for exercise_name, max_weight, date in results:
                    if exercise_name not in exercise_progress:
                        exercise_progress[exercise_name] = {"early": [], "recent": []}
                    
                    if date < mid_date:
                        exercise_progress[exercise_name]["early"].append(max_weight)
                    else:
                        exercise_progress[exercise_name]["recent"].append(max_weight)
                
                # 향상 비율 계산
                strength_gains = {}
                for exercise, data in exercise_progress.items():
                    if data["early"] and data["recent"]:
                        early_max = max(data["early"])
                        recent_max = max(data["recent"])
                        if early_max > 0:
                            improvement = ((recent_max - early_max) / early_max) * 100
                            strength_gains[exercise] = round(improvement, 1)
                
                return strength_gains
                
        except Exception as e:
            logger.error(f"Failed to analyze strength gains: {e}")
            return {}

    def log_body_measurement(self, user_id: str, measurements: Dict[str, float], date: str = None) -> bool:
        """신체 측정 기록"""
        if not date:
            date = datetime.now().strftime("%Y-%m-%d")
        
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                
                cursor.execute("""
                    INSERT INTO body_measurements 
                    (user_id, date, weight, body_fat_percentage, muscle_mass, 
                     chest, waist, hip, arm, thigh, notes)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """, (
                    user_id, date,
                    measurements.get("weight"),
                    measurements.get("body_fat_percentage"),
                    measurements.get("muscle_mass"),
                    measurements.get("chest"),
                    measurements.get("waist"),
                    measurements.get("hip"),
                    measurements.get("arm"),
                    measurements.get("thigh"),
                    measurements.get("notes", "")
                ))
                
                conn.commit()
                logger.info(f"Body measurement logged for user {user_id}")
                return True
                
        except Exception as e:
            logger.error(f"Failed to log body measurement: {e}")
            return False

    def update_one_rep_max(self, user_id: str, exercise: str, weight: float, estimated: bool = False) -> bool:
        """1RM 기록 업데이트"""
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                
                # 기존 기록과 비교
                cursor.execute("""
                    SELECT weight FROM one_rep_max 
                    WHERE user_id = ? AND exercise_name = ?
                    ORDER BY date DESC LIMIT 1
                """, (user_id, exercise))
                
                result = cursor.fetchone()
                current_max = result[0] if result else 0
                
                # 새 기록이 더 높을 때만 업데이트
                if weight > current_max:
                    cursor.execute("""
                        INSERT INTO one_rep_max (user_id, exercise_name, weight, date, estimated)
                        VALUES (?, ?, ?, ?, ?)
                    """, (user_id, exercise, weight, datetime.now().strftime("%Y-%m-%d"), estimated))
                    
                    conn.commit()
                    logger.info(f"New 1RM record: {exercise} - {weight}kg")
                    return True
                
                return False
                
        except Exception as e:
            logger.error(f"Failed to update 1RM: {e}")
            return False

    def get_personal_records(self, user_id: str) -> Dict[str, Any]:
        """개인 기록 조회"""
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                
                # 1RM 기록들
                cursor.execute("""
                    SELECT exercise_name, weight, date, estimated
                    FROM one_rep_max 
                    WHERE user_id = ?
                    ORDER BY exercise_name, weight DESC
                """, (user_id,))
                
                one_rep_maxes = {}
                for exercise, weight, date, estimated in cursor.fetchall():
                    if exercise not in one_rep_maxes:
                        one_rep_maxes[exercise] = {
                            "weight": weight,
                            "date": date,
                            "estimated": bool(estimated)
                        }
                
                # 최고 기록들
                cursor.execute("""
                    SELECT MAX(total_volume) as max_volume,
                           MAX(duration_minutes) as max_duration,
                           COUNT(*) as total_sessions
                    FROM workout_sessions 
                    WHERE user_id = ?
                """, (user_id,))
                
                stats = cursor.fetchone()
                
                return {
                    "one_rep_maxes": one_rep_maxes,
                    "session_records": {
                        "max_volume": stats[0] or 0,
                        "max_duration": stats[1] or 0,
                        "total_sessions": stats[2] or 0
                    }
                }
                
        except Exception as e:
            logger.error(f"Failed to get personal records: {e}")
            return {}

    def generate_workout_insights(self, user_id: str) -> Dict[str, Any]:
        """운동 인사이트 생성"""
        recent_history = self.get_workout_history(user_id, 30)
        progress = self.analyze_progress(user_id, "month")
        records = self.get_personal_records(user_id)
        
        insights = {
            "summary": {
                "consistency_rating": self._get_consistency_rating(progress.consistency_rate),
                "progress_trend": self._get_progress_trend(recent_history),
                "strength_improvement": len([gain for gain in progress.strength_gains.values() if gain > 0])
            },
            "recommendations": [],
            "achievements": [],
            "areas_to_improve": []
        }
        
        # 추천사항 생성
        if progress.consistency_rate < 70:
            insights["recommendations"].append("운동 빈도를 높여 일관성을 개선하세요")
        
        if progress.avg_session_duration < 45:
            insights["recommendations"].append("운동 시간을 늘려 더 많은 볼륨을 확보하세요")
        
        # 성취 사항
        for exercise, gain in progress.strength_gains.items():
            if gain > 10:
                insights["achievements"].append(f"{exercise} {gain:.1f}% 향상!")
        
        # 개선 영역
        weak_exercises = [exercise for exercise, gain in progress.strength_gains.items() if gain < 0]
        if weak_exercises:
            insights["areas_to_improve"].extend(weak_exercises[:3])
        
        return insights

    def _calculate_calories(self, session_type: str, duration_minutes: int) -> int:
        """칼로리 계산"""
        rate = self.calorie_rates.get(session_type, 6.0)
        return int(rate * duration_minutes)

    def _calculate_total_volume(self, exercises: List[Dict[str, Any]]) -> float:
        """총 운동량 계산"""
        total_volume = 0.0
        for exercise in exercises:
            for set_data in exercise.get("sets", []):
                weight = set_data.get("weight", 0)
                reps = set_data.get("reps", 0)
                total_volume += weight * reps
        return total_volume

    def _get_consistency_rating(self, rate: float) -> str:
        """일관성 등급"""
        if rate >= 90:
            return "excellent"
        elif rate >= 75:
            return "good"
        elif rate >= 50:
            return "average"
        else:
            return "needs_improvement"

    def _get_progress_trend(self, history: List[Dict[str, Any]]) -> str:
        """진행 추세"""
        if len(history) < 4:
            return "insufficient_data"
        
        recent_volumes = [session.get("total_volume", 0) for session in history[:4]]
        older_volumes = [session.get("total_volume", 0) for session in history[-4:]]
        
        recent_avg = sum(recent_volumes) / 4
        older_avg = sum(older_volumes) / 4
        
        if recent_avg > older_avg * 1.1:
            return "improving"
        elif recent_avg < older_avg * 0.9:
            return "declining"
        else:
            return "stable"