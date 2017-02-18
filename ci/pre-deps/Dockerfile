FROM g5search/ruby-base:v1.0.0

ENV LANG=C.UTF-8 \
    RACK_ENV=production \
    RAILS_ENV=production

RUN apt-get update && apt-get install -y \
# Up-to-date certificate trust info
    ca-certificates \
# Gems with C extensions often need this
    libffi-dev && \
# Try and trim down this image size a little bit
    apt-get clean

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
COPY ci/pre-build/gemfury.token /app/gemfury.token
RUN bundle config gem.fury.io $(cat /app/gemfury.token)
