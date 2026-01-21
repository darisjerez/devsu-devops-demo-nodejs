FROM node:18.15.0-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm ci

FROM node:18.15.0-alpine

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules

COPY . .

RUN chown -R appuser:appgroup /app

USER appuser

ENV DATABASE_NAME="./dev.sqlite" \
    DATABASE_USER="user" \
    DATABASE_PASSWORD="password"

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8000/api/users || exit 1

CMD ["node", "index.js"]
