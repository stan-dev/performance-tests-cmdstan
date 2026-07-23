properties([
  // disableConcurrentBuilds(),
  buildDiscarder(logRotator(numToKeepStr: '20', daysToKeepStr: '30')),
  parameters([
    string(defaultValue: 'develop', name: 'cmdstan_pr', description: "CmdStan hash/branch to compare against"),
    string(defaultValue: 'develop', name: 'stan_pr', description: "Stan PR to test against. Will check out this PR in the downstream Stan repo."),
    string(defaultValue: 'develop', name: 'math_pr', description: "Math PR to test against. Will check out this PR in the downstream Math repo."),
    // string(defaultValue: 'master', name: 'perf_branch', description: "Performance Tests Cmdstan Branch"), # env.BRANCH_NAME
    string(defaultValue: 'nightly', name: 'stanc3_bin_url', description: 'Custom stanc3 binary url'),
    booleanParam(name:"update_golds", defaultValue: false, description:"Update golds")
  ])
])

def isPrimary = ((env.BRANCH_NAME == "master" || env.BRANCH_NAME == "jenkins-new") && params.cmdstan_pr == "develop")
def stanc3_bin_url = ""
if (params.stanc3_bin_url != "nightly")
  stanc3_bin_url = "STANC3_TEST_BIN_URL=${params.stanc3_bin_url}"

def branchOrPR(pr) {
  [downstream_tests: "develop", downstream_hotfix: "master"].get(pr, pr)
}

def buildInfo = [:]

def postComment(String repo, String pr, Map info) {
  if (pr.startsWith("PR-")) {
    def prn = pr.drop(3)
    def comment = """
${info["table"]}
[Jenkins Console Log]($env.JENKINS_URL/job/CCM/job/$repo/view/change-requests/job/$pr/lastBuild/console)
[Jenkins Build Stages]($env.JENKINS_URL/job/CCM/job/$repo/view/change-requests/job/$pr/lastBuild/stages/)
Commit hash: ${info["hash"]}
<details><summary>Machine information</summary>
<pre>${info["system"]["sys_ver"]}</pre>

CPU:
<pre>${info["system"]["cpu"]}</pre>

G++: 
<pre>${info["system"]["gpp"]}</pre>

Clang: 
<pre>${info["system"]["clang"]}</pre>

</details>
"""
    withCredentials([usernamePassword(usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_TOKEN', credentialsId: 'stan-github')]) {
      httpRequest url:"https://api.github.com/repos/stan-dev/$repo/issues/$prn/comments",
        httpMode: 'POST',
        contentType: 'APPLICATION_JSON',
        customHeaders: [[maskValue: true, name: 'Authorization', value: 'token ' + GITHUB_TOKEN]],
        requestBody: writeJSON(returnText: true, json: [body: comment])
    }
  }
}

catchError {
  runPod(image: "stanorg/ci:gpu", memory: "64Gi") {
    stage('Gather machine information') {
      buildInfo["hash"] = sh(returnStdout: true, script: "git rev-parse HEAD").trim()
      buildInfo["system"] = [
        "cpu":     sh(returnStdout: true, script: "lscpu"),
        "sys_ver": sh(returnStdout: true, script: "lsb_release -a"),
        "gpp":     sh(returnStdout: true, script: "g++ --version"),
        "clang":   sh(returnStdout: true, script: "clang --version")
      ]
    }

    if (isPrimary) {
      stage('Shotgun Performance Regression Tests') {
        sh "make clean"
        writeFile(file: "cmdstan/make/local", text: "CXXFLAGS += -march=native \n$stanc3_bin_url\n")
        sh "cat shotgun_perf_all.tests"
        sh "./runPerformanceTests.py --name=shotgun_perf --tests-file=shotgun_perf_all.tests --runs=2 -j4"
      }
      stage('Collect test results') {
        junit '*.xml'
        archiveArtifacts '*.xml'
      }

    } else {
      stage("Test cmdstan develop against cmdstan pointer in this branch") {
        def cmdstan_pr = branchOrPR(params.cmdstan_pr)

        sh "./compare-git-hashes.sh stat_comp_benchmarks develop $cmdstan_pr ${branchOrPR(params.stan_pr)} ${branchOrPR(params.math_pr)} '$stanc3_bin_url'"
        buildInfo["table"] = sh(returnStdout: true, script: "./comparePerformance.py develop_performance.csv performance.csv md")
      }
    }
  }

  if (isPrimary) {
    node('macos && intel') {
      stage("Numerical Accuracy and Performance Tests on Known-Good Models") {
        checkout scm
        writeFile(file: "cmdstan/make/local", text: "PRECOMPILED_HEADERS=False CXXFLAGS += -march=core2 \n$stanc3_bin_url\n")
        def cmd = 'python3 runPerformanceTests.py --runs 3 --check-golds --name=known_good_perf --tests-file=known_good_perf_all.tests -j$PARALLEL'
        if (params.update_golds)
          cmd += ' --runj 8 --overwrite'
        sh cmd
        junit '*.xml'
        archiveArtifacts '*.xml'

        if (params.update_golds) {
          def currdate = new Date(currentBuild.startTimeInMillis).format("dd-MM-yyyy-HH-mm-ss")
          def branch = "update-golds-test/$currdate"
          def nocommit = sh(returnStatus: true, script: """
            git add golds
            GIT_COMMITTER_NAME="Stan Jenkins" GIT_COMMITTER_EMAIL="mc.stanislow@gmail.com" git commit --author="Stan Jenkins <mc.stanislaw@gmail.com>" -m "Update-golds test results for $currdate"
          """)
          withCredentials([gitUsernamePassword(credentialsId: 'stan-github', gitToolName: 'git-tool')]) {
            sh "git push origin HEAD:refs/heads/$branch"
          }
          withCredentials([usernamePassword(usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_TOKEN', credentialsId: 'stan-github')]) {
            httpRequest url:"https://api.github.com/repos/stan-dev/performance-tests-cmdstan/pulls",
              httpMode: 'POST',
              contentType: 'APPLICATION_JSON',
              customHeaders: [[maskValue: true, name: 'Authorization', value: 'token ' + GITHUB_TOKEN]],
              requestBody: writeJSON(returnText: true, json: [
                "title": "Update golds test results generated by Jenkins for '$currdate'",
                "head": branch,
                "base": env.BRANCH_NAME,
                "body": "Results generated through a [Jenkins Job]($env.RUN_DISPLAY_URL)"
              ])
          }
        }
      }
    }
  }
  else {
    postComment("cmdstan", params.cmdstan_pr, buildInfo)
    postComment("stan",    params.stan_pr,    buildInfo)
    postComment("math",    params.math_pr,    buildInfo)
  }
}

emailFailure()
