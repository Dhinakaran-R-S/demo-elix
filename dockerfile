FROM elixir:1.18-alpine

# Install system dependencies
RUN apk add --no-cache build-base git nodejs npm inotify-tools

WORKDIR /app

# Copy all files
COPY . .

# Install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Get dependencies for root mix.exs (if any) and Phoenix app
WORKDIR /app/phoenix_app
RUN mix deps.get && \
    npm install --prefix assets && \
    mix compile

# Return to root folder
WORKDIR /app

# CLI vs Phoenix: Choose based on ENV
ENV MODE=cli

CMD ["/bin/sh", "-c", \
     "if [ \"$MODE\" = \"cli\" ]; then mix run demo.ex; \
      else cd phoenix_app && mix phx.server; fi"]
