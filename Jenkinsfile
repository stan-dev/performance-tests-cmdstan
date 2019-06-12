#!/usr/bin/env groovy
@Library('StanUtils')
import org.stan.Utils

def utils = new org.stan.Utils()

def branchOrPR(pr) {
  if (pr == "downstream_tests") return "develop"
  if (pr == "downstream_hotfix") return "master"
  if (pr == "") return "develop"
  return pr
}

def post_comment(text, repository, pr_number) {
    sh """#!/bin/bash
        curl -s -H "Authorization: token ${GITHUB_TOKEN}" -X POST -d '{"body": "${text}"}' "https://api.github.com/repos/stan-dev/${repository}/issues/${pr_number}/comments"
    """
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
    agent none
    environment {
        cmdstan_pr = ""
        GITHUB_TOKEN = credentials('6e7c1e8f-ca2c-4b11-a70e-d934d3f6b681')
    }
    options {
        skipDefaultCheckout()
        preserveStashes(buildCount: 7)
    }
    parameters {
        string(defaultValue: 'develop', name: 'cmdstan_origin_pr', description: "CmdStan hash/branch to base hash/branch")
        string(defaultValue: '', name: 'cmdstan_pr', description: "CmdStan hash/branch to compare against")
        string(defaultValue: '', name: 'stan_pr', description: "Stan PR to test against. Will check out this PR in the downstream Stan repo.")
        string(defaultValue: '', name: 'math_pr', description: "Math PR to test against. Will check out this PR in the downstream Math repo.")
        string(defaultValue: '', name: 'make_local', description: "Make/file contents")
    }

    stages {

        stage('Clean checkout') {
            agent any
            steps {
                deleteDir()
                checkout([$class: 'GitSCM',
                          branches: [[name: '*/master']],
                          doGenerateSubmoduleConfigurations: false,
                          extensions: [[$class: 'SubmoduleOption',
                                        disableSubmodules: false,
                                        parentCredentials: false,
                                        recursiveSubmodules: true,
                                        reference: '',
                                        trackingSubmodules: false]],
                          submoduleCfg: [],
                          userRemoteConfigs: [[url: "git@github.com:stan-dev/performance-tests-cmdstan.git",
                                               credentialsId: 'a630aebc-6861-4e69-b497-fd7f496ec46b'
                    ]]])
            }
        }

        stage('Parallel tests') {
            parallel {
                stage("Test cmdstan base against cmdstan pointer in this branch on windows") {
                    agent { label 'windows' }
                    steps {
    
                        script{
                                /* Handle cmdstan_pr */
                                cmdstan_pr = branchOrPR(params.cmdstan_pr)
    
                                bat """
                                    bash -c "cd cmdstan"
                                    bash -c "git pull origin ${params.cmdstan_origin_pr}"
                                    bash -c "git submodule update --init --recursive"
                                """
    
                                bat """
                                    bash -c "old_hash=\$(git submodule status | grep cmdstan | awk '{print \$1}')""
                                    bash -c "cmdstan_hash=\$(if [ -n "${cmdstan_pr}" ]; then echo "${cmdstan_pr}"; else echo "\$old_hash" ; fi)""
                                    bash -c "compare-git-hashes.sh stat_comp_benchmarks ${cmdstan_origin_pr} \$cmdstan_hash ${branchOrPR(params.stan_pr)} ${branchOrPR(params.math_pr)}""
                                    bash -c "mv performance.xml \$cmdstan_hash.xml"
                                    bash -c "make revert clean"
                                """
                        }
    
                        bat "bash -c \"echo ${make_local} > cmdstan/make/local\""
                        bat "python runPerformanceTests.py -j${env.PARALLEL} --runs 3 stat_comp_benchmarks --check-golds --name=known_good_perf --tests-file=known_good_perf_all.tests"
    
                        bat "bash -c \"make clean\""
    
                        bat "bash -c \"echo ${make_local} > cmdstan/make/local\""
                        bat "python runPerformanceTests.py -j${env.PARALLEL} --runj 1 example-models/bugs_examples example-models/regressions --name=shotgun_perf --tests-file=shotgun_perf_all.tests"
    
                        junit '*.xml'
                        archiveArtifacts '*.xml'
                        perfReport compareBuildPrevious: true,
    
                            relativeFailedThresholdPositive: 10,
                            relativeUnstableThresholdPositive: 5,
    
                            errorFailedThreshold: 1,
                            failBuildIfNoResultFile: false,
                            modePerformancePerTestCase: true,
                            modeOfThreshold: true,
                            sourceDataFiles: '*.xml',
                            modeThroughput: false,
                            configType: 'PRT'
                    }
                }
    
                stage("Test cmdstan base against cmdstan pointer in this branch on linux") {
                    agent { label 'linux' }
                    steps {
                        
                        script{
                                /* Handle cmdstan_pr */
                                cmdstan_pr = branchOrPR(params.cmdstan_pr)
    
                                sh """
                                    cd cmdstan
                                    git pull origin ${params.cmdstan_origin_pr}
                                    git submodule update --init --recursive
                                """
    
                                sh """
                                    old_hash=\$(git submodule status | grep cmdstan | awk '{print \$1}')
                                    cmdstan_hash=\$(if [ -n "${cmdstan_pr}" ]; then echo "${cmdstan_pr}"; else echo "\$old_hash" ; fi)
                                    ./compare-git-hashes.sh stat_comp_benchmarks ${cmdstan_origin_pr} \$cmdstan_hash ${branchOrPR(params.stan_pr)} ${branchOrPR(params.math_pr)}
                                    mv performance.xml \$cmdstan_hash.xml
                                    make revert clean
                                """
                        }
    
                        writeFile(file: "cmdstan/make/local", text: make_local)
                        sh "./runPerformanceTests.py -j${env.PARALLEL} --runs 3 stat_comp_benchmarks --check-golds --name=known_good_perf --tests-file=known_good_perf_all.tests"
    
                        sh "make clean"
                        writeFile(file: "cmdstan/make/local", text: make_local)
                        sh "./runPerformanceTests.py -j${env.PARALLEL} --runj 1 example-models/bugs_examples example-models/regressions --name=shotgun_perf --tests-file=shotgun_perf_all.tests"
    
                        junit '*.xml'
                        archiveArtifacts '*.xml'
                        perfReport compareBuildPrevious: true,
    
                            relativeFailedThresholdPositive: 10,
                            relativeUnstableThresholdPositive: 5,
    
                            errorFailedThreshold: 1,
                            failBuildIfNoResultFile: false,
                            modePerformancePerTestCase: true,
                            modeOfThreshold: true,
                            sourceDataFiles: '*.xml',
                            modeThroughput: false,
                            configType: 'PRT'
                    }
                }
    
                stage("Test cmdstan base against cmdstan pointer in this branch on macosx") {
                    agent { label 'osx' }
                    steps {
                        
                        script{
                                /* Handle cmdstan_pr */
                                cmdstan_pr = branchOrPR(params.cmdstan_pr)
    
                                sh """
                                    cd cmdstan
                                    git pull origin ${params.cmdstan_origin_pr}
                                    git submodule update --init --recursive
                                """
    
                                sh """
                                    old_hash=\$(git submodule status | grep cmdstan | awk '{print \$1}')
                                    cmdstan_hash=\$(if [ -n "${cmdstan_pr}" ]; then echo "${cmdstan_pr}"; else echo "\$old_hash" ; fi)
                                    ./compare-git-hashes.sh stat_comp_benchmarks ${cmdstan_origin_pr} \$cmdstan_hash ${branchOrPR(params.stan_pr)} ${branchOrPR(params.math_pr)}
                                    mv performance.xml \$cmdstan_hash.xml
                                    make revert clean
                                """
                        }
    
                        writeFile(file: "cmdstan/make/local", text: make_local)
                        sh "./runPerformanceTests.py -j${env.PARALLEL} --runs 3 stat_comp_benchmarks --check-golds --name=known_good_perf --tests-file=known_good_perf_all.tests"
    
                        sh "make clean"
                        writeFile(file: "cmdstan/make/local", text: make_local)
                        sh "./runPerformanceTests.py -j${env.PARALLEL} --runj 1 example-models/bugs_examples example-models/regressions --name=shotgun_perf --tests-file=shotgun_perf_all.tests"
    
                        junit '*.xml'
                        archiveArtifacts '*.xml'
                        perfReport compareBuildPrevious: true,
    
                            relativeFailedThresholdPositive: 10,
                            relativeUnstableThresholdPositive: 5,
    
                            errorFailedThreshold: 1,
                            failBuildIfNoResultFile: false,
                            modePerformancePerTestCase: true,
                            modeOfThreshold: true,
                            sourceDataFiles: '*.xml',
                            modeThroughput: false,
                            configType: 'PRT'
                    }
                }       
            }
        }
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
    }
}
