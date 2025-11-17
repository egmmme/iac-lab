terraform {
  # Uncomment this block after creating a storage account for remote state
  # backend "azurerm" {
  #   resource_group_name  = "terraform-state-rg"
  #   storage_account_name = "tfstatexxxxx"  # Must be globally unique
  #   container_name       = "tfstate"
  #   key                  = "terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
  subscription_id = "13b98216-b11e-482f-b0a8-af5294c9f076"
}

# Variable for SSH public key
variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

resource "azurerm_resource_group" "lab_rg" {
  name     = "lab-resource-group"
  location = "East US"
}

# Virtual Network
resource "azurerm_virtual_network" "lab_vnet" {
  name                = "lab-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.lab_rg.location
  resource_group_name = azurerm_resource_group.lab_rg.name
}

# Subnet
resource "azurerm_subnet" "lab_subnet" {
  name                 = "lab-subnet"
  resource_group_name  = azurerm_resource_group.lab_rg.name
  virtual_network_name = azurerm_virtual_network.lab_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP
resource "azurerm_public_ip" "lab_public_ip" {
  name                = "lab-public-ip"
  location            = azurerm_resource_group.lab_rg.location
  resource_group_name = azurerm_resource_group.lab_rg.name
  allocation_method   = "Static"
}

# Network Security Group
resource "azurerm_network_security_group" "lab_nsg" {
  name                = "lab-nsg"
  location            = azurerm_resource_group.lab_rg.location
  resource_group_name = azurerm_resource_group.lab_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Interface
resource "azurerm_network_interface" "lab_nic" {
  name                = "lab-nic"
  location            = azurerm_resource_group.lab_rg.location
  resource_group_name = azurerm_resource_group.lab_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lab_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lab_public_ip.id
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "lab_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.lab_nic.id
  network_security_group_id = azurerm_network_security_group.lab_nsg.id
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "lab_vm" {
  name                = "lab-vm"
  resource_group_name = azurerm_resource_group.lab_rg.name
  location            = azurerm_resource_group.lab_rg.location
  size                = "Standard_B1s"  # Small, cost-effective size
  admin_username      = "azureuser"
  
  network_interface_ids = [
    azurerm_network_interface.lab_nic.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

# VM Extension to ensure cloud-init completes
resource "azurerm_virtual_machine_extension" "cloud_init_wait" {
  name                 = "wait-for-cloud-init"
  virtual_machine_id   = azurerm_linux_virtual_machine.lab_vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = jsonencode({
    commandToExecute = "cloud-init status --wait && systemctl status ssh"
  })

  depends_on = [azurerm_linux_virtual_machine.lab_vm]
}

# Output the public IP
output "vm_public_ip" {
  value = azurerm_public_ip.lab_public_ip.ip_address
  description = "The public IP address of the virtual machine"
}