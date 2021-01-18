package org.vendor

def seekAndDestroy() {
  node {
    try {
      stage ("Prepering workspace") {
        deleteDir()
      }

      stage ("checkout") {
        checkout scm
      }

      stage ("deploy") {
        def deployEnv = getParams.deployment()[0]
        def deployZone = getParams.deployment()[1]
        def deployName = getParams.deployment()[2]
        withCredentials([file(credentialsId: 'c436f526-ea12-4b8d-b34b-52e8651428d9', variable: 'file')]) {
          sh "gcloud auth activate-service-account --key-file=${file}"
          sh "gcloud config set compute/zone ${deployZone}"
          sh "gcloud container clusters get-credentials ${deployEnv}"
          def filesToDeploy = findFiles(glob: "**/*.y*ml")
          for (def i = 0; i < filesToDeploy.length; i++) {
            sh "cat ${filesToDeploy[i]}"
            sh "kubectl apply -f ${filesToDeploy[i].path}"
          }
        }
      }

      stage ("cleanup") {
        deleteDir()
        currentBuild.result = "SUCCESS"
      }
    }
    catch(err) {
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