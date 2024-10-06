FROM node:18 AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM node:18
WORKDIR /app
COPY --from=build /dist/package*.json ./
RUN npm install --production
COPY --from=build /dist ./
EXPOSE 3000
CMD ["npm", "run", "start"]