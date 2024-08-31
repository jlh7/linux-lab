FROM node:18-slim AS build

WORKDIR /usr/src/app
COPY package.json package-lock.json ./

# Install dependencies and copy them to the container
RUN npm install
COPY . .

# Build the Angular application for production
RUN npm run build --omit=dev

# Configure the nginx web server
FROM nginx:stable-alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build /usr/src/app/dist/client /usr/share/nginx/html

# Run the web service on container startup.
CMD ["nginx", "-g", "daemon off;"]
