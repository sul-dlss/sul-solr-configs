pipeline {
  agent any

  environment {
    PROJECT = 'sul-dlss/sul-solr-configs'
    SOLR_ADMIN_BASE_URL = credentials("sul-solr-admin-url")
  }

  stages {
    stage('Config deploy') {
      when {
        branch 'main'
      }

      steps {
        checkout scm

        sshagent (['sul-devops-team']){
          sh '''#!/bin/bash -l

          bundle install

          git diff --name-only $GIT_PREVIOUS_SUCCESSFUL_COMMIT $GIT_COMMIT | 
            xargs dirname | sort | uniq |
            grep -v "spec/" | grep -v "plugins" | grep -v "\\." |
            xargs -I {} bundle exec rake upconfig collection="{}"
          '''
        }
      }

      post {
        always {
          build job: '/Continuous Deployment/Slack Deployment Notification', parameters: [
            string(name: 'PROJECT', value: env.PROJECT),
            string(name: 'GIT_COMMIT', value: env.GIT_COMMIT),
            string(name: 'GIT_URL', value: env.GIT_URL),
            string(name: 'GIT_PREVIOUS_SUCCESSFUL_COMMIT', value: env.GIT_PREVIOUS_SUCCESSFUL_COMMIT),
            string(name: 'DEPLOY_ENVIRONMENT', value: env.DEPLOY_ENVIRONMENT),
            string(name: 'TAG_NAME', value: env.TAG_NAME),
            booleanParam(name: 'SUCCESS', value: currentBuild.resultIsBetterOrEqualTo('SUCCESS')),
            string(name: 'RUN_DISPLAY_URL', value: env.RUN_DISPLAY_URL)
          ]
        }
      }
    }
  }
}
