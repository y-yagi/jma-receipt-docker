#!/bin/bash

service jma-receipt restart

tail -f /var/log/dmesg
