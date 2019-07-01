#!/usr/bin/env groovy
@Library('StanUtils')
import org.stan.Utils
import groovy.json.JsonSlurper

def utils = new org.stan.Utils()

def branchOrPR(pr) {
  if (pr == "downstream_tests") return "develop"
  if (pr == "downstream_hotfix") return "master"
  if (pr == "") return "develop"
  return pr
}

def post_comment(text, repository, pr_number) {

    def new_results = results_to_obj(text)
    def old_results = get_last_results(repository, pr_number)
    def final_results = [:]

    new_results.each{ k, v ->   
      def new_value = v.toDouble();
      def old_value = old_results[k].toDouble();
      final_results[k] = 1 - new_value / old_value
    }

    def _comment = ""

    _comment += "Jenkins Console Log: https://jenkins.mc-stan.org/job/$repository/view/change-requests/job/PR-$pr_number/$BUILD_NUMBER/consoleFull"
    _comment += "Blue Ocean: https://jenkins.mc-stan.org/blue/organizations/jenkins/$repository/detail/PR-$pr_number/$BUILD_NUMBER/pipeline"

    _comment += "- - - - - - - - - - - - - - - - - - - - -"

    _comment += "| Name | Old Result | New Result | 1 - new / old |"
    _comment += "| ------------- |------------- | ------------- | ------------- |"

    final_results.each{ k, v -> 
    
    def _name = "${k}"
    def _final_value = "${v}"
    def _new_value = new_results[_name]
    def _old_value = old_results[_name]

    _comment += "| $_name | $_old_value | $_new_value | $_final_value |"
    
    }

    sh """#!/bin/bash
        curl -s -H "Authorization: token ${GITHUB_TOKEN}" -X POST -d '{"body": "${_comment}"}' "https://api.github.com/repos/stan-dev/${repository}/issues/${pr_number}/comments"
    """
}

def results_to_obj(body){

    def returnMap = [:]

    returnMap["gp_pois_regr"] = (body =~ /gp_pois_regr\.stan, (.*?)\)/)[0][1] 
    returnMap["low_dim_corr_gauss"] = (body =~ /low_dim_corr_gauss\.stan, (.*?)\)/)[0][1] 
    returnMap["irt_2pl"] = (body =~ /irt_2pl\.stan, (.*?)\)/)[0][1] 
    returnMap["one_comp_mm_elim_abs"] = (body =~ /one_comp_mm_elim_abs\.stan, (.*?)\)/)[0][1] 
    returnMap["eight_schools"] = (body =~ /eight_schools\.stan, (.*?)\)/)[0][1] 
    returnMap["gp_regr"] = (body =~ /gp_regr\.stan, (.*?)\)/)[0][1] 
    returnMap["arK"] = (body =~ /arK\.stan, (.*?)\)/)[0][1] 
    returnMap["compilation"] = (body =~ /compilation, (.*?)\)/)[0][1] 
    returnMap["low_dim_gauss_mix_collapse"] = (body =~ /low_dim_gauss_mix_collapse\.stan, (.*?)\)/)[0][1] 
    returnMap["low_dim_gauss_mix"] = (body =~ /low_dim_gauss_mix\.stan, (.*?)\)/)[0][1] 
    returnMap["sir"] = (body =~ /sir\.stan, (.*?)\)/)[0][1] 
    returnMap["sim_one_comp_mm_elim_abs"] = (body =~ /sim_one_comp_mm_elim_abs\.stan, (.*?)\)/)[0][1] 
    returnMap["garch"] = (body =~ /garch\.stan, (.*?)\)/)[0][1] 
    returnMap["gen_gp_data"] = (body =~ /gen_gp_data\.stan, (.*?)\)/)[0][1] 
    returnMap["arma"] = (body =~ /arma\.stan, (.*?)\)/)[0][1] 
    returnMap["result"] = (body =~ /(?m)Result: (.*?)$/)[0][1] 
    
    return returnMap
}

def get_last_results(repository, pr_number){

    def get = new URL("https://api.github.com/repos/stan-dev/${repository}/issues/${pr_number}/comments?direction=desc").openConnection();
    def getRC = get.getResponseCode();
    
    if(getRC.equals(200)) {
      
        def res = get.getInputStream().getText();
      
      	def jsonSlurper = new JsonSlurper();

        def returnMap = [:]
      
        for(o in jsonSlurper.parseText(res)){
          
            def body = o.body.toString()
            if(body.contains("stat_comp_benchmarks/benchmarks")){
                return results_to_obj(body);
            }    
        }
    }
}

