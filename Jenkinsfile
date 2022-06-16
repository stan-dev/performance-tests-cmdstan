#!/usr/bin/env groovy
@Library('StanUtils')
import org.stan.Utils
import groovy.json.JsonSlurper
import groovy.json.*

def utils = new org.stan.Utils()

def branchOrPR(pr) {
  if (pr == "downstream_tests") return "develop"
  if (pr == "downstream_hotfix") return "master"
  if (pr == "") return "develop"
  return pr
}

def checkOs(){
    if (isUnix()) {
        def uname = sh script: 'uname', returnStdout: true
        if (uname.startsWith("Darwin")) {
            return "macos"
        }
        else {
            return "linux"
        }
    }
    else {
        return "windows"
    }
}

def escapeStringForJson(inputString){
    return inputString.trim().replace("\r","\\r").replace("\n","\\n").replace("\t"," ").replace("\"","\\\"").replace("\\", "\\\\")
}

def mapBuildResult(body){

    def returnMap = [:]

    returnMap["table"] = (body =~ /(?s)---RESULTS---(.*?)---RESULTS---/)[0][1]
    returnMap["table"] = escapeStringForJson(returnMap["table"]).replace("stat_comp_benchmarks/benchmarks/","")

    returnMap["hash"] = (body =~ /Merge (.*?) into/)[0][1]
    returnMap["hash"] = escapeStringForJson(returnMap["hash"])

    def current_os = (body =~ /Current OS: (.*?) !/)[0][1]

    def cpu = ""
    def gpp = ""
    def clang = ""
    def sys_ver = ""

    if(current_os == "windows"){
        cpu = (body =~ /(?s)wmic CPU get NAME(.*?)(C:|J:|Z:)/)[0][1]
        sys_ver = (body =~ /(?s)>ver(.*?)(C:|J:|Z:)/)[0][1]
        gpp = (body =~ /(?s)g\+\+ --version(.*?)(C:|J:|Z:)/)[0][1]
        clang = (body =~ /(?s)clang --version(.*?)(C:|J:|Z:)/)[0][1]
    }
    else if(current_os == "macos"){
        cpu = (body =~ /(?s)sysctl -n machdep\.cpu\.brand_string(.*?)\+ sw_vers/)[0][1]
        sys_ver = (body =~ /(?s)sw_vers(.*?)\+ g\+\+/)[0][1]
        gpp = (body =~ /(?s)g\+\+ --version(.*?)\+ clang/)[0][1]
        clang = (body =~ /(?s)clang --version(.*?)\+ echo/)[0][1]
    }
    else{
        cpu = (body =~ /(?s)lscpu(.*?)\+ lsb_release/)[0][1]
        sys_ver = (body =~ /(?s)lsb_release -a(.*?)\+ g\+\+/)[0][1]
        gpp = (body =~ /(?s)g\+\+ --version(.*?)\+ clang/)[0][1]
        clang = (body =~ /(?s)clang --version(.*?)\+ echo/)[0][1]
    }


    returnMap["system"] = [
        "cpu": escapeStringForJson(cpu),
        "sys_ver": escapeStringForJson(sys_ver),
        "gpp": escapeStringForJson(gpp),
        "clang": escapeStringForJson(clang)
      ]

    return returnMap
}

@NonCPS
def get_results(){
    def performance_log = currentBuild.rawBuild.getLog(Integer.MAX_VALUE).join('\n')
    return performance_log
}

@NonCPS
def post_comment(text, repository, pr_number, blue_ocean_repository) {

    def new_results = mapBuildResult(text)

    def j = Jenkins.getInstance();

    def stanDir = j.getItem("Stan");
    def proj = stanDir.getItem("$blue_ocean_repository");
    def jobs = proj.getItems()

    def upstream_build_no = null
    def masterJob = null

    (jobs).each { job ->
    	if (job.displayName == "PR-$pr_number") {
    		upstream_build_no = job.getLastBuild().getNumber().toString()
    		println "Upstream Build No. $upstream_build_no"
    	}
    }

    def _comment = ""

    _comment += "- - - - - - - - - - - - - - - - - - - - -" + "\\r\\n"
    _comment += new_results["table"] + "\\r\\n"
    _comment += "- - - - - - - - - - - - - - - - - - - - -" + "\\r\\n"

    _comment += "[Jenkins Console Log](https://jenkins.flatironinstitute.org/job/Stan/job/$blue_ocean_repository/view/change-requests/job/PR-$pr_number/$upstream_build_no/consoleFull)" + "\\r\\n"
    _comment += "[Blue Ocean](https://jenkins.flatironinstitute.org/blue/organizations/jenkins/Stan%2F$blue_ocean_repository/detail/PR-$pr_number/$upstream_build_no/pipeline)" + "\\r\\n"

    _comment += "Commit hash: " + new_results["hash"] + "\\r\\n"

    _comment += "- - - - - - - - - - - - - - - - - - - - -" + "\\r\\n"

    _comment += "<details><summary>Machine information</summary>"

    _comment += "\\r\\n" + new_results["system"]["sys_ver"] + "\\r\\n" + "\\r\\n"

    _comment += "CPU: " + "\\r\\n"
    _comment += new_results["system"]["cpu"] + "\\r\\n" + "\\r\\n"

    _comment += "G++: " + "\\r\\n"
    _comment += new_results["system"]["gpp"] + "\\r\\n" + "\\r\\n"

    _comment += "Clang: " + "\\r\\n"
    _comment += new_results["system"]["clang"] + "\\r\\n" + "\\r\\n"

    _comment += "</details>"
    _comment = _comment.replace("\\\\","\\")

    sh """#!/bin/bash
        echo "${_comment}" >> /tmp/github.test
        curl -s -H "Authorization: token ${GITHUB_TOKEN}" -X POST -d '{"body": "${_comment}"}' "https://api.github.com/repos/stan-dev/${repository}/issues/${pr_number}/comments"
    """
}

