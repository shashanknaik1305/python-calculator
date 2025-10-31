
@Library('my-shared-lib@main') _

pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        DOCKER_IMAGE = "shashanknaik1308/python-calculator"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "🔁 Checking out code from GitHub..."
                checkout scm
            }
        }

        stage('Build and Test in Docker') {
            agent {
                docker {
                    image 'python:3.9'
                    args '-u root:root'
                }
            }
            steps {
                echo "⚙️ Running build and tests inside Docker..."
                sh '''
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install --upgrade pip
                    pip install -r requirements.txt || true
                    pip install pytest pytest-html
                    mkdir -p reports logs
                    pytest --html=reports/report.html --self-contained-html || echo "Tests failed"
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🐳 Building Docker image..."
                sh '''
                    docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                    docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                '''
            }
        }

        stage('Push to DockerHub') {
            steps {
                echo "📤 Pushing image to DockerHub..."
                sh '''
                    echo "${DOCKERHUB_CREDENTIALS_PSW}" | docker login -u "${DOCKERHUB_CREDENTIALS_USR}" --password-stdin
                    docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    docker push ${DOCKER_IMAGE}:latest
                '''
            }
        }

        stage('Archive Reports') {
            steps {
                echo "📁 Archiving reports and logs..."
                archiveArtifacts artifacts: 'reports/**/*, logs/**/*', allowEmptyArchive: true
                junit 'reports/*.xml'
            }
        }
    }

    post {
        success {
            emailext(
                subject: "✅ SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """<p>Hi,</p>
                         <p>The Jenkins build <b>${env.JOB_NAME}</b> #${env.BUILD_NUMBER} completed successfully.</p>
                         <p>View console output: <a href='${env.BUILD_URL}'>${env.BUILD_URL}</a></p>""",
                to: 'mrthreesixty360iu@gmail.com',
                mimeType: 'text/html'
            )
        }

        failure {
            emailext(
                subject: "❌ FAILURE: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """<p>Hi,</p>
                         <p>The Jenkins build <b>${env.JOB_NAME}</b> #${env.BUILD_NUMBER} has failed.</p>
                         <p>Check logs here: <a href='${env.BUILD_URL}'>${env.BUILD_URL}</a></p>""",
                to: 'mrthreesixty360iu@gmail.com',
                mimeType: 'text/html'
            )
        }

        unstable {
            emailext(
                subject: "⚠️ UNSTABLE: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """<p>Hi,</p>
                         <p>The Jenkins build <b>${env.JOB_NAME}</b> #${env.BUILD_NUMBER} is unstable (some tests failed).</p>
                         <p>Check details here: <a href='${env.BUILD_URL}'>${env.BUILD_URL}</a></p>""",
                to: 'mrthreesixty360iu@gmail.com',
                mimeType: 'text/html'
            )
        }
    }
}
