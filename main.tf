provider "google" {
  project = "<your-project-id>"
  region  = "us-central1"
}

resource "google_container_cluster" "my_cluster" {
  name     = "my-cluster"
  location = "us-central1-a"
  initial_node_count = 2

  node_config {
    machine_type = "n1-standard-1"
  }
}

resource "google_container_node_pool" "my_node_pool" {
  name       = "my-node-pool"
  location   = "us-central1-a"
  cluster    = google_container_cluster.my_cluster.name
  node_count = 1

  node_config {
    machine_type = "n1-standard-1"
  }
}

resource "kubernetes_deployment" "hello_world" {
  metadata {
    name = "hello-world"
  }

  spec {
    selector {
      match_labels = {
        app = "hello-world"
      }
    }

    template {
      metadata {
        labels = {
          app = "hello-world"
        }
      }

      spec {
        container {
          name  = "hello-world"
          image = "gcr.io/google-samples/hello-app:1.0"
          ports {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "hello_world" {
  metadata {
    name = "hello-world"
  }

  spec {
    selector = {
      app = "hello-world"
    }

    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}
