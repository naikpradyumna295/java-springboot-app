pipeline {
    agent {
        node {
            label 'Jenkins-slave-node'  
        }
    }
    environment {
        PATH = "/opt/maven/bin:$PATH"
        scannerHome = tool name: 'sonar-scanner-meportal', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
    }
    stages {
        stage("Build Code") { 
            steps {
                echo "Build started"
                sh 'mvn clean package -Dmaven.test.skip=true'
                echo "Build completed"
            }
        }
        stage('SonarQube analysis') {
            steps {
                script {
                    withSonarQubeEnv('sonar-server-meportal') {
                        sh "${env.scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }
    }
}
