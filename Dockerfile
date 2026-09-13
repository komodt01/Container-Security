# Use a minimal base image
FROM node:20-slim

# Set working directory
WORKDIR /app

# Copy package files first for dependency-layer caching
COPY package*.json ./

# Install production dependencies from the lock file
RUN npm ci --omit=dev

# Copy application code
COPY app.js ./

# Run as a non-root user
RUN useradd --create-home --shell /usr/sbin/nologin myappuser
USER myappuser

# Document the application port
EXPOSE 3000

# Start the application
CMD ["node", "app.js"]
