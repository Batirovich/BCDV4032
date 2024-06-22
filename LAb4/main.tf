terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Docker image resource for nginx
resource "docker_image" "nginx" {
  name = "nginx:latest"
}

# First Docker container resource using nginx image
resource "docker_container" "nginx" {
  name  = "nginx"
  image = docker_image.nginx.name
  ports {
    internal = 80
    external = 8081
  }
}

# Docker image resource for a second container (e.g., busybox)
resource "docker_image" "busybox" {
  name = "busybox:latest"
}

# Second Docker container resource using busybox image
resource "docker_container" "busybox" {
  name    = "busybox"
  image   = docker_image.busybox.name
  command = ["sh", "-c", "while true; do sleep 3600; done"]
  
  # Explicit dependency on nginx container
  depends_on = [docker_container.nginx]
}

# Third Docker container implicitly dependent on busybox container
resource "docker_container" "busybox_dep" {
  name    = "busybox_dep"
  image   = docker_image.busybox.name
  command = ["sh", "-c", "while true; do sleep 3600; done"]

  # Explicit dependency on busybox container
  depends_on = [docker_container.busybox]
}
