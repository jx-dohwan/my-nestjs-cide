# 1. ---- 빌드 스테이지 (Builder Stage) ----
# devDependencies를 포함한 모든 의존성을 설치합니다.
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./

# [수정됨] --only=production 플래그를 제거하여 devDependencies까지 모두 설치합니다.
RUN npm ci

# 소스 코드 복사
COPY . .

# 애플리케이션 빌드
RUN npm run build
# (이제 'nest' 명령어를 찾을 수 있습니다!)


# 2. ---- 프로덕션 스테이지 (Production Stage) ----
# node:18-alpine 이미지에서 새로 시작합니다.
FROM node:18-alpine

WORKDIR /app

# package.json 파일만 먼저 복사합니다.
COPY package*.json ./

# [수정됨] 최종 이미지에서는 "프로덕션" 의존성만 새로 설치합니다.
# 이렇게 하면 이미지 용량이 최소화됩니다.
RUN npm ci --only=production

# [수정됨] 빌드 스테이지에서 빌드된 'dist' 폴더만 복사합니다.
# node_modules는 위에서 새로 설치했으므로 복사하지 않습니다.
COPY --from=builder /app/dist ./dist

EXPOSE 3000

# [권장] npm 스크립트를 거치지 않고 node로 직접 실행하는 것이 더 효율적입니다.
CMD ["node", "dist/main"]