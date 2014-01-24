#!/bin/bash

function console_message {
  tput setaf 2
  echo "|-------- $1 -------|"
  tput sgr0
}