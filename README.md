# performance-tests-cmdstan
Performance testing tools for use with CmdStan

## "Install"

```
git clone --recursive https://github.com/stan-dev/performance-tests-cmdstan.git
```

## Test performance in current working directory

To test the performance of the current cmdstan et al working directory on, for example, @betanalpha's stat_comp_benchmarks model repo, you can run the following:
```
./runPerformanceTests.py -j8 stat_comp_benchmarks
```

`./runPerformanceTests.py --help` for more options.

## Cleaning
`make clean` will recursively remove all non-checked-in files from all submodules. `make revert` will bring cmdstan and its submodules back to the commit specified by the current commit of the top-level `performance-tests-cmdstan` repo.

## Testing one git commit against another
to test i.e. develop against a branch you've made on cmdstan,
```
./compare-git-hashes.sh develop <branch-name> stat_comp_benchmarks -j8 --runs 10
```
