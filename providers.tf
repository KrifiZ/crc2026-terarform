terraform {
  backend "azurerm" {
    resource_group_name  = "rg-crc2026-student-203-lab"
    storage_account_name = "michalsatf"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
  resource_provider_registrations = "none"
}