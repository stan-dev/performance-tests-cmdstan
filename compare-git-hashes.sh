#!/bin/bash -e

usage() {
    echo "=====!!!WARNING!!!===="
    echo "This will clean all repos involved! Use only on a clean checkout."
    echo "$0 \"<arguments to runPerformanceTests.py>\" <reference-cmdstan-git-hash> <cmdstan_pr_or_hash> <stan_pr> <math_pr> <os>"
}

write_makelocal() {
    echo "CXXFLAGS += -march=native" > make/local
}

clean_checkout() {
    make revert

    cd cmdstan

    #Checkout CmdStan
    if [[ "$1" == "PR-"* ]] ; then
        prNumber=$(echo $1 | cut -d "-" -f 2)
        git fetch https://github.com/stan-dev/cmdstan +refs/pull/$prNumber/merge:refs/remotes/origin/pr/$prNumber/merge
        git checkout refs/remotes/origin/pr/$prNumber/merge
    else
        git fetch && git checkout "$1" && git pull origin "$1"
    fi
    git reset --hard HEAD
    git clean -xffd
    git submodule update --init --recursive

    #Checkout stan
    cd stan
    if [[ "$2" == "PR-"* ]] ; then
        prNumber=$(echo $2 | cut -d "-" -f 2)
        git fetch https://github.com/stan-dev/stan +refs/pull/$prNumber/merge:refs/remotes/origin/pr/$prNumber/merge
        git checkout refs/remotes/origin/pr/$prNumber/merge
    elif [ "$2" != "false" ] ; then
        git fetch && git checkout "$2" && git pull origin "$2"
    fi
    git reset --hard HEAD
    git clean -xffd
    cd ..

    #Checkout math
    pushd stan/lib/stan_math
    if [[ "$3" == "PR-"* ]] ; then
        prNumber=$(echo $3 | cut -d "-" -f 2)
        git fetch https://github.com/stan-dev/math +refs/pull/$prNumber/merge:refs/remotes/origin/pr/$prNumber/merge
        git checkout refs/remotes/origin/pr/$prNumber/merge
    elif [ "$3" != "false" ] ; then
        git fetch && git checkout "$3" && git pull origin "$3"
    fi
    git reset --hard HEAD
    git clean -xffd
    popd

    cd ..
    make clean
    cd cmdstan
    dirty=$(git status --porcelain)
    #if [ "$dirty" != "" ]; then
    #    echo "ERROR: Git repo isn't clean - I'd recommend you make a separate recursive clone of CmdStan for this."
    #    exit
    #fi
    write_makelocal
    git status
    cd ..
}

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    usage
    exit
fi

set -e -x

# First checkout the first arg cmdstan hash, assuming stan and math are as specified
# by that cmdstan commit
clean_checkout "$2" "false" "false"
NAME1=$6"_reference-`date "+%y-%h-%m-%s"`"
./runPerformanceTests.py --overwrite-golds $1 --name="$NAME1"

clean_checkout "$3" "$4" "$5"
NAME2=$6"_performance"
./runPerformanceTests.py --check-golds-exact 1e-8 $1 --name="$NAME2"

./comparePerformance.py "$NAME1.csv" "$NAME2.csv" $6

