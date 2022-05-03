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

# run with the default optimization level
cd cmdstan; make clean-all; make -j4 build;
if [ -n "$3" ] ; then
    rm cmdstan/bin/stanc
    cp "$3" cmdstan/bin/stanc
fi
make -j4 examples/bernoulli/bernoulli; ./bin/stanc --version; cd ..
./runPerformanceTests.py --overwrite-golds $1

for i in performance.*; do
    mv $i "reference_${i}"
done

# run develop version of cmdstan with the nightly stanc3 binary and STANCFLAGS set to the flags provided in the second commandline argument
echo "STANCFLAGS += $2" >> cmdstan/make/local
./runPerformanceTests.py --check-golds-exact 1e-8 $1 --scorch-earth && ./comparePerformance.py "reference_performance.csv" performance.csv csv
