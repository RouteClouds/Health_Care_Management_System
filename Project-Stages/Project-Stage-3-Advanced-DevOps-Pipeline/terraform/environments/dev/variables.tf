# Root variables for dev environment so TF_VAR_* can control behavior

variable "preserve_existing_cluster" {
  description = "If true, do not create/replace the EKS control plane; assume an existing cluster and skip EKS cluster creation."
  type        = bool
  default     = true
}

