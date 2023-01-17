FROM node:18-alpine

RUN mkdir /app
WORKDIR /app

COPY ./api .

RUN npm install

EXPOSE 3000

ENTRYPOINT ["node", "server.js"] 