#!/usr/bin/env groovy
/**
  This is the Jenkinsfile to execute the ansible playbook to 
  deploy prometheus
 */
ansiColor('xterm') {
  timestamps {
        node('dhslave') {
          configFileProvider(
          [configFile( fileId: 'kubeconfig', variable: 'KUBECONFIG')]){
	      stage('Pull Git Repositories') {
                checkout_repo()
              }
              stage('Trigger Playbook') {
                deploy_prometheus()
              }
          }
        }
  }
}
def checkout_repo() {
    checkout poll: false, scm: [
      $class: 'GitSCM',
      branches: [[name: "*/master"]],
      doGenerateSubmoduleConfigurations: false,
      submoduleCfg: [],
      userRemoteConfigs: [[url: 'https://gitlab.cee.redhat.com/AICoE/prometheus-lts.git']]
    ]
}
def deploy_prometheus() {
  try {
      sh '''
virtualenv $WORKSPACE/venv
source $WORKSPACE/venv/bin/activate
set -ex
cd ansible
ansible-playbook playbooks/prometheus-deployment.yaml -vvv -i inventory --tags "delete_prometheus,deploy_prometheus" -e "kubeconfig=$KUBECONFIG project=${PROJECT}"
'''
  } catch (err) {
    echo 'Exception caught, being re-thrown...'
    throw err
  }
}
