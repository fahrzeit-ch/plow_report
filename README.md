# PlowTrack

[![Build Status](https://www.travis-ci.com/stestaub/plow_report.svg?branch=master)](https://www.travis-ci.com/stestaub/plow_report)
[![Maintainability](https://api.codeclimate.com/v1/badges/11b9c19478d424769dcd/maintainability)](https://codeclimate.com/github/stestaub/plow_report/maintainability)

A simple tracking app to report drives and standby dates,

## Development

```
$ git clone (this repo)
```

cd into plow-report and run
```
$ bundle install
```

### Datebase
We depend on postgresql.

On Mac: Follow these instructions: https://gist.github.com/ibraheem4/ce5ccd3e4d7a65589ce84f2a3b7c23a3#installing

Then run

```
$ rails db:create
$ rails db:migrate
```

### Background jobs
We use resque for background job processing. Resque depends on redis so make sure you have a local instance of redis running.

On Mac:
```
$ brew install redis
```

```
$ redis-server /usr/local/etc/redis.conf
```

On ubuntu... TODO

### Run development server
Copy .env.local file and set the environment variables to your needs:

```
$ cp .env.local .env
```

Use the heroku cli to run the application locally. This will start the puma server and the resque workers

 ```
 $ heroku local:start
 ```