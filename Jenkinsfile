@Library('my-shared-lib') _  // Replace with your actual shared library name from Jenkins config

node {

    // -------------------------------
    // 🌍 Environment Setup
    // -------------------------------
    def gitRepo = 'git@github.com:shashanknaik1305/python-calculator.git'   // Replace with your repo SSH URL
    def gitCreds = 'github-ssh'                                         // Your Jenkins GitHub SSH credentials ID
    def dockerImage = 'shashanknaik1308/python-calculator'              // Docker Hub repo
    def dockerCreds = 'dockerhub-creds'                                 // DockerHub credentials ID
    def recipientEmail = 'mrthreesixty360iu@gmail.com'                          // Notification email

    try {
        // -------------------------------
        // 📥 Checkout Source Code
        // -------------------------------
        stage('Checkout') {
            echo "📦 Checking out source code from GitHub..."
            checkout([$class: 'GitSCM',
                branches: [[name: '*/main']],
                userRemoteConfigs: [[
                    url: gitRepo,
                    credentialsId: gitCreds
                ]]
            ])
        }

        // -------------------------------
        // 🧪 Run Tests in Docker Container
        // -------------------------------
        stage('Test') {
            echo "🧪 Running tests inside container..."
            docker.image('python:3.9').inside {
                sh '''
                    pip install pytest pytest-html
                    mkdir -p reports logs
                    pytest tests/ --junitxml=reports/results.xml --html=reports/report.html || true
                '''
            }

            // Publish results in Jenkins UI
            junit 'reports/results.xml'
            publishHTML([
                reportDir: 'reports',
                reportFiles: 'report.html',
                reportName: 'Pytest HTML Report'
            ])
        }

        // -------------------------------
        // 🐳 Build Docker Image
        // -------------------------------
        stage('Build Docker Image') {
            echo "🐳 Building Docker image..."
            sh """
                docker build -t ${dockerImage}:${BUILD_NUMBER} .
                docker tag ${dockerImage}:${BUILD_NUMBER} ${dockerImage}:latest
            """
        }

        // -------------------------------
        // 🚀 Push to Docker Hub
        // -------------------------------
        stage('Push Docker Image') {
            echo "🚀 Pushing image to Docker Hub..."
            withCredentials([usernamePassword(credentialsId: dockerCreds, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    docker push ${dockerImage}:${BUILD_NUMBER}
                    docker push ${dockerImage}:latest
                '''
            }
        }

        // -------------------------------
        // 📧 Email Notification (Success)
        // -------------------------------
        stage('Notify Success') {
            emailext(
                to: recipientEmail,
                subject: "✅ SUCCESS: Jenkins Build #${BUILD_NUMBER}",
                body: """
                <h2>✅ Build Successful!</h2>
                <p><b>Project:</b> ${env.JOB_NAME}</p>
                <p><b>Build Number:</b> ${env.BUILD_NUMBER}</p>
                <p><b>Docker Image:</b> ${dockerImage}:${BUILD_NUMBER}</p>
                <p>Check details: <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                """,
                mimeType: 'text/html'
            )
        }

    } catch (err) {
        // -------------------------------
        // ❌ Failure Handling + Email
        // -------------------------------
        currentBuild.result = 'FAILURE'
        emailext(
            to: recipientEmail,
            subject: "❌ FAILURE: Jenkins Build #${BUILD_NUMBER}",
            body: """
            <h2>❌ Build Failed</h2>
            <p><b>Project:</b> ${env.JOB_NAME}</p>
            <p><b>Error:</b> ${err}</p>
            <p>Check logs: <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
            """,
            mimeType: 'text/html'
        )
        throw err

    } finally {
        // -------------------------------
        // 🗂 Archive Reports + Logs
        // -------------------------------
        stage('Archive Reports') {
            echo "📁 Archiving reports and logs..."
            archiveArtifacts artifacts: 'reports/*, logs/*', fingerprint: true
        }
    }
}
