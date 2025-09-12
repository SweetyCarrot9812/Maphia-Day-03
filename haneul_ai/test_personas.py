"""
Haneul AI Agent - Multi-Persona System Test
GPT-5 업그레이드 및 헬스 페르소나 테스트
"""

import asyncio
import requests
import json
from datetime import datetime


class PersonaTestSuite:
    """멀티 페르소나 시스템 테스트 스위트"""
    
    def __init__(self, base_url="http://localhost:8000"):
        self.base_url = base_url
        self.test_results = []
    
    def log_result(self, test_name: str, success: bool, details: str = ""):
        """테스트 결과 로깅"""
        result = {
            "test_name": test_name,
            "success": success,
            "details": details,
            "timestamp": datetime.now().isoformat()
        }
        self.test_results.append(result)
        
        status = "✅ PASS" if success else "❌ FAIL"
        print(f"{status} | {test_name}")
        if details:
            print(f"     └─ {details}")
    
    def test_health_check(self):
        """서버 상태 확인"""
        try:
            response = requests.get(f"{self.base_url}/health")
            success = response.status_code == 200
            
            if success:
                data = response.json()
                details = f"Status: {data.get('status', 'unknown')}"
            else:
                details = f"HTTP {response.status_code}"
                
            self.log_result("Health Check", success, details)
            return success
            
        except Exception as e:
            self.log_result("Health Check", False, str(e))
            return False
    
    def test_personas_list(self):
        """페르소나 목록 조회 테스트"""
        try:
            response = requests.get(f"{self.base_url}/api/ai/personas")
            success = response.status_code == 200
            
            if success:
                data = response.json()
                personas = data.get("data", [])
                details = f"Found {len(personas)} personas: {[p['name'] for p in personas]}"
            else:
                details = f"HTTP {response.status_code}"
                
            self.log_result("Personas List", success, details)
            return success
            
        except Exception as e:
            self.log_result("Personas List", False, str(e))
            return False
    
    def test_persona_detection(self):
        """페르소나 자동 감지 테스트"""
        test_cases = [
            {
                "content": "오늘 헬스장에서 벤치프레스 80kg 5세트 하고 싶은데 계획 짜주세요",
                "expected": "fitness",
                "name": "헬스 관련 자동 감지"
            },
            {
                "content": "프로젝트 마감일이 내일인데 우선순위를 정해주세요",
                "expected": "productivity", 
                "name": "업무 관련 자동 감지"
            }
        ]
        
        all_passed = True
        
        for case in test_cases:
            try:
                response = requests.post(
                    f"{self.base_url}/api/ai/personas/detect",
                    json={"content": case["content"]}
                )
                
                success = response.status_code == 200
                if success:
                    data = response.json()
                    detected = data.get("data", {}).get("detected_persona")
                    success = detected == case["expected"]
                    details = f"Expected: {case['expected']}, Got: {detected}"
                else:
                    details = f"HTTP {response.status_code}"
                
                self.log_result(case["name"], success, details)
                if not success:
                    all_passed = False
                    
            except Exception as e:
                self.log_result(case["name"], False, str(e))
                all_passed = False
        
        return all_passed
    
    def test_fitness_persona_analysis(self):
        """헬스 페르소나 분석 테스트"""
        try:
            test_content = "이번 주 3회 운동 계획을 세우고 싶습니다. 바디빌딩 초보자입니다."
            
            response = requests.post(
                f"{self.base_url}/api/ai/personas/fitness/analyze",
                json={
                    "content": test_content,
                    "context": "주 3회, 초보자 레벨"
                }
            )
            
            success = response.status_code == 200
            if success:
                data = response.json()
                analysis = data.get("data", {}).get("analysis", {})
                used_model = data.get("data", {}).get("model")
                
                details = f"Model: {used_model}, Score: {analysis.get('total_score', 0)}/20"
            else:
                details = f"HTTP {response.status_code}"
            
            self.log_result("Fitness Persona Analysis", success, details)
            return success
            
        except Exception as e:
            self.log_result("Fitness Persona Analysis", False, str(e))
            return False
    
    def test_fitness_persona_suggestion(self):
        """헬스 페르소나 제안 테스트"""
        try:
            test_content = "스쿼트 자세가 불안정해요. 무릎이 아픈 것 같습니다."
            
            response = requests.post(
                f"{self.base_url}/api/ai/personas/fitness/suggest",
                json={
                    "content": test_content,
                    "context": "초보자, 무릎 통증"
                }
            )
            
            success = response.status_code == 200
            if success:
                data = response.json()
                suggestion = data.get("data", {}).get("suggestion", "")
                used_model = data.get("data", {}).get("model")
                
                details = f"Model: {used_model}, Length: {len(suggestion)} chars"
            else:
                details = f"HTTP {response.status_code}"
            
            self.log_result("Fitness Persona Suggestion", success, details)
            return success
            
        except Exception as e:
            self.log_result("Fitness Persona Suggestion", False, str(e))
            return False
    
    def test_productivity_persona(self):
        """생산성 페르소나 테스트"""
        try:
            test_content = "이번 주 완료해야 할 5개 프로젝트가 있는데 우선순위를 정해주세요"
            
            response = requests.post(
                f"{self.base_url}/api/ai/personas/productivity/analyze",
                json={
                    "content": test_content,
                    "context": "프리랜서, 마감 압박"
                }
            )
            
            success = response.status_code == 200
            if success:
                data = response.json()
                analysis = data.get("data", {}).get("analysis", {})
                used_model = data.get("data", {}).get("model")
                
                details = f"Model: {used_model}, Score: {analysis.get('total_score', 0)}/20"
            else:
                details = f"HTTP {response.status_code}"
            
            self.log_result("Productivity Persona Analysis", success, details)
            return success
            
        except Exception as e:
            self.log_result("Productivity Persona Analysis", False, str(e))
            return False
    
    def run_all_tests(self):
        """모든 테스트 실행"""
        print("🌟 Haneul AI Multi-Persona System Test Suite")
        print("=" * 50)
        
        # 1. 기본 연결 테스트
        if not self.test_health_check():
            print("\n❌ 서버에 연결할 수 없습니다. 테스트를 중단합니다.")
            return False
        
        # 2. 페르소나 시스템 테스트
        self.test_personas_list()
        self.test_persona_detection()
        
        # 3. 헬스 페르소나 테스트
        self.test_fitness_persona_analysis()
        self.test_fitness_persona_suggestion()
        
        # 4. 생산성 페르소나 테스트 
        self.test_productivity_persona()
        
        # 결과 요약
        self.print_summary()
        return self.get_overall_success_rate() > 0.8
    
    def print_summary(self):
        """테스트 결과 요약 출력"""
        total_tests = len(self.test_results)
        passed_tests = len([r for r in self.test_results if r["success"]])
        
        print("\n" + "=" * 50)
        print(f"📊 테스트 결과 요약")
        print(f"총 테스트: {total_tests}")
        print(f"통과: {passed_tests} ✅")
        print(f"실패: {total_tests - passed_tests} ❌")
        print(f"성공률: {(passed_tests/total_tests*100):.1f}%")
        
        if passed_tests == total_tests:
            print("\n🎉 모든 테스트가 통과했습니다!")
        else:
            print("\n⚠️  일부 테스트가 실패했습니다.")
            
        print("=" * 50)
    
    def get_overall_success_rate(self):
        """전체 성공률 반환"""
        if not self.test_results:
            return 0.0
        return len([r for r in self.test_results if r["success"]]) / len(self.test_results)


if __name__ == "__main__":
    print("🚀 Haneul AI Agent - Multi-Persona System Test")
    print("⚠️  서버가 실행 중인지 확인하세요: python start_server.py")
    print()
    
    # 서버 실행 확인
    input("서버가 준비되었으면 Enter를 눌러주세요...")
    
    # 테스트 실행
    tester = PersonaTestSuite()
    success = tester.run_all_tests()
    
    # 결과에 따른 종료 코드
    exit(0 if success else 1)