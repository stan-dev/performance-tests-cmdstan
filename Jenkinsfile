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

def cleanCheckout() {

    deleteDir()
    checkout([$class: 'GitSCM',
        branches: [[name: '*/custom']],
        doGenerateSubmoduleConfigurations: false,
        extensions: [[$class: 'SubmoduleOption',
                    disableSubmodules: false,
                    parentCredentials: false,
                    recursiveSubmodules: true,
                    reference: '',
                    trackingSubmodules: false]],
        submoduleCfg: [],
        userRemoteConfigs: [[url: "https://github.com/stan-dev/performance-tests-cmdstan.git", credentialsId: 'a630aebc-6861-4e69-b497-fd7f496ec46b']]
    ])

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
        string(defaultValue: 'develop', name: 'cmdstan_origin_pr', description: "CmdStan hash/branch to base hash/branch. Example: PR-123 OR e6c3010fd0168ef961a531d56b2330fd64728523 OR develop")
        string(defaultValue: 'develop', name: 'cmdstan_pr', description: "CmdStan hash/branch to compare against. Example: PR-123 OR e6c3010fd0168ef961a531d56b2330fd64728523 OR develop")
        string(defaultValue: 'develop', name: 'stan_pr', description: "Stan PR to test against. Will check out this PR in the downstream Stan repo. Example: PR-123 OR e6c3010fd0168ef961a531d56b2330fd64728523 OR develop")
        string(defaultValue: 'develop', name: 'math_pr', description: "Math PR to test against. Will check out this PR in the downstream Math repo. Example: PR-123 OR e6c3010fd0168ef961a531d56b2330fd64728523 OR develop")

        string(defaultValue: '', name: 'make_local_windows', description: "Make/file contents")
        string(defaultValue: '', name: 'make_local_linux', description: "Make/file contents")
        string(defaultValue: 'CXXFLAGS += -march=core2', name: 'make_local_macosx', description: "Make/file contents")

        booleanParam(defaultValue: true, name: 'run_windows', description: "True/False to run tests on windows")
        string(defaultValue: '3', name: 'golds_runs_windows', description: "Number of runs for golds")
        string(defaultValue: '2', name: 'shotguns_runs_windows', description: "Number of runs for shotguns")

        booleanParam(defaultValue: true, name: 'run_linux', description: "True/False to run tests on linux")
        string(defaultValue: '3', name: 'golds_runs_linux', description: "Number of runs for golds")
        string(defaultValue: '2', name: 'shotguns_runs_linux', description: "Number of runs for shotguns")

        booleanParam(defaultValue: true, name: 'run_macosx', description: "True/False to run tests on macosx")
        string(defaultValue: '3', name: 'golds_runs_macosx', description: "Number of runs for golds")
        string(defaultValue: '2', name: 'shotguns_runs_macosx', description: "Number of runs for shotguns")

    }
    stages {
        stage('Parallel tests') {
            parallel {
                stage("Test cmdstan base against cmdstan pointer in this branch on windows") {
                    when {
                        expression { 
                            params.run_windows == true
                        }
                    }
                    agent { label 'windows' }
                    steps {

                        cleanCheckout()
    
                        script{
                                /* Handle cmdstan_pr */
                                cmdstan_pr = branchOrPR(params.cmdstan_pr)
    
                                bat """
                                    bash -c "cd cmdstan \\
                                        git submodule update --init --recursive \\
                                        git pull origin ${params.cmdstan_origin_pr} \\
                                        git submodule update --init --recursive"
                                """
    
                                bat """
                                    bash -c " export old_hash=\$(git submodule status | grep cmdstan | awk '{print \$1}') \\
                                        cmdstan_hash=\$(if [ -n "${cmdstan_pr}" ]; then echo "${cmdstan_pr}"; else echo "\$old_hash" ; fi) \\
                                        echo \$cmdstan_hash \\
                                        compare-git-hashes.sh stat_comp_benchmarks ${cmdstan_origin_pr} \$cmdstan_hash ${branchOrPR(params.stan_pr)} ${branchOrPR(params.math_pr)} windows \\
                                        mv windows_performance.xml windows_\$cmdstan_hash.xml \\
                                        make revert clean \\
                                        ls -lart"
                                """
                        }
                        bat "bash -c \"echo ${make_local_windows} > cmdstan/make/local\""
                        bat "bash -c \"python runPerformanceTests.py -j${env.PARALLEL} --runs=${golds_runs_windows} --check-golds --name=windows_known_good_perf --tests-file=known_good_perf_all.tests\""
    
                        bat "bash -c \"make clean\""
    
                        bat "bash -c \"echo ${make_local_windows} > cmdstan/make/local\""
                        bat "bash -c \"python runPerformanceTests.py -j${env.PARALLEL} --runs=${shotguns_runs_windows} --name=windows_shotgun_perf --tests-file=shotgun_perf_all.tests\""

                        archiveArtifacts '*.xml'
                    }
                }
    
                stage("Test cmdstan base against cmdstan pointer in this branch on linux") {
                    when {
                        expression { 
                            params.run_linux == true
                        }
                    }
                    agent { label 'linux' }
                    steps {

                        cleanCheckout()
                        
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
                                    echo \$cmdstan_hash
                                    ./compare-git-hashes.sh stat_comp_benchmarks ${cmdstan_origin_pr} \$cmdstan_hash ${branchOrPR(params.stan_pr)} ${branchOrPR(params.math_pr)} linux
                                    mv linux_performance.xml linux_\$cmdstan_hash.xml
                                    make revert clean
                                    ls -lart
                                """
                        }
    
                        writeFile(file: "cmdstan/make/local", text: make_local_linux)
                        sh "./runPerformanceTests.py -j${env.PARALLEL} --runs=${golds_runs_linux} --check-golds --name=linux_known_good_perf --tests-file=known_good_perf_all.tests"
    
                        sh "make clean"
                        writeFile(file: "cmdstan/make/local", text: make_local_linux)
                        sh "./runPerformanceTests.py -j${env.PARALLEL} --runs=${shotguns_runs_linux} --name=linux_shotgun_perf --tests-file=shotgun_perf_all.tests"
    
                        archiveArtifacts '*.xml'
                    }
                }
    
                stage("Test cmdstan base against cmdstan pointer in this branch on macosx") {
                    when {
                        expression { 
                            params.run_macosx == true
                        }
                    }
                    agent { label 'gelman-group-mac' }
                    steps {
                        
                        cleanCheckout()

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
                                    echo \$cmdstan_hash
                                    ./compare-git-hashes.sh stat_comp_benchmarks ${cmdstan_origin_pr} \$cmdstan_hash ${branchOrPR(params.stan_pr)} ${branchOrPR(params.math_pr)} macos
                                    mv macos_performance.xml macos_\$cmdstan_hash.xml
                                    make revert clean
                                    ls -lart
                                """
                        }
    
                        writeFile(file: "cmdstan/make/local", text: make_local_macosx)
                        sh "./runPerformanceTests.py -j${env.PARALLEL} --runs=${golds_runs_macosx} --check-golds --name=macos_known_good_perf --tests-file=known_good_perf_all.tests"
    
                        sh "make clean"
                        writeFile(file: "cmdstan/make/local", text: make_local_macosx)
                        sh "./runPerformanceTests.py -j${env.PARALLEL} --runs=${shotguns_runs_macosx} --name=macos_shotgun_perf --tests-file=shotgun_perf_all.tests"

                        archiveArtifacts '*.xml'
                    }
                }       
            }
        }
    }
}
