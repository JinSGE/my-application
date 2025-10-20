# 1. 베이스 이미지 선택
FROM openjdk:17-jdk-slim

# 2. 빌드 산출물 복사
COPY target/myapp-1.0.0.jar /app/myapp.jar

# 3. 실행 명령어
ENTRYPOINT ["java", "-jar", "/app/myapp.jar"]

