"""
User Activity Monitor and Auto Learning Plan Service
Monitors Firebase for active users and automatically generates learning plans
"""

import asyncio
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timedelta
from typing import List, Dict, Any
import os
from dotenv import load_dotenv

load_dotenv()

# Initialize Firebase if not already done
if not firebase_admin._apps:
    cred = credentials.Certificate('firebase-service-account.json')
    firebase_admin.initialize_app(cred)

db = firestore.client()


class UserActivityMonitor:
    """Monitors user activity and triggers automatic learning plan generation"""

    def __init__(self):
        self.db = firestore.client()
        self.monitored_users = set()
        self.processing_queue = []

    async def get_active_users(self, hours_back: int = 24) -> List[Dict[str, Any]]:
        """
        Get users who have been active in the last N hours
        Returns list of users with recent wrong answers
        """
        cutoff_time = datetime.now() - timedelta(hours=hours_back)

        # Query wrong_answers collection for recent activity
        wrong_answers_ref = self.db.collection('wrong_answers')
        query = wrong_answers_ref.where('timestamp', '>=', cutoff_time)

        active_users = {}
        docs = query.stream()

        for doc in docs:
            data = doc.to_dict()
            user_id = data.get('userId')

            if user_id:
                if user_id not in active_users:
                    active_users[user_id] = {
                        'user_id': user_id,
                        'wrong_count': 0,
                        'last_activity': data.get('timestamp'),
                        'concepts': [],
                        'subjects': set()
                    }

                active_users[user_id]['wrong_count'] += 1

                # Track concepts from wrong answers
                if data.get('concept'):
                    active_users[user_id]['concepts'].append(data.get('concept'))

                # Track subjects
                if data.get('subject'):
                    active_users[user_id]['subjects'].add(data.get('subject'))

                # Update last activity time
                if data.get('timestamp') > active_users[user_id]['last_activity']:
                    active_users[user_id]['last_activity'] = data.get('timestamp')

        # Convert to list and clean up sets
        result = []
        for user_id, user_data in active_users.items():
            user_data['subjects'] = list(user_data['subjects'])
            result.append(user_data)

        return result

    async def check_user_needs_help(self, user_data: Dict[str, Any]) -> bool:
        """
        Determine if user needs automatic help based on activity

        Criteria:
        - More than 5 wrong answers in last 24 hours
        - Accuracy rate below 60%
        - Repeated mistakes on same concepts
        """
        if user_data['wrong_count'] >= 5:
            return True

        # Check for repeated mistakes
        concept_counts = {}
        for concept in user_data['concepts']:
            concept_counts[concept] = concept_counts.get(concept, 0) + 1

        # If any concept has 3+ mistakes, user needs help
        for count in concept_counts.values():
            if count >= 3:
                return True

        return False

    async def monitor_and_process(self):
        """
        Main monitoring loop
        Continuously checks for active users and processes them
        """
        print("[MONITOR] Starting user activity monitoring...")

        while True:
            try:
                # Get active users from last 24 hours
                active_users = await self.get_active_users(hours_back=24)

                print(f"[MONITOR] Found {len(active_users)} active users")

                # Check each user
                for user_data in active_users:
                    user_id = user_data['user_id']

                    # Skip if already processed recently
                    if user_id in self.monitored_users:
                        continue

                    # Check if user needs help
                    needs_help = await self.check_user_needs_help(user_data)

                    if needs_help:
                        print(f"[ALERT] User {user_id} needs help - {user_data['wrong_count']} wrong answers")

                        # Add to processing queue
                        self.processing_queue.append({
                            'user_id': user_id,
                            'user_data': user_data,
                            'timestamp': datetime.now(),
                            'status': 'pending'
                        })

                        # Mark as monitored
                        self.monitored_users.add(user_id)

                # Wait before next check (5 minutes)
                await asyncio.sleep(300)

                # Clear monitored users after 1 hour
                if len(self.monitored_users) > 0:
                    self.monitored_users.clear()

            except Exception as e:
                print(f"[ERROR] Monitor error: {e}")
                await asyncio.sleep(60)  # Wait 1 minute on error

    async def auto_generate_plans(self):
        """
        Process queue and automatically generate learning plans
        """
        from learning_plan_engine import LearningPlanEngine
        from ai_batch_generator import BatchQuestionGenerator

        engine = LearningPlanEngine()
        generator = BatchQuestionGenerator()

        print("[PROCESSOR] Starting automatic plan generation...")

        while True:
            try:
                # Check processing queue
                if self.processing_queue:
                    # Get next user to process
                    task = None
                    for item in self.processing_queue:
                        if item['status'] == 'pending':
                            task = item
                            break

                    if task:
                        user_id = task['user_id']
                        print(f"[PROCESSING] Generating plan for user: {user_id}")

                        # Update status
                        task['status'] = 'processing'

                        try:
                            # Analyze user history
                            analysis = await engine.analyze_user_history(user_id, days_back=30)

                            if analysis:
                                # Generate learning plan using GPT-5-mini
                                plan = await engine.generate_learning_plan(
                                    learning_analysis=analysis,
                                    target_count=10  # Generate 10 questions automatically
                                )

                                if plan:
                                    print(f"[SUCCESS] Plan generated for {user_id}")

                                    # Execute plan to generate questions
                                    result = await engine.execute_plan(
                                        plan=plan,
                                        save_to_firebase=True
                                    )

                                    if result['success']:
                                        print(f"[SUCCESS] Generated {result['total_generated']} questions for {user_id}")

                                        # Save notification for user
                                        notification = {
                                            'user_id': user_id,
                                            'type': 'auto_learning_plan',
                                            'message': f"자동으로 {result['total_generated']}개의 맞춤 문제가 생성되었습니다",
                                            'plan': plan,
                                            'timestamp': firestore.SERVER_TIMESTAMP,
                                            'read': False
                                        }

                                        self.db.collection('notifications').add(notification)

                                        # Update task status
                                        task['status'] = 'completed'
                                        task['completed_at'] = datetime.now()
                                        task['questions_generated'] = result['total_generated']
                                    else:
                                        task['status'] = 'failed'
                                        task['error'] = 'Plan execution failed'
                                else:
                                    task['status'] = 'failed'
                                    task['error'] = 'Plan generation failed'
                            else:
                                task['status'] = 'failed'
                                task['error'] = 'No learning history found'

                        except Exception as e:
                            print(f"[ERROR] Processing failed for {user_id}: {e}")
                            task['status'] = 'failed'
                            task['error'] = str(e)

                # Clean up completed tasks
                self.processing_queue = [
                    task for task in self.processing_queue
                    if task['status'] not in ['completed', 'failed']
                ]

                # Wait before next processing
                await asyncio.sleep(30)  # Check every 30 seconds

            except Exception as e:
                print(f"[ERROR] Processor error: {e}")
                await asyncio.sleep(60)

    def get_queue_status(self) -> Dict[str, Any]:
        """Get current status of monitoring and processing"""
        return {
            'monitored_users': len(self.monitored_users),
            'queue_length': len(self.processing_queue),
            'pending': sum(1 for t in self.processing_queue if t['status'] == 'pending'),
            'processing': sum(1 for t in self.processing_queue if t['status'] == 'processing'),
            'completed': sum(1 for t in self.processing_queue if t['status'] == 'completed'),
            'failed': sum(1 for t in self.processing_queue if t['status'] == 'failed'),
            'queue_details': self.processing_queue
        }


# Singleton instance
monitor_instance = UserActivityMonitor()


async def start_monitoring():
    """Start the monitoring service"""
    print("[START] User Activity Monitoring Service")

    # Create tasks for monitoring and processing
    monitor_task = asyncio.create_task(monitor_instance.monitor_and_process())
    processor_task = asyncio.create_task(monitor_instance.auto_generate_plans())

    # Run both tasks
    await asyncio.gather(monitor_task, processor_task)


if __name__ == "__main__":
    # Run the monitoring service
    asyncio.run(start_monitoring())