FROM pre-deps

RUN bundle --deployment --without development test --path vendor/cache

COPY ./ /app
