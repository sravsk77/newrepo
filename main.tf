provider "azurerm" {
  features {}
  subscription_id = "fc102f36-a2bd-49c9-bb42-99584f85dc5a"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

resource "azurerm_resource_group" "rg1" {
  name     = "rg-practice-01"
  location = "South India"
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "practicevnet1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
}

resource "azurerm_subnet" "sbnet1" {
  name                 = "practicesbnet1"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.2.0/27"]
}

resource "azurerm_network_interface" "nic1" {
  name                = "practicenic1"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sbnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "testvm1"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "Testvmazure@321"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic1.id
  ]
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 64
  }

  source_image_reference {
    publisher = "Redhat"
    offer     = "RHEL"
    sku       = "9-lvm"
    version   = "latest"
  }
}