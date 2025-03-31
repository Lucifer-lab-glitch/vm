# -------------------- General Configuration -------------------
variable "resource_group_name" {
  description = "The name of the Resource Group"
  type        = string
}

variable "project" {
  description = "The project name, used as a prefix for the network watcher name."
  type        = string
}
variable "environment" {
  description = "The environment for this deployment (e.g., dev, prod, staging)."
  type        = string
}

variable "location" {
  description = "Location for the resources"
  type        = string
}

variable "vm_name" {
  description = "The name of the Virtual Machine"
  type        = string
}

variable "vm_size" {
  description = "The size of the Virtual Machine"
  type        = string
}

variable "tags" {
  description = "Tags to associate with the resources"
  type        = map(string)
  default     = {}
}

variable "admin_username" {
  description = "Admin username for the virtual machine"
  type        = string
}
variable "zone" {
  description = "Availability zone for the resources"
  type        = string
  default     = null
}
variable "disk_storage_account_type" {
  description = "Storage account type for the managed disk"
  type        = string
  default     = "Standard_LRS"
}

variable "resource_count" {
  type        = number
  default     = 1
  description = "Number of NICs to create. Set >1 only if using VM scale sets or multiple NICs."
}

variable "enable_monitoring" {
  description = "Enable Azure Monitor and Log Analytics Workspace"
  type        = bool
  default     = true
}
variable "log_analytics_workspace_key" {
  description = "The primary key for the Log Analytics workspace"
  type        = string
  sensitive   = true
}


variable "admin_password" {
  description = "Optional admin password for manual input. Ignored if random_password is generated."
  type        = string
  sensitive   = true
  default     = ""
}


variable "os_disk_size" {
  description = "Size of the OS disk in GB"
  type        = number
  default     = 30
}

# -------------------- Data Disk Configuration -------------------
variable "data_disk_managed_disks" {
  description = "Map of managed disks with encryption settings"
  type = map(object({
    name                        = string
    create_option               = string
    disk_size_gb                = number
    os_type                     = string
    storage_account_type        = string
    disk_encryption_key_vault_secret_url = string
    key_encryption_key_vault_secret_url = string
    disk_attachment_create_option = string
    caching                     = string
    lun                         = number
    write_accelerator_enabled   = bool
    lock_level                  = string
    lock_name                   = string
  }))
}

variable "key_vault_name" {
  description = "The name of the Key Vault. Must be globally unique, 3-24 characters, and only alphanumeric with hyphens."
  type        = string
  default     = "kushal"  # Ensure it's valid and unique
}

variable "key_vault_id" {
  description = "Key Vault ID for encryption settings"
  type        = string
  default     = null
}

# -------------------- Variables ------------------- #

variable "os_type" {
  description = "Operating System Type (linux or windows)"
  type        = string
}

variable "generate_admin_password_or_ssh_key" {
  description = "Whether to generate an admin password or SSH key"
  type        = bool
  default     = false
}

variable "admin_generated_ssh_key_vault_secret_name" {
  description = "The name of the Key Vault secret for the admin SSH key"
  type        = string
  default     = null
}


variable "admin_password_key_vault_secret_name" {
  description = "The name of the Key Vault secret for the admin password"
  type        = string
  default     = null
}


# -------------------- Identity for VM -------------------

variable "identity_type" {
  description = "The Managed Service Identity type (SystemAssigned or UserAssigned)"
  type        = string
  default     = "SystemAssigned"
}

variable "identity_ids" {
  description = "List of user-assigned identity IDs (required for UserAssigned identity type)"
  type        = list(string)
  default     = []
}

#-------------------------------------------------------------------

variable "disable_password_authentication" {
  description = "Whether to disable password authentication for the VM"
  type        = bool
  default     = true
}

variable "admin_credential_key_vault_resource_id" {
  description = "The Key Vault resource ID where admin credentials are stored"
  type        = string
  default     = null
}

variable "generated_secrets_key_vault_secret_config" {
  description = "The configuration for secrets in the Key Vault"
  type        = object({
    key_vault_resource_id = string
    name                  = string
    content_type          = string
    not_before_date       = string
    expiration_date      = string
    tags                  = map(string)
  })
  default = null
}


