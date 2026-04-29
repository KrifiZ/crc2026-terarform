resource "azurerm_key_vault" "default" {
  name                = "${local.prefix}-kvtf"
  resource_group_name = data.azurerm_resource_group.default.name
  location            = data.azurerm_resource_group.default.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  tags                = local.tags

  soft_delete_retention_days = 7
  purge_protection_enabled   = false
}

resource "azurerm_key_vault_access_policy" "service_principal" {
  key_vault_id = azurerm_key_vault.default.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create", "Delete", "Get", "List", "Purge", "Recover", "Update",
    "GetRotationPolicy", "SetRotationPolicy"
  ]

  secret_permissions = [
    "Set", "Get", "List", "Delete", "Purge", "Recover"
  ]
}

resource "azurerm_key_vault_access_policy" "user" {
  key_vault_id = azurerm_key_vault.default.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.user_object_id

  key_permissions = [
    "Get", "List"
  ]

  secret_permissions = [
    "Get", "List"
  ]
}

resource "azurerm_key_vault_key" "default" {
  name         = "${local.prefix}-key"
  key_vault_id = azurerm_key_vault.default.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"
  ]

  depends_on = [
    azurerm_key_vault_access_policy.service_principal
  ]
}

resource "random_password" "default" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_key_vault_secret" "default" {
  name         = "${local.prefix}-secret"
  value        = random_password.default.result
  key_vault_id = azurerm_key_vault.default.id

  depends_on = [
    azurerm_key_vault_access_policy.service_principal
  ]
}
