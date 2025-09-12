#!/usr/bin/env python3
"""
Haneul AI Agent - Server Launcher
Quick start script for development and production
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path


def check_requirements():
    """Check if all requirements are satisfied"""
    print("🔍 Checking requirements...")
    
    # Check Python version
    if sys.version_info < (3.8, 0):
        print("❌ Python 3.8 or higher is required")
        return False
    
    print(f"✅ Python {sys.version.split()[0]}")
    
    # Check if virtual environment exists
    venv_path = Path("venv")
    if not venv_path.exists():
        print("⚠️  Virtual environment not found - creating...")
        subprocess.run([sys.executable, "-m", "venv", "venv"], check=True)
        print("✅ Virtual environment created")
    
    # Check if requirements are installed
    try:
        import fastapi
        import uvicorn
        import openai
        print("✅ Core dependencies found")
    except ImportError:
        print("📦 Installing requirements...")
        if os.name == 'nt':  # Windows
            pip_cmd = ["venv\\Scripts\\pip.exe"]
        else:  # Unix/Linux/Mac
            pip_cmd = ["venv/bin/pip"]
        
        subprocess.run(pip_cmd + ["install", "-r", "requirements.txt"], check=True)
        print("✅ Requirements installed")
    
    return True


def check_environment():
    """Check environment configuration"""
    print("🔧 Checking environment configuration...")
    
    env_file = Path(".env")
    if not env_file.exists():
        print("⚠️  .env file not found")
        print("📝 Creating .env from template...")
        
        example_file = Path(".env.example")
        if example_file.exists():
            import shutil
            shutil.copy(example_file, env_file)
            print("✅ .env file created from template")
            print("⚠️  Please edit .env file with your API keys!")
            return False
        else:
            print("❌ .env.example not found")
            return False
    
    # Load and check critical environment variables
    from dotenv import load_dotenv
    load_dotenv()
    
    required_vars = ["OPENAI_API_KEY", "EMAIL_ADDRESS", "OBSIDIAN_VAULT_PATH"]
    missing_vars = []
    
    for var in required_vars:
        if not os.getenv(var):
            missing_vars.append(var)
    
    if missing_vars:
        print(f"❌ Missing environment variables: {', '.join(missing_vars)}")
        print("📝 Please edit .env file with required values")
        return False
    
    print("✅ Environment configuration OK")
    return True


def check_obsidian_vault():
    """Check if Obsidian vault exists"""
    print("📁 Checking Obsidian vault...")
    
    vault_path = os.getenv("OBSIDIAN_VAULT_PATH")
    if not vault_path:
        print("⚠️  OBSIDIAN_VAULT_PATH not set")
        return False
    
    vault_path = Path(vault_path)
    if not vault_path.exists():
        print(f"⚠️  Obsidian vault not found at: {vault_path}")
        print("📁 Creating vault directory...")
        vault_path.mkdir(parents=True, exist_ok=True)
        print("✅ Vault directory created")
    
    # Create required folders
    folders = ["00-Inbox", "01-Todo", "02-Completed"]
    for folder in folders:
        folder_path = vault_path / folder
        folder_path.mkdir(exist_ok=True)
    
    print("✅ Obsidian vault structure ready")
    return True


def start_server(host="0.0.0.0", port=8000, reload=True, log_level="info"):
    """Start the FastAPI server"""
    print(f"🚀 Starting Haneul AI Agent server...")
    print(f"   Host: {host}")
    print(f"   Port: {port}")
    print(f"   Reload: {reload}")
    print(f"   Log Level: {log_level}")
    
    try:
        if os.name == 'nt':  # Windows
            python_cmd = "venv\\Scripts\\python.exe"
        else:  # Unix/Linux/Mac
            python_cmd = "venv/bin/python"
        
        cmd = [
            python_cmd, "-m", "uvicorn",
            "app.main:app",
            "--host", host,
            "--port", str(port),
            "--log-level", log_level
        ]
        
        if reload:
            cmd.append("--reload")
        
        subprocess.run(cmd, check=True)
        
    except KeyboardInterrupt:
        print("\n🛑 Server stopped by user")
    except subprocess.CalledProcessError as e:
        print(f"❌ Server failed to start: {e}")
        return False
    
    return True


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(description="Haneul AI Agent Server Launcher")
    parser.add_argument("--host", default="0.0.0.0", help="Host to bind (default: 0.0.0.0)")
    parser.add_argument("--port", type=int, default=8000, help="Port to bind (default: 8000)")
    parser.add_argument("--no-reload", action="store_true", help="Disable auto-reload")
    parser.add_argument("--log-level", default="info", choices=["debug", "info", "warning", "error"], help="Log level")
    parser.add_argument("--skip-checks", action="store_true", help="Skip environment checks")
    
    args = parser.parse_args()
    
    print("Haneul AI Agent - Server Launcher")
    print("=" * 50)
    
    if not args.skip_checks:
        # Run all checks
        if not check_requirements():
            print("[ERROR] Requirements check failed")
            sys.exit(1)
        
        if not check_environment():
            print("[ERROR] Environment check failed")
            print("[INFO] Edit .env file with your API keys and try again")
            sys.exit(1)
        
        if not check_obsidian_vault():
            print("[ERROR] Obsidian vault check failed")
            sys.exit(1)
        
        print("[SUCCESS] All checks passed!")
        print("=" * 50)
    
    # Start server
    success = start_server(
        host=args.host,
        port=args.port,
        reload=not args.no_reload,
        log_level=args.log_level
    )
    
    if success:
        print("✅ Server started successfully")
    else:
        print("❌ Server failed to start")
        sys.exit(1)


if __name__ == "__main__":
    main()