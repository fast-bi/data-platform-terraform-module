variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint URL of the GKE cluster"
  type        = string
  sensitive   = true
}

variable "cluster_ca_certificate" {
  description = "The CA certificate for the GKE cluster"
  type        = string
  sensitive   = true
}

# Client certificate and key are no longer needed with exec-based authentication

variable "output_path" {
  description = "The path where the kubeconfig file should be saved"
  type        = string
  default     = "./kubeconfig"
} 