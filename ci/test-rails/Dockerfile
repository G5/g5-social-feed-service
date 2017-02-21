FROM pre-deps

RUN bundle --deployment --jobs 8 --retry 5 --without production

COPY ./ /app
