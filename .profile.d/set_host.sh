#!/bin/bash

if [[ -z "${HEROKU_APP_NAME}" ]]; then
  export HOST="app.fahrzeit.ch"
else
  export HOST=${HEROKU_APP_NAME}.herokuapp.com
fi