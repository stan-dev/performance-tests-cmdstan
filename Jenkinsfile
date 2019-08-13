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

def mapBuildResult(body){

    println body

    returnMap = [:]

    benchmarks = (body =~ /\/benchmarks\/(\w+)\/(.*?)', (.*?), (.*?), (.*?), (.*?)\)/)
    compilation = (body =~ /compilation', (.*?), (.*?), (.*?), (.*?)\)/)[0]
    mean = (body =~ /(?s)(\d{1}\.?\d{11})/)[0][1]

    for (i = 0; i < benchmarks.size(); i++) {

      println benchmarks[i]

      name = benchmarks[i][1]
      filename = benchmarks[i][2]
      old_value = benchmarks[i][3]
      new_value = benchmarks[i][4]
      ratio = benchmarks[i][5]
      change = benchmarks[i][6]

      returnMap["$name"] = [
        "old": old_value,
        "new": new_value,
        "ratio": ratio,
        "change": change
      ]

    }

    returnMap["compilation"] = [
        "old": compilation[1],
        "new": compilation[2],
        "ratio": compilation[3],
        "change": compilation[4]
      ]

    returnMap["mean"] = mean.toString()
    
    return returnMap
}

def MapLastGitHubComment(body){
    returnMap = [:]

    benchmarks = (body =~ /\| (.*?) \| (.*?) \| (.*?) \| (.*?) \| (.*?) \|/)

    for (i = 0; i < benchmarks.size(); i++) {
      name = benchmarks[i][1]
      old_value = benchmarks[i][2]
      new_value = benchmarks[i][3]
      ratio = benchmarks[i][4]
      change = benchmarks[i][5]

      if(name != "Name") 
        returnMap[name] = value
    }

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

            if(body.contains("low_dim_gauss_mix_collapse")){
                return mapLastGitHubComment(body);
            }    
        }
    }

    return [:]
}

@NonCPS
def get_results(){
    def performance_log = currentBuild.rawBuild.getLog(Integer.MAX_VALUE).join('\n')
    def comment = ""

    def test_matches = (performance_log =~ /\('(.*)\)/)
    for(item in test_matches){
        comment += item[0] + "\\r\\n"
    }

    def result_match = (performance_log =~ /(?s)(\d{1}\.?\d{12})/)[0][1].toString()
    comment += "Result: " + result_match[0][1].toString() + "\\r\\n"

    def result_match_hash = (performance_log =~ /Merge (.*?) into/)
    comment += "Commit hash: " + result_match_hash[0][1].toString() + "\\r\\n"

    performance_log = null

    return comment
}

def post_comment(text, repository, pr_number) {

    new_results = mapBuildResult(text)
    _comment = ""

    _comment += "[Jenkins Console Log](https://jenkins.mc-stan.org/job/$repository/view/change-requests/job/PR-$pr_number/$BUILD_NUMBER/consoleFull)" + "\\r\\n"
    _comment += "[Blue Ocean](https://jenkins.mc-stan.org/blue/organizations/jenkins/$repository/detail/PR-$pr_number/$BUILD_NUMBER/pipeline)"+ "\\r\\n"
    _comment += "- - - - - - - - - - - - - - - - - - - - -" + "\\r\\n"

    _comment += "| Name | Old Result | New Result | Ratio | Performance change( 1 - new / old ) |" + "\\r\\n"
    _comment += "| ------------- |------------- | ------------- | ------------- |" + "\\r\\n"

    new_results.each{ k, v -> 
        name = "${k}"
        values = "${v}"
        if (name != "mean")
            _comment += "| $name | " + values["old"] + " | " + values["new"] + " | " + values["ratio"] + " | " + values["change"] + " | " + "\\r\\n"
    }

    _comment += "Mean result: " + new_results["mean"]

    sh """#!/bin/bash
        curl -s -H "Authorization: token ${GITHUB_TOKEN}" -X POST -d '{"body": "${_comment}"}' "https://api.github.com/repos/stan-dev/${repository}/issues/${pr_number}/comments"
    """
}

pipeline {
    agent { label 'gelman-group-mac' }
    environment {
        cmdstan_pr = ""
        GITHUB_TOKEN = credentials('6e7c1e8f-ca2c-4b11-a70e-d934d3f6b681')
    }
    options {
        skipDefaultCheckout()
        preserveStashes(buildCount: 7)
    }
    parameters {
        string(defaultValue: 'develop', name: 'cmdstan_pr', description: "CmdStan hash/branch to compare against")
        string(defaultValue: 'PR-2761', name: 'stan_pr', description: "Stan PR to test against. Will check out this PR in the downstream Stan repo.")
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
                            #git pull
                            git checkout print-results
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
            when { branch 'master' }
            steps {
                writeFile(file: "cmdstan/make/local", text: "CXXFLAGS += -march=core2")
                sh "./runPerformanceTests.py --runs 3 --check-golds --name=known_good_perf --tests-file=known_good_perf_all.tests"
            }
        }
        stage('Shotgun Performance Regression Tests') {
            when { branch 'master' }
            steps {
                sh "make clean"
                writeFile(file: "cmdstan/make/local", text: "CXXFLAGS += -march=native")
                sh "cat shotgun_perf_all.tests"
                sh "./runPerformanceTests.py --name=shotgun_perf --tests-file=shotgun_perf_all.tests --runs=2"
            }
        }
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
        /*
        unstable {
            script { utils.mailBuildResults("UNSTABLE", "stan-buildbot@googlegroups.com, sean.talts@gmail.com, serban.nicusor@toptal.com") }
        }
        failure {
            script { utils.mailBuildResults("FAILURE", "stan-buildbot@googlegroups.com, sean.talts@gmail.com, serban.nicusor@toptal.com") }
        }
        */
    }
}
