# =============================
# Stage 1: Build Elixir + Phoenix
# =============================
FROM elixir:1.15-alpine AS build

# Install build tools
RUN apk add --no-cache build-base git nodejs npm python3

# Set working directory to phoenix app
WORKDIR /app

# Install Hex & Rebar
RUN mix local.hex --force && mix local.rebar --force

# Copy mix files
COPY phoenix/phoenix_app/mix.exs phoenix/phoenix_app/mix.lock ./
COPY phoenix/phoenix_app/config ./config

# Fetch deps
RUN mix deps.get --only prod

# Copy rest of the Phoenix app
COPY phoenix/phoenix_app/lib ./lib
COPY phoenix/phoenix_app/priv ./priv
COPY phoenix/phoenix_app/assets ./assets

# Build frontend assets
WORKDIR /app/assets
RUN npm install && npm run deploy

# Back to root and digest
WORKDIR /app
RUN MIX_ENV=prod mix phx.digest

# Compile and release
RUN MIX_ENV=prod mix compile
RUN MIX_ENV=prod mix release

# =============================
# Stage 2: Minimal runtime container
# =============================
FROM alpine:3.19 AS app

RUN apk add --no-cache libstdc++ openssl ncurses-libs

WORKDIR /app

# Set environment
ENV MIX_ENV=prod \
    LANG=en_US.UTF-8 \
    PHX_SERVER=true \
    PORT=4000

# Replace `phoenix_app` with your actual app name in mix.exs if different
COPY --from=build /app/_build/prod/rel/phoenix_app ./

EXPOSE 4000

# Launch the Phoenix server
CMD ["bin/phoenix_app", "start"]
