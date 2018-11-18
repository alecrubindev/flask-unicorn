def label = "worker-${UUID.randomUUID().toString()}"

podTemplate(label: label, containers: [
  containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'helm', image: 'alpine/helm', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'cloud-sdk', image: 'google/cloud-sdk', command: 'cat', ttyEnabled: true)
],
volumes: [
  hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
]) {
  node(label) {
    def myRepo = checkout scm
    def commitShort = myRepo.GIT_COMMIT[0..6]
    def chartRepoName = "kuber-charts"
    def chartRepoUrl = "https://kuber-charts.storage.googleapis.com"

    stage('Build Image') {
      container('docker') {
        app = docker.build("kuber-221407/flask-sample-one")
      }
    }

    stage('Push Image') {
      container('docker') {
        docker.withRegistry("https://us.gcr.io", "gcr:kuber-221407-gcr") {
          app.push("${commitShort}")
          app.push("latest")
        }
      }
    }

    stage('Build Chart') {
      container('helm') {
        sh "helm init --client-only"
        sh "mkdir -p ${chartRepoName}"
        sh "helm package helm/flask-unicorn/"
        sh "mv flask-unicorn-*.tgz ${chartRepoName}/"
        sh "helm repo index ${chartRepoName} --merge ${chartRepoUrl}/index.yaml --url ${chartRepoUrl}"
      }
    }

    stage('Push Chart') {
      container('cloud-sdk') {
        withCredentials([file(credentialsId: 'kuber-221407-storage', variable: 'FILE')]) {
          sh "gcloud auth activate-service-account --key-file $FILE"
          sh "gsutil cp ${chartRepoName}/ gs://${chartRepoName}"
        }
      }
    }
  }
}