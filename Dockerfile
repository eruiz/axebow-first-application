FROM node:20-alpine as builder

# Update and upgrade the installed packages
RUN apk -U upgrade

# Install bash shell 
RUN apk add --no-cache bash

# Install vim
RUN apk add --no-cache vim


ENV NODE_ENV build

USER node
WORKDIR /home/node

COPY package*.json ./
RUN npm ci

COPY --chown=node:node . .

RUN npx prisma generate \
    && npm run build \
    && npm prune --omit=dev

# ---

FROM node:20-alpine

ENV NODE_ENV production

USER node
WORKDIR /home/node

COPY --from=builder --chown=node:node /home/node/package*.json ./
COPY --from=builder --chown=node:node /home/node/node_modules/ ./node_modules/
COPY --from=builder --chown=node:node /home/node/dist/ ./dist/
COPY --from=builder --chown=node:node /home/node/views/ ./views/
COPY --from=builder --chown=node:node /home/node/public/ ./public/

EXPOSE 3000

CMD ["node", "dist/main.js"]

