#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
apt-get -qy update && 
    apt-get -qy -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" dist-upgrade &&
    apt-get -qy clean