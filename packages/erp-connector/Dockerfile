FROM node:20-alpine AS builder
WORKDIR /app

COPY package.json tsconfig.json ./
# Copy the standalone event-broker package so workspace:* resolves
COPY ../event-broker /event-broker

RUN npm install --legacy-peer-deps
COPY src ./src
RUN npm run build

FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package.json ./

EXPOSE 4001
CMD ["node", "dist/connector.js"]
