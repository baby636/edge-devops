/* groovylint-disable-next-line CompileStatic */
pipeline {
  agent any
  options {
    timestamps()
  }
  environment {
    COVERAGE_TARGET = '70, 0, 0'
    MASTER_BRANCH = 'master'
    INTEGRATION_CONFIG = credentials(env.JOB_NAME)
    IMAGE_NAME_NON_VERSIONED = "${project}/${env.JOB_NAME}"
    IMAGE_NAME = "${project}/${env.JOB_NAME}:${env.BUILD_NUMBER}"
  }

  stages {
    stage('Clean the workspace and checkout source') {
      steps {
        deleteDir()
        checkout scm
        sh "cp $INTEGRATION_CONFIG ./config.integration.json"
      }
    }
    stage ('Build a new image') {
      steps {
        sh "docker rmi -f \$(docker images ${env.IMAGE_NAME_NON_VERSIONED} -q)  || true"
        sh "docker build -t ${imageName} ."
      }
    }
    stage ('Unit Tests') {
      steps {
        sh "docker rm -f ${env.JOB_NAME}-unit-tests || true"
        sh "docker run \
            -v \$(pwd)/coverage:/usr/app/coverage \
            --network=host \
            --name ${env.JOB_NAME}-unit-tests \
            ${env.IMAGE_NAME} unit-tests"
      }
    }
    stage ('Component Tests') {
      steps {
        sh "docker rm -f ${env.JOB_NAME}-component-tests || true"
        sh 'docker-compose down'
        sh 'docker-compose up -d'
        sh "docker run \
            -v \$(pwd)/coverage:/usr/app/coverage \
            --network=host \
            --name ${env.JOB_NAME}-component-tests \
            ${env.IMAGE_NAME} component-tests"
      }
    }
    stage ('Integration Tests') {
      steps {
        sh "docker rm -f ${env.JOB_NAME}-integration-tests || true"
        sh "docker run \
            -v \$(pwd)/coverage:/usr/app/coverage \
            --network=host \
            --name ${env.JOB_NAME}-integration-tests \
            ${env.IMAGE_NAME} integration-tests"
      }
    }
    stage ('End To End Tests') {
      when {
        anyOf {
          branch env.MASTER_BRANCH
          branch 'develop'
        }
      }
      stages {
        stage ('Deploy to QA environment') {
          /* groovylint-disable-next-line NestedBlockDepth */
          steps {
            sh 'echo deploy to QA'
          }
        }
        stage ('Run End To End') {
          /* groovylint-disable-next-line NestedBlockDepth */
          steps {
            build 'end-to-end'
          }
        }
      }
    }
    stage ('Deploy to Production') {
      when { branch env.MASTER_BRANCH }
      steps {
        sh 'echo deploy to Production'
      }
    }
  }
  post {
    always {
      echo 'Trying to publish the test report'
      junit healthScaleFactor: 100.0, testResults: '**/coverage/junit.xml', allowEmptyResults: true
      echo 'Trying to publish the XML code coverage report'
      cobertura(
        coberturaReportFile: '**/coverage/cobertura-coverage.xml',
        failNoReports: false,
        failUnstable: false,
        onlyStable: false,
        zoomCoverageChart: false,
        conditionalCoverageTargets: env.COVERAGE_TARGET,
        lineCoverageTargets: env.COVERAGE_TARGET,
        methodCoverageTargets: env.COVERAGE_TARGET,
        maxNumberOfBuilds: 0,
        sourceEncoding: 'ASCII'
      )
      echo 'Trying to publish the HTML coverage report'
      publishHTML (target: [
        allowMissing: false,
        alwaysLinkToLastBuild: false,
        keepAll: true,
        reportDir: 'coverage',
        reportFiles: 'index.html',
        reportName: 'Istanbul Report'
      ])
    }
    success {
      echo 'The force is strong with this one'
      deleteDir()
    }
    regression {
      echo 'Do or do not there is no try'
    }
    failure {
      echo 'The dark side I sense in you.'
    }
    cleanup {
      sh "docker rm -f ${env.JOB_NAME}-unit-tests || true"
      sh 'docker-compose down || true'
      sh "docker rm -f ${env.JOB_NAME}-component-tests || true"
      sh "docker rm -f ${env.JOB_NAME}-integration-tests || true"
      sh "docker rmi -f \$(docker images ${env.IMAGE_NAME_NON_VERSIONED} -q)  || true"
    }
  }
}

