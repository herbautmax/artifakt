FROM registry.artifakt.io/ruby:2.7

ARG CODE_ROOT=.

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

COPY --chown=www-data:www-data $CODE_ROOT/Gemfile* /var/www/html/

WORKDIR /var/www/html

# dependency management
RUN if [ -f Gemfile ]; then bundle install; fi

COPY --chown=www-data:www-data $CODE_ROOT /var/www/html

# copy the artifakt folder on root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN  if [ -d .artifakt ]; then cp -rp /var/www/html/.artifakt /.artifakt/; fi

# run custom scripts build.sh
# hadolint ignore=SC1091
RUN --mount=source=artifakt-custom-build-args,target=/tmp/build-args \
  if [ -f /tmp/build-args ]; then source /tmp/build-args; fi && \
  if [ -f /.artifakt/build.sh ]; then /.artifakt/build.sh; fi

CMD ["ruby", "-run", "-ehttpd", ".", "-p80"]
