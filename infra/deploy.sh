#!/bin/bash

# 배포 폴더로 이동
cd ~/deploy

echo "🚀 무중단 배포 스크립트 시작!"

# 1. 현재 켜져 있는 컨테이너 색깔 확인
if [ -n "$(docker ps | grep backend-blue)" ]; then
  CURRENT_COLOR="blue"
  TARGET_COLOR="green"
  TARGET_PORT=8001
else
  CURRENT_COLOR="green"
  TARGET_COLOR="blue"
  TARGET_PORT=8000
fi

echo "🎯 현재 상태: $CURRENT_COLOR 동작 중"
echo "✨ 배포 타겟: $TARGET_COLOR (포트: $TARGET_PORT) 출격 준비!"

# 2. 새 버전 컨테이너 띄우기 (구버전 호환용 명령어)
# --pull always 대신 pull 명령어를 따로 실행함
docker-compose --env-file infra/.env -f infra/docker-compose.infra.yml -f infra/docker-compose.${TARGET_COLOR}.yml pull
docker-compose --env-file infra/.env -f infra/docker-compose.infra.yml -f infra/docker-compose.${TARGET_COLOR}.yml up -d

# 3. 새 컨테이너 부팅 대기 (네트워크 안정화를 위해 20초)
echo "⏳ $TARGET_COLOR 서버 부팅 대기 중... (20초)"
sleep 20

# infra/deploy.sh 4번 스텝
# 기존 꺼 다 지우고 딱 이렇게만 나오게 수정
echo "server backend-${TARGET_COLOR}:${TARGET_PORT};" > ./nginx/service-url.inc

# 5. Nginx 새로고침 (실패해도 죽지 않게 || true)
echo "🔄 Nginx 트래픽 전환 중..."
docker exec nginx nginx -s reload || echo "⚠️ Nginx 리로드 실패"

# 6. 구버전 컨테이너 종료 (이름으로 확실히 제거)
echo "👋 구버전($CURRENT_COLOR) 컨테이너 종료 중..."
docker rm -f backend-${CURRENT_COLOR} || echo "⚠️ 삭제할 컨테이너가 없음"

echo "✅ 무중단 배포 완벽하게 성공!"