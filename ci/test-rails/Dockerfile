FROM pre-deps

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-client

RUN bundle --deployment --jobs 8 --retry 5 --without production
COPY ./ /app
COPY config/env.yml.sample /app/config/env.yml
