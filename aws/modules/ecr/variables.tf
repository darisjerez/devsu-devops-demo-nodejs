variable "project_name" {
  description = "Project name"
  type        = string
}

variable "image_tag_mutability" {
  description = "Image tag mutability: MUTABLE or IMMUTABLE"
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Must be MUTABLE or IMMUTABLE."
  }
}

variable "max_image_count" {
  description = "Maximum number of images to retain in the repository"
  type        = number
  default     = 10

  validation {
    condition     = var.max_image_count > 0
    error_message = "Must be greater than 0."
  }
}
