# followr.club

Mass follow & profit w/ followers

[Working demo](https://followr.herokuapp.com)

## Development environment
A `Vagrantfile` is provided with the app, allowing to boot a self-contained development environment. Vagrant 1.7+ is required to provision the VM correctly.

The virtual machine can be spun up with `vagrant up` – after a successful boot, the application will be available at `http://followr.dev/` (assuming that the project has been cloned in a directory called `followr`, otherwise it will be `#{project_dir}.dev`).

The application server can be wound down by pressing `Ctrl + C` in the console or the session can be left running in the background pressing `Ctrl + A` and then `d` (for other keyboard shortcuts, see [gnu screen manual](http://www.gnu.org/software/screen/manual/screen.html#Commands)).

On the first run, the virtual machine will be automatically provisioned with all the necessary dependencies and packages.

On every restart (`vagrant halt` + `vagrant up`) one of the provisioning scripts will check for the necessity of installing dependencies or running DB migrations and will do that automatically.

## Executing commands in the VM
The environment comes bundled with `vagrant-plugin-exec`, that allows you to conveniently run commands in the guest environment, with proper prefixing (`foreman run` and/or `bundle exec` where necessary).

E.g.
```shell
$ vagrant exec rails g model MyModel
$ vagrant exec rake db:migrate
$ vagrant exec bundle install
```

### Note for Windows users

GIT by default replaces LF returns (Unix-style) with CRLF (Windows-style) and vice-versa. This may cause some errors when running the provisioning scripts.

Probably the easiest way to fix this is to disable the conversion for the checked-out files:

```shell
$ git config --global core.autocrlf input
```

## `.env` files

The project comes with a file named `.env.development` that contains the non-sensitive configuration values to run the project in development inside the VM (e.g. development database, Redis instance).

A second file, named `.env`, must be placed at the root of the repository, containing the sensitive configuration values for the system (e.g. Twitter credentials). The file contains sensitive informations (API keys etc.), thus its contents must never be committed in the repository.

General structure of `.env.development` is the following:

```shell
# General configuration
RAILS_ENV="development"     # or "production"

# Application Database
APP_DB="app"
APP_DB_USER="app"
APP_DB_PASSWORD="app"
APP_DB_HOST="localhost"

DOMAIN="http://followr.dev"

# Redis configuration
REDIS_URL="redis://127.0.0.1:6379/1"

# Don't run follow/unfollow workers, comment to enable them
WORKERS_DRY_RUN=1
```

While `.env` should contain:

```shell
# Postgres setup
APP_DB=""
APP_DB_USER=""
APP_DB_PASSWORD=""
APP_DB_HOST="localhost"

DOMAIN="http://followr.dev"

# Redis configuration
REDIS_URL="redis://127.0.0.1:6379/1"

# Twitter application key/secret
TWITTER_CONSUMER_KEY=""
TWITTER_CONSUMER_SECRET=""

# Airbrake API key
AIRBRAKE_API_KEY=""

# Encryption key
APPLICATION_SECRET_KEY=""

# Rails secret
SECRET_KEY_BASE=""
```

## Provisioning scripts

The `provision/` directory contains several scripts that can automatically provision a Linux server running Ubuntu 14.04. They are the same scripts that get run by Vagrant when provisioning a new VM, thus a general idea about the expected order of execution and arguments can be inferred by reading the `Vagrantfile`.

All the scripts take as first argument the domain on which the application is run (optional on `application.sh`) and as second (optional) argument the project root (when not set, it will be inferred to be the root of the cloned repository).

- `provision/system.sh` is the "global" provisioning script and must be run once as root.
- `provision/application.sh` must be run as an unprivileged user after each application update.

The application server can be started with `foreman start -e .env,.env.$RAILS_ENV` in the app directory or exporting the configuration to another process management format through [`foreman export`](http://ddollar.github.io/foreman/#EXPORTING)`.

The scripts will install globally:

- Ruby 2.2 from [Brightbox PPA](https://launchpad.net/~brightbox/+archive/ubuntu/ruby-ng)
- Node.js from [Chris Lea PPA](https://launchpad.net/~chris-lea/+archive/ubuntu/node.js)
- PostgreSQL 9.3 + contrib packages from Ubuntu repositories
- Redis server

Example usage in production:

```shell
$ sudo provision/system.sh followr.club
$ provision/application.sh
$ foreman start -e .env,.env.production
```
