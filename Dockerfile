FROM bitwalker/alpine-elixir:1.9.0

EXPOSE 80
ENV PORT=80

ENV MIX_ENV=prod


COPY . .
RUN mix deps.get --only prod
RUN mix compile

CMD mix run --no-halt
