
import time
import os
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

# 1. 환경변수에서 정보 읽어오기 (로봇이 만든 .env랑 이름 맞춰야 함!)
DB_USER = "root"
DB_PASSWORD = os.getenv("MYSQL_ROOT_PASSWORD")
DB_HOST = "mysql"  # 중요! localhost가 아니라 docker-compose의 서비스 이름
DB_PORT = "3306"
DB_NAME = os.getenv("MYSQL_DATABASE")

# 2. 접속 주소(URL) 만들기
DATABASE_URL = f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

# 3. 엔진 및 세션 설정
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def check_db_connection():
    max_retries = 5  # 최대 5번 시도
    retry_interval = 5  # 5초 간격
    
    for i in range(max_retries):
        try:
            with engine.connect() as connection:
                connection.execute(text("SELECT 1"))
            print(f"✅ DB 연결 성공! ({i+1}번 시도 만에 성공)")
            return True
        except Exception as e:
            print(f"⚠️ {i+1}번 시도 실패: DB가 아직 준비되지 않았음... ({retry_interval}초 후 재시도)")
            time.sleep(retry_interval)
            
    print("❌ 결국 DB 연결에 실패함.")
    return False

# 실행 시 바로 확인
if __name__ == "__main__":
    check_db_connection()