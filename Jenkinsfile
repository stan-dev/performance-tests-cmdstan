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

pipeline {
    agent { label 'gelman-group-mac' }
    environment {
        cmdstan_pr = ""
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
        stage('Clean checkout') {
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
        stage('Update CmdStan pointer to latest develop') {
            when { branch 'master' }
            steps {
                script {
                    sh """
                        cd cmdstan
                        git pull origin develop
                        git submodule update --init --recursive
                        cd ..
                        if [ -n "\$(git status --porcelain cmdstan)" ]; then
                            git checkout master
                            git pull
                            git commit cmdstan -m "Update submodules"
                            git push origin master
                        fi
                        """
                }
            }
        }
        stage("Test cmdstan develop against cmdstan pointer in this branch") {
            when { not { branch 'master' } }
            steps {
                script{
                        /* Handle cmdstan_pr */
                        cmdstan_pr = branchOrPR(params.cmdstan_pr)

                        sh """       
                            old_hash=\$(git submodule status | grep cmdstan | awk '{print \$1}')
                            cmdstan_hash=\$(if [ -n "${cmdstan_pr}" ]; then echo "${cmdstan_pr}"; else echo "\$old_hash" ; fi)
                            bash compare-git-hashes.sh develop \$cmdstan_hash stat_comp_benchmarks ${branchOrPR(params.stan_pr)} ${branchOrPR(params.math_pr)}
                            mv performance.xml \$cmdstan_hash.xml
                            make revert clean
                        """
                }
            }
        }
        stage("Numerical Accuracy and Performance Tests on Known-Good Models") {
            when { branch 'master' }
            steps {
                writeFile(file: "cmdstan/make/local", text: "CXXFLAGS += -march=core2")
                sh "./runPerformanceTests.py -j${env.PARALLEL} --runs 3 stat_comp_benchmarks --check-golds --name=known_good_perf --tests-file=known_good_perf_all.tests"
            }
        }
        stage('Shotgun Performance Regression Tests') {
            when { branch 'master' }
            steps {
                sh "make clean"
                writeFile(file: "cmdstan/make/local", text: "CXXFLAGS += -march=native")
                sh "./runPerformanceTests.py -j${env.PARALLEL} --runj 1 example-models/bugs_examples example-models/regressions --name=shotgun_perf --tests-file=shotgun_perf_all.tests"
            }
        }
        stage('Collect test results') {
            when { branch 'master' }
            steps {
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

    post {
        unstable {
            script { utils.mailBuildResults("UNSTABLE", "stan-buildbot@googlegroups.com") }
        }
        failure {
            script { utils.mailBuildResults("FAILURE", "stan-buildbot@googlegroups.com") }
        }
    }
}
