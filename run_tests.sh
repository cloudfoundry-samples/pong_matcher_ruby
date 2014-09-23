#!/bin/bash

set -ex

docker build -t andrewbruce/pongruby .
docker run andrewbruce/pongruby
