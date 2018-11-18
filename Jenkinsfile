def label = "worker-${UUID.randomUUID().toString()}"

podTemplate(label: label, containers: [
  containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'helm', image: 'alpine/helm', command: 'cat', ttyEnabled: true)
],
volumes: [
  hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
]) {
  node(label) {
    def myRepo = checkout scm
    def gitBranch = myRepo.GIT_BRANCH
    def gitCommit = myRepo.GIT_COMMIT
    def gitShort = myRepo.GIT_COMMIT[0..6]
    def chartRepoName = "kuber-charts"
    def chartRepoUrl = "https://kuber-charts.storage.googleapis.com"

    stage('Build Image') {
      container('docker') {
        echo "${gitBranch}/${gitShort}"
        app = docker.build("kuber-221407/flask-sample-one")
      }
    }

    stage('Push Image') {
      container('docker') {
        docker.withRegistry("https://us.gcr.io", "gcr:kuber-221407-gcr") {
          app.push("${gitShort}")
          app.push("latest")
        }
      }
    }

    stage('Run helm') {
      container('helm') {
        sh "helm init --client-only"
        sh "helm list"
        sh "mkdir -p ${chartRepoName}"
        sh "helm package helm/flask-unicorn/"
        sh "mv flask-unicorn-*.tgz ${chartRepoName}/"
        sh "helm repo index ${chartRepoName} --merge ${chartRepoUrl}/index.yaml --url ${chartRepoUrl}"
        sh "ls ${chartRepoName}/"
      }
    }
  }
}