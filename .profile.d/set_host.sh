#!/bin/bash

if [[ -z "${HEROKU_APP_NAME}" ]] && [[ -z "${HOST}" ]]; then
  export HOST="app.fahrzeit.ch"
elif [[ -z "${HOST}" ]]; then
  export HOST=${HEROKU_APP_NAME}.herokuapp.com
fi