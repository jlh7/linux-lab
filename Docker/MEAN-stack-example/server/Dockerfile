FROM node:17-slim
WORKDIR /usr/app

# Install dependencies and build the project.
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
EXPOSE 3030

# Run the web service on container startup.
CMD ["node", "dist/server.js"]
