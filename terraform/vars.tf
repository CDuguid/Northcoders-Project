variable "region_name" {
  default = "eu-west-2"
}

variable "deploy_lambda_bool" {
  default     = false
  description = "Whether or not to deploy ingestion lambda function"
}

variable "alerts_email" {
  default     = "taimoor.deds@gmail.com"
  description = "The email address to send breakage alerts to"
}

variable "database_credentials" {
  default = "arn:aws:secretsmanager:eu-west-2:267414915338:secret:Totesys_DB_Credentials-YeWucm"
}

variable "warehouse_credentials" {
  default = "arn:aws:secretsmanager:eu-west-2:267414915338:secret:Totesys_Warehouse_Credentials-4OiHJW"
}
