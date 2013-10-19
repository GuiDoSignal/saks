#!/bin/bash

## Fix all directories permissions (permission for anyone to navigate any directory)
find /opt/IBM /apps/wsadmin -user wasadmin -type d -exec chmod 0755 {} \;

## Firstly, grant reading to all files (owner can do anything, group and others can read)
find /opt/IBM /apps/wsadmin -user wasadmin -type f -exec chmod 0744 {} \;

## Then, remove from sensitive file types (owner can do anything, group can read, others do nothing)
find /opt/IBM /apps/wsadmin -user wasadmin -type f -iname "*.xml"        -exec chmod 0740 {} \;
find /opt/IBM /apps/wsadmin -user wasadmin -type f -iname "*.jsp"        -exec chmod 0740 {} \;
find /opt/IBM /apps/wsadmin -user wasadmin -type f -iname "*.php"        -exec chmod 0740 {} \;
find /opt/IBM /apps/wsadmin -user wasadmin -type f -iname "*.ini"        -exec chmod 0740 {} \;
find /opt/IBM /apps/wsadmin -user wasadmin -type f -iname "*.conf"       -exec chmod 0740 {} \;
find /opt/IBM /apps/wsadmin -user wasadmin -type f -iname "*.config"     -exec chmod 0740 {} \;
find /opt/IBM /apps/wsadmin -user wasadmin -type f -iname "*.props"      -exec chmod 0740 {} \;
find /opt/IBM /apps/wsadmin -user wasadmin -type f -iname "*.properties" -exec chmod 0740 {} \;
find /opt/IBM /apps/wsadmin -user wasadmin -type f -iname "*.prefs"      -exec chmod 0740 {} \;
find /opt/IBM /apps/wsadmin -user wasadmin -type f -iname "*.arm"        -exec chmod 0740 {} \;
find /opt/IBM /apps/wsadmin -user wasadmin -type f -iname "*.cer"        -exec chmod 0740 {} \;
find /opt/IBM /apps/wsadmin -user wasadmin -type f -iname "*.sth"        -exec chmod 0740 {} \;
find /opt/IBM /apps/wsadmin -user wasadmin -type f -iname "*.kdb"        -exec chmod 0740 {} \;
