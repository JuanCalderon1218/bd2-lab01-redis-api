
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.6.0"
    }
  }
}

variable "docker_host" {
  description = "Docker Engine connection"
  type        = string
  default     = "npipe:////.//pipe//docker_engine"
}

provider "docker" {
  host = var.docker_host
}

# Network for the application
resource "docker_network" "lab_network" {
  name   = "bd2-lab01-iac-network"
  driver = "bridge"
}

# Redis image
resource "docker_image" "redis" {
  name         = "redis:7-alpine"
  keep_locally = true
}

# Redis container
resource "docker_container" "redis" {
  name    = "bd2-lab01-redis-iac"
  image   = docker_image.redis.image_id
  restart = "unless-stopped"

  ports {
    internal = 6379
    external = 6380
  }

  networks_advanced {
    name    = docker_network.lab_network.name
    aliases = ["redis"]
  }
}

# API image from GitHub Container Registry
resource "docker_image" "api" {
  name         = "ghcr.io/juancalderon1218/app-redis-api:latest"
  keep_locally = true
}

# API container
resource "docker_container" "api" {
  name    = "bd2-lab01-api-iac"
  image   = docker_image.api.image_id
  restart = "unless-stopped"

  env = [
    "ASPNETCORE_URLS=http://+:8080",
    "REDIS_HOST=redis",
    "REDIS_PORT=6379",
    "REDIS_SSL=false"
  ]

  ports {
    internal = 8080
    external = 8082
  }

  networks_advanced {
    name = docker_network.lab_network.name
  }

  depends_on = [
    docker_container.redis
  ]
}

output "api_url" {
  value = "http://localhost:8082/Todos"
}

output "redis_endpoint" {
  value = "localhost:6380"
}
