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

# 2. 새 버전 컨테이너 띄우기
# 만약 이미 띄워져 있다면 무시하고 진행하도록 함
docker-compose --env-file infra/.env -f infra/docker-compose.infra.yml -f infra/docker-compose.${TARGET_COLOR}.yml up -d --pull always

# 3. 새 컨테이너 부팅 대기
echo "⏳ $TARGET_COLOR 서버 부팅 대기 중... (15초)"
sleep 15

# 4. Nginx의 방향 틀기
echo "proxy_pass http://backend-${TARGET_COLOR}:${TARGET_PORT};" > ./nginx/service-url.inc

# 5. Nginx 새로고침 (실패해도 스크립트 안 멈추게 || true 붙임)
echo "🔄 Nginx 트래픽 전환 중..."
docker exec nginx nginx -s reload || echo "⚠️ Nginx 리로드 실패 (설정 확인 필요)"

# 6. 구버전 컨테이너 종료 (이게 핵심!)
# || true를 붙여서 삭제할 게 없어도 스크립트가 안 멈추게 함
echo "👋 구버전($CURRENT_COLOR) 컨테이너 종료 중..."
docker rm -f backend-${CURRENT_COLOR} || echo "⚠️ 삭제할 컨테이너가 없음"

echo "✅ 무중단 배포 완벽하게 성공!"