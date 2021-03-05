# syntax=docker/dockerfile:1.2

# base
FROM ruby:3.0.0-alpine3.13 AS base
WORKDIR /app
RUN \
  --mount=type=cache,target=/var/cache/apk \
  apk add -U \
    build-base \
    git \
    nodejs \
    sqlite-dev \
    tzdata \
    yarn \
    ;

# bundle
FROM base AS bundle
COPY Gemfile Gemfile.lock /app/
RUN \
  --mount=type=cache,target=/app/vendor/cache \
  bundle install && \
  bundle cache

# yarn
FROM base AS node_modules
COPY package.json yarn.lock /app/
RUN \
  --mount=type=cache,target=/usr/local/share/.cache/yarn/v4 \
  yarn install

# main
FROM base
ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY $RAILS_MASTER_KEY
COPY --from=bundle /usr/local/bundle/ /usr/local/bundle/
COPY --from=node_modules /app/node_modules/ /app/node_modules/
COPY . /app/
EXPOSE 3000
CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
