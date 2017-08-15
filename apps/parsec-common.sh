#!/bin/bash
case $(uname -i) in
  armv7l) export ARCH=arm
          ;;
  x86_64) export ARCH=amd64
          ;;
  *) export ARCH=x86
esac
