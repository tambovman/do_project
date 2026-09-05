Part 3 - Docker CI/CD

This section documents the Docker-based CI/CD setup added to the DevOps project.

1. Part 3 branch

Part 3 development was completed on:

part3/docker-app

The goal of this phase was to extend the Jenkins CI pipeline so it could build, test, package, publish, and prepare deployment of a Dockerized application.

2. Application structure

A small Flask application was added to the repository.

Project structure:

DO_project/
├── app/
│   ├── app.py
│   ├── requirements.txt
│   └── tests/
│       └── test_app.py
├── config/
├── docs/
│   ├── part1-github-vscode.md
│   ├── part2-jenkins-ci.md
│   └── part3-docker-cicd.md
├── Dockerfile
├── Jenkinsfile
└── README.md

The application exposes:

/

and a health-check endpoint:

/health

The health endpoint returns:

{"status":"healthy"}

3. Python dependencies

Application dependencies are stored in:

app/requirements.txt

Contents:

flask
pytest

Flask runs the web application.

Pytest is used for automated unit testing.

4. Unit test

A unit test was added at:

app/tests/test_app.py

The test creates a Flask test client and verifies the /health endpoint.

It checks:

HTTP status code = 200
JSON response = {"status":"healthy"}

The Jenkins pipeline runs this test inside the Docker image.

Successful output:

tests/test_app.py::test_health PASSED
1 passed

5. Docker installation on agent01

Docker was installed on the Linux Jenkins agent:

Hostname: agent01
IP: 192.168.57.11

Docker was enabled with:

sudo systemctl enable --now docker

The Jenkins user was added to the Docker group:

sudo usermod -aG docker jenkins

The agent was restarted so the new group membership was applied.

Verification:

id jenkins
sudo -u jenkins docker version
ls -l /var/run/docker.sock

The Docker socket is owned by:

root:docker

This allows the Jenkins user to use Docker without running Docker commands through sudo.

6. Dockerfile

The project uses a Dockerfile based on:

python:3.13-slim

The Dockerfile:

sets /app as the working directory

copies app/requirements.txt

installs Python dependencies

copies the application files

exposes port 8080

starts the Flask application

Dockerfile:

FROM python:3.13-slim

WORKDIR /app

COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ .

EXPOSE 8080

CMD ["python", "app.py"]

7. Jenkins Docker build

The Jenkins pipeline builds the Docker image on agent01.

Images are tagged with:

Jenkins build number
Git commit SHA

Example:

devops-demo:15
devops-demo:26b9510

Both tags point to the same Docker image.

The build command is:

docker build   -t devops-demo:${BUILD_NUMBER}   -t devops-demo:${GIT_SHORT}   .

8. Unit test stage

After the image is built, Jenkins runs pytest inside the built image:

docker run --rm   devops-demo:${BUILD_NUMBER}   pytest tests -v

This tests the same image that is later used for the smoke test and registry push.

Successful result:

1 passed

9. Image verification

Jenkins verifies that the expected Docker image tags exist:

docker images devops-demo

Example:

devops-demo:15
devops-demo:26b9510

10. Smoke test

Jenkins starts a temporary test container:

docker run -d   --name devops-demo-test   -p 18080:8080   devops-demo:${BUILD_NUMBER}

The application is then tested locally on the Jenkins agent:

curl -f http://127.0.0.1:18080/health

Expected response:

{"status":"healthy"}

The temporary container is removed after the test.

The use of:

127.0.0.1

means the request is sent to the same machine running the Jenkins build, which is agent01.

Docker maps:

agent01:18080 -> container:8080

11. Docker Hub registry

A private Docker Hub repository was used:

tambovman/devops-demo

Docker Hub credentials were stored in Jenkins Credentials with the ID:

dockerhub-creds

A Docker Hub access token is used instead of storing a password directly in the Jenkinsfile.

Jenkins authenticates with:

echo "$DOCKERHUB_TOKEN" |   docker login -u "$DOCKERHUB_USER"   --password-stdin

The image is then tagged for Docker Hub:

docker tag   devops-demo:${BUILD_NUMBER}   ${DOCKERHUB_USER}/devops-demo:${BUILD_NUMBER}

and:

docker tag   devops-demo:${BUILD_NUMBER}   ${DOCKERHUB_USER}/devops-demo:${GIT_SHORT}

Both tags are pushed:

docker push ${DOCKERHUB_USER}/devops-demo:${BUILD_NUMBER}
docker push ${DOCKERHUB_USER}/devops-demo:${GIT_SHORT}

Jenkins logs out after the push:

