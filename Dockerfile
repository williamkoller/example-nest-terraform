# Base
FROM --platform=linux/amd64 node:20.11.1-alpine AS base

WORKDIR /app

COPY --chown=node:node package*.json ./
COPY --chown=node:node nest-cli.json ./

# Builder
FROM base AS builder

RUN npm ci

COPY --chown=node:node . .

USER node

FROM base AS build

COPY --chown=node:node --from=builder /app/node_modules ./node_modules

COPY --chown=node:node . .

RUN npm run build

RUN npm ci --omit=dev && npm cache clean --force

ENV NODE_ENV production

USER node

# Production
FROM base AS production

COPY --chown=node:node --from=build /app/node_modules ./node_modules
COPY --chown=node:node --from=build /app/dist ./dist

EXPOSE 3000

CMD [ "npm", "run", "start:prod" ]