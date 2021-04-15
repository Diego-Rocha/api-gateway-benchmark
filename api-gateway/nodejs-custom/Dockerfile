FROM node:14.16-alpine
COPY package*.json ./
RUN npm install

COPY index.js .
CMD [ "node", "index.js" ]