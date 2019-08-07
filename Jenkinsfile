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

def results_to_obj(body, state){

    def returnMap = [:]

    returnMap["gp_pois_regr"] = (body =~ /gp_pois_regr\.stan', (.*?)\)/)[0][1] 
    returnMap["low_dim_corr_gauss"] = (body =~ /low_dim_corr_gauss\.stan', (.*?)\)/)[0][1] 
    returnMap["irt_2pl"] = (body =~ /irt_2pl\.stan', (.*?)\)/)[0][1] 
    returnMap["one_comp_mm_elim_abs"] = (body =~ /one_comp_mm_elim_abs\.stan', (.*?)\)/)[0][1] 
    returnMap["eight_schools"] = (body =~ /eight_schools\.stan', (.*?)\)/)[0][1] 
    returnMap["gp_regr"] = (body =~ /gp_regr\.stan', (.*?)\)/)[0][1] 
    returnMap["arK"] = (body =~ /arK\.stan', (.*?)\)/)[0][1] 
    returnMap["compilation"] = (body =~ /compilation', (.*?)\)/)[0][1] 
    returnMap["low_dim_gauss_mix_collapse"] = (body =~ /low_dim_gauss_mix_collapse\.stan', (.*?)\)/)[0][1] 
    returnMap["low_dim_gauss_mix"] = (body =~ /low_dim_gauss_mix\.stan', (.*?)\)/)[0][1] 
    returnMap["sir"] = (body =~ /sir\.stan', (.*?)\)/)[0][1] 
    returnMap["sim_one_comp_mm_elim_abs"] = (body =~ /sim_one_comp_mm_elim_abs\.stan', (.*?)\)/)[0][1] 
    returnMap["garch"] = (body =~ /garch\.stan', (.*?)\)/)[0][1] 
    returnMap["gen_gp_data"] = (body =~ /gen_gp_data\.stan', (.*?)\)/)[0][1] 
    returnMap["arma"] = (body =~ /arma\.stan', (.*?)\)/)[0][1] 

    if( state == "old"){
        returnMap["result"] = (body =~ /(?m)Result: (.*?)$/)[0][1] 
    }
    else if (state == "new"){
        returnMap["result"] = (body =~ /(?m)Result: (.*?)\\r\\n/)[0][1] 
    }

    return returnMap
}


def get_last_results(repository, pr_number){

    println "https://api.github.com/repos/stan-dev/${repository}/issues/${pr_number}/comments?direction=desc"

    def get = new URL("https://api.github.com/repos/stan-dev/${repository}/issues/${pr_number}/comments?direction=desc").openConnection();
    def getRC = get.getResponseCode();
    
    if(getRC.equals(200)) {
      
        def res = get.getInputStream().getText();

        println res
      
      	def jsonSlurper = new JsonSlurper();

        def returnMap = [:]
      
        for(o in jsonSlurper.parseText(res)){
          
            def body = o.body.toString()

            println body

            if(body.contains("stat_comp_benchmarks/benchmarks")){

                println body

                return results_to_obj(body, "old");
            }    
        }
    }
    else{
        println "Something wrong happened when trying to get the last result from github."
        return false
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

def post_comment(text, repository, pr_number) {

    def new_results = results_to_obj(text, "new")

    println "old_results"
    /* HANDLE EMPTY OLD VALUE !!! */
    def old_results = get_last_results(repository, pr_number)

    if(!old_results){
      new_results.each{ k, v ->   
        old_results[k] = v
      }
    }

    println old_results

    println "final_results"
    def final_results = [:]

    println "iteration"
    new_results.each{ k, v ->   

      def new_value = v.toDouble();
      def old_value = old_results[k].toDouble();
      def change_result = (1 - new_value) / old_value

      if(change_result > 0){
          final_results[k] = ((change_result * 100).toInteger()).toString() + "% faster"
      }
      else{
          final_results[k] = ((change_result * 100).toInteger()).toString() + "% slower"
      }

    }

    def _comment = ""

    _comment += "Jenkins Console Log: https://jenkins.mc-stan.org/job/$repository/view/change-requests/job/PR-$pr_number/$BUILD_NUMBER/consoleFull" + "\\r\\n"
    _comment += "Blue Ocean: https://jenkins.mc-stan.org/blue/organizations/jenkins/$repository/detail/PR-$pr_number/$BUILD_NUMBER/pipeline"+ "\\r\\n"

    _comment += "- - - - - - - - - - - - - - - - - - - - -" + "\\r\\n"

    _comment += "| Name | Old Result | New Result | Performance change( 1 - new / old ) |" + "\\r\\n"
    _comment += "| ------------- |------------- | ------------- | ------------- |" + "\\r\\n"

    final_results.each{ k, v -> 
    
    def _name = "${k}"
    def _final_value = "${v}"
    def _new_value = new_results[_name]
    def _old_value = old_results[_name]

    _comment += "| $_name | $_old_value | $_new_value | $_final_value |" + "\\r\\n"
    }

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
                println "post success"
                def comment = get_results()

                println "post cmdstan"
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
