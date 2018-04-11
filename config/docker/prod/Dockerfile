FROM ruby:2.4.2-jessie
MAINTAINER Noosfero Development Team <noosfero-dev@listas.softwarelivre.org>

LABEL Description="This dockerfile builds a noosfero production environment."

EXPOSE 80

ENV RAILS_ENV production
RUN apt-get update && apt-get install -y sudo cron nodejs postgresql-client

VOLUME /noosfero/public/image_uploads
VOLUME /noosfero/articles
VOLUME /noosfero/public/thumbnails
VOLUME /noosfero/public/user_themes

WORKDIR /noosfero
ADD Gemfile /noosfero/Gemfile
WORKDIR /noosfero
RUN bundle install

ADD . /noosfero/

ADD /public /noosfero/public/

COPY ./config/docker/prod/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/noosfero/script/production", "run"]
