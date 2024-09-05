# Dockerfile for mean-server

# Sử dụng Node.js phiên bản 20
FROM node:20

# Đặt thư mục làm việc trong container
WORKDIR /usr/src/app

# Sao chép file package.json và package-lock.json
COPY package*.json ./

# Cài đặt các dependencies
RUN npm install

# Sao chép toàn bộ mã nguồn của ứng dụng vào container
COPY . .

# Expose cổng mà ứng dụng sẽ chạy
EXPOSE 3030

# Chạy ứng dụng
CMD ["node", "server.js"]
