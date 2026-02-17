# Build frontend files
FROM node:24.12.0-alpine3.23 AS builder

WORKDIR /app

RUN apk add --no-cache dos2unix
COPY . .
RUN find . -type d -name node_modules -prune -o -type f \( -name "*.sh" -o -name "*.ts" -o -name "*.js" -o -name "*.mjs" -o -name "*.json" -o -name "*.vue" -o -name "*.scss" -o -name "*.css" -o -name "*.html" -o -name "*.txt" \) -print0 | xargs -0 dos2unix
RUN npm ci
RUN npm run build

# Serve with Nginx
FROM nginx:1.27-alpine

COPY docker/frontend/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist/ /usr/share/nginx/html/

EXPOSE 80
