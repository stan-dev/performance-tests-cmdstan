#!/bin/bash

usage() {
    echo "This won't clean anything, it will use whatever is in the cmdstan submodule even if it's dirty."
    echo "Pass the arguments to runPerformanceTests.py in quotes as the first argument."
    echo "Pass the alternative compiler binary path as the second argument."
}

if [ -z "$1" ] || [ -z "$2" ] ; then
    usage
    exit
fi

set -e -x

rm cmdstan/bin/stanc || true
./runPerformanceTests.py --overwrite-golds $1

for i in performance.*; do
    mv $i "${2}_${i}"
done

cp "$2" cmdstan/bin/stanc
make clean-models
./runPerformanceTests.py --check-golds-exact 2e-8 $1 && ./comparePerformance.py "${2}_performance.csv" performance.csv
