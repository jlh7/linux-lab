FROM node:18-slim AS build

WORKDIR /home/
COPY package.json package-lock.json ./

# Install dependencies and copy them to the container
COPY . .
RUN npm install

# Build the Angular application for production
RUN npm run build

# Configure the nginx web server
FROM nginx:1.17.1-alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build /home/dist/client/browser /usr/share/nginx/html

# Run the web service on container startup.
CMD ["nginx", "-g", "daemon off;"]
