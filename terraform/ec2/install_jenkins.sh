#!/bin/bash
sudo yum update –y
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y
sudo yum install git -y
sudo yum install java-17-amazon-corretto -y
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
cd /var/lib/jenkins
sudo -u jenkins touch jenkins.install.UpgradeWizard.state
sudo chmod 777 jenkins.install.UpgradeWizard.state
sudo -u jenkins echo "2.0" >> jenkins.install.UpgradeWizard.state
sudo -u jenkins mkdir init.groovy.d
cd init.groovy.d
sudo -u jenkins touch basic-security.groovy
sudo chmod 777 basic-security.groovy
cat << EOF >> basic-security.groovy
#!groovy

import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

println "--> creating local user 'admin'"

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount('admin','admin')
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)
instance.save()
EOF

sudo systemctl restart jenkins

cd /
#sudo git clone #git credentials
#cd Repo

sudo wget http://localhost:8080/jnlpJars/jenkins-cli.jar

sudo chmod 777 jenkins-cli.jar

java -jar jenkins-cli.jar -s http://localhost:8080/ -auth 'admin:admin' -webSocket install-plugin extra-columns:1.26
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth 'admin:admin' -webSocket install-plugin deploy-dashboard:0.1.0
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth 'admin:admin' -webSocket install-plugin pipeline-agent-build-history
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth 'admin:admin' -webSocket install-plugin workflow-job
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth 'admin:admin' -webSocket install-plugin workflow-aggregator
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth 'admin:admin' -webSocket install-plugin Git
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth 'admin:admin' -webSocket install-plugin github
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth 'admin:admin' -webSocket install-plugin configuration-as-code:1775.v810dc950b_514
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth 'admin:admin' -webSocket install-plugin workflow-aggregator:596.v8c21c963d92d
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth 'admin:admin' -webSocket install-plugin cloudbees-folder:6.928.v7c780211d66e
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth 'admin:admin' -webSocket install-plugin sonar:2.17.2
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth 'admin:admin' -webSocket install-plugin aws-credentials:218.v1b_e9466ec5da_
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth 'admin:admin' -webSocket install-plugin job-dsl:1.87
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth 'admin:admin' -webSocket install-plugin pipeline-utility-steps:2.16.2
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth 'admin:admin' -webSocket install-plugin pipeline-utility-steps:2.16.2
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth 'admin:admin' -webSocket install-plugin pipeline-stage-view:2.34
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth 'admin:admin' -webSocket install-plugin multibranch-scan-webhook-trigger:1.0.11
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth 'admin:admin' -webSocket install-plugin jobcacher:432.vb_b_fc2291c917
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth 'admin:admin' -webSocket install-plugin aws-secrets-manager-secret-source:1.72.v61781b_35c542
sudo systemctl restart jenkins

#java -jar jenkins-cli.jar -s http://localhost:8080/ -auth 'admin:admin' -webSocket create-job new-pipeline < job.xml
#java -jar jenkins-cli.jar -s http://localhost:8080/ -auth 'admin:admin' -webSocket build new-pipeline