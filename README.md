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
to test e.g. develop against a branch you've made on cmdstan,
```
./compare-git-hashes.sh "stat_comp_benchmarks -j8 --runs 10 <other options to runPerformanceTests.py>" <Baseline CmdStan hash/branch/PR-???> <CmdStan hash for comparison run> <Stan hash for comparison run> <Math hash for comparison run>
```

All of these take pull request numbers, so to test stan-dev/math#1244 against develop (for example) you can run:
```
./compare-git-hashes.sh example-models/bugs_examples/vol2/schools/ develop develop false d013e55
```
Here the false could be replaced with `develop` - just says to use the Stan hash associated with the CmdStan hash, in this case `develop`.

The script will then check out and pull all of these commits, branches, or PRs from stan-dev. It should print out which commit hashes it ends up on; please check that these are correct as the script is new. For PRs, you will see an unfamiliar hash that GitHub creates to store the result of the merge of the PR into the base branch the PR is against.

## Jenkins Job Usage

The [Custom Jenkins](https://jenkins.mc-stan.org/job/CmdStan%20Performance%20Tests/job/Custom/) job has the following parameters:  
```
    string(defaultValue: 'develop', name: 'cmdstan_origin_pr', description: "CmdStan hash/branch to base hash/branch")
    string(defaultValue: '', name: 'cmdstan_pr', description: "CmdStan hash/branch to compare against")
    string(defaultValue: '', name: 'stan_pr', description: "Stan PR to test against. Will check out this PR in the downstream Stan repo.")
    string(defaultValue: '', name: 'math_pr', description: "Math PR to test against. Will check out this PR in the downstream Math repo.")
    string(defaultValue: '', name: 'make_local', description: "Make/file contents")
    booleanParam(defaultValue: true, name: 'run_windows', description: "True/False to run tests on windows")
    booleanParam(defaultValue: true, name: 'run_linux', description: "True/False to run tests on linux")
    booleanParam(defaultValue: true, name: 'run_macosx', description: "True/False to run tests on macosx")
```

The job will:
- Clone the repository locally on each machine in parallel
- Get the submodules `git submodule update --init --recursive`
- Run performance tests and compare outputs see [compare-git-hashes.sh](https://github.com/stan-dev/Performance-tests-cmdstan/blob/master/compare-git-hashes.sh)
- Run `Numerical Accuracy and Performance Tests on Known-Good Models`
- Run `Shotgun Performance Regression Tests`
- Build final results
- Log outputs and comparations  


* To start a job simply build it with default or custom parameters passed in the UI
* To check logs, click on the job number and go to `Console Output`