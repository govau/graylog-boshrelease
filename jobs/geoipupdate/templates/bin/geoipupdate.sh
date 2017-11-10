#!/bin/bash

set -eux

JOB_NAME=geoipupdate
JOB_DIR=/var/vcap/jobs/$JOB_NAME
LOG_DIR=/var/vcap/sys/log/$JOB_NAME
STORE_DIR=/var/vcap/store/$JOB_NAME

mkdir -p $LOG_DIR
chown vcap:vcap $LOG_DIR

{
  echo "$(date) running geoipupdate"

  # graylog looks for the geoip database at
  # /etc/graylog/server/GeoLite2-City.mmdb, so we download the db
  # to the bosh standard location and add a symlink for graylog

  mkdir -p $STORE_DIR
  mkdir -p /etc/graylog
  ln -sf $STORE_DIR /etc/graylog/server | true

  chown vcap -R $STORE_DIR

  chpst -u vcap:vcap /var/vcap/packages/geoipupdate/bin/geoipupdate \
    -v \
    -f $JOB_DIR/etc/GeoIP.conf \
    -d $STORE_DIR

  exit 0
} >>$LOG_DIR/$JOB_NAME.stdout.log \
  2>>$LOG_DIR/$JOB_NAME.stderr.log
