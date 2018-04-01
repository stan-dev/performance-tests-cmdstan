pipeline {
    agent { label 'master' }
    options { skipDefaultCheckout() }
    stages {
        stage('Update CmdStan pointer to latest develop') {
            when { branch 'master' }
            steps {
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
                sh """
                cd cmdstan
                git pull origin develop
                cd ..
                if [ -n "\$(git status --porcelain cmdstan)" ]; then
                  git commit cmdstan -m "Update submodules"
                  git push origin master
                fi
            """
            }
        }
        stage("Test cmdstan develop against cmdstan pointer in this branch") {
            when { not { branch 'master' } }
            steps {
                sh """
                cmdstan_hash=\$(git submodule status | grep cmdstan | awk '{print \$1}')
                bash compare-git-hashes.sh develop \$cmdstan_hash stat_comp_benchmarks
            """
            }
        }
        stage("Numerical Accuracy and Performance Tests on Known-Good Models") {
            when { branch 'master' }
            steps {
                sh "./runPerformanceTests.py -j${env.PARALLEL} --runs 10 stat_comp_benchmarks"
            }
            post {
                always {
                    retry(2) {
                        junit '*.xml'
                        archiveArtifacts '*.csv, *.xml'
                        perfReport compareBuildPrevious: true, errorFailedThreshold: 0, errorUnstableThreshold: 0, failBuildIfNoResultFile: false, modePerformancePerTestCase: true, sourceDataFiles: '*.xml'
                    }
                }
            }
        }
        stage('Shotgun Performance Regression Tests') {
            when { branch 'master' }
            steps {
                sh "./runPerformanceTests.py -j${env.PARALLEL} --runj ${env.PARALLEL} example-models/bugs_examples"
            }
            post {
                always {
                    retry(2) {
                        junit '*.xml'
                        archiveArtifacts '*.xml'
                    }
                }
            }
        }
    }
    post {
        always {
            deleteDir()
        }
    }
}
