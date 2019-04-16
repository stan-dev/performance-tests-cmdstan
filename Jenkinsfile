#!/usr/bin/env groovy
@Library('StanUtils')
import org.stan.Utils

def utils = new org.stan.Utils()

pipeline {
    agent { label 'master' }
    options {
        skipDefaultCheckout()
        preserveStashes(buildCount: 7)
    }
    parameters {
        string(defaultValue: '', name: 'cmdstan_hash',
               description: "CmdStan hash/branch to compare against")
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
                sh """
                bash compare-git-hashes.sh develop ${cmdstan_hash} stat_comp_benchmarks
                mv performance.xml ${cmdstan_hash}.xml
                make revert clean
            """
            }
        }
        stage("Numerical Accuracy and Performance Tests on Known-Good Models") {
            when { branch 'master' }
            steps {
                writeFile(file: "cmdstan/make/local", text: "CXXFLAGS += -march=core2")
                sh "./runPerformanceTests.py -j${env.PARALLEL} --runs 3 stat_comp_benchmarks --check-golds --name=known_good_perf"
            }
        }
        stage('Shotgun Performance Regression Tests') {
            when { branch 'master' }
            steps {
                sh "make clean"
                writeFile(file: "cmdstan/make/local", text: "CXXFLAGS += -march=native")
                sh "./runPerformanceTests.py -j${env.PARALLEL} --runj ${env.PARALLEL} example-models/bugs_examples example-models/regressions --name=shotgun_perf"
            }
        }
        stage('Collect test results') {
            steps {
                junit '*.xml'
                archiveArtifacts '*.xml'
                perfReport compareBuildPrevious: true, errorFailedThreshold: 0, errorUnstableThreshold: 0, failBuildIfNoResultFile: false, modePerformancePerTestCase: true, sourceDataFiles: '*.xml', modeThroughput: false
            }
        }
    }

    post {
        failure {
            script { utils.mailBuildResults("FAILURE", "stan-buildbot@googlegroups.com") }
        }
    }
}
