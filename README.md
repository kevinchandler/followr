# Followr.club

Mass follow & profit w/ followers

[Working demo](https://followr.herokuapp.com)

## Development environment
A `Dockerfile` and `docker-compose.yml` are provided with the app, allowing to boot a self-contained development environment.


```shell
$ docker-compose run web rails g model MyModel
$ docker-compose run web rake db:migrate
$ docker-compose run web bundle install
```

## `.env` file

The project comes with a file named `.env.example` that should be renamed to `.env`

General structure of `.env` is the following:

```shell
RAILS_ENV="development"

# Application
DOMAIN=localhost:3000

# Database
DB_NAME=
DB_USER=
DB_PASSWORD=
DB_HOST=
DB_PORT=


# Redis configuration
REDIS_URL="redis://127.0.0.1:6379/1"

# Don't run follow/unfollow workers, comment to enable them
WORKERS_DRY_RUN=1

TWITTER_CONSUMER_KEY=''
TWITTER_CONSUMER_SECRET=''
```
