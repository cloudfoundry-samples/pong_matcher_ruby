#!/bin/bash

set -ex

exec rake docker:test
