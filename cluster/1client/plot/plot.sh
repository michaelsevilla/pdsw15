#!/bin/bash
tailplot -x 1 --field-format=1,date,HH:mm:ss --x-format=date,HH:mm:ss -s 2,3,4 -f nRequests,latency,avg --y2=2 creates.dat &
