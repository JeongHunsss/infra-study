from fastapi import FastAPI
import os
from database import check_db_connection, engine # database.py에서 가져오기

app = FastAPI()

# 서버가 시작될 때 실행되는 이벤트
@app.on_event("startup")
def on_startup():
    print("🚀 서버가 시작됩니다. DB 연결을 확인합니다...")
    if check_db_connection():
        print("✅ DB 연결 확인 완료!")
    else:
        print("❌ DB 연결에 실패했습니다. 인프라 설정을 확인하세요.")

@app.get("/")
def read_root():
    return {"message": "무중단 배포 blue"}

@app.get("/health")
def health_check():
    # 도커가 .env 파일의 변수들을 잘 주입해 주었는지 확인해 봅니다.
    # (보안을 위해 비밀번호 대신 DB 이름만 확인합니다)
    mysql_db = os.getenv("MYSQL_DATABASE", "연결 안 됨")
    pg_db = os.getenv("POSTGRES_DB", "연결 안 됨")
    
    return {
        "status": "정상 작동 중",
        "mysql_db_name": mysql_db,
        "postgres_db_name": pg_db
    }