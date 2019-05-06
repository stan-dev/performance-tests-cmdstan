#!/bin/bash

usage() {
    echo "=====!!!WARNING!!!===="
    echo "This will clean all repos involved! Use only on a clean checkout."
    echo "$0 <git-hash-1> <git-hash-2> <directories of models> <extra args for runPerformanceTests.py>'"
    echo "(those last extra args are in quotes)"
}

write_makelocal() {
    echo "CXXFLAGS += -march=native" > make/local
}

clean_checkout() {
    make revert
	
	cd cmdstan
	
	if [[ "$1" == "PR-"* ]] ; then
        prNumber=$(echo $1 | cut -d "-" -f 2)
		git fetch https://github.com/stan-dev/cmdstan +refs/pull/$prNumber/merge:refs/remotes/origin/pr/$prNumber/merge
        git checkout refs/remotes/origin/pr/$prNumber/merge
	else
        if [[ "$1" == "downstream_tests" ]] ; then
            git checkout develop
        elif [[ "$1" == "downstream_hotfix" ]] ; then
            git checkout master
        else
		    git checkout "$1"
        fi
	fi

    git submodule update --init --recursive
    cd ..
    make clean
    cd cmdstan
    dirty=$(git status --porcelain)
    if [ "$dirty" != "" ]; then
        echo "ERROR: Git repo isn't clean - I'd recommend you make a separate recursive clone of CmdStan for this."
        exit
    fi
    write_makelocal
    git status
    cd ..
}

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    usage
    exit
fi

set -e -x

clean_checkout "$1"
./runPerformanceTests.py --overwrite-golds ${@:3:99}

for i in performance.*; do
    mv $i "${1}_${i}"
done

clean_checkout "$2"
./runPerformanceTests.py --check-golds-exact 1e-8 ${@:3:99}

./comparePerformance.py "${1}_performance.csv" performance.csv
