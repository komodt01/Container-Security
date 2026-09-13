provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "secure-aks-rg"
  location = var.location
}

# ----------------------------
# Networking
# ----------------------------

resource "azurerm_virtual_network" "main" {
  name                = "secure-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_network_security_group" "aks_nsg" {
  name                = "aks-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Purpose = "AKS network security"
  }
}

resource "azurerm_subnet_network_security_group_association" "aks" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}

# ----------------------------
# Container Registry
# ----------------------------

resource "azurerm_container_registry" "acr" {
  name                = "secureacr12345"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Standard"

  # Use Microsoft Entra ID / managed identities rather
  # than registry administrator credentials.
  admin_enabled = false

  tags = {
    Purpose = "Application container registry"
  }
}

# ----------------------------
# Log Analytics
# ----------------------------

resource "azurerm_log_analytics_workspace" "main" {
  name                = "aks-logs-workspace"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# ----------------------------
# AKS
# ----------------------------

resource "azurerm_kubernetes_cluster" "main" {
  name                = "secure-aks"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "secureaks"

  default_node_pool {
    name           = "default"
    node_count     = 2
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.2.0.0/16"
    dns_service_ip = "10.2.0.10"
  }

  role_based_access_control_enabled = true

  tags = {
    Purpose = "Secure container workload"
  }
}

# ----------------------------
# AKS Access to ACR
# ----------------------------

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

# ----------------------------
# Monitoring
# ----------------------------

resource "azurerm_monitor_diagnostic_setting" "aks_logs" {
  name                       = "aks-logs"
  target_resource_id         = azurerm_kubernetes_cluster.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "kube-apiserver"
  }

  metric {
    category = "AllMetrics"
  }
}
