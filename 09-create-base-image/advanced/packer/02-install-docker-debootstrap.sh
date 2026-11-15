#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive
apt-get install -y docker.io debootstrap