@NonCPS
def get_results(){
    def performance_log = currentBuild.rawBuild.getLog(Integer.MAX_VALUE).join('\n')
    def comment = ""

    def test_matches = (performance_log =~ /\('(.*)\)/)
    for(item in test_matches){
        comment += item[0] + "\\r\\n"
    }
    def result_match = (performance_log =~ /(?s)\).(\d{1}\.?\d{11})/)
    try{
        comment += "Result: " + result_match[0][1].toString() + "\\r\\n"
    }
    catch(Exception ex){
        comment += "Result: " + "Regex did not match anything" + "\\r\\n"
    }
    def result_match_hash = (performance_log =~ /Merge (.*?) into/)
    try{
        comment += "Commit hash: " + result_match_hash[0][1].toString() + "\\r\\n"
    }
    catch(Exception ex){
        comment += "Commit hash: " + "Regex did not match anything" + "\\r\\n"
    }

    performance_log = null

    return comment
}

pipeline {
    //gelman-group-mac
    agent { label 'linux' }
    environment {
        cmdstan_pr = ""
        GITHUB_TOKEN = credentials('6e7c1e8f-ca2c-4b11-a70e-d934d3f6b681')
    }
    options {
        skipDefaultCheckout()
        preserveStashes(buildCount: 7)
    }
    parameters {
        string(defaultValue: '', name: 'cmdstan_pr', description: "CmdStan hash/branch to compare against")
        string(defaultValue: '', name: 'stan_pr', description: "Stan PR to test against. Will check out this PR in the downstream Stan repo.")
        string(defaultValue: '', name: 'math_pr', description: "Math PR to test against. Will check out this PR in the downstream Math repo.")
    }
    stages {
        stage('aaa'){
            steps{
                script{
                    sh """
                    Started by upstream project "CmdStan/downstream_tests" build number 677
originally caused by:
 Started by upstream project "Stan/PR-2775" build number 2
 originally caused by:
  Pull request #2775 updated
Checking out git https://github.com/stan-dev/performance-tests-cmdstan.git into /mnt/nvme1n1/Jenkins/jobs/CmdStan Performance Tests/branches/downstream-tests.3ol1sn/workspace@script to read Jenkinsfile
No credentials specified
 > /usr/bin/git rev-parse --is-inside-work-tree # timeout=10
Fetching changes from the remote Git repository
 > /usr/bin/git config remote.origin.url https://github.com/stan-dev/performance-tests-cmdstan.git # timeout=10
Fetching upstream changes from https://github.com/stan-dev/performance-tests-cmdstan.git
 > /usr/bin/git --version # timeout=10
 > /usr/bin/git fetch --tags --progress https://github.com/stan-dev/performance-tests-cmdstan.git +refs/heads/*:refs/remotes/origin/* # timeout=10
 > /usr/bin/git rev-parse refs/remotes/origin/master^{commit} # timeout=10
 > /usr/bin/git rev-parse refs/remotes/origin/origin/master^{commit} # timeout=10
Checking out Revision 53ce53bf2ce65cf1a091f5be5c8beaedd452712f (refs/remotes/origin/master)
 > /usr/bin/git config core.sparsecheckout # timeout=10
 > /usr/bin/git checkout -f 53ce53bf2ce65cf1a091f5be5c8beaedd452712f # timeout=10
Commit message: "Not ready for these yet"
 > /usr/bin/git rev-list --no-walk 53ce53bf2ce65cf1a091f5be5c8beaedd452712f # timeout=10
 > /usr/bin/git remote # timeout=10
 > /usr/bin/git submodule init # timeout=10
 > /usr/bin/git submodule sync # timeout=10
 > /usr/bin/git config --get remote.origin.url # timeout=10
 > /usr/bin/git submodule init # timeout=10
 > /usr/bin/git config -f .gitmodules --get-regexp ^submodule\.(.+)\.url # timeout=10
 > /usr/bin/git config --get submodule.cmdstan.url # timeout=10
 > /usr/bin/git config -f .gitmodules --get submodule.cmdstan.path # timeout=10
 > /usr/bin/git config --get submodule.example-models.url # timeout=10
 > /usr/bin/git config -f .gitmodules --get submodule.example-models.path # timeout=10
 > /usr/bin/git config --get submodule.stat_comp_benchmarks.url # timeout=10
 > /usr/bin/git config -f .gitmodules --get submodule.stat_comp_benchmarks.path # timeout=10
 > /usr/bin/git submodule update cmdstan # timeout=10
 > /usr/bin/git submodule update example-models # timeout=10
 > /usr/bin/git submodule update stat_comp_benchmarks # timeout=10
Running in Durability level: MAX_SURVIVABILITY
Loading library StanUtils@master
Examining stan-dev/jenkins-shared-libraries
Attempting to resolve master as a branch
Resolved master as branch master at revision 43fee5fc72a580ef2815afa94651d552158296af
using credential a630aebc-6861-4e69-b497-fd7f496ec46b
 > /usr/bin/git rev-parse --is-inside-work-tree # timeout=10
Fetching changes from the remote Git repository
 > /usr/bin/git config remote.origin.url https://github.com/stan-dev/jenkins-shared-libraries.git # timeout=10
Fetching without tags
Fetching upstream changes from https://github.com/stan-dev/jenkins-shared-libraries.git
 > /usr/bin/git --version # timeout=10
using GIT_ASKPASS to set credentials stan-buildbot github authentication
 > /usr/bin/git fetch --no-tags --progress https://github.com/stan-dev/jenkins-shared-libraries.git +refs/heads/master:refs/remotes/origin/master # timeout=10
Checking out Revision 43fee5fc72a580ef2815afa94651d552158296af (master)
 > /usr/bin/git config core.sparsecheckout # timeout=10
 > /usr/bin/git checkout -f 43fee5fc72a580ef2815afa94651d552158296af # timeout=10
Commit message: "Don't email for downstream_tests"
 > /usr/bin/git rev-list --no-walk 43fee5fc72a580ef2815afa94651d552158296af # timeout=10
[Pipeline] Start of Pipeline
[Pipeline] node
Still waiting to schedule task
Waiting for next available executor on ‘gelman-group-mac’
Running on gelman-group-mac in /Users/Shared/Jenkins/gelman-group-mac/workspace/rformance_Tests_downstream_tests
[Pipeline] {
[Pipeline] withCredentials
Masking supported pattern matches of $GITHUB_TOKEN
[Pipeline] {
[Pipeline] withEnv
[Pipeline] {
[Pipeline] stage
[Pipeline] { (Clean checkout)
[Pipeline] deleteDir
[Pipeline] checkout
using credential a630aebc-6861-4e69-b497-fd7f496ec46b
Cloning the remote Git repository
Checking out Revision 53ce53bf2ce65cf1a091f5be5c8beaedd452712f (refs/remotes/origin/master)
Cloning repository git@github.com:stan-dev/performance-tests-cmdstan.git
 > /usr/bin/git init /Users/Shared/Jenkins/gelman-group-mac/workspace/rformance_Tests_downstream_tests # timeout=10
Fetching upstream changes from git@github.com:stan-dev/performance-tests-cmdstan.git
 > /usr/bin/git --version # timeout=10
using GIT_ASKPASS to set credentials stan-buildbot github authentication
 > /usr/bin/git fetch --tags --progress git@github.com:stan-dev/performance-tests-cmdstan.git +refs/heads/*:refs/remotes/origin/* # timeout=10
 > /usr/bin/git config remote.origin.url git@github.com:stan-dev/performance-tests-cmdstan.git # timeout=10
 > /usr/bin/git config --add remote.origin.fetch +refs/heads/*:refs/remotes/origin/* # timeout=10
 > /usr/bin/git config remote.origin.url git@github.com:stan-dev/performance-tests-cmdstan.git # timeout=10
Fetching upstream changes from git@github.com:stan-dev/performance-tests-cmdstan.git
using GIT_ASKPASS to set credentials stan-buildbot github authentication
 > /usr/bin/git fetch --tags --progress git@github.com:stan-dev/performance-tests-cmdstan.git +refs/heads/*:refs/remotes/origin/* # timeout=10
 > /usr/bin/git rev-parse refs/remotes/origin/master^{commit} # timeout=10
 > /usr/bin/git rev-parse refs/remotes/origin/origin/master^{commit} # timeout=10
 > /usr/bin/git config core.sparsecheckout # timeout=10
 > /usr/bin/git checkout -f 53ce53bf2ce65cf1a091f5be5c8beaedd452712f # timeout=10
Commit message: "Not ready for these yet"
 > /usr/bin/git rev-list --no-walk 53ce53bf2ce65cf1a091f5be5c8beaedd452712f # timeout=10
 > /usr/bin/git remote # timeout=10
 > /usr/bin/git submodule init # timeout=10
 > /usr/bin/git submodule sync # timeout=10
 > /usr/bin/git config --get remote.origin.url # timeout=10
 > /usr/bin/git submodule init # timeout=10
 > /usr/bin/git config -f .gitmodules --get-regexp ^submodule\.(.+)\.url # timeout=10
 > /usr/bin/git config --get submodule.cmdstan.url # timeout=10
 > /usr/bin/git config -f .gitmodules --get submodule.cmdstan.path # timeout=10
 > /usr/bin/git config --get submodule.example-models.url # timeout=10
 > /usr/bin/git config -f .gitmodules --get submodule.example-models.path # timeout=10
 > /usr/bin/git config --get submodule.stat_comp_benchmarks.url # timeout=10
 > /usr/bin/git config -f .gitmodules --get submodule.stat_comp_benchmarks.path # timeout=10
 > /usr/bin/git submodule update --init --recursive cmdstan # timeout=10
 > /usr/bin/git submodule update --init --recursive example-models # timeout=10
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Update CmdStan pointer to latest develop)
Stage "Update CmdStan pointer to latest develop" skipped due to when conditional
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Test cmdstan develop against cmdstan pointer in this branch)
[Pipeline] script
[Pipeline] {
[Pipeline] sh
++ git submodule status
++ grep cmdstan
++ awk '{print $1}'
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
+ old_hash=7fdbd7de6c0ca004cf44c9d537d2353a4e9bc386
++ '[' -n develop ']'
++ echo develop
+ cmdstan_hash=develop
+ bash compare-git-hashes.sh stat_comp_benchmarks develop develop PR-2775 develop
+ clean_checkout develop false false
+ make revert
git submodule update --init --recursive
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
+ cd cmdstan
+ [[ develop == \P\R\-* ]]
+ git fetch
 > /usr/bin/git submodule update --init --recursive stat_comp_benchmarks # timeout=10
+ git checkout develop
Switched to branch 'develop'
Your branch is up-to-date with 'origin/develop'.
+ git pull origin develop
From https://github.com/stan-dev/cmdstan
 * branch            develop    -> FETCH_HEAD
Already up-to-date.
+ git reset --hard HEAD
HEAD is now at 7fdbd7d Updates the Stan submodule to d03404ca9.
+ git clean -xffd
+ git submodule update --init --recursive
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
+ cd stan
+ [[ false == \P\R\-* ]]
+ '[' false '!=' false ']'
+ git reset --hard HEAD
HEAD is now at d03404c Updates the Math submodule to 8f8cbbb.
+ git clean -xffd
+ cd ..
+ pushd stan/lib/stan_math
/Users/Shared/Jenkins/gelman-group-mac/workspace/rformance_Tests_downstream_tests/cmdstan/stan/lib/stan_math /Users/Shared/Jenkins/gelman-group-mac/workspace/rformance_Tests_downstream_tests/cmdstan
+ [[ false == \P\R\-* ]]
+ '[' false '!=' false ']'
+ git reset --hard HEAD
HEAD is now at 8f8cbbb Merge pull request #1234 from bstatcomp/feature/issue-1122-is-constant-struct-parameter-packs
+ git clean -xffd
+ popd
/Users/Shared/Jenkins/gelman-group-mac/workspace/rformance_Tests_downstream_tests/cmdstan
+ cd ..
+ make clean
cd cmdstan; make clean-all; cd ..
rm -f -r doc
cd src/docs/cmdstan-guide; rm -f *.brf *.aux *.bbl *.blg *.log *.toc *.pdf *.out *.idx *.ilg *.ind *.cb *.cb2 *.upa
rm -f -r test
rm -f 
rm -f 
  removing dependency files
  cleaning sundials targets
rm -f 
rm -f -r bin
rm -f 
git submodule foreach --recursive git clean -xffd
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
Entering 'cmdstan'
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
Entering 'cmdstan/stan'
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
Entering 'cmdstan/stan/lib/stan_math'
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
Entering 'example-models'
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
Entering 'stat_comp_benchmarks'
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
+ cd cmdstan
++ git status --porcelain
+ dirty=
+ write_makelocal
+ echo 'CXXFLAGS += -march=native'
+ git status
On branch develop
Your branch is up-to-date with 'origin/develop'.
nothing to commit, working directory clean
+ cd ..
+ ./runPerformanceTests.py --overwrite-golds stat_comp_benchmarks
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT src/cmdstan/stanc.o -MM -E -MG -MP -MF src/cmdstan/stanc.d src/cmdstan/stanc.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/semantic_actions_def.o -MT stan/src/stan/lang/grammars/semantic_actions_def.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/semantic_actions_def.d stan/src/stan/lang/grammars/semantic_actions_def.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/ast_def.o -MT stan/src/stan/lang/ast_def.d -MM -E -MG -MP -MF stan/src/stan/lang/ast_def.d stan/src/stan/lang/ast_def.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/whitespace_grammar_inst.o -MT stan/src/stan/lang/grammars/whitespace_grammar_inst.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/whitespace_grammar_inst.d stan/src/stan/lang/grammars/whitespace_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/term_grammar_inst.o -MT stan/src/stan/lang/grammars/term_grammar_inst.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/term_grammar_inst.d stan/src/stan/lang/grammars/term_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/statement_grammar_inst.o -MT stan/src/stan/lang/grammars/statement_grammar_inst.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/statement_grammar_inst.d stan/src/stan/lang/grammars/statement_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/statement_2_grammar_inst.o -MT stan/src/stan/lang/grammars/statement_2_grammar_inst.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/statement_2_grammar_inst.d stan/src/stan/lang/grammars/statement_2_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/program_grammar_inst.o -MT stan/src/stan/lang/grammars/program_grammar_inst.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/program_grammar_inst.d stan/src/stan/lang/grammars/program_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/local_var_decls_grammar_inst.o -MT stan/src/stan/lang/grammars/local_var_decls_grammar_inst.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/local_var_decls_grammar_inst.d stan/src/stan/lang/grammars/local_var_decls_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/indexes_grammar_inst.o -MT stan/src/stan/lang/grammars/indexes_grammar_inst.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/indexes_grammar_inst.d stan/src/stan/lang/grammars/indexes_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/functions_grammar_inst.o -MT stan/src/stan/lang/grammars/functions_grammar_inst.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/functions_grammar_inst.d stan/src/stan/lang/grammars/functions_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/expression_grammar_inst.o -MT stan/src/stan/lang/grammars/expression_grammar_inst.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/expression_grammar_inst.d stan/src/stan/lang/grammars/expression_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/expression07_grammar_inst.o -MT stan/src/stan/lang/grammars/expression07_grammar_inst.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/expression07_grammar_inst.d stan/src/stan/lang/grammars/expression07_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/block_var_decls_grammar_inst.o -MT stan/src/stan/lang/grammars/block_var_decls_grammar_inst.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/block_var_decls_grammar_inst.d stan/src/stan/lang/grammars/block_var_decls_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/bare_type_grammar_inst.o -MT stan/src/stan/lang/grammars/bare_type_grammar_inst.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/bare_type_grammar_inst.d stan/src/stan/lang/grammars/bare_type_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT stan/src/stan/model/model_header.hpp.gch -MT stan/src/stan/model/model_header.d -MM -E -MG -MP -MF stan/src/stan/model/model_header.d stan/src/stan/model/model_header.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/stanc.o src/cmdstan/stanc.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/bare_type_grammar_inst.o stan/src/stan/lang/grammars/bare_type_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/block_var_decls_grammar_inst.o stan/src/stan/lang/grammars/block_var_decls_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/expression07_grammar_inst.o stan/src/stan/lang/grammars/expression07_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/expression_grammar_inst.o stan/src/stan/lang/grammars/expression_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/functions_grammar_inst.o stan/src/stan/lang/grammars/functions_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/indexes_grammar_inst.o stan/src/stan/lang/grammars/indexes_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/local_var_decls_grammar_inst.o stan/src/stan/lang/grammars/local_var_decls_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/program_grammar_inst.o stan/src/stan/lang/grammars/program_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/statement_2_grammar_inst.o stan/src/stan/lang/grammars/statement_2_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/statement_grammar_inst.o stan/src/stan/lang/grammars/statement_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/term_grammar_inst.o stan/src/stan/lang/grammars/term_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/whitespace_grammar_inst.o stan/src/stan/lang/grammars/whitespace_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/ast_def.o stan/src/stan/lang/ast_def.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/semantic_actions_def.o stan/src/stan/lang/grammars/semantic_actions_def.cpp
ar -rs bin/cmdstan/libstanc.a bin/cmdstan/lang/grammars/bare_type_grammar_inst.o bin/cmdstan/lang/grammars/block_var_decls_grammar_inst.o bin/cmdstan/lang/grammars/expression07_grammar_inst.o bin/cmdstan/lang/grammars/expression_grammar_inst.o bin/cmdstan/lang/grammars/functions_grammar_inst.o bin/cmdstan/lang/grammars/indexes_grammar_inst.o bin/cmdstan/lang/grammars/local_var_decls_grammar_inst.o bin/cmdstan/lang/grammars/program_grammar_inst.o bin/cmdstan/lang/grammars/statement_2_grammar_inst.o bin/cmdstan/lang/grammars/statement_grammar_inst.o bin/cmdstan/lang/grammars/term_grammar_inst.o bin/cmdstan/lang/grammars/whitespace_grammar_inst.o bin/cmdstan/lang/ast_def.o bin/cmdstan/lang/grammars/semantic_actions_def.o
ar: creating archive bin/cmdstan/libstanc.a
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            bin/cmdstan/stanc.o bin/cmdstan/libstanc.a        -o bin/stanc








--- Translating Stan model to C++ code ---
--- Translating Stan model to C++ code ---
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs.hpp ../stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs.stan
--- Translating Stan model to C++ code ---
--- Translating Stan model to C++ code ---
--- Translating Stan model to C++ code ---
--- Translating Stan model to C++ code ---
--- Translating Stan model to C++ code ---
--- Translating Stan model to C++ code ---
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.hpp ../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.stan
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.hpp ../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.stan
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss.hpp ../stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss.stan
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/sir/sir.hpp ../stat_comp_benchmarks/benchmarks/sir/sir.stan
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.hpp ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.stan
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.hpp ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.stan
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.hpp ../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.stan






--- Translating Stan model to C++ code ---
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data.hpp ../stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data.stan
--- Translating Stan model to C++ code ---
--- Translating Stan model to C++ code ---
--- Translating Stan model to C++ code ---
--- Translating Stan model to C++ code ---
--- Translating Stan model to C++ code ---
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/garch/garch.hpp ../stat_comp_benchmarks/benchmarks/garch/garch.stan
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/arK/arK.hpp ../stat_comp_benchmarks/benchmarks/arK/arK.stan
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/arma/arma.hpp ../stat_comp_benchmarks/benchmarks/arma/arma.stan
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/eight_schools/eight_schools.hpp ../stat_comp_benchmarks/benchmarks/eight_schools/eight_schools.stan
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.hpp ../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.stan
Model name=irt_2pl_model
Input file=../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.stan
Output file=../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.hpp
Model name=sir_model
Input file=../stat_comp_benchmarks/benchmarks/sir/sir.stan
Output file=../stat_comp_benchmarks/benchmarks/sir/sir.hpp
Model name=one_comp_mm_elim_abs_model
Input file=../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.stan
Output file=../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.hpp
Model name=gp_regr_model
Input file=../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.stan
Output file=../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.hpp
Model name=gen_gp_data_model
Input file=../stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data.stan
Output file=../stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data.hpp
Model name=garch_model
Input file=../stat_comp_benchmarks/benchmarks/garch/garch.stan
Output file=../stat_comp_benchmarks/benchmarks/garch/garch.hpp
Model name=low_dim_corr_gauss_model
Input file=../stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss.stan
Output file=../stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss.hpp
Model name=sim_one_comp_mm_elim_abs_model
Input file=../stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs.stan
Output file=../stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs.hpp
Model name=low_dim_gauss_mix_collapse_model
Input file=../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.stan
Output file=../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.hpp
Model name=arma_model
Input file=../stat_comp_benchmarks/benchmarks/arma/arma.stan
Output file=../stat_comp_benchmarks/benchmarks/arma/arma.hpp
Model name=low_dim_gauss_mix_model
Input file=../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.stan
Output file=../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.hpp
Model name=gp_pois_regr_model
Input file=../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.stan
Output file=../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.hpp
Model name=eight_schools_model
Input file=../stat_comp_benchmarks/benchmarks/eight_schools/eight_schools.stan
Output file=../stat_comp_benchmarks/benchmarks/eight_schools/eight_schools.hpp
Model name=arK_model
Input file=../stat_comp_benchmarks/benchmarks/arK/arK.stan
Output file=../stat_comp_benchmarks/benchmarks/arK/arK.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/garch/garch.o -MT ../stat_comp_benchmarks/benchmarks/garch/garch -include ../stat_comp_benchmarks/benchmarks/garch/garch.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/garch/garch.d ../stat_comp_benchmarks/benchmarks/garch/garch.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data.o -MT ../stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data -include ../stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data.d ../stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/eight_schools/eight_schools.o -MT ../stat_comp_benchmarks/benchmarks/eight_schools/eight_schools -include ../stat_comp_benchmarks/benchmarks/eight_schools/eight_schools.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/eight_schools/eight_schools.d ../stat_comp_benchmarks/benchmarks/eight_schools/eight_schools.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/arma/arma.o -MT ../stat_comp_benchmarks/benchmarks/arma/arma -include ../stat_comp_benchmarks/benchmarks/arma/arma.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/arma/arma.d ../stat_comp_benchmarks/benchmarks/arma/arma.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.o -MT ../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl -include ../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.d ../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.o -MT ../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr -include ../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.d ../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.o -MT ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse -include ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.d ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss.o -MT ../stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss -include ../stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss.d ../stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/sir/sir.o -MT ../stat_comp_benchmarks/benchmarks/sir/sir -include ../stat_comp_benchmarks/benchmarks/sir/sir.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/sir/sir.d ../stat_comp_benchmarks/benchmarks/sir/sir.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.o -MT ../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs -include ../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.d ../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.o -MT ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix -include ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.d ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.o -MT ../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr -include ../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.d ../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs.o -MT ../stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs -include ../stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs.d ../stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/arK/arK.o -MT ../stat_comp_benchmarks/benchmarks/arK/arK -include ../stat_comp_benchmarks/benchmarks/arK/arK.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/arK/arK.d ../stat_comp_benchmarks/benchmarks/arK/arK.hpp
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_math.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_math.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_bandpre.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_bandpre.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodea_io.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodea_io.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodea.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodea.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/nvector/serial/nvector_serial.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/nvector/serial/nvector_serial.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_bbdpre.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_bbdpre.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_direct.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_direct.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_io.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_io.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_diag.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_diag.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_ls.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_ls.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls_stg.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls_stg.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls_stg1.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls_stg1.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls_sim.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls_sim.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_spils.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_spils.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_band.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_band.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_dense.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_dense.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_direct.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_direct.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_iterative.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_iterative.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_linearsolver.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_linearsolver.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_matrix.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_matrix.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_mpi.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_mpi.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nonlinearsolver.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nonlinearsolver.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nvector.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nvector.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nvector_senswrapper.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nvector_senswrapper.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_pcg.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_pcg.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_sparse.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_sparse.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_spbcgs.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_spbcgs.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_sptfqmr.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_sptfqmr.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_version.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_version.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sunmatrix/band/sunmatrix_band.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sunmatrix/band/sunmatrix_band.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sunmatrix/dense/sunmatrix_dense.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sunmatrix/dense/sunmatrix_dense.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sunlinsol/band/sunlinsol_band.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sunlinsol/band/sunlinsol_band.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sunlinsol/dense/sunlinsol_dense.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sunlinsol/dense/sunlinsol_dense.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sunnonlinsol/newton/sunnonlinsol_newton.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sunnonlinsol/newton/sunnonlinsol_newton.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sunnonlinsol/fixedpoint/sunnonlinsol_fixedpoint.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sunnonlinsol/fixedpoint/sunnonlinsol_fixedpoint.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idaa.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idaa.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idaa_io.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idaa_io.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_bbdpre.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_bbdpre.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_direct.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_direct.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_ic.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_ic.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_io.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_io.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_ls.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_ls.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_nls.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_nls.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_nls_sim.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_nls_sim.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_nls_stg.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_nls_stg.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_spils.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_spils.o
ar -rs stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/src/nvector/serial/nvector_serial.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_math.o
ar: creating archive stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a
ar -rs stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idaa.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idaa_io.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_bbdpre.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_direct.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_ic.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_io.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_ls.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_nls.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_nls_sim.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_nls_stg.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_spils.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_band.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_dense.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_direct.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_iterative.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_linearsolver.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_math.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_matrix.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_mpi.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nonlinearsolver.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nvector.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nvector_senswrapper.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_pcg.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_sparse.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_spbcgs.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_sptfqmr.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_version.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunmatrix/band/sunmatrix_band.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunmatrix/dense/sunmatrix_dense.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunlinsol/band/sunlinsol_band.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunlinsol/dense/sunlinsol_dense.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunnonlinsol/newton/sunnonlinsol_newton.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunnonlinsol/fixedpoint/sunnonlinsol_fixedpoint.o
ar: creating archive stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a
ar -rs stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodea.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodea_io.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_bandpre.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_bbdpre.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_diag.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_direct.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_io.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_ls.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls_sim.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls_stg.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls_stg1.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_spils.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_band.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_dense.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_direct.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_iterative.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_linearsolver.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_math.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_matrix.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_mpi.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nonlinearsolver.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nvector.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nvector_senswrapper.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_pcg.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_sparse.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_spbcgs.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_sptfqmr.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_version.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunmatrix/band/sunmatrix_band.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunmatrix/dense/sunmatrix_dense.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunlinsol/band/sunlinsol_band.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunlinsol/dense/sunlinsol_dense.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunnonlinsol/newton/sunnonlinsol_newton.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunnonlinsol/fixedpoint/sunnonlinsol_fixedpoint.o
ar: creating archive stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a

--- Compiling pre-compiled header ---	
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c stan/src/stan/model/model_header.hpp -o stan/src/stan/model/model_header.hpp.gch

--- Linking C++ model ---

/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/arK/arK.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/arK/arK
--- Linking C++ model ---
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/arma/arma.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/arma/arma

--- Linking C++ model ---

/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/eight_schools/eight_schools.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/eight_schools/eight_schools
--- Linking C++ model ---

/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/garch/garch.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/garch/garch
--- Linking C++ model ---

/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr
--- Linking C++ model ---

/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data
--- Linking C++ model ---

/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr
--- Linking C++ model ---

/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl
--- Linking C++ model ---

/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss
--- Linking C++ model ---

/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix
--- Linking C++ model ---

/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse
--- Linking C++ model ---

/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs
--- Linking C++ model ---
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs

--- Linking C++ model ---
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/sir/sir.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/sir/sir
method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/arK/arK.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_arK_arK.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)


Gradient evaluation took 0.000124 seconds
1000 transitions using 10 leapfrog steps per transition would take 1.24 seconds.
Adjust your expectations accordingly!


Iteration:    1 / 2000 [  0%]  (Warmup)
Iteration:  100 / 2000 [  5%]  (Warmup)
Iteration:  200 / 2000 [ 10%]  (Warmup)
Iteration:  300 / 2000 [ 15%]  (Warmup)
Iteration:  400 / 2000 [ 20%]  (Warmup)
Iteration:  500 / 2000 [ 25%]  (Warmup)
Iteration:  600 / 2000 [ 30%]  (Warmup)
Iteration:  700 / 2000 [ 35%]  (Warmup)
Iteration:  800 / 2000 [ 40%]  (Warmup)
Iteration:  900 / 2000 [ 45%]  (Warmup)
Iteration: 1000 / 2000 [ 50%]  (Warmup)
Iteration: 1001 / 2000 [ 50%]  (Sampling)
Iteration: 1100 / 2000 [ 55%]  (Sampling)
Iteration: 1200 / 2000 [ 60%]  (Sampling)
Iteration: 1300 / 2000 [ 65%]  (Sampling)
Iteration: 1400 / 2000 [ 70%]  (Sampling)
Iteration: 1500 / 2000 [ 75%]  (Sampling)
Iteration: 1600 / 2000 [ 80%]  (Sampling)
Iteration: 1700 / 2000 [ 85%]  (Sampling)
Iteration: 1800 / 2000 [ 90%]  (Sampling)
Iteration: 1900 / 2000 [ 95%]  (Sampling)
Iteration: 2000 / 2000 [100%]  (Sampling)

 Elapsed Time: 1.10929 seconds (Warm-up)
               1.24649 seconds (Sampling)
               2.35578 seconds (Total)

method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/arma/arma.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_arma_arma.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)


Gradient evaluation took 6.2e-05 seconds
1000 transitions using 10 leapfrog steps per transition would take 0.62 seconds.
Adjust your expectations accordingly!


Iteration:    1 / 2000 [  0%]  (Warmup)
Iteration:  100 / 2000 [  5%]  (Warmup)
Iteration:  200 / 2000 [ 10%]  (Warmup)
Iteration:  300 / 2000 [ 15%]  (Warmup)
Iteration:  400 / 2000 [ 20%]  (Warmup)
Iteration:  500 / 2000 [ 25%]  (Warmup)
Iteration:  600 / 2000 [ 30%]  (Warmup)
Iteration:  700 / 2000 [ 35%]  (Warmup)
Iteration:  800 / 2000 [ 40%]  (Warmup)
Iteration:  900 / 2000 [ 45%]  (Warmup)
Iteration: 1000 / 2000 [ 50%]  (Warmup)
Iteration: 1001 / 2000 [ 50%]  (Sampling)
Iteration: 1100 / 2000 [ 55%]  (Sampling)
Iteration: 1200 / 2000 [ 60%]  (Sampling)
Iteration: 1300 / 2000 [ 65%]  (Sampling)
Iteration: 1400 / 2000 [ 70%]  (Sampling)
Iteration: 1500 / 2000 [ 75%]  (Sampling)
Iteration: 1600 / 2000 [ 80%]  (Sampling)
Iteration: 1700 / 2000 [ 85%]  (Sampling)
Iteration: 1800 / 2000 [ 90%]  (Sampling)
Iteration: 1900 / 2000 [ 95%]  (Sampling)
Iteration: 2000 / 2000 [100%]  (Sampling)

 Elapsed Time: 0.247612 seconds (Warm-up)
               0.42513 seconds (Sampling)
               0.672742 seconds (Total)

method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/eight_schools/eight_schools.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_eight_schools_eight_schools.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)


Gradient evaluation took 2e-05 seconds
1000 transitions using 10 leapfrog steps per transition would take 0.2 seconds.
Adjust your expectations accordingly!


Iteration:    1 / 2000 [  0%]  (Warmup)
Iteration:  100 / 2000 [  5%]  (Warmup)
Iteration:  200 / 2000 [ 10%]  (Warmup)
Iteration:  300 / 2000 [ 15%]  (Warmup)
Iteration:  400 / 2000 [ 20%]  (Warmup)
Iteration:  500 / 2000 [ 25%]  (Warmup)
Iteration:  600 / 2000 [ 30%]  (Warmup)
Iteration:  700 / 2000 [ 35%]  (Warmup)
Iteration:  800 / 2000 [ 40%]  (Warmup)
Iteration:  900 / 2000 [ 45%]  (Warmup)
Iteration: 1000 / 2000 [ 50%]  (Warmup)
Iteration: 1001 / 2000 [ 50%]  (Sampling)
Iteration: 1100 / 2000 [ 55%]  (Sampling)
Iteration: 1200 / 2000 [ 60%]  (Sampling)
Iteration: 1300 / 2000 [ 65%]  (Sampling)
Iteration: 1400 / 2000 [ 70%]  (Sampling)
Iteration: 1500 / 2000 [ 75%]  (Sampling)
Iteration: 1600 / 2000 [ 80%]  (Sampling)
Iteration: 1700 / 2000 [ 85%]  (Sampling)
Iteration: 1800 / 2000 [ 90%]  (Sampling)
Iteration: 1900 / 2000 [ 95%]  (Sampling)
Iteration: 2000 / 2000 [100%]  (Sampling)

 Elapsed Time: 0.037644 seconds (Warm-up)
               0.04507 seconds (Sampling)
               0.082714 seconds (Total)

method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/garch/garch.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_garch_garch.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)


Gradient evaluation took 8.2e-05 seconds
1000 transitions using 10 leapfrog steps per transition would take 0.82 seconds.
Adjust your expectations accordingly!


Iteration:    1 / 2000 [  0%]  (Warmup)
Iteration:  100 / 2000 [  5%]  (Warmup)
Iteration:  200 / 2000 [ 10%]  (Warmup)
Iteration:  300 / 2000 [ 15%]  (Warmup)
Iteration:  400 / 2000 [ 20%]  (Warmup)
Iteration:  500 / 2000 [ 25%]  (Warmup)
Iteration:  600 / 2000 [ 30%]  (Warmup)
Iteration:  700 / 2000 [ 35%]  (Warmup)
Iteration:  800 / 2000 [ 40%]  (Warmup)
Iteration:  900 / 2000 [ 45%]  (Warmup)
Iteration: 1000 / 2000 [ 50%]  (Warmup)
Iteration: 1001 / 2000 [ 50%]  (Sampling)
Iteration: 1100 / 2000 [ 55%]  (Sampling)
Iteration: 1200 / 2000 [ 60%]  (Sampling)
Iteration: 1300 / 2000 [ 65%]  (Sampling)
Iteration: 1400 / 2000 [ 70%]  (Sampling)
Iteration: 1500 / 2000 [ 75%]  (Sampling)
Iteration: 1600 / 2000 [ 80%]  (Sampling)
Iteration: 1700 / 2000 [ 85%]  (Sampling)
Iteration: 1800 / 2000 [ 90%]  (Sampling)
Iteration: 1900 / 2000 [ 95%]  (Sampling)
Iteration: 2000 / 2000 [100%]  (Sampling)

 Elapsed Time: 0.286311 seconds (Warm-up)
               0.255292 seconds (Sampling)
               0.541603 seconds (Total)

method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_gp_pois_regr_gp_pois_regr.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)


Gradient evaluation took 0.000164 seconds
1000 transitions using 10 leapfrog steps per transition would take 1.64 seconds.
Adjust your expectations accordingly!


Iteration:    1 / 2000 [  0%]  (Warmup)
Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: gp_exp_quad_cov: length_scale is 0, but must be > 0!  (in '../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.stan' at line 16)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Iteration:  100 / 2000 [  5%]  (Warmup)
Iteration:  200 / 2000 [ 10%]  (Warmup)
Iteration:  300 / 2000 [ 15%]  (Warmup)
Iteration:  400 / 2000 [ 20%]  (Warmup)
Iteration:  500 / 2000 [ 25%]  (Warmup)
Iteration:  600 / 2000 [ 30%]  (Warmup)
Iteration:  700 / 2000 [ 35%]  (Warmup)
Iteration:  800 / 2000 [ 40%]  (Warmup)
Iteration:  900 / 2000 [ 45%]  (Warmup)
Iteration: 1000 / 2000 [ 50%]  (Warmup)
Iteration: 1001 / 2000 [ 50%]  (Sampling)
Iteration: 1100 / 2000 [ 55%]  (Sampling)
Iteration: 1200 / 2000 [ 60%]  (Sampling)
Iteration: 1300 / 2000 [ 65%]  (Sampling)
Iteration: 1400 / 2000 [ 70%]  (Sampling)
Iteration: 1500 / 2000 [ 75%]  (Sampling)
Iteration: 1600 / 2000 [ 80%]  (Sampling)
Iteration: 1700 / 2000 [ 85%]  (Sampling)
Iteration: 1800 / 2000 [ 90%]  (Sampling)
Iteration: 1900 / 2000 [ 95%]  (Sampling)
Iteration: 2000 / 2000 [100%]  (Sampling)

 Elapsed Time: 2.02503 seconds (Warm-up)
               2.08574 seconds (Sampling)
               4.11077 seconds (Total)

method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_gp_regr_gen_gp_data.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)

Must use algorithm=fixed_param for model that has no parameters.
method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = fixed_param
id = 0 (Default)
data
  file =  (Default)
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_gp_regr_gen_gp_data.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)

Iteration:   1 / 1000 [  0%]  (Sampling)
Iteration: 100 / 1000 [ 10%]  (Sampling)
Iteration: 200 / 1000 [ 20%]  (Sampling)
Iteration: 300 / 1000 [ 30%]  (Sampling)
Iteration: 400 / 1000 [ 40%]  (Sampling)
Iteration: 500 / 1000 [ 50%]  (Sampling)
Iteration: 600 / 1000 [ 60%]  (Sampling)
Iteration: 700 / 1000 [ 70%]  (Sampling)
Iteration: 800 / 1000 [ 80%]  (Sampling)
Iteration: 900 / 1000 [ 90%]  (Sampling)
Iteration: 1000 / 1000 [100%]  (Sampling)

 Elapsed Time: 0 seconds (Warm-up)
               0.02558 seconds (Sampling)
               0.02558 seconds (Total)

method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_gp_regr_gp_regr.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)


Gradient evaluation took 0.000143 seconds
1000 transitions using 10 leapfrog steps per transition would take 1.43 seconds.
Adjust your expectations accordingly!


Iteration:    1 / 2000 [  0%]  (Warmup)
Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: cholesky_decompose: A is not symmetric. A[1,2] = inf, but A[2,1] = inf  (in '../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.stan' at line 16)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: cholesky_decompose: Matrix m is not positive definite  (in '../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.stan' at line 16)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Iteration:  100 / 2000 [  5%]  (Warmup)
Iteration:  200 / 2000 [ 10%]  (Warmup)
Iteration:  300 / 2000 [ 15%]  (Warmup)
Iteration:  400 / 2000 [ 20%]  (Warmup)
Iteration:  500 / 2000 [ 25%]  (Warmup)
Iteration:  600 / 2000 [ 30%]  (Warmup)
Iteration:  700 / 2000 [ 35%]  (Warmup)
Iteration:  800 / 2000 [ 40%]  (Warmup)
Iteration:  900 / 2000 [ 45%]  (Warmup)
Iteration: 1000 / 2000 [ 50%]  (Warmup)
Iteration: 1001 / 2000 [ 50%]  (Sampling)
Iteration: 1100 / 2000 [ 55%]  (Sampling)
Iteration: 1200 / 2000 [ 60%]  (Sampling)
Iteration: 1300 / 2000 [ 65%]  (Sampling)
Iteration: 1400 / 2000 [ 70%]  (Sampling)
Iteration: 1500 / 2000 [ 75%]  (Sampling)
Iteration: 1600 / 2000 [ 80%]  (Sampling)
Iteration: 1700 / 2000 [ 85%]  (Sampling)
Iteration: 1800 / 2000 [ 90%]  (Sampling)
Iteration: 1900 / 2000 [ 95%]  (Sampling)
Iteration: 2000 / 2000 [100%]  (Sampling)

 Elapsed Time: 0.101064 seconds (Warm-up)
               0.088802 seconds (Sampling)
               0.189866 seconds (Total)

method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_irt_2pl_irt_2pl.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)


Gradient evaluation took 0.000382 seconds
1000 transitions using 10 leapfrog steps per transition would take 3.82 seconds.
Adjust your expectations accordingly!


Iteration:    1 / 2000 [  0%]  (Warmup)
Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: normal_lpdf: Scale parameter is 0, but must be > 0!  (in '../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.stan' at line 21)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Iteration:  100 / 2000 [  5%]  (Warmup)
Iteration:  200 / 2000 [ 10%]  (Warmup)
Iteration:  300 / 2000 [ 15%]  (Warmup)
Iteration:  400 / 2000 [ 20%]  (Warmup)
Iteration:  500 / 2000 [ 25%]  (Warmup)
Iteration:  600 / 2000 [ 30%]  (Warmup)
Iteration:  700 / 2000 [ 35%]  (Warmup)
Iteration:  800 / 2000 [ 40%]  (Warmup)
Iteration:  900 / 2000 [ 45%]  (Warmup)
Iteration: 1000 / 2000 [ 50%]  (Warmup)
Iteration: 1001 / 2000 [ 50%]  (Sampling)
Iteration: 1100 / 2000 [ 55%]  (Sampling)
Iteration: 1200 / 2000 [ 60%]  (Sampling)
Iteration: 1300 / 2000 [ 65%]  (Sampling)
Iteration: 1400 / 2000 [ 70%]  (Sampling)
Iteration: 1500 / 2000 [ 75%]  (Sampling)
Iteration: 1600 / 2000 [ 80%]  (Sampling)
Iteration: 1700 / 2000 [ 85%]  (Sampling)
Iteration: 1800 / 2000 [ 90%]  (Sampling)
Iteration: 1900 / 2000 [ 95%]  (Sampling)
Iteration: 2000 / 2000 [100%]  (Sampling)

 Elapsed Time: 3.57179 seconds (Warm-up)
               3.11809 seconds (Sampling)
               6.68988 seconds (Total)

make -i -j16 ../stat_comp_benchmarks/benchmarks/arK/arK ../stat_comp_benchmarks/benchmarks/arma/arma ../stat_comp_benchmarks/benchmarks/eight_schools/eight_schools ../stat_comp_benchmarks/benchmarks/garch/garch ../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr ../stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data ../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr ../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl ../stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse ../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs ../stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs ../stat_comp_benchmarks/benchmarks/sir/sir
stat_comp_benchmarks/benchmarks/arK/arK method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/arK/arK.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_arK_arK.gold.tmp
mv golds/stat_comp_benchmarks_benchmarks_arK_arK.gold.tmp golds/stat_comp_benchmarks_benchmarks_arK_arK.gold
stat_comp_benchmarks/benchmarks/arma/arma method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/arma/arma.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_arma_arma.gold.tmp
mv golds/stat_comp_benchmarks_benchmarks_arma_arma.gold.tmp golds/stat_comp_benchmarks_benchmarks_arma_arma.gold
stat_comp_benchmarks/benchmarks/eight_schools/eight_schools method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/eight_schools/eight_schools.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_eight_schools_eight_schools.gold.tmp
mv golds/stat_comp_benchmarks_benchmarks_eight_schools_eight_schools.gold.tmp golds/stat_comp_benchmarks_benchmarks_eight_schools_eight_schools.gold
stat_comp_benchmarks/benchmarks/garch/garch method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/garch/garch.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_garch_garch.gold.tmp
mv golds/stat_comp_benchmarks_benchmarks_garch_garch.gold.tmp golds/stat_comp_benchmarks_benchmarks_garch_garch.gold
stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_gp_pois_regr_gp_pois_regr.gold.tmp
mv golds/stat_comp_benchmarks_benchmarks_gp_pois_regr_gp_pois_regr.gold.tmp golds/stat_comp_benchmarks_benchmarks_gp_pois_regr_gp_pois_regr.gold
stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_gp_regr_gen_gp_data.gold.tmp
stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data method=sample algorithm='fixed_param' random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_gp_regr_gen_gp_data.gold.tmp
mv golds/stat_comp_benchmarks_benchmarks_gp_regr_gen_gp_data.gold.tmp golds/stat_comp_benchmarks_benchmarks_gp_regr_gen_gp_data.gold
stat_comp_benchmarks/benchmarks/gp_regr/gp_regr method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_gp_regr_gp_regr.gold.tmp
mv golds/stat_comp_benchmarks_benchmarks_gp_regr_gp_regr.gold.tmp golds/stat_comp_benchmarks_benchmarks_gp_regr_gp_regr.gold
stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_irt_2pl_irt_2pl.gold.tmp
mv golds/stat_comp_benchmarks_benchmarks_irt_2pl_irt_2pl.gold.tmp golds/stat_comp_benchmarks_benchmarks_irt_2pl_irt_2pl.gold
stat_comp_benchmarks/benchmmethod = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = fixed_param
id = 0 (Default)
data
  file =  (Default)
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_low_dim_corr_gauss_low_dim_corr_gauss.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)

Iteration:   1 / 1000 [  0%]  (Sampling)
Iteration: 100 / 1000 [ 10%]  (Sampling)
Iteration: 200 / 1000 [ 20%]  (Sampling)
Iteration: 300 / 1000 [ 30%]  (Sampling)
Iteration: 400 / 1000 [ 40%]  (Sampling)
Iteration: 500 / 1000 [ 50%]  (Sampling)
Iteration: 600 / 1000 [ 60%]  (Sampling)
Iteration: 700 / 1000 [ 70%]  (Sampling)
Iteration: 800 / 1000 [ 80%]  (Sampling)
Iteration: 900 / 1000 [ 90%]  (Sampling)
Iteration: 1000 / 1000 [100%]  (Sampling)

 Elapsed Time: 0 seconds (Warm-up)
               0.007834 seconds (Sampling)
               0.007834 seconds (Total)

method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_low_dim_gauss_mix_low_dim_gauss_mix.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)


Gradient evaluation took 0.000439 seconds
1000 transitions using 10 leapfrog steps per transition would take 4.39 seconds.
Adjust your expectations accordingly!


Iteration:    1 / 2000 [  0%]  (Warmup)
Iteration:  100 / 2000 [  5%]  (Warmup)
Iteration:  200 / 2000 [ 10%]  (Warmup)
Iteration:  300 / 2000 [ 15%]  (Warmup)
Iteration:  400 / 2000 [ 20%]  (Warmup)
Iteration:  500 / 2000 [ 25%]  (Warmup)
Iteration:  600 / 2000 [ 30%]  (Warmup)
Iteration:  700 / 2000 [ 35%]  (Warmup)
Iteration:  800 / 2000 [ 40%]  (Warmup)
Iteration:  900 / 2000 [ 45%]  (Warmup)
Iteration: 1000 / 2000 [ 50%]  (Warmup)
Iteration: 1001 / 2000 [ 50%]  (Sampling)
Iteration: 1100 / 2000 [ 55%]  (Sampling)
Iteration: 1200 / 2000 [ 60%]  (Sampling)
Iteration: 1300 / 2000 [ 65%]  (Sampling)
Iteration: 1400 / 2000 [ 70%]  (Sampling)
Iteration: 1500 / 2000 [ 75%]  (Sampling)
Iteration: 1600 / 2000 [ 80%]  (Sampling)
Iteration: 1700 / 2000 [ 85%]  (Sampling)
Iteration: 1800 / 2000 [ 90%]  (Sampling)
Iteration: 1900 / 2000 [ 95%]  (Sampling)
Iteration: 2000 / 2000 [100%]  (Sampling)

 Elapsed Time: 1.84228 seconds (Warm-up)
               1.50516 seconds (Sampling)
               3.34745 seconds (Total)

method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_low_dim_gauss_mix_collapse_low_dim_gauss_mix_collapse.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)


Gradient evaluation took 0.000463 seconds
1000 transitions using 10 leapfrog steps per transition would take 4.63 seconds.
Adjust your expectations accordingly!


Iteration:    1 / 2000 [  0%]  (Warmup)
Iteration:  100 / 2000 [  5%]  (Warmup)
Iteration:  200 / 2000 [ 10%]  (Warmup)
Iteration:  300 / 2000 [ 15%]  (Warmup)
Iteration:  400 / 2000 [ 20%]  (Warmup)
Iteration:  500 / 2000 [ 25%]  (Warmup)
Iteration:  600 / 2000 [ 30%]  (Warmup)
Iteration:  700 / 2000 [ 35%]  (Warmup)
Iteration:  800 / 2000 [ 40%]  (Warmup)
Iteration:  900 / 2000 [ 45%]  (Warmup)
Iteration: 1000 / 2000 [ 50%]  (Warmup)
Iteration: 1001 / 2000 [ 50%]  (Sampling)
Iteration: 1100 / 2000 [ 55%]  (Sampling)
Iteration: 1200 / 2000 [ 60%]  (Sampling)
Iteration: 1300 / 2000 [ 65%]  (Sampling)
Iteration: 1400 / 2000 [ 70%]  (Sampling)
Iteration: 1500 / 2000 [ 75%]  (Sampling)
Iteration: 1600 / 2000 [ 80%]  (Sampling)
Iteration: 1700 / 2000 [ 85%]  (Sampling)
Iteration: 1800 / 2000 [ 90%]  (Sampling)
Iteration: 1900 / 2000 [ 95%]  (Sampling)
Iteration: 2000 / 2000 [100%]  (Sampling)

 Elapsed Time: 4.71579 seconds (Warm-up)
               5.34372 seconds (Sampling)
               10.0595 seconds (Total)

method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_pkpd_one_comp_mm_elim_abs.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)


Gradient evaluation took 0.002377 seconds
1000 transitions using 10 leapfrog steps per transition would take 23.77 seconds.
Adjust your expectations accordingly!


Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: integrate_ode_cvodes: parameter vector[2] is inf, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: integrate_ode_cvodes: parameter vector[2] is inf, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: integrate_ode_cvodes: parameter vector[2] is inf, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: integrate_ode_cvodes: parameter vector[2] is inf, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Iteration:    1 / 2000 [  0%]  (Warmup)
Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: integrate_ode_cvodes: parameter vector[2] is inf, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: integrate_ode_cvodes: parameter vector[2] is inf, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Iteration:  100 / 2000 [  5%]  (Warmup)
Iteration:  200 / 2000 [ 10%]  (Warmup)
Iteration:  300 / 2000 [ 15%]  (Warmup)
Iteration:  400 / 2000 [ 20%]  (Warmup)
Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: lognormal_lpdf: Location parameter is nan, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.stan' at line 68)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Iteration:  500 / 2000 [ 25%]  (Warmup)
Iteration:  600 / 2000 [ 30%]  (Warmup)
Iteration:  700 / 2000 [ 35%]  (Warmup)
Iteration:  800 / 2000 [ 40%]  (Warmup)
Iteration:  900 / 2000 [ 45%]  (Warmup)
Iteration: 1000 / 2000 [ 50%]  (Warmup)
Iteration: 1001 / 2000 [ 50%]  (Sampling)
Iteration: 1100 / 2000 [ 55%]  (Sampling)
Iteration: 1200 / 2000 [ 60%]  (Sampling)
Iteration: 1300 / 2000 [ 65%]  (Sampling)
Iteration: 1400 / 2000 [ 70%]  (Sampling)
Iteration: 1500 / 2000 [ 75%]  (Sampling)
Iteration: 1600 / 2000 [ 80%]  (Sampling)
Iteration: 1700 / 2000 [ 85%]  (Sampling)
Iteration: 1800 / 2000 [ 90%]  (Sampling)
Iteration: 1900 / 2000 [ 95%]  (Sampling)
Iteration: 2000 / 2000 [100%]  (Sampling)

 Elapsed Time: 14.658 seconds (Warm-up)
               9.50452 seconds (Sampling)
               24.1625 seconds (Total)

method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_pkpd_sim_one_comp_mm_elim_abs.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)

Must use algorithm=fixed_param for model that has no parameters.
method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = fixed_param
id = 0 (Default)
data
  file =  (Default)
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_pkpd_sim_one_comp_mm_elim_abs.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)

Iteration:   1 / 1000 [  0%]  (Sampling)
Iteration: 100 / 1000 [ 10%]  (Sampling)
Iteration: 200 / 1000 [ 20%]  (Sampling)
Iteration: 300 / 1000 [ 30%]  (Sampling)
Iteration: 400 / 1000 [ 40%]  (Sampling)
Iteration: 500 / 1000 [ 50%]  (Sampling)
Iteration: 600 / 1000 [ 60%]  (Sampling)
Iteration: 700 / 1000 [ 70%]  (Sampling)
Iteration: 800 / 1000 [ 80%]  (Sampling)
Iteration: 900 / 1000 [ 90%]  (Sampling)
Iteration: 1000 / 1000 [100%]  (Sampling)

 Elapsed Time: 0 seconds (Warm-up)
               0.349786 seconds (Sampling)
               0.349786 seconds (Total)

method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/sir/sir.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_sir_sir.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)


Gradient evaluation took 0.001395 seconds
1000 transitions using 10 leapfrog steps per transition would take 13.95 seconds.
Adjust your expectations accordingly!


Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: integrate_ode_rk45: parameter vector[3] is inf, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/sir/sir.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: integrate_ode_rk45: parameter vector[3] is inf, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/sir/sir.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: integrate_ode_rk45: parameter vector[3] is inf, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/sir/sir.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: integrate_ode_rk45: parameter vector[3] is inf, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/sir/sir.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: Max number of iterations exceeded (1000000).  (in '../stat_comp_benchmarks/benchmarks/sir/sir.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: Max number of iterations exceeded (1000000).  (in '../stat_comp_benchmarks/benchmarks/sir/sir.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: Max number of iterations exceeded (1000000).  (in '../stat_comp_benchmarks/benchmarks/sir/sir.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Iteration:    1 / 2000 [  0%]  (Warmup)
Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: integrate_ode_rk45: parameter vector[3] is inf, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/sir/sir.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: integrate_ode_rk45: parameter vector[3] is inf, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/sir/sir.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: Max number of iterations exceeded (1000000).  (in '../stat_comp_benchmarks/benchmarks/sir/sir.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Iteration:  100 / 2000 [  5%]  (Warmup)
Iteration:  200 / 2000 [ 10%]  (Warmup)
Iteration:  300 / 2000 [ 15%]  (Warmup)
Iteration:  400 / 2000 [ 20%]  (Warmup)
Iteration:  500 / 2000 [ 25%]  (Warmup)
Iteration:  600 / 2000 [ 30%]  (Warmup)
Iteration:  700 / 2000 [ 35%]  (Warmup)
Iteration:  800 / 2000 [ 40%]  (Warmup)
Iteration:  900 / 2000 [ 45%]  (Warmup)
Iteration: 1000 / 2000 [ 50%]  (Warmup)
Iteration: 1001 / 2000 [ 50%]  (Sampling)
Iteration: 1100 / 2000 [ 55%]  (Sampling)
Iteration: 1200 / 2000 [ 60%]  (Sampling)
Iteration: 1300 / 2000 [ 65%]  (Sampling)
Iteration: 1400 / 2000 [ 70%]  (Sampling)
Iteration: 1500 / 2000 [ 75%]  (Sampling)
Iteration: 1600 / 2000 [ 80%]  (Sampling)
Iteration: 1700 / 2000 [ 85%]  (Sampling)
Iteration: 1800 / 2000 [ 90%]  (Sampling)
Iteration: 1900 / 2000 [ 95%]  (Sampling)
Iteration: 2000 / 2000 [100%]  (Sampling)

 Elapsed Time: 51.3171 seconds (Warm-up)
               45.6999 seconds (Sampling)
               97.0171 seconds (Total)

arks/low_dim_corr_gauss/low_dim_corr_gauss method=sample algorithm='fixed_param' random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_low_dim_corr_gauss_low_dim_corr_gauss.gold.tmp
mv golds/stat_comp_benchmarks_benchmarks_low_dim_corr_gauss_low_dim_corr_gauss.gold.tmp golds/stat_comp_benchmarks_benchmarks_low_dim_corr_gauss_low_dim_corr_gauss.gold
stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_low_dim_gauss_mix_low_dim_gauss_mix.gold.tmp
mv golds/stat_comp_benchmarks_benchmarks_low_dim_gauss_mix_low_dim_gauss_mix.gold.tmp golds/stat_comp_benchmarks_benchmarks_low_dim_gauss_mix_low_dim_gauss_mix.gold
stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_low_dim_gauss_mix_collapse_low_dim_gauss_mix_collapse.gold.tmp
mv golds/stat_comp_benchmarks_benchmarks_low_dim_gauss_mix_collapse_low_dim_gauss_mix_collapse.gold.tmp golds/stat_comp_benchmarks_benchmarks_low_dim_gauss_mix_collapse_low_dim_gauss_mix_collapse.gold
stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_pkpd_one_comp_mm_elim_abs.gold.tmp
mv golds/stat_comp_benchmarks_benchmarks_pkpd_one_comp_mm_elim_abs.gold.tmp golds/stat_comp_benchmarks_benchmarks_pkpd_one_comp_mm_elim_abs.gold
stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_pkpd_sim_one_comp_mm_elim_abs.gold.tmp
stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs method=sample algorithm='fixed_param' random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_pkpd_sim_one_comp_mm_elim_abs.gold.tmp
mv golds/stat_comp_benchmarks_benchmarks_pkpd_sim_one_comp_mm_elim_abs.gold.tmp golds/stat_comp_benchmarks_benchmarks_pkpd_sim_one_comp_mm_elim_abs.gold
stat_comp_benchmarks/benchmarks/sir/sir method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/sir/sir.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_sir_sir.gold.tmp
mv golds/stat_comp_benchmarks_benchmarks_sir_sir.gold.tmp golds/stat_comp_benchmarks_benchmarks_sir_sir.gold
+ for i in 'performance.*'
+ mv performance.csv develop_performance.csv
+ for i in 'performance.*'
+ mv performance.xml develop_performance.xml
+ clean_checkout develop PR-2775 develop
+ make revert
git submodule update --init --recursive
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
+ cd cmdstan
+ [[ develop == \P\R\-* ]]
+ git fetch
+ git checkout develop
Already on 'develop'
Your branch is up-to-date with 'origin/develop'.
+ git pull origin develop
From https://github.com/stan-dev/cmdstan
 * branch            develop    -> FETCH_HEAD
Already up-to-date.
+ git reset --hard HEAD
HEAD is now at 7fdbd7d Updates the Stan submodule to d03404ca9.
+ git clean -xffd
Removing bin/
Removing make/local
Removing src/cmdstan/stanc.d
+ git submodule update --init --recursive
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
+ cd stan
+ [[ PR-2775 == \P\R\-* ]]
++ echo PR-2775
++ cut -d - -f 2
+ prNumber=2775
+ git fetch https://github.com/stan-dev/stan +refs/pull/2775/merge:refs/remotes/origin/pr/2775/merge
From https://github.com/stan-dev/stan
 * [new ref]         refs/pull/2775/merge -> origin/pr/2775/merge
+ git checkout refs/remotes/origin/pr/2775/merge
Previous HEAD position was d03404c... Updates the Math submodule to 8f8cbbb.
HEAD is now at c0ad1df... Merge 1ddac3fc56d97aeca26cdf2c99720bfc5f0cc99b into d03404ca999095e2a85b3b4c8ad70964f956d601
+ git reset --hard HEAD
HEAD is now at c0ad1df Merge 1ddac3fc56d97aeca26cdf2c99720bfc5f0cc99b into d03404ca999095e2a85b3b4c8ad70964f956d601
+ git clean -xffd
Removing src/stan/lang/ast_def.d
Removing src/stan/lang/grammars/bare_type_grammar_inst.d
Removing src/stan/lang/grammars/block_var_decls_grammar_inst.d
Removing src/stan/lang/grammars/expression07_grammar_inst.d
Removing src/stan/lang/grammars/expression_grammar_inst.d
Removing src/stan/lang/grammars/functions_grammar_inst.d
Removing src/stan/lang/grammars/indexes_grammar_inst.d
Removing src/stan/lang/grammars/local_var_decls_grammar_inst.d
Removing src/stan/lang/grammars/program_grammar_inst.d
Removing src/stan/lang/grammars/semantic_actions_def.d
Removing src/stan/lang/grammars/statement_2_grammar_inst.d
Removing src/stan/lang/grammars/statement_grammar_inst.d
Removing src/stan/lang/grammars/term_grammar_inst.d
Removing src/stan/lang/grammars/whitespace_grammar_inst.d
Removing src/stan/model/model_header.d
Removing src/stan/model/model_header.hpp.gch
+ cd ..
+ pushd stan/lib/stan_math
/Users/Shared/Jenkins/gelman-group-mac/workspace/rformance_Tests_downstream_tests/cmdstan/stan/lib/stan_math /Users/Shared/Jenkins/gelman-group-mac/workspace/rformance_Tests_downstream_tests/cmdstan
+ [[ develop == \P\R\-* ]]
+ '[' develop '!=' false ']'
+ git fetch
+ git checkout develop
Switched to branch 'develop'
Your branch is up-to-date with 'origin/develop'.
+ git pull origin develop
From https://github.com/stan-dev/math
 * branch            develop    -> FETCH_HEAD
Already up-to-date.
+ git reset --hard HEAD
HEAD is now at 8f8cbbb Merge pull request #1234 from bstatcomp/feature/issue-1122-is-constant-struct-parameter-packs
+ git clean -xffd
Removing lib/sundials_4.1.0/lib/
Removing lib/sundials_4.1.0/src/cvodes/cvodea.o
Removing lib/sundials_4.1.0/src/cvodes/cvodea_io.o
Removing lib/sundials_4.1.0/src/cvodes/cvodes.o
Removing lib/sundials_4.1.0/src/cvodes/cvodes_bandpre.o
Removing lib/sundials_4.1.0/src/cvodes/cvodes_bbdpre.o
Removing lib/sundials_4.1.0/src/cvodes/cvodes_diag.o
Removing lib/sundials_4.1.0/src/cvodes/cvodes_direct.o
Removing lib/sundials_4.1.0/src/cvodes/cvodes_io.o
Removing lib/sundials_4.1.0/src/cvodes/cvodes_ls.o
Removing lib/sundials_4.1.0/src/cvodes/cvodes_nls.o
Removing lib/sundials_4.1.0/src/cvodes/cvodes_nls_sim.o
Removing lib/sundials_4.1.0/src/cvodes/cvodes_nls_stg.o
Removing lib/sundials_4.1.0/src/cvodes/cvodes_nls_stg1.o
Removing lib/sundials_4.1.0/src/cvodes/cvodes_spils.o
Removing lib/sundials_4.1.0/src/idas/idaa.o
Removing lib/sundials_4.1.0/src/idas/idaa_io.o
Removing lib/sundials_4.1.0/src/idas/idas.o
Removing lib/sundials_4.1.0/src/idas/idas_bbdpre.o
Removing lib/sundials_4.1.0/src/idas/idas_direct.o
Removing lib/sundials_4.1.0/src/idas/idas_ic.o
Removing lib/sundials_4.1.0/src/idas/idas_io.o
Removing lib/sundials_4.1.0/src/idas/idas_ls.o
Removing lib/sundials_4.1.0/src/idas/idas_nls.o
Removing lib/sundials_4.1.0/src/idas/idas_nls_sim.o
Removing lib/sundials_4.1.0/src/idas/idas_nls_stg.o
Removing lib/sundials_4.1.0/src/idas/idas_spils.o
Removing lib/sundials_4.1.0/src/nvector/serial/nvector_serial.o
Removing lib/sundials_4.1.0/src/sundials/sundials_band.o
Removing lib/sundials_4.1.0/src/sundials/sundials_dense.o
Removing lib/sundials_4.1.0/src/sundials/sundials_direct.o
Removing lib/sundials_4.1.0/src/sundials/sundials_iterative.o
Removing lib/sundials_4.1.0/src/sundials/sundials_linearsolver.o
Removing lib/sundials_4.1.0/src/sundials/sundials_math.o
Removing lib/sundials_4.1.0/src/sundials/sundials_matrix.o
Removing lib/sundials_4.1.0/src/sundials/sundials_mpi.o
Removing lib/sundials_4.1.0/src/sundials/sundials_nonlinearsolver.o
Removing lib/sundials_4.1.0/src/sundials/sundials_nvector.o
Removing lib/sundials_4.1.0/src/sundials/sundials_nvector_senswrapper.o
Removing lib/sundials_4.1.0/src/sundials/sundials_pcg.o
Removing lib/sundials_4.1.0/src/sundials/sundials_sparse.o
Removing lib/sundials_4.1.0/src/sundials/sundials_spbcgs.o
Removing lib/sundials_4.1.0/src/sundials/sundials_sptfqmr.o
Removing lib/sundials_4.1.0/src/sundials/sundials_version.o
Removing lib/sundials_4.1.0/src/sunlinsol/band/sunlinsol_band.o
Removing lib/sundials_4.1.0/src/sunlinsol/dense/sunlinsol_dense.o
Removing lib/sundials_4.1.0/src/sunmatrix/band/sunmatrix_band.o
Removing lib/sundials_4.1.0/src/sunmatrix/dense/sunmatrix_dense.o
Removing lib/sundials_4.1.0/src/sunnonlinsol/fixedpoint/sunnonlinsol_fixedpoint.o
Removing lib/sundials_4.1.0/src/sunnonlinsol/newton/sunnonlinsol_newton.o
+ popd
/Users/Shared/Jenkins/gelman-group-mac/workspace/rformance_Tests_downstream_tests/cmdstan
+ cd ..
+ make clean
cd cmdstan; make clean-all; cd ..
rm -f -r doc
cd src/docs/cmdstan-guide; rm -f *.brf *.aux *.bbl *.blg *.log *.toc *.pdf *.out *.idx *.ilg *.ind *.cb *.cb2 *.upa
rm -f -r test
rm -f 
rm -f 
  removing dependency files
  cleaning sundials targets
rm -f 
rm -f -r bin
rm -f 
git submodule foreach --recursive git clean -xffd
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
Entering 'cmdstan'
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
Entering 'cmdstan/stan'
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
Entering 'cmdstan/stan/lib/stan_math'
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
Entering 'example-models'
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
Entering 'stat_comp_benchmarks'
Removing benchmarks/arK/arK
Removing benchmarks/arK/arK.d
Removing benchmarks/arK/arK.hpp
Removing benchmarks/arma/arma
Removing benchmarks/arma/arma.d
Removing benchmarks/arma/arma.hpp
Removing benchmarks/eight_schools/eight_schools
Removing benchmarks/eight_schools/eight_schools.d
Removing benchmarks/eight_schools/eight_schools.hpp
Removing benchmarks/garch/garch
Removing benchmarks/garch/garch.d
Removing benchmarks/garch/garch.hpp
Removing benchmarks/gp_pois_regr/gp_pois_regr
Removing benchmarks/gp_pois_regr/gp_pois_regr.d
Removing benchmarks/gp_pois_regr/gp_pois_regr.hpp
Removing benchmarks/gp_regr/gen_gp_data
Removing benchmarks/gp_regr/gen_gp_data.d
Removing benchmarks/gp_regr/gen_gp_data.hpp
Removing benchmarks/gp_regr/gp_regr
Removing benchmarks/gp_regr/gp_regr.d
Removing benchmarks/gp_regr/gp_regr.hpp
Removing benchmarks/irt_2pl/irt_2pl
Removing benchmarks/irt_2pl/irt_2pl.d
Removing benchmarks/irt_2pl/irt_2pl.hpp
Removing benchmarks/low_dim_corr_gauss/low_dim_corr_gauss
Removing benchmarks/low_dim_corr_gauss/low_dim_corr_gauss.d
Removing benchmarks/low_dim_corr_gauss/low_dim_corr_gauss.hpp
Removing benchmarks/low_dim_gauss_mix/low_dim_gauss_mix
Removing benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.d
Removing benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.hpp
Removing benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse
Removing benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.d
Removing benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.hpp
Removing benchmarks/pkpd/one_comp_mm_elim_abs
Removing benchmarks/pkpd/one_comp_mm_elim_abs.d
Removing benchmarks/pkpd/one_comp_mm_elim_abs.hpp
Removing benchmarks/pkpd/sim_one_comp_mm_elim_abs
Removing benchmarks/pkpd/sim_one_comp_mm_elim_abs.d
Removing benchmarks/pkpd/sim_one_comp_mm_elim_abs.hpp
Removing benchmarks/sir/sir
Removing benchmarks/sir/sir.d
Removing benchmarks/sir/sir.hpp
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
+ cd cmdstan
++ git status --porcelain
+ dirty=' M stan'
+ write_makelocal
+ echo 'CXXFLAGS += -march=native'
+ git status
On branch develop
Your branch is up-to-date with 'origin/develop'.
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   stan (new commits)

no changes added to commit (use "git add" and/or "git commit -a")
+ cd ..
+ ./runPerformanceTests.py --check-golds-exact 2e-8 stat_comp_benchmarks
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT src/cmdstan/stanc.o -MM -E -MG -MP -MF src/cmdstan/stanc.d src/cmdstan/stanc.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/semantic_actions_def.o -MT stan/src/stan/lang/grammars/semantic_actions_def.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/semantic_actions_def.d stan/src/stan/lang/grammars/semantic_actions_def.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/ast_def.o -MT stan/src/stan/lang/ast_def.d -MM -E -MG -MP -MF stan/src/stan/lang/ast_def.d stan/src/stan/lang/ast_def.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/whitespace_grammar_inst.o -MT stan/src/stan/lang/grammars/whitespace_grammar_inst.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/whitespace_grammar_inst.d stan/src/stan/lang/grammars/whitespace_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/term_grammar_inst.o -MT stan/src/stan/lang/grammars/term_grammar_inst.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/term_grammar_inst.d stan/src/stan/lang/grammars/term_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/statement_grammar_inst.o -MT stan/src/stan/lang/grammars/statement_grammar_inst.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/statement_grammar_inst.d stan/src/stan/lang/grammars/statement_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/statement_2_grammar_inst.o -MT stan/src/stan/lang/grammars/statement_2_grammar_inst.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/statement_2_grammar_inst.d stan/src/stan/lang/grammars/statement_2_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/program_grammar_inst.o -MT stan/src/stan/lang/grammars/program_grammar_inst.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/program_grammar_inst.d stan/src/stan/lang/grammars/program_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/local_var_decls_grammar_inst.o -MT stan/src/stan/lang/grammars/local_var_decls_grammar_inst.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/local_var_decls_grammar_inst.d stan/src/stan/lang/grammars/local_var_decls_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/indexes_grammar_inst.o -MT stan/src/stan/lang/grammars/indexes_grammar_inst.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/indexes_grammar_inst.d stan/src/stan/lang/grammars/indexes_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/functions_grammar_inst.o -MT stan/src/stan/lang/grammars/functions_grammar_inst.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/functions_grammar_inst.d stan/src/stan/lang/grammars/functions_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/expression_grammar_inst.o -MT stan/src/stan/lang/grammars/expression_grammar_inst.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/expression_grammar_inst.d stan/src/stan/lang/grammars/expression_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/expression07_grammar_inst.o -MT stan/src/stan/lang/grammars/expression07_grammar_inst.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/expression07_grammar_inst.d stan/src/stan/lang/grammars/expression07_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/block_var_decls_grammar_inst.o -MT stan/src/stan/lang/grammars/block_var_decls_grammar_inst.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/block_var_decls_grammar_inst.d stan/src/stan/lang/grammars/block_var_decls_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT bin/cmdstan/lang/grammars/bare_type_grammar_inst.o -MT stan/src/stan/lang/grammars/bare_type_grammar_inst.d -MM -E -MG -MP -MF stan/src/stan/lang/grammars/bare_type_grammar_inst.d stan/src/stan/lang/grammars/bare_type_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT stan/src/stan/model/model_header.hpp.gch -MT stan/src/stan/model/model_header.d -MM -E -MG -MP -MF stan/src/stan/model/model_header.d stan/src/stan/model/model_header.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/stanc.o src/cmdstan/stanc.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/bare_type_grammar_inst.o stan/src/stan/lang/grammars/bare_type_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/expression07_grammar_inst.o stan/src/stan/lang/grammars/expression07_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/block_var_decls_grammar_inst.o stan/src/stan/lang/grammars/block_var_decls_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/expression_grammar_inst.o stan/src/stan/lang/grammars/expression_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/functions_grammar_inst.o stan/src/stan/lang/grammars/functions_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/indexes_grammar_inst.o stan/src/stan/lang/grammars/indexes_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/local_var_decls_grammar_inst.o stan/src/stan/lang/grammars/local_var_decls_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/statement_2_grammar_inst.o stan/src/stan/lang/grammars/statement_2_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/program_grammar_inst.o stan/src/stan/lang/grammars/program_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/statement_grammar_inst.o stan/src/stan/lang/grammars/statement_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/term_grammar_inst.o stan/src/stan/lang/grammars/term_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/whitespace_grammar_inst.o stan/src/stan/lang/grammars/whitespace_grammar_inst.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/ast_def.o stan/src/stan/lang/ast_def.cpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -o bin/cmdstan/lang/grammars/semantic_actions_def.o stan/src/stan/lang/grammars/semantic_actions_def.cpp
ar -rs bin/cmdstan/libstanc.a bin/cmdstan/lang/grammars/bare_type_grammar_inst.o bin/cmdstan/lang/grammars/block_var_decls_grammar_inst.o bin/cmdstan/lang/grammars/expression07_grammar_inst.o bin/cmdstan/lang/grammars/expression_grammar_inst.o bin/cmdstan/lang/grammars/functions_grammar_inst.o bin/cmdstan/lang/grammars/indexes_grammar_inst.o bin/cmdstan/lang/grammars/local_var_decls_grammar_inst.o bin/cmdstan/lang/grammars/program_grammar_inst.o bin/cmdstan/lang/grammars/statement_2_grammar_inst.o bin/cmdstan/lang/grammars/statement_grammar_inst.o bin/cmdstan/lang/grammars/term_grammar_inst.o bin/cmdstan/lang/grammars/whitespace_grammar_inst.o bin/cmdstan/lang/ast_def.o bin/cmdstan/lang/grammars/semantic_actions_def.o
ar: creating archive bin/cmdstan/libstanc.a
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O0 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            bin/cmdstan/stanc.o bin/cmdstan/libstanc.a        -o bin/stanc








--- Translating Stan model to C++ code ---
--- Translating Stan model to C++ code ---
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/sir/sir.hpp ../stat_comp_benchmarks/benchmarks/sir/sir.stan
--- Translating Stan model to C++ code ---
--- Translating Stan model to C++ code ---
--- Translating Stan model to C++ code ---
--- Translating Stan model to C++ code ---

--- Translating Stan model to C++ code ---
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.hpp ../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.stan
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss.hpp ../stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss.stan
--- Translating Stan model to C++ code ---
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data.hpp ../stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data.stan
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.hpp ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.stan
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.hpp ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.stan
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.hpp ../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.stan
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs.hpp ../stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs.stan
--- Translating Stan model to C++ code ---
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.hpp ../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.stan





--- Translating Stan model to C++ code ---
--- Translating Stan model to C++ code ---
--- Translating Stan model to C++ code ---
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/garch/garch.hpp ../stat_comp_benchmarks/benchmarks/garch/garch.stan
--- Translating Stan model to C++ code ---
--- Translating Stan model to C++ code ---
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/arK/arK.hpp ../stat_comp_benchmarks/benchmarks/arK/arK.stan
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.hpp ../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.stan
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/arma/arma.hpp ../stat_comp_benchmarks/benchmarks/arma/arma.stan
bin/stanc  --o=../stat_comp_benchmarks/benchmarks/eight_schools/eight_schools.hpp ../stat_comp_benchmarks/benchmarks/eight_schools/eight_schools.stan
Model name=sir_model
Input file=../stat_comp_benchmarks/benchmarks/sir/sir.stan
Output file=../stat_comp_benchmarks/benchmarks/sir/sir.hpp
Model name=arma_model
Input file=../stat_comp_benchmarks/benchmarks/arma/arma.stan
Output file=../stat_comp_benchmarks/benchmarks/arma/arma.hpp
Model name=garch_model
Input file=../stat_comp_benchmarks/benchmarks/garch/garch.stan
Output file=../stat_comp_benchmarks/benchmarks/garch/garch.hpp
Model name=one_comp_mm_elim_abs_model
Input file=../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.stan
Output file=../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.hpp
Model name=irt_2pl_model
Input file=../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.stan
Output file=../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.hpp
Model name=low_dim_gauss_mix_collapse_model
Input file=../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.stan
Output file=../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.hpp
Model name=arK_model
Input file=../stat_comp_benchmarks/benchmarks/arK/arK.stan
Output file=../stat_comp_benchmarks/benchmarks/arK/arK.hpp
Model name=gp_regr_model
Input file=../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.stan
Output file=../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.hpp
Model name=low_dim_corr_gauss_model
Input file=../stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss.stan
Output file=../stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss.hpp
Model name=eight_schools_model
Input file=../stat_comp_benchmarks/benchmarks/eight_schools/eight_schools.stan
Output file=../stat_comp_benchmarks/benchmarks/eight_schools/eight_schools.hpp
Model name=sim_one_comp_mm_elim_abs_model
Input file=../stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs.stan
Output file=../stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs.hpp
Model name=gen_gp_data_model
Input file=../stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data.stan
Output file=../stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data.hpp
Model name=gp_pois_regr_model
Input file=../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.stan
Output file=../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.hpp
Model name=low_dim_gauss_mix_model
Input file=../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.stan
Output file=../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/garch/garch.o -MT ../stat_comp_benchmarks/benchmarks/garch/garch -include ../stat_comp_benchmarks/benchmarks/garch/garch.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/garch/garch.d ../stat_comp_benchmarks/benchmarks/garch/garch.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/arK/arK.o -MT ../stat_comp_benchmarks/benchmarks/arK/arK -include ../stat_comp_benchmarks/benchmarks/arK/arK.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/arK/arK.d ../stat_comp_benchmarks/benchmarks/arK/arK.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.o -MT ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse -include ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.d ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/arma/arma.o -MT ../stat_comp_benchmarks/benchmarks/arma/arma -include ../stat_comp_benchmarks/benchmarks/arma/arma.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/arma/arma.d ../stat_comp_benchmarks/benchmarks/arma/arma.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.o -MT ../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr -include ../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.d ../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.o -MT ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix -include ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.d ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/eight_schools/eight_schools.o -MT ../stat_comp_benchmarks/benchmarks/eight_schools/eight_schools -include ../stat_comp_benchmarks/benchmarks/eight_schools/eight_schools.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/eight_schools/eight_schools.d ../stat_comp_benchmarks/benchmarks/eight_schools/eight_schools.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.o -MT ../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl -include ../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.d ../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.o -MT ../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr -include ../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.d ../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss.o -MT ../stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss -include ../stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss.d ../stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data.o -MT ../stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data -include ../stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data.d ../stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.o -MT ../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs -include ../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.d ../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/sir/sir.o -MT ../stat_comp_benchmarks/benchmarks/sir/sir -include ../stat_comp_benchmarks/benchmarks/sir/sir.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/sir/sir.d ../stat_comp_benchmarks/benchmarks/sir/sir.hpp
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c -MT ../stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs.o -MT ../stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs -include ../stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs.hpp -include src/cmdstan/main.cpp -MM -E -MG -MP -MF ../stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs.d ../stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs.hpp
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/nvector/serial/nvector_serial.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/nvector/serial/nvector_serial.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodea_io.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodea_io.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodea.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodea.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_math.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_math.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_bbdpre.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_bbdpre.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_direct.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_direct.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_io.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_io.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_diag.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_diag.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_bandpre.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_bandpre.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls_sim.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls_sim.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_ls.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_ls.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls_stg.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls_stg.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_spils.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_spils.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls_stg1.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls_stg1.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_band.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_band.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_dense.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_dense.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_direct.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_direct.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_iterative.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_iterative.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_linearsolver.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_linearsolver.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_matrix.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_matrix.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_mpi.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_mpi.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nonlinearsolver.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nonlinearsolver.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nvector.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nvector.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nvector_senswrapper.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nvector_senswrapper.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_pcg.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_pcg.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_sparse.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_sparse.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_spbcgs.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_spbcgs.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_sptfqmr.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_sptfqmr.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_version.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_version.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sunmatrix/band/sunmatrix_band.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sunmatrix/band/sunmatrix_band.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sunmatrix/dense/sunmatrix_dense.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sunmatrix/dense/sunmatrix_dense.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sunlinsol/band/sunlinsol_band.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sunlinsol/band/sunlinsol_band.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sunlinsol/dense/sunlinsol_dense.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sunlinsol/dense/sunlinsol_dense.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sunnonlinsol/newton/sunnonlinsol_newton.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sunnonlinsol/newton/sunnonlinsol_newton.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/sunnonlinsol/fixedpoint/sunnonlinsol_fixedpoint.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/sunnonlinsol/fixedpoint/sunnonlinsol_fixedpoint.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idaa.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idaa.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idaa_io.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idaa_io.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_bbdpre.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_bbdpre.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_direct.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_direct.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_ic.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_ic.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_io.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_io.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_ls.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_ls.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_nls.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_nls.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_nls_sim.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_nls_sim.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_nls_stg.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_nls_stg.o
/usr/local/opt/llvm@6/bin/clang++ -pipe -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare -O3 -I stan/lib/stan_math/lib/sundials_4.1.0/include -DNO_FPRINTF_OUTPUT   -c -x c -include stan/lib/stan_math/lib/sundials_4.1.0/include/stan_sundials_printf_override.hpp stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_spils.c -o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_spils.o
ar -rs stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/src/nvector/serial/nvector_serial.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_math.o
ar: creating archive stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a
ar -rs stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idaa.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idaa_io.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_bbdpre.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_direct.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_ic.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_io.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_ls.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_nls.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_nls_sim.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_nls_stg.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_spils.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_band.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_dense.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_direct.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_iterative.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_linearsolver.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_math.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_matrix.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_mpi.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nonlinearsolver.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nvector.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nvector_senswrapper.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_pcg.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_sparse.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_spbcgs.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_sptfqmr.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_version.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunmatrix/band/sunmatrix_band.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunmatrix/dense/sunmatrix_dense.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunlinsol/band/sunlinsol_band.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunlinsol/dense/sunlinsol_dense.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunnonlinsol/newton/sunnonlinsol_newton.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunnonlinsol/fixedpoint/sunnonlinsol_fixedpoint.o
ar: creating archive stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a
ar -rs stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodea.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodea_io.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_bandpre.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_bbdpre.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_diag.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_direct.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_io.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_ls.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls_sim.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls_stg.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls_stg1.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_spils.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_band.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_dense.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_direct.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_iterative.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_linearsolver.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_math.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_matrix.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_mpi.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nonlinearsolver.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nvector.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nvector_senswrapper.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_pcg.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_sparse.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_spbcgs.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_sptfqmr.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_version.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunmatrix/band/sunmatrix_band.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunmatrix/dense/sunmatrix_dense.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunlinsol/band/sunlinsol_band.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunlinsol/dense/sunlinsol_dense.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunnonlinsol/newton/sunnonlinsol_newton.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunnonlinsol/fixedpoint/sunnonlinsol_fixedpoint.o
ar: creating archive stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a

--- Compiling pre-compiled header ---	
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION     -c stan/src/stan/model/model_header.hpp -o stan/src/stan/model/model_header.hpp.gch

--- Linking C++ model ---

/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/arK/arK.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/arK/arK
--- Linking C++ model ---
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/arma/arma.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/arma/arma

--- Linking C++ model ---

/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/eight_schools/eight_schools.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/eight_schools/eight_schools
--- Linking C++ model ---

/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/garch/garch.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/garch/garch
--- Linking C++ model ---

/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr
--- Linking C++ model ---

/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data
--- Linking C++ model ---

/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr
--- Linking C++ model ---

/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl
--- Linking C++ model ---

/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss
--- Linking C++ model ---

/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix
--- Linking C++ model ---

/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse
--- Linking C++ model ---

/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs
--- Linking C++ model ---
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs

--- Linking C++ model ---
/usr/local/opt/llvm@6/bin/clang++ -march=native -std=c++1y -Wno-unknown-warning-option -Wno-tautological-compare -Wno-sign-compare      -O3 -I src -I stan/src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION            -include-pch stan/src/stan/model/model_header.hpp.gch -include ../stat_comp_benchmarks/benchmarks/sir/sir.hpp src/cmdstan/main.cpp        stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  -o ../stat_comp_benchmarks/benchmarks/sir/sir
method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/arK/arK.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_arK_arK.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)


Gradient evaluation took 0.000125 seconds
1000 transitions using 10 leapfrog steps per transition would take 1.25 seconds.
Adjust your expectations accordingly!


Iteration:    1 / 2000 [  0%]  (Warmup)
Iteration:  100 / 2000 [  5%]  (Warmup)
Iteration:  200 / 2000 [ 10%]  (Warmup)
Iteration:  300 / 2000 [ 15%]  (Warmup)
Iteration:  400 / 2000 [ 20%]  (Warmup)
Iteration:  500 / 2000 [ 25%]  (Warmup)
Iteration:  600 / 2000 [ 30%]  (Warmup)
Iteration:  700 / 2000 [ 35%]  (Warmup)
Iteration:  800 / 2000 [ 40%]  (Warmup)
Iteration:  900 / 2000 [ 45%]  (Warmup)
Iteration: 1000 / 2000 [ 50%]  (Warmup)
Iteration: 1001 / 2000 [ 50%]  (Sampling)
Iteration: 1100 / 2000 [ 55%]  (Sampling)
Iteration: 1200 / 2000 [ 60%]  (Sampling)
Iteration: 1300 / 2000 [ 65%]  (Sampling)
Iteration: 1400 / 2000 [ 70%]  (Sampling)
Iteration: 1500 / 2000 [ 75%]  (Sampling)
Iteration: 1600 / 2000 [ 80%]  (Sampling)
Iteration: 1700 / 2000 [ 85%]  (Sampling)
Iteration: 1800 / 2000 [ 90%]  (Sampling)
Iteration: 1900 / 2000 [ 95%]  (Sampling)
Iteration: 2000 / 2000 [100%]  (Sampling)

 Elapsed Time: 1.10394 seconds (Warm-up)
               1.24124 seconds (Sampling)
               2.34518 seconds (Total)

method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/arma/arma.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_arma_arma.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)


Gradient evaluation took 5.9e-05 seconds
1000 transitions using 10 leapfrog steps per transition would take 0.59 seconds.
Adjust your expectations accordingly!


Iteration:    1 / 2000 [  0%]  (Warmup)
Iteration:  100 / 2000 [  5%]  (Warmup)
Iteration:  200 / 2000 [ 10%]  (Warmup)
Iteration:  300 / 2000 [ 15%]  (Warmup)
Iteration:  400 / 2000 [ 20%]  (Warmup)
Iteration:  500 / 2000 [ 25%]  (Warmup)
Iteration:  600 / 2000 [ 30%]  (Warmup)
Iteration:  700 / 2000 [ 35%]  (Warmup)
Iteration:  800 / 2000 [ 40%]  (Warmup)
Iteration:  900 / 2000 [ 45%]  (Warmup)
Iteration: 1000 / 2000 [ 50%]  (Warmup)
Iteration: 1001 / 2000 [ 50%]  (Sampling)
Iteration: 1100 / 2000 [ 55%]  (Sampling)
Iteration: 1200 / 2000 [ 60%]  (Sampling)
Iteration: 1300 / 2000 [ 65%]  (Sampling)
Iteration: 1400 / 2000 [ 70%]  (Sampling)
Iteration: 1500 / 2000 [ 75%]  (Sampling)
Iteration: 1600 / 2000 [ 80%]  (Sampling)
Iteration: 1700 / 2000 [ 85%]  (Sampling)
Iteration: 1800 / 2000 [ 90%]  (Sampling)
Iteration: 1900 / 2000 [ 95%]  (Sampling)
Iteration: 2000 / 2000 [100%]  (Sampling)

 Elapsed Time: 0.247781 seconds (Warm-up)
               0.426837 seconds (Sampling)
               0.674618 seconds (Total)

method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/eight_schools/eight_schools.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_eight_schools_eight_schools.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)


Gradient evaluation took 2.1e-05 seconds
1000 transitions using 10 leapfrog steps per transition would take 0.21 seconds.
Adjust your expectations accordingly!


Iteration:    1 / 2000 [  0%]  (Warmup)
Iteration:  100 / 2000 [  5%]  (Warmup)
Iteration:  200 / 2000 [ 10%]  (Warmup)
Iteration:  300 / 2000 [ 15%]  (Warmup)
Iteration:  400 / 2000 [ 20%]  (Warmup)
Iteration:  500 / 2000 [ 25%]  (Warmup)
Iteration:  600 / 2000 [ 30%]  (Warmup)
Iteration:  700 / 2000 [ 35%]  (Warmup)
Iteration:  800 / 2000 [ 40%]  (Warmup)
Iteration:  900 / 2000 [ 45%]  (Warmup)
Iteration: 1000 / 2000 [ 50%]  (Warmup)
Iteration: 1001 / 2000 [ 50%]  (Sampling)
Iteration: 1100 / 2000 [ 55%]  (Sampling)
Iteration: 1200 / 2000 [ 60%]  (Sampling)
Iteration: 1300 / 2000 [ 65%]  (Sampling)
Iteration: 1400 / 2000 [ 70%]  (Sampling)
Iteration: 1500 / 2000 [ 75%]  (Sampling)
Iteration: 1600 / 2000 [ 80%]  (Sampling)
Iteration: 1700 / 2000 [ 85%]  (Sampling)
Iteration: 1800 / 2000 [ 90%]  (Sampling)
Iteration: 1900 / 2000 [ 95%]  (Sampling)
Iteration: 2000 / 2000 [100%]  (Sampling)

 Elapsed Time: 0.03743 seconds (Warm-up)
               0.045414 seconds (Sampling)
               0.082844 seconds (Total)

method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/garch/garch.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_garch_garch.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)


Gradient evaluation took 8e-05 seconds
1000 transitions using 10 leapfrog steps per transition would take 0.8 seconds.
Adjust your expectations accordingly!


Iteration:    1 / 2000 [  0%]  (Warmup)
Iteration:  100 / 2000 [  5%]  (Warmup)
Iteration:  200 / 2000 [ 10%]  (Warmup)
Iteration:  300 / 2000 [ 15%]  (Warmup)
Iteration:  400 / 2000 [ 20%]  (Warmup)
Iteration:  500 / 2000 [ 25%]  (Warmup)
Iteration:  600 / 2000 [ 30%]  (Warmup)
Iteration:  700 / 2000 [ 35%]  (Warmup)
Iteration:  800 / 2000 [ 40%]  (Warmup)
Iteration:  900 / 2000 [ 45%]  (Warmup)
Iteration: 1000 / 2000 [ 50%]  (Warmup)
Iteration: 1001 / 2000 [ 50%]  (Sampling)
Iteration: 1100 / 2000 [ 55%]  (Sampling)
Iteration: 1200 / 2000 [ 60%]  (Sampling)
Iteration: 1300 / 2000 [ 65%]  (Sampling)
Iteration: 1400 / 2000 [ 70%]  (Sampling)
Iteration: 1500 / 2000 [ 75%]  (Sampling)
Iteration: 1600 / 2000 [ 80%]  (Sampling)
Iteration: 1700 / 2000 [ 85%]  (Sampling)
Iteration: 1800 / 2000 [ 90%]  (Sampling)
Iteration: 1900 / 2000 [ 95%]  (Sampling)
Iteration: 2000 / 2000 [100%]  (Sampling)

 Elapsed Time: 0.298068 seconds (Warm-up)
               0.264677 seconds (Sampling)
               0.562745 seconds (Total)

method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_gp_pois_regr_gp_pois_regr.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)


Gradient evaluation took 0.000218 seconds
1000 transitions using 10 leapfrog steps per transition would take 2.18 seconds.
Adjust your expectations accordingly!


Iteration:    1 / 2000 [  0%]  (Warmup)
Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: gp_exp_quad_cov: length_scale is 0, but must be > 0!  (in '../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.stan' at line 16)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Iteration:  100 / 2000 [  5%]  (Warmup)
Iteration:  200 / 2000 [ 10%]  (Warmup)
Iteration:  300 / 2000 [ 15%]  (Warmup)
Iteration:  400 / 2000 [ 20%]  (Warmup)
Iteration:  500 / 2000 [ 25%]  (Warmup)
Iteration:  600 / 2000 [ 30%]  (Warmup)
Iteration:  700 / 2000 [ 35%]  (Warmup)
Iteration:  800 / 2000 [ 40%]  (Warmup)
Iteration:  900 / 2000 [ 45%]  (Warmup)
Iteration: 1000 / 2000 [ 50%]  (Warmup)
Iteration: 1001 / 2000 [ 50%]  (Sampling)
Iteration: 1100 / 2000 [ 55%]  (Sampling)
Iteration: 1200 / 2000 [ 60%]  (Sampling)
Iteration: 1300 / 2000 [ 65%]  (Sampling)
Iteration: 1400 / 2000 [ 70%]  (Sampling)
Iteration: 1500 / 2000 [ 75%]  (Sampling)
Iteration: 1600 / 2000 [ 80%]  (Sampling)
Iteration: 1700 / 2000 [ 85%]  (Sampling)
Iteration: 1800 / 2000 [ 90%]  (Sampling)
Iteration: 1900 / 2000 [ 95%]  (Sampling)
Iteration: 2000 / 2000 [100%]  (Sampling)

 Elapsed Time: 2.03126 seconds (Warm-up)
               2.11208 seconds (Sampling)
               4.14334 seconds (Total)

method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_gp_regr_gen_gp_data.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)

Must use algorithm=fixed_param for model that has no parameters.
method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = fixed_param
id = 0 (Default)
data
  file =  (Default)
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_gp_regr_gen_gp_data.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)

Iteration:   1 / 1000 [  0%]  (Sampling)
Iteration: 100 / 1000 [ 10%]  (Sampling)
Iteration: 200 / 1000 [ 20%]  (Sampling)
Iteration: 300 / 1000 [ 30%]  (Sampling)
Iteration: 400 / 1000 [ 40%]  (Sampling)
Iteration: 500 / 1000 [ 50%]  (Sampling)
Iteration: 600 / 1000 [ 60%]  (Sampling)
Iteration: 700 / 1000 [ 70%]  (Sampling)
Iteration: 800 / 1000 [ 80%]  (Sampling)
Iteration: 900 / 1000 [ 90%]  (Sampling)
Iteration: 1000 / 1000 [100%]  (Sampling)

 Elapsed Time: 0 seconds (Warm-up)
               0.025897 seconds (Sampling)
               0.025897 seconds (Total)

method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_gp_regr_gp_regr.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)


Gradient evaluation took 0.00016 seconds
1000 transitions using 10 leapfrog steps per transition would take 1.6 seconds.
Adjust your expectations accordingly!


Iteration:    1 / 2000 [  0%]  (Warmup)
Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: cholesky_decompose: A is not symmetric. A[1,2] = inf, but A[2,1] = inf  (in '../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.stan' at line 16)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: cholesky_decompose: Matrix m is not positive definite  (in '../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.stan' at line 16)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Iteration:  100 / 2000 [  5%]  (Warmup)
Iteration:  200 / 2000 [ 10%]  (Warmup)
Iteration:  300 / 2000 [ 15%]  (Warmup)
Iteration:  400 / 2000 [ 20%]  (Warmup)
Iteration:  500 / 2000 [ 25%]  (Warmup)
Iteration:  600 / 2000 [ 30%]  (Warmup)
Iteration:  700 / 2000 [ 35%]  (Warmup)
Iteration:  800 / 2000 [ 40%]  (Warmup)
Iteration:  900 / 2000 [ 45%]  (Warmup)
Iteration: 1000 / 2000 [ 50%]  (Warmup)
Iteration: 1001 / 2000 [ 50%]  (Sampling)
Iteration: 1100 / 2000 [ 55%]  (Sampling)
Iteration: 1200 / 2000 [ 60%]  (Sampling)
Iteration: 1300 / 2000 [ 65%]  (Sampling)
Iteration: 1400 / 2000 [ 70%]  (Sampling)
Iteration: 1500 / 2000 [ 75%]  (Sampling)
Iteration: 1600 / 2000 [ 80%]  (Sampling)
Iteration: 1700 / 2000 [ 85%]  (Sampling)
Iteration: 1800 / 2000 [ 90%]  (Sampling)
Iteration: 1900 / 2000 [ 95%]  (Sampling)
Iteration: 2000 / 2000 [100%]  (Sampling)

 Elapsed Time: 0.106718 seconds (Warm-up)
               0.092646 seconds (Sampling)
               0.199364 seconds (Total)

method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_irt_2pl_irt_2pl.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)


Gradient evaluation took 0.000339 seconds
1000 transitions using 10 leapfrog steps per transition would take 3.39 seconds.
Adjust your expectations accordingly!


Iteration:    1 / 2000 [  0%]  (Warmup)
Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: normal_lpdf: Scale parameter is 0, but must be > 0!  (in '../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.stan' at line 21)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Iteration:  100 / 2000 [  5%]  (Warmup)
Iteration:  200 / 2000 [ 10%]  (Warmup)
Iteration:  300 / 2000 [ 15%]  (Warmup)
Iteration:  400 / 2000 [ 20%]  (Warmup)
Iteration:  500 / 2000 [ 25%]  (Warmup)
Iteration:  600 / 2000 [ 30%]  (Warmup)
Iteration:  700 / 2000 [ 35%]  (Warmup)
Iteration:  800 / 2000 [ 40%]  (Warmup)
Iteration:  900 / 2000 [ 45%]  (Warmup)
Iteration: 1000 / 2000 [ 50%]  (Warmup)
Iteration: 1001 / 2000 [ 50%]  (Sampling)
Iteration: 1100 / 2000 [ 55%]  (Sampling)
Iteration: 1200 / 2000 [ 60%]  (Sampling)
Iteration: 1300 / 2000 [ 65%]  (Sampling)
Iteration: 1400 / 2000 [ 70%]  (Sampling)
Iteration: 1500 / 2000 [ 75%]  (Sampling)
Iteration: 1600 / 2000 [ 80%]  (Sampling)
Iteration: 1700 / 2000 [ 85%]  (Sampling)
Iteration: 1800 / 2000 [ 90%]  (Sampling)
Iteration: 1900 / 2000 [ 95%]  (Sampling)
Iteration: 2000 / 2000 [100%]  (Sampling)

 Elapsed Time: 3.56221 seconds (Warm-up)
               3.10359 seconds (Sampling)
               6.6658 seconds (Total)

method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = fixed_param
id = 0 (Default)
data
  file =  (Default)
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_low_dim_corr_gauss_low_dim_corr_gauss.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)

Iteration:   1 / 1000 [  0%]  (Sampling)
Iteration: 100 / 1000 [ 10%]  (Sampling)
Iteration: 200 / 1000 [ 20%]  (Sampling)
Iteration: 300 / 1000 [ 30%]  (Sampling)
Iteration: 400 / 1000 [ 40%]  (Sampling)
Iteration: 500 / 1000 [ 50%]  (Sampling)
Iteration: 600 / 1000 [ 60%]  (Sampling)
Iteration: 700 / 1000 [ 70%]  (Sampling)
Iteration: 800 / 1000 [ 80%]  (Sampling)
Iteration: 900 / 1000 [ 90%]  (Sampling)
Iteration: 1000 / 1000 [100%]  (Sampling)

 Elapsed Time: 0 seconds (Warm-up)
               0.007987 seconds (Sampling)
               0.007987 seconds (Total)

make -i -j16 ../stat_comp_benchmarks/benchmarks/arK/arK ../stat_comp_benchmarks/benchmarks/arma/arma ../stat_comp_benchmarks/benchmarks/eight_schools/eight_schools ../stat_comp_benchmarks/benchmarks/garch/garch ../stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr ../stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data ../stat_comp_benchmarks/benchmarks/gp_regr/gp_regr ../stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl ../stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix ../stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse ../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs ../stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs ../stat_comp_benchmarks/benchmarks/sir/sir
stat_comp_benchmarks/benchmarks/arK/arK method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/arK/arK.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_arK_arK.gold.tmp
SUCCESS: Gold golds/stat_comp_benchmarks_benchmarks_arK_arK.gold passed.
stat_comp_benchmarks/benchmarks/arma/arma method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/arma/arma.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_arma_arma.gold.tmp
SUCCESS: Gold golds/stat_comp_benchmarks_benchmarks_arma_arma.gold passed.
stat_comp_benchmarks/benchmarks/eight_schools/eight_schools method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/eight_schools/eight_schools.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_eight_schools_eight_schools.gold.tmp
SUCCESS: Gold golds/stat_comp_benchmarks_benchmarks_eight_schools_eight_schools.gold passed.
stat_comp_benchmarks/benchmarks/garch/garch method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/garch/garch.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_garch_garch.gold.tmp
SUCCESS: Gold golds/stat_comp_benchmarks_benchmarks_garch_garch.gold passed.
stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_gp_pois_regr_gp_pois_regr.gold.tmp
SUCCESS: Gold golds/stat_comp_benchmarks_benchmarks_gp_pois_regr_gp_pois_regr.gold passed.
stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_gp_regr_gen_gp_data.gold.tmp
stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data method=sample algorithm='fixed_param' random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_gp_regr_gen_gp_data.gold.tmp
SUCCESS: Gold golds/stat_comp_benchmarks_benchmarks_gp_regr_gen_gp_data.gold passed.
stat_comp_benchmarks/benchmarks/gp_regr/gp_regr method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_gp_regr_gp_regr.gold.tmp
SUCCESS: Gold golds/stat_comp_benchmarks_benchmarks_gp_regr_gp_regr.gold passed.
stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_irt_2pl_irt_2pl.gold.tmp
SUCCESS: Gold golds/stat_comp_benchmarks_benchmarks_irt_2pl_irt_2pl.gold passed.
stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss method=sample algorithm='fixed_param' random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_low_dim_corr_gauss_low_dim_corr_gauss.gold.tmp
SUCCESS: Gold golds/stat_comp_benchmarks_benchmarks_low_dim_corr_gauss_low_dim_corr_gauss.gold passed.
stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gausmethod = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_low_dim_gauss_mix_low_dim_gauss_mix.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)


Gradient evaluation took 0.00044 seconds
1000 transitions using 10 leapfrog steps per transition would take 4.4 seconds.
Adjust your expectations accordingly!


Iteration:    1 / 2000 [  0%]  (Warmup)
Iteration:  100 / 2000 [  5%]  (Warmup)
Iteration:  200 / 2000 [ 10%]  (Warmup)
Iteration:  300 / 2000 [ 15%]  (Warmup)
Iteration:  400 / 2000 [ 20%]  (Warmup)
Iteration:  500 / 2000 [ 25%]  (Warmup)
Iteration:  600 / 2000 [ 30%]  (Warmup)
Iteration:  700 / 2000 [ 35%]  (Warmup)
Iteration:  800 / 2000 [ 40%]  (Warmup)
Iteration:  900 / 2000 [ 45%]  (Warmup)
Iteration: 1000 / 2000 [ 50%]  (Warmup)
Iteration: 1001 / 2000 [ 50%]  (Sampling)
Iteration: 1100 / 2000 [ 55%]  (Sampling)
Iteration: 1200 / 2000 [ 60%]  (Sampling)
Iteration: 1300 / 2000 [ 65%]  (Sampling)
Iteration: 1400 / 2000 [ 70%]  (Sampling)
Iteration: 1500 / 2000 [ 75%]  (Sampling)
Iteration: 1600 / 2000 [ 80%]  (Sampling)
Iteration: 1700 / 2000 [ 85%]  (Sampling)
Iteration: 1800 / 2000 [ 90%]  (Sampling)
Iteration: 1900 / 2000 [ 95%]  (Sampling)
Iteration: 2000 / 2000 [100%]  (Sampling)

 Elapsed Time: 1.8494 seconds (Warm-up)
               1.49773 seconds (Sampling)
               3.34713 seconds (Total)

method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_low_dim_gauss_mix_collapse_low_dim_gauss_mix_collapse.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)


Gradient evaluation took 0.000403 seconds
1000 transitions using 10 leapfrog steps per transition would take 4.03 seconds.
Adjust your expectations accordingly!


Iteration:    1 / 2000 [  0%]  (Warmup)
Iteration:  100 / 2000 [  5%]  (Warmup)
Iteration:  200 / 2000 [ 10%]  (Warmup)
Iteration:  300 / 2000 [ 15%]  (Warmup)
Iteration:  400 / 2000 [ 20%]  (Warmup)
Iteration:  500 / 2000 [ 25%]  (Warmup)
Iteration:  600 / 2000 [ 30%]  (Warmup)
Iteration:  700 / 2000 [ 35%]  (Warmup)
Iteration:  800 / 2000 [ 40%]  (Warmup)
Iteration:  900 / 2000 [ 45%]  (Warmup)
Iteration: 1000 / 2000 [ 50%]  (Warmup)
Iteration: 1001 / 2000 [ 50%]  (Sampling)
Iteration: 1100 / 2000 [ 55%]  (Sampling)
Iteration: 1200 / 2000 [ 60%]  (Sampling)
Iteration: 1300 / 2000 [ 65%]  (Sampling)
Iteration: 1400 / 2000 [ 70%]  (Sampling)
Iteration: 1500 / 2000 [ 75%]  (Sampling)
Iteration: 1600 / 2000 [ 80%]  (Sampling)
Iteration: 1700 / 2000 [ 85%]  (Sampling)
Iteration: 1800 / 2000 [ 90%]  (Sampling)
Iteration: 1900 / 2000 [ 95%]  (Sampling)
Iteration: 2000 / 2000 [100%]  (Sampling)

 Elapsed Time: 4.73797 seconds (Warm-up)
               5.37733 seconds (Sampling)
               10.1153 seconds (Total)

method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_pkpd_one_comp_mm_elim_abs.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)


Gradient evaluation took 0.002309 seconds
1000 transitions using 10 leapfrog steps per transition would take 23.09 seconds.
Adjust your expectations accordingly!


Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: integrate_ode_cvodes: parameter vector[2] is inf, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: integrate_ode_cvodes: parameter vector[2] is inf, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: integrate_ode_cvodes: parameter vector[2] is inf, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: integrate_ode_cvodes: parameter vector[2] is inf, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Iteration:    1 / 2000 [  0%]  (Warmup)
Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: integrate_ode_cvodes: parameter vector[2] is inf, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: integrate_ode_cvodes: parameter vector[2] is inf, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Iteration:  100 / 2000 [  5%]  (Warmup)
Iteration:  200 / 2000 [ 10%]  (Warmup)
Iteration:  300 / 2000 [ 15%]  (Warmup)
Iteration:  400 / 2000 [ 20%]  (Warmup)
Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: lognormal_lpdf: Location parameter is nan, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.stan' at line 68)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Iteration:  500 / 2000 [ 25%]  (Warmup)
Iteration:  600 / 2000 [ 30%]  (Warmup)
Iteration:  700 / 2000 [ 35%]  (Warmup)
Iteration:  800 / 2000 [ 40%]  (Warmup)
Iteration:  900 / 2000 [ 45%]  (Warmup)
Iteration: 1000 / 2000 [ 50%]  (Warmup)
Iteration: 1001 / 2000 [ 50%]  (Sampling)
Iteration: 1100 / 2000 [ 55%]  (Sampling)
Iteration: 1200 / 2000 [ 60%]  (Sampling)
Iteration: 1300 / 2000 [ 65%]  (Sampling)
Iteration: 1400 / 2000 [ 70%]  (Sampling)
Iteration: 1500 / 2000 [ 75%]  (Sampling)
Iteration: 1600 / 2000 [ 80%]  (Sampling)
Iteration: 1700 / 2000 [ 85%]  (Sampling)
Iteration: 1800 / 2000 [ 90%]  (Sampling)
Iteration: 1900 / 2000 [ 95%]  (Sampling)
Iteration: 2000 / 2000 [100%]  (Sampling)

 Elapsed Time: 14.8707 seconds (Warm-up)
               9.62344 seconds (Sampling)
               24.4941 seconds (Total)

method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_pkpd_sim_one_comp_mm_elim_abs.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)

Must use algorithm=fixed_param for model that has no parameters.
method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = fixed_param
id = 0 (Default)
data
  file =  (Default)
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_pkpd_sim_one_comp_mm_elim_abs.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)

Iteration:   1 / 1000 [  0%]  (Sampling)
Iteration: 100 / 1000 [ 10%]  (Sampling)
Iteration: 200 / 1000 [ 20%]  (Sampling)
Iteration: 300 / 1000 [ 30%]  (Sampling)
Iteration: 400 / 1000 [ 40%]  (Sampling)
Iteration: 500 / 1000 [ 50%]  (Sampling)
Iteration: 600 / 1000 [ 60%]  (Sampling)
Iteration: 700 / 1000 [ 70%]  (Sampling)
Iteration: 800 / 1000 [ 80%]  (Sampling)
Iteration: 900 / 1000 [ 90%]  (Sampling)
Iteration: 1000 / 1000 [100%]  (Sampling)

 Elapsed Time: 0 seconds (Warm-up)
               0.34925 seconds (Sampling)
               0.34925 seconds (Total)

method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = stat_comp_benchmarks/benchmarks/sir/sir.data.R
init = 2 (Default)
random
  seed = 1234
output
  file = golds/stat_comp_benchmarks_benchmarks_sir_sir.gold.tmp
  diagnostic_file =  (Default)
  refresh = 100 (Default)


Gradient evaluation took 0.001472 seconds
1000 transitions using 10 leapfrog steps per transition would take 14.72 seconds.
Adjust your expectations accordingly!


Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: integrate_ode_rk45: parameter vector[3] is inf, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/sir/sir.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: integrate_ode_rk45: parameter vector[3] is inf, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/sir/sir.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: integrate_ode_rk45: parameter vector[3] is inf, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/sir/sir.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: integrate_ode_rk45: parameter vector[3] is inf, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/sir/sir.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: Max number of iterations exceeded (1000000).  (in '../stat_comp_benchmarks/benchmarks/sir/sir.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: Max number of iterations exceeded (1000000).  (in '../stat_comp_benchmarks/benchmarks/sir/sir.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: Max number of iterations exceeded (1000000).  (in '../stat_comp_benchmarks/benchmarks/sir/sir.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Iteration:    1 / 2000 [  0%]  (Warmup)
Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: integrate_ode_rk45: parameter vector[3] is inf, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/sir/sir.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: integrate_ode_rk45: parameter vector[3] is inf, but must be finite!  (in '../stat_comp_benchmarks/benchmarks/sir/sir.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Informational Message: The current Metropolis proposal is about to be rejected because of the following issue:
Exception: Max number of iterations exceeded (1000000).  (in '../stat_comp_benchmarks/benchmarks/sir/sir.stan' at line 55)

If this warning occurs sporadically, such as for highly constrained variable types like covariance matrices, then the sampler is fine,
but if this warning occurs often then your model may be either severely ill-conditioned or misspecified.

Iteration:  100 / 2000 [  5%]  (Warmup)
Iteration:  200 / 2000 [ 10%]  (Warmup)
Iteration:  300 / 2000 [ 15%]  (Warmup)
Iteration:  400 / 2000 [ 20%]  (Warmup)
Iteration:  500 / 2000 [ 25%]  (Warmup)
Iteration:  600 / 2000 [ 30%]  (Warmup)
Iteration:  700 / 2000 [ 35%]  (Warmup)
Iteration:  800 / 2000 [ 40%]  (Warmup)
Iteration:  900 / 2000 [ 45%]  (Warmup)
Iteration: 1000 / 2000 [ 50%]  (Warmup)
Iteration: 1001 / 2000 [ 50%]  (Sampling)
Iteration: 1100 / 2000 [ 55%]  (Sampling)
Iteration: 1200 / 2000 [ 60%]  (Sampling)
Iteration: 1300 / 2000 [ 65%]  (Sampling)
Iteration: 1400 / 2000 [ 70%]  (Sampling)
Iteration: 1500 / 2000 [ 75%]  (Sampling)
Iteration: 1600 / 2000 [ 80%]  (Sampling)
Iteration: 1700 / 2000 [ 85%]  (Sampling)
Iteration: 1800 / 2000 [ 90%]  (Sampling)
Iteration: 1900 / 2000 [ 95%]  (Sampling)
Iteration: 2000 / 2000 [100%]  (Sampling)

 Elapsed Time: 51.7258 seconds (Warm-up)
               45.9129 seconds (Sampling)
               97.6387 seconds (Total)

s_mix method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_low_dim_gauss_mix_low_dim_gauss_mix.gold.tmp
SUCCESS: Gold golds/stat_comp_benchmarks_benchmarks_low_dim_gauss_mix_low_dim_gauss_mix.gold passed.
stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_low_dim_gauss_mix_collapse_low_dim_gauss_mix_collapse.gold.tmp
SUCCESS: Gold golds/stat_comp_benchmarks_benchmarks_low_dim_gauss_mix_collapse_low_dim_gauss_mix_collapse.gold passed.
stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_pkpd_one_comp_mm_elim_abs.gold.tmp
SUCCESS: Gold golds/stat_comp_benchmarks_benchmarks_pkpd_one_comp_mm_elim_abs.gold passed.
stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_pkpd_sim_one_comp_mm_elim_abs.gold.tmp
stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs method=sample algorithm='fixed_param' random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_pkpd_sim_one_comp_mm_elim_abs.gold.tmp
SUCCESS: Gold golds/stat_comp_benchmarks_benchmarks_pkpd_sim_one_comp_mm_elim_abs.gold passed.
stat_comp_benchmarks/benchmarks/sir/sir method=sample num_samples=1000 num_warmup=1000 data file=stat_comp_benchmarks/benchmarks/sir/sir.data.R random seed=1234 output file=golds/stat_comp_benchmarks_benchmarks_sir_sir.gold.tmp
SUCCESS: Gold golds/stat_comp_benchmarks_benchmarks_sir_sir.gold passed.
+ ./comparePerformance.py develop_performance.csv performance.csv
('stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.stan', 0.99)
('stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss.stan', 0.99)
('stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.stan', 1.0)
('stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.stan', 0.99)
('stat_comp_benchmarks/benchmarks/eight_schools/eight_schools.stan', 1.0)
('stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.stan', 0.96)
('stat_comp_benchmarks/benchmarks/arK/arK.stan', 1.0)
('performance.compilation', 1.02)
('stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.stan', 0.99)
('stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.stan', 1.0)
('stat_comp_benchmarks/benchmarks/sir/sir.stan', 0.99)
('stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs.stan', 1.0)
('stat_comp_benchmarks/benchmarks/garch/garch.stan', 0.96)
('stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data.stan', 0.99)
('stat_comp_benchmarks/benchmarks/arma/arma.stan', 1.0)
0.992197862963
+ mv performance.xml develop.xml
+ make revert clean
git submodule update --init --recursive
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
Submodule path 'cmdstan/stan': checked out 'd03404ca999095e2a85b3b4c8ad70964f956d601'
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
cd cmdstan; make clean-all; cd ..
rm -f -r doc
cd src/docs/cmdstan-guide; rm -f *.brf *.aux *.bbl *.blg *.log *.toc *.pdf *.out *.idx *.ilg *.ind *.cb *.cb2 *.upa
rm -f -r test
rm -f 
rm -f 
  removing dependency files
  cleaning sundials targets
rm -f stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodea.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodea_io.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_bandpre.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_bbdpre.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_diag.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_direct.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_io.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_ls.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls_sim.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls_stg.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_nls_stg1.o stan/lib/stan_math/lib/sundials_4.1.0/src/cvodes/cvodes_spils.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idaa.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idaa_io.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_bbdpre.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_direct.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_ic.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_io.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_ls.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_nls.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_nls_sim.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_nls_stg.o stan/lib/stan_math/lib/sundials_4.1.0/src/idas/idas_spils.o stan/lib/stan_math/lib/sundials_4.1.0/src/nvector/serial/nvector_serial.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_band.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_dense.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_direct.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_iterative.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_linearsolver.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_math.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_matrix.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_mpi.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nonlinearsolver.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nvector.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_nvector_senswrapper.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_pcg.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_sparse.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_spbcgs.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_sptfqmr.o stan/lib/stan_math/lib/sundials_4.1.0/src/sundials/sundials_version.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunlinsol/band/sunlinsol_band.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunlinsol/dense/sunlinsol_dense.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunmatrix/band/sunmatrix_band.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunmatrix/dense/sunmatrix_dense.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunnonlinsol/fixedpoint/sunnonlinsol_fixedpoint.o stan/lib/stan_math/lib/sundials_4.1.0/src/sunnonlinsol/newton/sunnonlinsol_newton.o
rm -f -r bin
rm -f stan/src/stan/model/model_header.hpp.gch
git submodule foreach --recursive git clean -xffd
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
Entering 'cmdstan'
Removing make/local
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
Entering 'cmdstan/stan'
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
Entering 'cmdstan/stan/lib/stan_math'
Removing lib/sundials_4.1.0/lib/
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
Entering 'example-models'
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
Entering 'stat_comp_benchmarks'
Removing benchmarks/arK/arK
Removing benchmarks/arK/arK.d
Removing benchmarks/arK/arK.hpp
Removing benchmarks/arma/arma
Removing benchmarks/arma/arma.d
Removing benchmarks/arma/arma.hpp
Removing benchmarks/eight_schools/eight_schools
Removing benchmarks/eight_schools/eight_schools.d
Removing benchmarks/eight_schools/eight_schools.hpp
Removing benchmarks/garch/garch
Removing benchmarks/garch/garch.d
Removing benchmarks/garch/garch.hpp
Removing benchmarks/gp_pois_regr/gp_pois_regr
Removing benchmarks/gp_pois_regr/gp_pois_regr.d
Removing benchmarks/gp_pois_regr/gp_pois_regr.hpp
Removing benchmarks/gp_regr/gen_gp_data
Removing benchmarks/gp_regr/gen_gp_data.d
Removing benchmarks/gp_regr/gen_gp_data.hpp
Removing benchmarks/gp_regr/gp_regr
Removing benchmarks/gp_regr/gp_regr.d
Removing benchmarks/gp_regr/gp_regr.hpp
Removing benchmarks/irt_2pl/irt_2pl
Removing benchmarks/irt_2pl/irt_2pl.d
Removing benchmarks/irt_2pl/irt_2pl.hpp
Removing benchmarks/low_dim_corr_gauss/low_dim_corr_gauss
Removing benchmarks/low_dim_corr_gauss/low_dim_corr_gauss.d
Removing benchmarks/low_dim_corr_gauss/low_dim_corr_gauss.hpp
Removing benchmarks/low_dim_gauss_mix/low_dim_gauss_mix
Removing benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.d
Removing benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.hpp
Removing benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse
Removing benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.d
Removing benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.hpp
Removing benchmarks/pkpd/one_comp_mm_elim_abs
Removing benchmarks/pkpd/one_comp_mm_elim_abs.d
Removing benchmarks/pkpd/one_comp_mm_elim_abs.hpp
Removing benchmarks/pkpd/sim_one_comp_mm_elim_abs
Removing benchmarks/pkpd/sim_one_comp_mm_elim_abs.d
Removing benchmarks/pkpd/sim_one_comp_mm_elim_abs.hpp
Removing benchmarks/sir/sir
Removing benchmarks/sir/sir.d
Removing benchmarks/sir/sir.hpp
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LC_ALL = (unset),
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
[Pipeline] }
[Pipeline] // script
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Numerical Accuracy and Performance Tests on Known-Good Models)
Stage "Numerical Accuracy and Performance Tests on Known-Good Models" skipped due to when conditional
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Shotgun Performance Regression Tests)
Stage "Shotgun Performance Regression Tests" skipped due to when conditional
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Collect test results)
Stage "Collect test results" skipped due to when conditional
                    """
                }
            }
        }
        //stage('Clean checkout') {
        //    steps {
        //        deleteDir()
        //        checkout([$class: 'GitSCM',
        //                  branches: [[name: '*/master']],
        //                  doGenerateSubmoduleConfigurations: false,
        //                  extensions: [[$class: 'SubmoduleOption',
        //                                disableSubmodules: false,
        //                                parentCredentials: false,
        //                                recursiveSubmodules: true,
        //                                reference: '',
        //                                trackingSubmodules: false]],
        //                  submoduleCfg: [],
        //                  userRemoteConfigs: [[url: "git@github.com:stan-dev/performance-tests-cmdstan.git",
        //                                       credentialsId: 'a630aebc-6861-4e69-b497-fd7f496ec46b'
        //            ]]])
        //    }
        //}
        //stage('Update CmdStan pointer to latest develop') {
        //    when { branch 'master' }
        //    steps {
        //        script {
        //            sh """
        //                cd cmdstan
        //                git pull origin develop
        //                git submodule update --init --recursive
        //                cd ..
        //                if [ -n "\$(git status --porcelain cmdstan)" ]; then
        //                    git checkout master
        //                    git pull
        //                    git commit cmdstan -m "Update submodules"
        //                    git push origin master
        //                fi
        //                """
        //        }
        //    }
        //}
        //stage("Test cmdstan develop against cmdstan pointer in this branch") {
        //    when { not { branch 'master' } }
        //    steps {
        //        script{
        //                /* Handle cmdstan_pr */
        //                cmdstan_pr = branchOrPR(params.cmdstan_pr)
//
        //                sh """
        //                    old_hash=\$(git submodule status | grep cmdstan | awk '{print \$1}')
        //                    cmdstan_hash=\$(if [ -n "${cmdstan_pr}" ]; then echo "${cmdstan_pr}"; else echo "\$old_hash" ; fi)
        //                    bash compare-git-hashes.sh stat_comp_benchmarks develop \$cmdstan_hash ${branchOrPR(params.stan_pr)} ${branchOrPR(params.math_pr)}
        //                    mv performance.xml \$cmdstan_hash.xml
        //                    make revert clean
        //                """
        //        }
        //    }
        //}
        //stage("Numerical Accuracy and Performance Tests on Known-Good Models") {
        //    when { branch 'master' }
        //    steps {
        //        writeFile(file: "cmdstan/make/local", text: "CXXFLAGS += -march=core2")
        //        sh "./runPerformanceTests.py -j${env.PARALLEL} --runs 3 stat_comp_benchmarks --check-golds --name=known_good_perf --tests-file=known_good_perf_all.tests"
        //    }
        //}
        //stage('Shotgun Performance Regression Tests') {
        //    when { branch 'master' }
        //    steps {
        //        sh "make clean"
        //        writeFile(file: "cmdstan/make/local", text: "CXXFLAGS += -march=native")
        //        sh "./runPerformanceTests.py -j${env.PARALLEL} --runj 1 example-models/bugs_examples example-models/regressions --name=shotgun_perf --tests-file=shotgun_perf_all.tests"
        //    }
        //}
        //stage('Collect test results') {
        //    when { branch 'master' }
        //    steps {
        //        junit '*.xml'
        //        archiveArtifacts '*.xml'
        //        perfReport compareBuildPrevious: true,
//
        //            relativeFailedThresholdPositive: 10,
        //            relativeUnstableThresholdPositive: 5,
//
        //            errorFailedThreshold: 1,
        //            failBuildIfNoResultFile: false,
        //            modePerformancePerTestCase: true,
        //            modeOfThreshold: true,
        //            sourceDataFiles: '*.xml',
        //            modeThroughput: false,
        //            configType: 'PRT'
        //    }
        //}
    }

    post {
        success {
            script {
                def comment = get_results()

                if(params.cmdstan_pr.contains("PR-")){
                    def pr_number = (params.cmdstan_pr =~ /(?m)PR-(.*?)$/)[0][1]
                    post_comment(comment, "cmdstan", pr_number)
                }
                
                if(params.stan_pr.contains("PR-")){
                    def pr_number = (params.stan_pr =~ /(?m)PR-(.*?)$/)[0][1]
                    post_comment(comment, "stan", pr_number)
                }
                
                if(params.math_pr.contains("PR-")){
                    def pr_number = (params.math_pr =~ /(?m)PR-(.*?)$/)[0][1]
                    post_comment(comment, "math", pr_number)
                } 
            }
        }
        unstable {
            script { utils.mailBuildResults("UNSTABLE", "stan-buildbot@googlegroups.com") }
        }
        failure {
            script { utils.mailBuildResults("FAILURE", "stan-buildbot@googlegroups.com") }
        }
    }
}
