pipeline {
    agent {
        node {
            label 'Jenkins-slave-node'
        }
    }

    environment {
        PATH = "/opt/apache-maven-3.9.6/bin:$PATH"
    }

    stages {
        stage("Build Stage") {
            steps {
                echo "----------- build started ----------"
                sh 'mvn clean deploy -Dmaven.test.skip=true'
                echo "----------- build completed ----------"
            }
        }

        stage("Test Stage") {
            steps {
                echo "----------- unit test started ----------"
                sh 'mvn surefire-report:report'
                echo "----------- unit test Completed ----------"
            }
        }

        /*
        stage('SonarQube Analysis') {
            environment {
                scannerHome = tool 'sonar-scanner-meportal'
            }
            steps {
                withSonarQubeEnv('sonar-server-meportal') {
                    sh "${scannerHome}/bin/sonar-scanner"
                }
            }
        }

        stage("Quality Gate") {
            steps {
                script {
                    timeout(time: 1, unit: 'HOURS') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }
        */
        

        stage("Artifact Publish") {
            steps {
                script {
                    echo '-------------- Artifact Publish Started --------------'
                    def server = Artifactory.newServer url:"https://myportall1234.jfrog.io//artifactory" ,  credentialsId:"jfrog-cred"
                    def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}";
                    def uploadSpec = """{
                        "files": [
                            {
                                "pattern": "staging/(*)",
                                "target": "release-local-artifacts/{1}",
                                "flat": "false",
                                "props" : "${properties}",
                                "exclusions": [ "*.sha1", "*.md5"]
                            }
                        ]
                    }"""
                    def buildInfo = server.upload(uploadSpec)
                    buildInfo.env.collect()
                    server.publishBuildInfo(buildInfo)
                    echo '------------ Artifact Publish Ended -----------'  
                }
            }
        }

       stage("Create Docker Image") {
            steps {
                script {
                    echo '-------------- Docker Build Started -------------'
                    app = docker.build("myportall1234.jfrog.io/mymeportal-docker-local/myapp:1.0.1")
                    echo '-------------- Docker Build Ended -------------'
                }
            }
        }
        stage (" Docker Publish ") {
            steps {
                script {
                    echo '---------- Docker Publish Started --------'
                    docker.withRegistry("https://myportall1234.jfrog.io", 'jfrog-cred') {
                        app.push()
                        echo '------------ Docker Publish Ended ---------'
                    }
                }
            }
        }

        /*stage("Deploy Stage") {
            steps {
                script {
                    sh './deploy.sh'
                }    
            }
        }
        */
        stage(" Deploy ") {
       steps {
         script {
            echo '<--------------- Helm Deploy Started --------------->'
            sh 'helm install meportal /home/ubuntu/meportal-1.0.1.tgz'
            echo '<--------------- Helm deploy Ends --------------->'
         }
       }
     }
    
        
    

    
    }
}
