#!/usr/bin/env groovy
@Library('StanUtils')
import org.stan.Utils
import groovy.json.JsonSlurper

def utils = new org.stan.Utils()

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

@NonCPS
def get_results(){
    def performance_log = currentBuild.rawBuild.getLog(Integer.MAX_VALUE).join('\n')
}

pipeline {
    agent { label 'windows' }
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
        stage('Gather machine information') {
            steps {
                script {

                    current_os = checkOs()

                    def command = """
                            echo "--- Machine Information ---"
                            echo "--- CPU ---"
                    """

                    if(current_os == "windows"){
                        command += """ wmic CPU get NAME """
                    }
                    else if(current_os == "macos"){
                        command += """ sysctl -n machdep.cpu.brand_string """
                    }
                    else{
                        command += """ lscpu """
                    }

                    command += """
                            echo "--- CPU ---"
                    """

                    command += """
                            echo "--- G++ ---"
                            g++ --version
                            echo "--- G++ ---"

                            echo "--- CLANG ---"
                            clang --version
                            echo "--- CLANG ---"

                            echo "--- Machine Information ---"
                    """

                    if(current_os == "windows"){
                        bat command
                    }
                    else{
                        sh command
                    }

                    performance_log = get_results()
                    println performance_log
                }
            }
        }
    }
}
