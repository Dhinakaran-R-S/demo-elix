# Use the official Elixir image as base
FROM elixir:1.15-alpine AS build

# Install build dependencies
RUN apk add --no-cache build-base npm git python3

# Set build ENV
ENV MIX_ENV=prod

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Create app directory
WORKDIR /app

# Copy mix files
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
RUN mkdir config

# Copy config files
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

# Copy priv, lib, assets
COPY priv priv
COPY lib lib
COPY assets assets

# Install npm dependencies and build assets
WORKDIR /app/assets
RUN npm ci --only=production
RUN npm run build
WORKDIR /app

# Compile assets and build release
RUN mix phx.digest
RUN mix release

# Start a new build stage for runtime
FROM alpine:3.18 AS runtime

# Install runtime dependencies
RUN apk add --no-cache openssl ncurses-libs

# Create app user
RUN addgroup -g 1000 -S app && \
    adduser -S app -u 1000 -G app

# Create app directory
WORKDIR /app

# Copy the built application from build stage
COPY --from=build --chown=app:app /app/_build/prod/rel/myapp ./

# Switch to app user
USER app

# Set environment variables
ENV MIX_ENV=prod
ENV PORT=4000
ENV PHX_HOST=0.0.0.0

# Expose port
EXPOSE 4000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:4000/health || exit 1

# Start the application
CMD ["./bin/myapp", "start"]