pipeline {
    agent { label 'docker' }
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
        stage('Clean checkout') {
            agent {
                docker {
                    image 'stanorg/ci:gpu'
                    label 'docker'
                    reuseNode true
                }
            }
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
                          userRemoteConfigs: [[url: "https://github.com/stan-dev/performance-tests-cmdstan.git",
                                               credentialsId: 'a630aebc-6861-4e69-b497-fd7f496ec46b'
                    ]]])

                stash 'PerfSetup'
            }
        }
        stage('Gather machine information') {
            agent {
                docker {
                    image 'stanorg/ci:gpu'
                    label 'docker'
                    reuseNode true
                }
            }
            steps {
                script {

                    def current_os = checkOs()

                    def command = """
                            echo "--- Machine Information ---"
                            echo "Current OS: ${current_os} !"
                    """

                    if(current_os == "windows"){
                        command += """
                                wmic CPU get NAME
                                ver
                        """
                    }
                    else if(current_os == "macos"){
                        command += """
                                sysctl -n machdep.cpu.brand_string
                                sw_vers
                        """
                    }
                    else{
                        command += """
                                lscpu
                                lsb_release -a || true
                        """
                    }

                    command += """
                            g++ --version || true
                            clang --version || true
                            echo "--- Machine Information ---"
                    """

                    if(current_os == "windows"){
                        bat command
                    }
                    else{
                        sh command
                    }
                }
            }
        }
        stage('Update CmdStan pointer to latest develop') {
            agent {
                docker {
                    image 'stanorg/ci:gpu'
                    label 'docker'
                    reuseNode true
                }
            }
            when { branch 'master' }
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'a630aebc-6861-4e69-b497-fd7f496ec46b', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                        sh """#!/bin/bash
                            set -e

                            git config user.email "mc.stanislaw@gmail.com"
                            git config user.name "Stan Jenkins"

                            cd cmdstan
                            git pull origin develop
                            git submodule update --init --recursive
                            cd ..

                            if [ -n "\$(git status --porcelain cmdstan)" ]; then
                                git checkout master
                                git pull
                                git commit cmdstan --author="Stan BuildBot <mc.stanislaw@gmail.com>" -m "Update submodules"
                                git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/stan-dev/performance-tests-cmdstan.git master
                            fi
                        """
                    }
                }
            }
        }
        stage("Test cmdstan develop against cmdstan pointer in this branch") {
            agent {
                docker {
                    image 'stanorg/ci:gpu'
                    label 'docker'
                    reuseNode true
                }
            }
            when { not { branch 'master' } }
            steps {
                script{
                        cmdstan_pr = branchOrPR(params.cmdstan_pr)

                        sh """
                            old_hash=\$(git submodule status | grep cmdstan | awk '{print \$1}')
                            cmdstan_hash=\$(if [ -n "${cmdstan_pr}" ]; then echo "${cmdstan_pr}"; else echo "\$old_hash" ; fi)
                            bash compare-git-hashes.sh stat_comp_benchmarks develop \$cmdstan_hash ${branchOrPR(params.stan_pr)} ${branchOrPR(params.math_pr)}
                            mv performance.xml \$cmdstan_hash.xml
                            make revert clean
                        """
                }
            }
        }
        stage("Numerical Accuracy and Performance Tests on Known-Good Models") {
            agent { label 'osx' }
            when { branch 'master' }
            steps {
               unstash "PerfSetup"
               writeFile(file: "cmdstan/make/local", text: "CXXFLAGS += -march=core2")
               sh "python3 runPerformanceTests.py --runs 3 --check-golds --name=known_good_perf --tests-file=known_good_perf_all.tests"
               junit '*.xml'
               archiveArtifacts '*.xml'
            }
        }
        stage('Shotgun Performance Regression Tests') {
            agent {
                docker {
                    image 'stanorg/ci:gpu'
                    label 'docker'
                    reuseNode true
                }
            }
            when { branch 'master' }
            steps {
                sh "make clean"
                writeFile(file: "cmdstan/make/local", text: "CXXFLAGS += -march=native")
                sh "cat shotgun_perf_all.tests"
                sh "./runPerformanceTests.py --name=shotgun_perf --tests-file=shotgun_perf_all.tests --runs=2"
            }
        }
        stage('Collect test results') {
            agent {
                docker {
                    image 'stanorg/ci:gpu'
                    label 'docker'
                    reuseNode true
                }
            }
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
            post { always { deleteDir() }}
        }
    }

    post {
        success {
            script {
                def job_log = get_results()

                if(params.cmdstan_pr.contains("PR-")){
                    def pr_number = (params.cmdstan_pr =~ /(?m)PR-(.*?)$/)[0][1]
                    post_comment(job_log, "cmdstan", pr_number, "CmdStan")
                }

                if(params.stan_pr.contains("PR-")){
                    def pr_number = (params.stan_pr =~ /(?m)PR-(.*?)$/)[0][1]
                    post_comment(job_log, "stan", pr_number, "Stan")
                }

                if(params.math_pr.contains("PR-")){
                    def pr_number = (params.math_pr =~ /(?m)PR-(.*?)$/)[0][1]
                    post_comment(job_log, "math", pr_number, "Math")
                }
            }
        }
        unstable {
            script { utils.mailBuildResults("UNSTABLE", "stan-buildbot@googlegroups.com, serban.nicusor@toptal.com") }
        }
        failure {
            script { utils.mailBuildResults("FAILURE", "stan-buildbot@googlegroups.com, serban.nicusor@toptal.com") }
        }
    }
}
