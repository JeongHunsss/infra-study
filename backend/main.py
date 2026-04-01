from fastapi import FastAPI
import os

app = FastAPI()

@app.get("/")
def read_root():
    return {"message":  "AWS 보안 그룹 테스트1"}

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