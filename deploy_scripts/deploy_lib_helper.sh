#!/bin/bash

function console_message {
  tput setaf 2
  echo "|-------- $1 -------|"
  tput sgr0
}

function console_error {
  tput setaf 1
  echo ">-------- $1 -------<"
  tput sgr0
}

function console_warning {
  tput setaf 5
  echo "($1)"
  tput sgr0
}