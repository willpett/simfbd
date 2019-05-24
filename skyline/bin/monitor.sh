#!/bin/sh

find sims -type f | grep rb.log | xargs wc -l | grep -v 1002
