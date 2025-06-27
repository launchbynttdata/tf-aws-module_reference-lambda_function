// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

data "aws_region" "current" {}

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.resource_names_map

  region                  = join("", split("-", data.aws_region.current.name))
  class_env               = var.class_env
  cloud_resource_type     = each.value.name
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource
  maximum_length          = each.value.max_length
  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
}


module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.4"

  function_name           = module.resource_names["lambda_function"][var.resource_names_strategy]
  description             = var.description
  handler                 = var.handler
  runtime                 = var.runtime
  architectures           = var.architectures
  publish                 = var.publish
  ephemeral_storage_size  = var.ephemeral_storage_size
  ignore_source_code_hash = var.ignore_source_code_hash
  memory_size             = var.memory_size
  timeout                 = var.timeout


  # Packaging
  create_package         = var.create_package
  source_path            = var.create_package ? var.source_path : null
  local_existing_package = var.create_package ? null : var.zip_file_path
  s3_existing_package    = var.create_package ? null : var.s3_existing_package
  s3_bucket              = var.store_on_s3 ? var.s3_bucket : null
  s3_prefix              = var.store_on_s3 ? var.s3_prefix : null
  layers                 = var.layers
  environment_variables  = var.environment_variables
  hash_extra             = var.hash_extra

  # Function URL
  authorization_type         = var.authorization_type
  cors                       = var.cors
  create_lambda_function_url = var.create_lambda_function_url
  invoke_mode                = var.invoke_mode

  # Policy
  attach_async_event_policy     = var.attach_async_event_policy
  assume_role_policy_statements = var.assume_role_policy_statements
  trusted_entities              = var.trusted_entities
  allowed_triggers              = var.allowed_triggers
  # Statements
  attach_policy_statements = var.attach_policy_statements
  policy_statements        = var.policy_statements
  # Single Policy ARN
  attach_policy = var.attach_policy
  policy        = var.policy
  # Multiple Policy ARNs
  attach_policies    = var.attach_policies
  policies           = var.policies
  number_of_policies = length(var.policies)
  # Single Policy JSON
  attach_policy_json = var.attach_policy_json
  policy_json        = var.policy_json
  # Multiple Policy JSONs
  attach_policy_jsons    = var.attach_policy_jsons
  policy_jsons           = var.policy_jsons
  number_of_policy_jsons = length(var.policy_jsons)
  # DLQ Policy
  attach_dead_letter_policy = var.attach_dead_letter_policy
  dead_letter_target_arn    = var.dead_letter_target_arn
  # VPC Networking Policy
  attach_network_policy = var.attach_network_policy

  # Logging
  attach_cloudwatch_logs_policy      = var.attach_cloudwatch_logs_policy
  attach_create_log_group_permission = var.attach_create_log_group_permission
  cloudwatch_logs_kms_key_id         = var.cloudwatch_logs_kms_key_id
  cloudwatch_logs_log_group_class    = var.cloudwatch_logs_log_group_class
  cloudwatch_logs_retention_in_days  = var.cloudwatch_logs_retention_in_days
  cloudwatch_logs_skip_destroy       = var.cloudwatch_logs_skip_destroy
  cloudwatch_logs_tags               = var.cloudwatch_logs_tags
  attach_tracing_policy              = var.attach_tracing_policy
  tracing_mode                       = var.tracing_mode

  # VPC Settings
  vpc_security_group_ids = var.vpc_security_group_ids
  vpc_subnet_ids         = var.vpc_subnet_ids

  # Lambda@Edge
  lambda_at_edge                  = var.lambda_at_edge
  lambda_at_edge_logs_all_regions = var.lambda_at_edge_logs_all_regions

  tags   = local.tags
  create = var.create
}
