FROM alpine:3.5
MAINTAINER Jan Dudulski <jan@dudulski.pl>

ENV MIX_ENV prod
ENV DEBUG 1
ENV PORT 80
EXPOSE 80

RUN apk -U upgrade
RUN apk add curl wget bash
RUN apk add elixir
RUN apk add erlang-crypto erlang-ssl erlang-dev erlang-syntax-tools erlang-parsetools erlang-eunit

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY mix.* ./

RUN mix local.hex --force
RUN mix local.rebar --force

RUN mix deps.get
RUN mix compile

COPY config config/
COPY rel rel/
COPY lib lib/

RUN mix release --verbose --env=prod

RUN mkdir -p /opt/app
RUN cp _build/prod/rel/service/releases/0.1.0/service.tar.gz /opt/app/app.tar.gz

WORKDIR /opt/app
RUN tar -xzf app.tar.gz

# Cleanup
RUN rm -rf /var/cache/apk/*
RUN rm -rf /usr/src/app

CMD ["/opt/app/bin/app", "foreground"]
