FROM node:19-alpine
WORKDIR /app
COPY . .
EXPOSE 3000
RUN npm install
ENV NODE_ENV=docker
CMD ["npm", "start"]
