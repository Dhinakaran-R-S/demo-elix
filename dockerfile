# ---------- Stage 1: Build ----------
FROM elixir:1.18-alpine AS build

# Install required packages
RUN apk add --no-cache build-base git nodejs npm

# Set working directory
WORKDIR /app

# Set environment
ENV MIX_ENV=prod

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy mix files and fetch deps
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only prod

# Copy application code
COPY lib lib
COPY priv priv

# Compile and build release
RUN mix compile
RUN mix release

# ---------- Stage 2: Runtime ----------
FROM alpine:3.19 AS app

# Install runtime dependencies
RUN apk add --no-cache libstdc++ openssl ncurses

# Set working directory
WORKDIR /app

# Copy release from the build stage
COPY --from=build /app/_build/prod/rel/phoenix_app ./

# Expose Phoenix port
EXPOSE 4000

# Default start command
CMD ["bin/phoenix_app", "start"]