# -------------------- Shutdown Schedule -------------------

#Automatically Shut Down Schedule!

# Automatically Shut Down Schedule
variable "shutdown_schedules" {
  type = map(object({
    daily_recurrence_time = string
    notification_settings = optional(object({
      enabled         = optional(bool, false)
      email           = optional(string, null)
      time_in_minutes = optional(string, "30")
      webhook_url     = optional(string, null)
    }), { enabled = false })
    timezone = string
    enabled  = optional(bool, true)
    tags     = optional(map(string), null)
  }))
  default     = {}

  description = <<SHUTDOWN_SCHEDULES
This map of objects describes an auto-shutdown schedule for the virtual machine. The default is to not have a shutdown schedule.
Example Input:
  shutdown_schedules = {
    test_schedule = {
      daily_recurrence_time = "1700"
      enabled               = true
      timezone              = "Pacific Standard Time"
      notification_settings = {
        enabled         = true
        email           = "example@example.com;example2@example.com"
        time_in_minutes = "15"
        webhook_url     = "https://example-webhook-url.example.com"
      }
    }
  }
SHUTDOWN_SCHEDULES
}


variable "create_linux_vm" {
  description = "Whether to create the Linux VM or not"
  type        = bool
  default     = true
}

variable "create_windows_vm" {
  description = "Whether to create the Windows VM or not"
  type        = bool
  default     = true
}

# variables.tf
variable "subnet" {
  description = "The ID of the subnet where the VM will be placed"
  type        = string
}


variable "generate_admin_ssh_key" {
  description = "Whether to generate an admin SSH key"
  type        = bool
  default     = false
}
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the subnet"
  type        = list(string)
  default = ["10.0.1.0/24"]
}

variable "public_ip_id" {
  description = "Public IP ID to be assigned to VM (if any)"
  type        = string
  default     = ""
}

variable "allocation_method" {
  description = "Public IP allocation method"
  type        = string
  default     = "Static"
}

variable "public_ip_sku" {
  description = "Public IP SKU"
  type        = string
  default     = "Standard"
}


variable "cloud_init_script" {
  description = "Cloud-init script for Linux VM setup"
  type        = string
  default     = <<EOT
#!/bin/bash
# Update packages and install nginx
apt-get update -y
apt-get install nginx -y
systemctl enable nginx
systemctl start nginx
EOT
}
#---------------Source OS Image Reference---------------
variable "image_publisher" {
  description = "The publisher of the image to use for the VM"
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "The offer of the image to use for the VM"
  type        = string
  default     = "UbuntuServer"
}

variable "image_sku" {
  description = "The SKU of the image to use for the VM"
  type        = string
  default     = "18.04-LTS"
}

variable "image_version" {
  description = "The version of the image to use for the VM"
  type        = string
  default     = "latest"
}


#-------------Boot Diagnosticsn-----------
variable "boot_diagnostics_storage_account_uri" {
  description = "The URI of the storage account for boot diagnostics."
  type        = string
  default     = null
}

#-------------Customer-specific Controls-----------
variable "deploy_linux_vm" {
  description = "Deploy Linux VM"
  type        = bool
  default     = false
}

variable "deploy_windows_vm" {
  description = "Deploy Windows VM"
  type        = bool
  default     = false
}

variable "enable_auto_shutdown_linux" {
  description = "Enable Auto Shutdown for Linux VM"
  type        = bool
  default     = false
}

variable "enable_auto_shutdown_windows" {
  description = "Enable Auto Shutdown for Windows VM"
  type        = bool
  default     = false
}

variable "enable_public_ip_linux" {
  description = "Enable Public IP for Linux VM"
  type        = bool
  default     = false
}

variable "enable_public_ip_windows" {
  description = "Enable Public IP for Windows VM"
  type        = bool
  default     = false
}

variable "enable_public_ip" {
  description = "Enable Public IP for the Virtual Machine"
  type        = bool
  default     = true
}

variable "enable_nsg" {
  description = "Enable or disable NSG creation"
  type        = bool
  default     = false
} 