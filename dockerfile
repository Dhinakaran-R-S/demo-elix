# Base Elixir image with Alpine
FROM elixir:1.18-alpine

# Set environment variables
ENV MIX_ENV=prod \
    LANG=C.UTF-8 \
    MODE=web

# Install dependencies
RUN apk add --no-cache \
    build-base \
    git \
    nodejs \
    npm \
    inotify-tools \
    openssl

# Set working directory
WORKDIR /app

# Copy entire app
COPY . .

# Prepare CLI (in root) and Phoenix app (in /phoenix_app)
WORKDIR /app/phoenix_app

# Install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Get Phoenix deps & build assets
RUN mix deps.get && \
    npm install --prefix assets && \
    npm run deploy --prefix assets && \
    mix phx.digest && \
    mix compile

# Expose Phoenix port
EXPOSE 4000

# Final CMD based on MODE
WORKDIR /app

CMD ["/bin/sh", "-c", \
     "if [ \"$MODE\" = \"cli\" ]; then mix run demo.ex; \
      else cd phoenix_app && mix phx.server; fi"]
