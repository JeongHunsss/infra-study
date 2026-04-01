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

# 4. [핵심] 연결 확인용 함수
def check_db_connection():
    try:
        # DB에 "1"이라는 숫자를 던져서 잘 돌아오는지 확인 (Select 1)
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))
        print("✅ DB 연결 성공! 인프라 세팅 완벽함.")
        return True
    except Exception as e:
        print(f"❌ DB 연결 실패: {e}")
        return False

# 실행 시 바로 확인
if __name__ == "__main__":
    check_db_connection()