# Данные для подключения к провайдеру
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">=0.84.0"
    }
  }
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = "ru-central1-a"
}

# Указываем дефолтную сеть для сервисных инстансов
resource "yandex_vpc_network" "default" {
  name           = "default-srv"
}

# Создаём локальную сеть между нодами - сервисных инстансов
resource "yandex_vpc_subnet" "srv-local" {
  name           = "srv-local"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}


# Создание сервисной ВМ и развертывание с неё kubernetes кластера согласно вложенного модуля
module "kubernetes_cluster" {
  source        = "./modules/instance"
  vpc_subnet_id = yandex_vpc_subnet.srv-local.id
  user_token = var.token
  user_cloud = var.cloud_id
  user_folder = var.folder_id
  }