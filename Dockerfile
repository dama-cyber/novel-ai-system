# Dockerfile for Novel AI System Server

FROM node:20-alpine

WORKDIR /app

# 复制 package 文件
COPY package*.json ./
COPY server/package*.json ./server/

# 为服务器安装依赖
WORKDIR /app/server
RUN npm ci --only=production

# 复制应用代码
WORKDIR /app
COPY . .

# 为客户端安装依赖（如果存在）
WORKDIR /app/server/client
# 如果客户端存在，则安装依赖
RUN if [ -f "package.json" ]; then npm ci --only=production; fi

# 暴露端口
EXPOSE 3000

# 启动命令
WORKDIR /app/server
CMD ["node", "server.js"]