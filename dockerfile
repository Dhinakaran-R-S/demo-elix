# Use Elixir image with Alpine base
FROM elixir:1.18-alpine AS build

# Install dependencies
RUN apk add --no-cache build-base npm git curl nodejs

# Set working directory
WORKDIR /app

# Set environment
ENV MIX_ENV=prod

# Copy mix files and install dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get --only prod

# Copy source files
COPY lib lib
COPY priv priv

# Compile the project
RUN mix compile

# Create release
RUN mix release

# Final runtime stage
FROM alpine:3.19 AS app

RUN apk add --no-cache libstdc++ openssl ncurses

# Copy release from build stage
COPY --from=build /app/_build/prod/rel/phoenix_app ./

# Expose Phoenix default port
EXPOSE 4000

# Start the server
CMD ["bin/phoenix_app", "start"]
