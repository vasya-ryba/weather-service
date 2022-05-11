variable "repl_num" {
  default = 1
  description = "Number of replicas"
}

variable "full_output_url" {
  description = "URL for weather full output"
}

variable "short_output_url" {
  description = "URL for weather short output"
}

# Full output
resource "kubernetes_deployment" "weather-1" {
  metadata {
    name = "weather-1"
    labels = {
      App = "Weather-1"
    }
  }

  spec {
    replicas = var.repl_num
    selector {
      match_labels = {
        App = "Weather-1"
      }
    }
    template {
      metadata {
        labels = {
          App = "Weather-1"
        }
      }
      spec {
        container {
          image = "gcr.io/${var.project_id}/server:0.0.1"
          name  = "server"
          image_pull_policy = "Always"

          port {
            container_port = 80
          }

          volume_mount {
            mount_path = "/usr/share/nginx/html/"
            name       = "data"
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
        container {
          image = "gcr.io/${var.project_id}/updater:0.0.1"
          name  = "updater"
          image_pull_policy = "Always"

          volume_mount {
            mount_path = "/data/"
            name       = "data"
          }

          resources {
            limits = {
              cpu    = "0.2"
              memory = "512Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "50Mi"
            }
          }
        }

        volume {
            name = "data"
            empty_dir {
              medium = "Memory"
            }
          }
      }
    }
  }
}

resource "kubernetes_service" "weather-service-1" {
  metadata {
    name = "weather-service-1"
  }
  spec {
    selector = {
      App = kubernetes_deployment.weather-1.spec.0.template.0.metadata[0].labels.App
    }
    port {
      name = "http"
      protocol = "TCP"
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

# Short output
resource "kubernetes_deployment" "weather-2" {
  metadata {
    name = "weather-2"
    labels = {
      App = "Weather-2"
    }
  }

  spec {
    replicas = var.repl_num
    selector {
      match_labels = {
        App = "Weather-2"
      }
    }
    template {
      metadata {
        labels = {
          App = "Weather-2"
        }
      }
      spec {
        container {
          image = "gcr.io/${var.project_id}/server:0.0.1"
          name  = "server"
          image_pull_policy = "Always"

          port {
            container_port = 80
          }

          volume_mount {
            mount_path = "/usr/share/nginx/html/"
            name       = "data"
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
        container {
          image = "gcr.io/${var.project_id}/updater:0.0.3"
          name  = "updater"
          image_pull_policy = "Always"

          volume_mount {
            mount_path = "/data/"
            name       = "data"
          }

          resources {
            limits = {
              cpu    = "0.2"
              memory = "512Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "50Mi"
            }
          }
        }

        volume {
            name = "data"
            empty_dir {
              medium = "Memory"
            }
          }
      }
    }
  }
}

resource "kubernetes_service" "weather-service-2" {
  metadata {
    name = "weather-service-2"
  }
  spec {
    selector = {
      App = kubernetes_deployment.weather-2.spec.0.template.0.metadata[0].labels.App
    }
    port {
      name = "http"
      protocol = "TCP"
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}

# Routing
resource "kubernetes_ingress" "weather_ingress" {
  metadata {
    name = "http-balancer"
  }

  spec {
    rule {
      host = var.full_output_url
      http {
        path {
          backend {
            service_name = "weather-service-1"
            service_port = 80
          }
          path = "/*"
        }
      }
    }

    rule {
      host = var.short_output_url
      http {
        path {
          backend {
            service_name = "weather-service-2"
            service_port = 80
          }
          path = "/*"
        }
      }
    }
  }
}