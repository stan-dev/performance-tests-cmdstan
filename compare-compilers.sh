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
# cd cmdstan; make -j4 examples/bernoulli/bernoulli; cd ..
cd cmdstan; make -j4 build; cd ..
NAME1="reference-`date "+%y-%h-%m-%s"`"
./runPerformanceTests.py --overwrite-golds $1 --name="$NAME1"

cp "$2" cmdstan/bin/stanc
NAME2="comparison-`date "+%y-%h-%m-%s"`"
./runPerformanceTests.py --check-golds-exact 1e-8 $1 --scorch-earth --name="$NAME2"
./comparePerformance.py "$NAME1.csv" "$NAME2.csv"
