# Stage 1: Build Elixir + assets
FROM elixir:1.18-alpine AS build

# Install required packages
RUN apk add --no-cache build-base nodejs npm git python3

# Set working directory
WORKDIR /app/phoenix/phoenix_app

# Install hex & rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy mix files
COPY mix.exs /app/phoenix/phoenix_app

# Fetch dependencies
RUN mix deps.get --only prod

# Copy the rest of the project
COPY . .

# Compile the project
RUN MIX_ENV=prod mix compile

# Install Node dependencies & build assets
WORKDIR /app/assets

RUN mix compile
RUN mix phx.digest

# Digest assets
WORKDIR /app
# RUN MIX_ENV=prod mix phx.digest

# Stage 2: Create minimal release image
FROM alpine:3.19 AS app

# Install runtime dependencies
RUN apk add --no-cache libstdc++ openssl ncurses-libs

WORKDIR /app

# Copy release from build stage
# COPY --from=build /app/_build/prod/rel/* ./
# COPY --from=build /app/priv/static ./priv/static

# Set environment variables (configure for your app)
ENV MIX_ENV=prod \
    PHX_SERVER=true \
    PORT=4000

# Expose Phoenix default port
EXPOSE 4000

# Run the Phoenix app
CMD ["mix","phx.server"]