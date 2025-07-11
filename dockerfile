# =============================
# Stage 1: Build Elixir + Phoenix
# =============================
FROM elixir:1.15-alpine AS build

# Install build tools
RUN apk add --no-cache build-base git nodejs npm python3

# Set working directory
WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && mix local.rebar --force

# Copy mix files
COPY mix.exs mix.lock ./
COPY config config

# Install dependencies
RUN mix deps.get --only prod

# Copy app source
COPY lib lib
COPY priv priv

# Build assets
WORKDIR /app/assets
COPY assets ./
RUN npm install && npm run deploy
RUN mix phx.digest

# Compile project
WORKDIR /app
RUN MIX_ENV=prod mix compile

# Generate release
RUN MIX_ENV=prod mix release

# =============================
# Stage 2: Release Container
# =============================
FROM alpine:3.19 AS app

# Install runtime dependencies
RUN apk add --no-cache libstdc++ openssl ncurses-libs

# Set app working directory
WORKDIR /app

# Set environment variables
ENV MIX_ENV=prod \
    LANG=en_US.UTF-8 \
    PHX_SERVER=true \
    PORT=4000

# Copy release from build
COPY --from=build /app/_build/prod/rel/phoenix_app ./

# Expose Phoenix default port
EXPOSE 4000

# Run the Phoenix app
CMD ["bin/phoenix_app", "start"]
