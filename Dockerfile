# syntax=docker/dockerfile:1

# --- Dependencies layer (installs only prod deps for speed & security)
FROM node:20-alpine AS deps
WORKDIR /app

# Copy manifest(s) first to leverage Docker layer caching
COPY package.json package-lock.json* ./

# Install production dependencies (falls back to npm install if no lockfile)
RUN if [ -f package-lock.json ]; then \
      npm ci --omit=dev; \
    else \
      npm install --omit=dev; \
    fi

# --- Runtime layer
FROM node:20-alpine AS runner
ENV NODE_ENV=production
WORKDIR /app

# Copy node_modules from deps and then the app source
COPY --chown=node:node --from=deps /app/node_modules ./node_modules
COPY --chown=node:node . .

# Drop privileges
USER node

# Your app should listen on PORT (default 3000)
ENV PORT=3000
EXPOSE 3000

# Use your package.json "start" script (recommended)
CMD ["npm", "start"]