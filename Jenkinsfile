@Library('my-shared-lib') _
node {
    // Use Docker agent with root user
    stage('Checkout') {
        checkout([$class: 'GitSCM',
            branches: [[name: '*/main']],
            doGenerateSubmoduleConfigurations: false,
            extensions: [],
            userRemoteConfigs: [[
                url: 'git@github.com:shashanknaik1305/python-calculator.git',
                credentialsId: 'github-ssh'
            ]]
        ])
    }

    stage('Build and Test in Docker') {
        docker.image('python:3.9').inside('--user root') {
            sh '''
                echo "Installing dependencies..."
                pip install --no-cache-dir -r requirements.txt

                echo "Running tests..."
                mkdir -p reports logs
                pytest tests/ --junitxml=reports/results.xml --html=reports/report.html || true
            '''
        }
    }

    stage('Build Docker Image') {
        docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
            sh '''
                echo "Building Docker image..."
                docker build -t shashanknaik1308/python-calculator:latest .

                echo "Pushing image to DockerHub..."
                docker push shashanknaik1308/python-calculator:latest
            '''
        }
    }

    stage('Archive Reports') {
        echo '📁 Archiving reports and logs...'
        archiveArtifacts artifacts: 'reports/**/*, logs/**/*', allowEmptyArchive: true
        junit 'reports/results.xml'
    }

    stage('Send Email') {
        emailext(
            subject: "Build #${env.BUILD_NUMBER} - ${currentBuild.currentResult}",
            body: """\
                <p>Build result: ${currentBuild.currentResult}</p>
                <p>Check console output at <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
            """,
            to: 'mrthreesixty360iu@gmail.com'
        )
    }
}

