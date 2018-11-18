def label = "worker-${UUID.randomUUID().toString()}"

podTemplate(label: label, containers: [
  containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl:v1.8.8', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'helm', image: 'lachlanevenson/k8s-helm:latest', command: 'cat', ttyEnabled: true)
],
volumes: [
  hostPathVolume(mountPath: '/home/gradle/.gradle', hostPath: '/tmp/jenkins/.gradle'),
  hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
]) {
  node(label) {
    def myRepo = checkout scm
    def gitBranch = myRepo.GIT_BRANCH
    def gitCommit = myRepo.GIT_COMMIT
    def gitShort = myRepo.GIT_COMMIT[1..10]

    stage('Build Image') {
      container('docker') {
        echo "${gitBranch}/${gitShort}"
        app = docker.build("kuber-221407/flask-sample-one")
      }
    }

    stage('Push Image') {
      container('docker') {
        docker.withRegistry("https://us.gcr.io", "kuber-221407-gcr") {
          app.push("${gitShort}")
          app.push("latest")
        }
      }
    }

    stage('Run kubectl') {
      container('kubectl') {
        sh "kubectl get pods"
      }
    }

    stage('Run helm') {
      container('helm') {
        sh "helm list"
      }
    }
  }
}