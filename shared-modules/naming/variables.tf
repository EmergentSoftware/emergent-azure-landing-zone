# =============================================================================
# Naming Module Variables
# =============================================================================

variable "suffix" {
  description = "Suffix to append to resource names. Typically includes environment, location, or other identifiers."
  type        = list(string)
  default     = []
}

variable "prefix" {
  description = "Prefix to prepend to resource names. Typically includes organization or project identifiers."
  type        = list(string)
  default     = ["acme"]
}

variable "unique_seed" {
  description = "Custom seed value for unique name generation. If not provided, uses default uniqueness logic."
  type        = string
  default     = ""
}

variable "unique_length" {
  description = "Length of the unique identifier suffix for resources requiring global uniqueness."
  type        = number
  default     = 4
}

variable "unique_include_numbers" {
  description = "Include numbers in the unique identifier suffix."
  type        = bool
  default     = true
}
