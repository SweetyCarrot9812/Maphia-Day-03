@echo off
echo.
echo ========================================
echo     Hanoa 통합 플랫폼 시작
echo ========================================
echo.
echo 백엔드 서버와 Flutter 앱을 동시에 실행합니다...
echo.

cd /d "%~dp0"

REM 의존성 설치 확인
if not exist "node_modules" (
    echo 의존성을 설치합니다...
    npm install
)

if not exist "backend\node_modules" (
    echo 백엔드 의존성을 설치합니다...
    cd backend && npm install && cd ..
)

REM Flutter 의존성 확인
cd frontend
if not exist "pubspec.lock" (
    echo Flutter 의존성을 설치합니다...
    flutter pub get
)
cd ..

echo.
echo 시작 중...
npm run dev

pause