# Use Elixir Alpine image
FROM elixir:1.18-alpine

# Install system dependencies
RUN apk add --no-cache \
  build-base \
  git \
  nodejs \
  npm \
  inotify-tools \
  postgresql-client

# Set environment
ENV MIX_ENV=dev \
    LANG=C.UTF-8 \
    PORT=4000

# Set working directory
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy only the mix files and deps to cache them
COPY mix.exs mix.lock ./
COPY config ./config

# Fetch dependencies
RUN mix deps.get

# Copy the entire application
COPY . .

# Install JS dependencies
RUN cd assets && npm install

# Expose the Phoenix port
EXPOSE 4000

# Default command to run Phoenix
CMD ["mix", "phx.server"]
