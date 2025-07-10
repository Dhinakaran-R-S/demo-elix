# base Elixir image with build tools
FROM elixir:1.15.0-erlang-26.0.2-alpine-3.18.0 AS build

# install build dependencies
RUN apk add --no-cache build-base git npm python3

# install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set working directory
WORKDIR /app

# set environment
ENV MIX_ENV=prod

# cache deps
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only prod
RUN mix deps.compile

# build assets
COPY assets assets
RUN cd assets && npm install && npm run deploy
RUN mix phx.digest

# build project
COPY lib lib
COPY priv priv
RUN mix compile
RUN mix release

# Final stage: slim production image
FROM alpine:3.18 AS app

RUN apk add --no-cache libstdc++ openssl ncurses-libs

WORKDIR /app

COPY --from=build /app/_build/prod/rel/phoenix_app ./

ENV HOME=/app \
    MIX_ENV=prod \
    LANG=en_US.UTF-8

CMD ["bin/phoenix_app", "start"]
