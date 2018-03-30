#!/bin/bash
set -e -x

usage() {
    echo "This will clean all repos involved! Use only on a clean checkout."
    echo "$0 <git-hash-1> <git-hash-2> <directories of models> '<extra args for runPerformanceTests.py>''"
}

clean_checkout() {
    git checkout "$1"
    git submodule update --recursive
    dirty=$(git status --porcelain)
    if [ "$dirty" != "" ]; then
        echo "ERROR: Git repo isn't clean - I'd recommend you make a separate recursive clone of CmdStan for this."
        exit
    fi
}

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    usage
    exit
fi

clean_checkout "$1"
./runPerformanceTests.py -j8 --runj 5 --overwrite-golds $4 $3

git submodule foreach --recursive git clean -xffd
make clean-all
for i in performance.*; do
    mv $i "${1}_${i}"
done

git checkout $2
git submodule update --recursive
./runPerformanceTests.py -j8 --runj 5 --check-golds-exact 1e-8 $4 $3
python comparePerformance.py "${1}_performance.csv" performance.csv
