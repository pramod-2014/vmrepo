terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.35.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "a29ac6ee-0d4f-41fe-8359-df26a6fce56c"
}



resource "azurerm_resource_group" "rgblock" {
    for_each = {
        var.rg_name = var.locaton
    }
    
 name = each.key
 location = each.value

} 

resource "azurerm_virtual_network" "demo-vnet" {
  depends_on = [azurerm_resource_group.rgblock]
  name                = "demo-vnet"
  address_space       = ["10.0.0/16"]
  location            = azurerm_resource_group.rgblock.location
  resource_group_name = azurerm_resource_group.rgblock.name
}

resource "azurerm_subnet" "demo-subnet" {
  depends_on = [azurerm_virtual_network.demo-vnet]
  name                 = "demo-subnet"
  resource_group_name  = azurerm_resource_group.rgblock.name
  virtual_network_name = azurerm_virtual_network.demo-vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_interface" "demo-nic" {
  depends_on = [azurerm_subnet.demo-subnet]
  name                = "demo-nic"
  location            = azurerm_resource_group.rgblock.location
  resource_group_name = azurerm_resource_group.rgblock.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.demo-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}