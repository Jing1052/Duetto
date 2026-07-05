# Duetto — self-hosted listen-together player with a bring-your-own-AI companion.
# Node 24 for the built-in node:sqlite (used for the long-term listen archive).
FROM node:24-alpine

WORKDIR /app

# Install deps against the lockfile first for better layer caching.
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# App source (frontend + server). The data/ dir is gitignored and lives on a
# mounted volume at runtime (see DUETTO_DATA_DIR).
COPY . .

# Persistent data (SQLite db, settings.json, netease cookie, auth). Mount a
# volume here on the host/platform so it survives redeploys.
ENV DUETTO_DATA_DIR=/app/data
ENV PORT=4183
EXPOSE 4183

CMD ["npm", "start"]
