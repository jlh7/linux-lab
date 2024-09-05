# Dockerfile for mean-client

# Bước 1: Sử dụng image Node.js để xây dựng ứng dụng Angular
FROM node:20 AS build

# Đặt thư mục làm việc trong container
WORKDIR /usr/src/app

# Sao chép file package.json và package-lock.json
COPY package*.json ./

# Cài đặt các dependencies
RUN npm install

# Sao chép toàn bộ mã nguồn của ứng dụng vào container
COPY . .

# Xây dựng ứng dụng Angular
RUN npm run build --prod

# Bước 2: Sử dụng image Nginx để phục vụ ứng dụng Angular
FROM nginx:alpine

# Sao chép các file được xây dựng từ bước trước vào thư mục Nginx mặc định
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /usr/src/app/dist/mean-client/browser /usr/share/nginx/html

# Expose cổng 80 để phục vụ ứng dụng
EXPOSE 80

# Khởi động Nginx
CMD ["nginx", "-g", "daemon off;"]
