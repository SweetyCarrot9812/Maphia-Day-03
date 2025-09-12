#!/usr/bin/env python3
"""
Haneul AI Agent - API Test Suite
Quick API testing and demonstration script
"""

import requests
import json
import time
from datetime import datetime
from typing import Dict, Any


class HaneulAPITester:
    """API testing class for Haneul AI Agent"""
    
    def __init__(self, base_url: str = "http://localhost:8000"):
        """Initialize API tester"""
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        
    def test_health_check(self) -> Dict[str, Any]:
        """Test basic health check"""
        print("🏥 Testing health check...")
        
        try:
            response = self.session.get(f"{self.base_url}/health")
            result = response.json()
            
            if response.status_code == 200:
                print("✅ Health check passed")
                print(f"   Status: {result['status']}")
                print(f"   Obsidian Vault: {result.get('obsidian_vault', 'Not configured')}")
                return {"success": True, "data": result}
            else:
                print(f"❌ Health check failed: {response.status_code}")
                return {"success": False, "error": f"HTTP {response.status_code}"}
                
        except requests.RequestException as e:
            print(f"❌ Health check failed: {e}")
            return {"success": False, "error": str(e)}
    
    def test_ai_priority_analysis(self) -> Dict[str, Any]:
        """Test AI priority analysis"""
        print("🧠 Testing AI priority analysis...")
        
        test_content = "프로젝트 최종 발표를 위한 PPT 자료 준비해야 함. 내일까지 완료 필요."
        
        try:
            response = self.session.post(
                f"{self.base_url}/api/ai/analyze",
                params={
                    "content": test_content,
                    "context": "중요한 프로젝트 마감"
                }
            )
            
            if response.status_code == 200:
                result = response.json()
                print("✅ AI analysis successful")
                print(f"   시급성: {result['urgency']}/10")
                print(f"   중요도: {result['importance']}/10")
                print(f"   총점: {result['total_score']}/20")
                print(f"   추천 태그: {', '.join(result['suggested_tags'])}")
                print(f"   예상 시간: {result['estimated_time']}")
                return {"success": True, "data": result}
            else:
                print(f"❌ AI analysis failed: {response.status_code}")
                return {"success": False, "error": f"HTTP {response.status_code}"}
                
        except requests.RequestException as e:
            print(f"❌ AI analysis failed: {e}")
            return {"success": False, "error": str(e)}
    
    def test_task_creation(self) -> Dict[str, Any]:
        """Test task creation with AI analysis"""
        print("📝 Testing task creation...")
        
        task_data = {
            "title": "AI 에이전트 테스트",
            "content": "Haneul AI 에이전트의 모든 기능을 테스트하고 결과를 문서화한다.",
            "urgency": 0,  # AI가 자동 분석
            "importance": 0,
            "tags": ["테스트", "AI"],
            "estimated_time": None
        }
        
        try:
            response = self.session.post(
                f"{self.base_url}/api/ai/tasks",
                json=task_data
            )
            
            if response.status_code == 200:
                result = response.json()
                print("✅ Task created successfully")
                print(f"   ID: {result['id']}")
                print(f"   제목: {result['title']}")
                print(f"   우선순위: {result['priority_score']}/20")
                print(f"   상태: {result['status']}")
                print(f"   Obsidian 파일: {result.get('obsidian_file_path', 'None')}")
                return {"success": True, "data": result}
            else:
                print(f"❌ Task creation failed: {response.status_code}")
                return {"success": False, "error": f"HTTP {response.status_code}"}
                
        except requests.RequestException as e:
            print(f"❌ Task creation failed: {e}")
            return {"success": False, "error": str(e)}
    
    def test_top_priority_tasks(self) -> Dict[str, Any]:
        """Test top priority tasks retrieval"""
        print("🎯 Testing top priority tasks...")
        
        try:
            response = self.session.get(f"{self.base_url}/api/ai/tasks/top-priority?limit=3")
            
            if response.status_code == 200:
                result = response.json()
                tasks = result['data']
                print("✅ Top priority tasks retrieved")
                print(f"   Found {len(tasks)} tasks")
                
                for i, task in enumerate(tasks, 1):
                    print(f"   {i}. [{task['priority_score']}점] {task['title']}")
                
                return {"success": True, "data": result}
            else:
                print(f"❌ Top priority tasks failed: {response.status_code}")
                return {"success": False, "error": f"HTTP {response.status_code}"}
                
        except requests.RequestException as e:
            print(f"❌ Top priority tasks failed: {e}")
            return {"success": False, "error": str(e)}
    
    def test_obsidian_vault_stats(self) -> Dict[str, Any]:
        """Test Obsidian vault statistics"""
        print("📁 Testing Obsidian vault stats...")
        
        try:
            response = self.session.get(f"{self.base_url}/api/obsidian/vault/stats")
            
            if response.status_code == 200:
                result = response.json()
                stats = result['data']
                print("✅ Vault stats retrieved")
                print(f"   Vault exists: {stats['vault_exists']}")
                print(f"   Vault path: {stats['vault_path']}")
                if 'folders' in stats:
                    print(f"   Inbox: {stats['folders']['inbox']} files")
                    print(f"   Todo: {stats['folders']['todo']} files")
                    print(f"   Completed: {stats['folders']['completed']} files")
                return {"success": True, "data": result}
            else:
                print(f"❌ Vault stats failed: {response.status_code}")
                return {"success": False, "error": f"HTTP {response.status_code}"}
                
        except requests.RequestException as e:
            print(f"❌ Vault stats failed: {e}")
            return {"success": False, "error": str(e)}
    
    def test_notification_settings(self) -> Dict[str, Any]:
        """Test notification settings"""
        print("📧 Testing notification settings...")
        
        try:
            # Get current settings
            response = self.session.get(f"{self.base_url}/api/notifications/settings")
            
            if response.status_code == 200:
                result = response.json()
                print("✅ Notification settings retrieved")
                print(f"   Email enabled: {result['email_enabled']}")
                print(f"   Email address: {result['email_address']}")
                print(f"   Notification time: {result['notification_time']}")
                print(f"   Frequency: {result['frequency']}")
                return {"success": True, "data": result}
            else:
                print(f"❌ Notification settings failed: {response.status_code}")
                return {"success": False, "error": f"HTTP {response.status_code}"}
                
        except requests.RequestException as e:
            print(f"❌ Notification settings failed: {e}")
            return {"success": False, "error": str(e)}
    
    def run_full_test_suite(self) -> Dict[str, Any]:
        """Run complete API test suite"""
        print("🌟 Haneul AI Agent - Full API Test Suite")
        print("=" * 60)
        
        results = {
            "timestamp": datetime.now().isoformat(),
            "base_url": self.base_url,
            "tests": {}
        }
        
        # Run all tests
        test_methods = [
            ("health_check", self.test_health_check),
            ("ai_priority_analysis", self.test_ai_priority_analysis),
            ("task_creation", self.test_task_creation),
            ("top_priority_tasks", self.test_top_priority_tasks),
            ("obsidian_vault_stats", self.test_obsidian_vault_stats),
            ("notification_settings", self.test_notification_settings)
        ]
        
        for test_name, test_method in test_methods:
            print(f"\n{'-' * 40}")
            result = test_method()
            results["tests"][test_name] = result
            
            if result["success"]:
                print("✅ Test passed")
            else:
                print(f"❌ Test failed: {result.get('error', 'Unknown error')}")
            
            time.sleep(0.5)  # Brief pause between tests
        
        # Summary
        print("\n" + "=" * 60)
        print("📊 TEST SUMMARY")
        print("=" * 60)
        
        passed = sum(1 for r in results["tests"].values() if r["success"])
        total = len(results["tests"])
        
        print(f"Tests passed: {passed}/{total}")
        print(f"Success rate: {(passed/total)*100:.1f}%")
        
        if passed == total:
            print("🎉 All tests passed! Haneul AI Agent is working perfectly.")
        else:
            print("⚠️  Some tests failed. Check the error messages above.")
        
        return results


def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Haneul AI Agent API Tester")
    parser.add_argument("--url", default="http://localhost:8000", help="Base URL of the API")
    parser.add_argument("--test", choices=[
        "health", "ai", "task", "priority", "obsidian", "notifications", "all"
    ], default="all", help="Specific test to run")
    
    args = parser.parse_args()
    
    tester = HaneulAPITester(args.url)
    
    if args.test == "all":
        results = tester.run_full_test_suite()
    elif args.test == "health":
        results = tester.test_health_check()
    elif args.test == "ai":
        results = tester.test_ai_priority_analysis()
    elif args.test == "task":
        results = tester.test_task_creation()
    elif args.test == "priority":
        results = tester.test_top_priority_tasks()
    elif args.test == "obsidian":
        results = tester.test_obsidian_vault_stats()
    elif args.test == "notifications":
        results = tester.test_notification_settings()
    
    # Save results to file
    with open(f"test_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json", 'w') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    
    print(f"\n📄 Test results saved to: test_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json")


if __name__ == "__main__":
    main()