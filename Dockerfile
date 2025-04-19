# Use a minimal base image
FROM node:20-slim

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy application code
COPY app.js ./

# Run as non-root user
RUN useradd -m myappuser
USER myappuser

# Expose port
EXPOSE 3000

# Start the app
CMD ["node", "app.js"]
