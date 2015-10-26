#!/bin/sh

if ! which bundle; then
  echo "Bundler gem is required. Run '[sudo] gem install bundler' to install it."
  exit 1
fi

bundle --path=.bundle --binstubs=.bin --verbose
