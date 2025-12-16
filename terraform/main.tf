terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  # Configuração do Backend (Onde o arquivo de estado ficará salvo na nuvem) [cite: 87, 91]
  # Você precisará criar este Storage Account manualmente no portal antes (veja Passo 4)
  backend "azurerm" {
    resource_group_name  = "NetworkWatcherRG"
    storage_account_name = "tfstatefutebol"
    container_name       = "container1"
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# 1. Grupo de Recursos
resource "azurerm_resource_group" "rg" {
  name     = "rg-atividade-cicd-v2"
  location = "eastus2" 
}

# 2. Rede Virtual e Subnet
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-cicd"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-cicd"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 3. IP Público (Para acessarmos via SSH e Web) [cite: 84]
resource "azurerm_public_ip" "public_ip" {
  name                = "public-ip-cicd"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"    # MUDOU DE Dynamic PARA Static
  sku                 = "Standard"  # MUDOU DE Basic PARA Standard
}

# 4. Firewall (Network Security Group) - Liberando SSH (22) e HTTP (80)
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-cicd"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

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

# 5. Placa de Rede (NIC) - Conecta o IP e o Firewall à VM
resource "azurerm_network_interface" "nic" {
  name                = "nic-cicd"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Associa o Firewall à Placa de Rede
resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# 6. A Máquina Virtual (Linux Ubuntu)
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-cicd-prod"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_A1_v2" # Tamanho Gratuito (Free Tier)
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.public_key # Chave SSH vinda das variáveis [cite: 78]
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # Injeta o script para instalar Docker [cite: 77, 114]
  custom_data = filebase64("user_data.sh")
}