docker logout

12. Successful registry push

The pipeline successfully pushed:

tambovman/devops-demo:15
tambovman/devops-demo:26b9510

Both tags used the same image digest:

sha256:6e3d3188e14bd031052f0969729925c38c648a549902013fecbe2989caf26da8

The complete Jenkins build finished with:

Finished: SUCCESS

13. Application server

A new Ubuntu VM was created for application deployment.

Configuration:

Hostname: app01
IP: 192.168.57.20
Gateway: 192.168.57.2
Timezone: Asia/Jerusalem

The VM uses the same VMware NAT network as the other lab machines:

192.168.57.0/24

Docker and SSH were installed and enabled on app01.

14. Docker on app01

Docker was installed with:

sudo apt install -y docker.io
sudo systemctl enable --now docker

The devops user was added to the Docker group:

sudo usermod -aG docker devops

After reconnecting or rebooting, Docker was verified with:

docker version

15. Pulling the private image

Because the Docker Hub repository is private, app01 must authenticate before pulling the image.

Interactive login:

docker login

The image was then pulled:

docker pull tambovman/devops-demo:15

16. Manual deployment test

The Docker image was manually started on app01:

docker run -d   --name devops-demo   -p 8080:8080   tambovman/devops-demo:15

The running container was verified with:

docker ps

The health endpoint was tested with:

curl http://127.0.0.1:8080/health

Successful response:

{"status":"healthy"}

This confirmed that the image built by Jenkins and stored in Docker Hub can run successfully on the application server.

17. Dedicated deployment user

A dedicated deployment account was created on app01:

deploy

This separates automated deployment access from the general devops administrator account.

The user was added to the Docker group:

sudo usermod -aG docker deploy

SSH access was prepared under:

/home/deploy/.ssh/

with the correct permissions:

sudo chmod 700 /home/deploy/.ssh
sudo chmod 600 /home/deploy/.ssh/authorized_keys

A dedicated SSH key for deployment was generated for the Jenkins service account on the Jenkins controller.

The intended access model is:

devops
  -> server administration

deploy
  -> automated application deployment
  -> SSH access
  -> Docker access

jenkins
  -> CI/CD orchestration

18. Current CI/CD flow

The current workflow is:

VS Code
   ↓
Git push
   ↓
GitHub
   ↓ webhook
Smee.io
   ↓
Jenkins controller
   ↓
agent01
   ↓
Docker build
   ↓
Unit test
   ↓
Smoke test
   ↓
Docker Hub
   ↓
app01
   ↓
Running application

19. Jenkins pipeline stages

The Part 3 Jenkins pipeline now contains:

Declarative Checkout SCM
Environment
Tool Check
Docker Build
Unit Test
Verify Image
Smoke Test
Push Image
Post Actions

A successful pipeline confirms:

Git checkout          SUCCESS
Docker build          SUCCESS
Unit test             SUCCESS
Smoke test            SUCCESS
Docker Hub push       SUCCESS
Pipeline              SUCCESS

20. Troubleshooting

Docker permission denied

Problem:

permission denied while trying to connect to the docker API at unix:///var/run/docker.sock

Cause:

The Jenkins agent process was started before the jenkins user received Docker group membership.

Fix:

sudo usermod -aG docker jenkins
sudo reboot

Verify:

id jenkins
ls -l /var/run/docker.sock

Dockerfile cannot find application files

Problem:

COPY failed: file not found in build context:
stat app/requirements.txt: file does not exist

Cause:

The app directory was accidentally placed inside:

docs/app/

instead of the repository root.

Fix:

mv docs/app ./app

Correct structure:

DO_project/
├── app/
├── docs/
├── Dockerfile
└── Jenkinsfile

Jenkinsfile missing closing brace

Problem:

expecting '}', found ''

Cause:

A Groovy block in the Jenkinsfile was not closed.

Fix:

Review the structure and make sure the final blocks close correctly:

pipeline {
    stages {
        // stages
    }

    post {
        // post actions
    }
}

Private Docker Hub image cannot be pulled

Problem:

pull access denied for tambovman/devops-demo

Cause:

The Docker Hub repository is private and the server has not authenticated.

Fix:

docker login
docker pull tambovman/devops-demo:15

21. Part 3 result

Part 3 successfully extended the project from a basic Jenkins CI pipeline to a Docker-based CI/CD workflow.

The project can now:

Build application image
Test application image
Verify container health
Version images
Push images to a private registry
Pull images onto an application server
Run the application as a Docker container

The next improvement is to automate the final deployment from Jenkins to app01 using the dedicated deploy account.