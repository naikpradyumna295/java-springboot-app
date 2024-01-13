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
                script {
                    echo "Build started"
                    sh 'mvn deploy package -Dmaven.test.skip=true' || error "Build failed"
                    echo "Build completed"
                }
            }
        }

        stage('SonarQube analysis') {
            steps {
                script {
                    withSonarQubeEnv('sonar-server-meportal') {
                        sh "${env.scannerHome}/bin/sonar-scanner" || error "SonarQube analysis failed"
                    }
                }
            }
        }

        stage("Artifact Publish") {
            steps {
                script {
                    echo '------------- Artifact Publish Started ------------'
                    def server = Artifactory.newServer url:"https://myportall1234.jfrog.io/artifactory" ,  credentialsId:"jfrog-cred"
                    def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}";
                    def uploadSpec = """{
                        "files": [
                            {
                                "pattern": "staging/*",
                                "target": "release-local-artifacts/{1}",
                                "flat": "false",
                                "props" : "${properties}",
                                "exclusions": [ "*.sha1", "*.md5"]
                            }
                        ]
                    }"""
                    def buildInfo = server.upload(uploadSpec)
                    buildInfo.env.collect()
                    server.publishBuildInfo(buildInfo) || 
                    echo '------------ Artifact Publish Ended -----------'  
                }
            }
        }

        stage("Create Docker Image") {
            steps {
                script {
                    echo '-------------- Docker Build Started -------------'
                    app = docker.build("myportall1234.jfrog.io/meportal-docker-local/myapp:1.0") || error "Docker build failed"
                    echo '-------------- Docker Build Ended -------------'
                }
            }
        }

        stage("Docker Publish") {
            steps {
                script {
                    echo '---------- Docker Publish Started --------'  
                    docker.withRegistry("https://myportall1234.jfrog.io", 'jfrog-cred') {
                        app.push() || error "Docker publish failed"
                        echo '------------ Docker Publish Ended ---------'
                    }    
                }
            }
        }
    }

    post {
        failure {
            echo "One or more stages failed. Marking the build as unstable."
            currentBuild.result = 'UNSTABLE'
        }
    }
}

def error(String errorMessage) {
    currentBuild.result = 'FAILURE'
    error errorMessage
}
