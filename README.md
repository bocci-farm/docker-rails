# RailsのDockerイメージの作り方

## 1. ローカル環境にRailsをインストール

```console
% rails new app
```

## 2. Dockerfileの作成

```dockerfile:docker/app/Dockerfile
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
```

## 3. .dockerignoreの用意

不要なファイルをイメージに含めないために.dockerignoreを作成します

```:app/.dockerignore
/.bundle/
/.dockerignore
/.git/
/.git*
/.ruby-version
/README.md
/config/master.key
/log/
/node_modules/
/storage/
/tmp/
/vendor/bundle/
```

## 4. Dockerイメージのビルド

```console
% DOCKER_BUILDKIT=1 docker image build --build-arg RAILS_MASTER_KEY=<RAILS_MASTER_KEY> -t boccifarm/rails:6.1.3-ruby3.0.0-alpine3.13 -f docker/app/Dockerfile app
```

## 5. Dockerイメージのプッシュ

```
% docker login
% docker image push boccifarm/rails:6.1.3-ruby3.0.0-alpine3.13
```
