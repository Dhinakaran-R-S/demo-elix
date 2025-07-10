FROM elixir:1.18-alpine
WORKDIR /app
COPY . .
RUN mix local.hex --force && \
    mix deps.get && \
    mix compile
CMD ["mix", "-S", "iex"]
