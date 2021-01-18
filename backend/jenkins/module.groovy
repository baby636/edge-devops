package org.edge

def seekAndDestroy(lint = true, security = true, prep = true, sleepTime = 30) {
  node {
    try {
      deleteDir()

      stage ("checkout") {
        checkout scm
      }

      nodejs(nodeJSInstallationName: "LTS") {
        stage ("install modules") {
          sh "npm i"
        }

        if (lint) {
          stage ("Lint Module") {
            sh "npm run lint"
          }
        }

        if (security) {
          stage ("Module Security Check") {
            sh "npm run security"
          }
        }

        if (prep) {
          stage ("Prepare Enviroment") {
            sh "sudo apt-get install -y jq"
            sh "sh bin/prepareEnv.sh"
            sleep(sleepTime)
          }
        }

        stage ("Test Module") {
          sh "npm test"
        }

        stage ("Coverage") {
          sh "npm run cover"
          publishHTML (target: [
            allowMissing: false,
            alwaysLinkToLastBuild: false,
            keepAll: true,
            reportDir: "coverage",
            reportFiles: "index.html",
            reportName: "Istanbul Report"
          ])
        }
      }

      stage ("cleanup") {
        if (prep) {
          sh "sh bin/cleanEnv.sh"
        }
        deleteDir()
        currentBuild.result = "SUCCESS"
      }
    }
    catch(err) {
      if (prep) {
        sh "sh bin/cleanEnv.sh"
      }
      deleteDir()
      // Do not add a stage here.
      // When "stage" commands are run in a different order than the previous run
      // the history is hidden since the rendering plugin assumes that the system has changed and
      // that the old runs are irrelevant. As such adding a stage at this point will trigger a
      // "change of the system" each time a run fails.
      println "Something went wrong!"
      println err
      currentBuild.result = "FAILURE"
    }
    finally {
      email.send(currentBuild)
      println "Fin"
    }
  }
}

return this