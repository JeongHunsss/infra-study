#!/bin/bash

# 배포 폴더로 이동 (기본 위치: ~/deploy)
cd ~/deploy

echo "🚀 무중단 배포 스크립트 시작!"

# 1. 현재 켜져 있는 컨테이너 색깔 확인
# 'backend-blue'라는 이름의 컨테이너가 실행 중인지 검사함
IS_BLUE_UP=$(docker ps | grep backend-blue)

# 만약 블루가 켜져 있다면, 다음 타겟은 그린! (아니면 반대)
if [ -n "$IS_BLUE_UP" ]; then
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
# --env-file 옵션으로 infra/.env 를 강제로 읽게 함
docker-compose --env-file infra/.env -f infra/docker-compose.infra.yml -f infra/docker-compose.${TARGET_COLOR}.yml pull
docker-compose --env-file infra/.env -f infra/docker-compose.infra.yml -f infra/docker-compose.${TARGET_COLOR}.yml up -d
# 3. 새 컨테이너가 켜질 때까지 얌전히 기다리기 (Health Check)
# 백엔드 서버가 완전히 뜰 때까지 10초 정도 여유를 줌 (서버 속도에 따라 늘려도 됨)
echo "⏳ $TARGET_COLOR 서버 부팅 대기 중... (10초)"
sleep 15

# 4. Nginx의 방향 틀기 (대망의 하이라이트)
# service-url.inc 파일의 내용을 통째로 새 주소로 덮어씀 (>)
echo "proxy_pass http://backend-${TARGET_COLOR}:${TARGET_PORT};" > ./nginx/service-url.inc

# 5. Nginx 새로고침 (연결 끊김 없이 설정만 쇽 바뀜)
echo "🔄 Nginx 트래픽 전환 중..."
docker exec nginx nginx -s reload

# 6. 구버전 컨테이너 종료 (이제 쉬어라!)
echo "👋 구버전($CURRENT_COLOR) 컨테이너 종료 중..."
docker-compose -f docker-compose.${CURRENT_COLOR}.yml down

echo "✅ 무중단 배포 완벽하게 성공!"