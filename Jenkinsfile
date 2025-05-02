pipeline {
  agent { label 'adacloud-bridge-wn' }
  triggers { githubPush() }
  options {
    skipDefaultCheckout(true)
    buildDiscarder(logRotator(numToKeepStr: '7'))
    disableConcurrentBuilds()
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Check for Relevant Changes') {
      when { 
        changeset "nginx/**",
                  "compose.yaml",
                  "Dockerfile",
                  "entrypoint.sh",
                  "saber_monitor_settings.yaml",
                  "swag-playbook.yaml",
                  "**/*.ga",
                  "Jenkinsfile"
      }
      steps {
        echo "Relevant files changed—continuing build."
      }
    }

    stage('Deploy') {
      when { branch 'master' }
      steps {
        sshagent(['usegalaxy_it_robot_ssh_key_pair']) {
          withCredentials([
            string(credentialsId: 'ad609b86-aec4-4657-a224-b4bb62e3bea7', variable: 'SABER_PASSWORD'),
            string(credentialsId: 'cert_mail_saber', variable: 'CERT_EMAIL')
          ]) {
            sh '''
              python3 -m venv venv
              . venv/bin/activate
              pip install ansible

              echo "password: $SABER_PASSWORD" > .temp_vars.yaml
              echo "cert_mail: $CERT_EMAIL" >> .temp_vars.yaml
              chmod 600 .temp_vars.yaml

              ansible-playbook -i monitor.usegalaxy.it, swag-playbook.yaml \
                -u ubuntu -b --extra-vars "@.temp_vars.yaml"
            '''
          }
        }
      }
    }
  }

  post {
    always {
      sh 'rm -f .temp_vars.yaml || true'
      cleanWs(
        cleanWhenAborted: true,
        cleanWhenFailure: true,
        cleanWhenNotBuilt: true,
        cleanWhenUnstable: true,
        cleanupMatrixParent: true,
        excludePatterns: "**/venv/**"
      )
    }
    failure {
      emailext(
        subject: "FAILED: ${currentBuild.fullDisplayName}",
        body: "Build ${BUILD_URL} failed. See logs for details.",
        recipientProviders: [[$class: 'DevelopersRecipientProvider']]
      )
    }
  }
}
