variable "aws_profile_name" {
  description = "AWS profile name"
}

variable "site_domain" {
  description = "Domain you own and want users to use to access your content. Example value: `example.com`"
}

variable "ttl" {
  description = "TTL used for MX and CNAME records"
}

variable "mx_records" {
  description = "MX records"
  type = "list"
  default = []
}

variable "cname_records" {
  description = "CNAME records"
  type = "list"
  default = []
}
