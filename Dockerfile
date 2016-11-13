FROM ruby:2.3.0

RUN apt-get update -qq && apt-get install -y build-essential
RUN apt-get install -y libpq-dev
RUN apt-get install -y nodejs
ENV APP_HOME /followr
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
VOLUME $APP_HOME
EXPOSE 3000
ADD Gemfile* $APP_HOME/
RUN bundle install

ADD . $APP_HOME
