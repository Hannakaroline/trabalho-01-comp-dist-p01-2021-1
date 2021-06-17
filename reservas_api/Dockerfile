# syntax=docker/dockerfile:1
FROM ruby:2.6.6
RUN apt-get update -qq && apt-get install -y postgresql-client
WORKDIR /reservas_api
COPY . .
RUN gem install bundler
RUN bash -l -c "bundle install"

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]