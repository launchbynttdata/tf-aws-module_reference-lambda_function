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
variable "resource_names_map" {
  description = "A map of key to resource_name that will be used by tf-launch-module_library-resource_name to generate resource names"
  type = map(object({
    name       = string
    max_length = optional(number, 60)
    region     = optional(string, "eastus2")
  }))

  default = {
    lambda_function = {
      name       = "fn"
      max_length = 80
      region     = "us-east-2"
    }
  }
}

variable "resource_names_strategy" {
  description = "Strategy to use for generating resource names, taken from the outputs of the naming module, e.g. 'standard', 'minimal_random_suffix', 'dns_compliant_standard', etc."
  type        = string
  default     = "minimal_random_suffix"
}

variable "instance_env" {
  type        = number
  description = "Number that represents the instance of the environment."
  default     = 0

  validation {
    condition     = var.instance_env >= 0 && var.instance_env <= 999
    error_message = "Instance number should be between 0 to 999."
  }
}

variable "instance_resource" {
  type        = number
  description = "Number that represents the instance of the resource."
  default     = 0

  validation {
    condition     = var.instance_resource >= 0 && var.instance_resource <= 100
    error_message = "Instance number should be between 0 to 100."
  }
}

variable "logical_product_family" {
  type        = string
  description = <<EOF
    (Required) Name of the product family for which the resource is created.
    Example: org_name, department_name.
  EOF
  nullable    = false

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_family))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }

  default = "launch"
}

variable "logical_product_service" {
  type        = string
  description = <<EOF
    (Required) Name of the product service for which the resource is created.
    For example, backend, frontend, middleware etc.
  EOF
  nullable    = false

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_service))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }

  default = "lambda"
}

variable "class_env" {
  type        = string
  description = "(Required) Environment where resource is going to be deployed. For example. dev, qa, uat"
  nullable    = false
  default     = "demo"

  validation {
    condition     = length(regexall("\\b \\b", var.class_env)) == 0
    error_message = "Spaces between the words are not allowed."
  }
}

variable "description" {
  description = "Description of your Lambda Function"
  type        = string
  default     = ""
}

variable "handler" {
  description = "Lambda Function entrypoint in your code"
  type        = string
  default     = "index.lambda_handler"
}

variable "runtime" {
  description = "Lambda Function runtime"
  type        = string
  default     = "python3.9"
}

variable "architectures" {
  description = "(Optional) Instruction set architecture for your Lambda function. Valid architectures are x86_64 (default) and arm64."
  type        = list(string)
  default     = ["x86_64"]
}

variable "publish" {
  description = "Whether to publish creation/change as new Lambda Function Version."
  type        = bool
  default     = true
}

variable "ephemeral_storage_size" {
  description = "mount of ephemeral storage (/tmp) in MB your Lambda Function can use at runtime. Valid values are between 512 MB to 10,240 MB (10 GB)."
  type        = number
  default     = 512

  validation {
    condition     = var.ephemeral_storage_size >= 512 && var.ephemeral_storage_size <= 10240
    error_message = "ephemeral_storage_size must be in the range of 512 to 10240 inclusive."
  }
}

variable "environment_variables" {
  description = "A map that defines environment variables for the Lambda Function."
  type        = map(string)
  default     = {}
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime. Valid values are between 128 MB to 10,240 MB (10 GB), in 64 MB increments."
  type        = number
  default     = 128

  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240 && var.memory_size % 64 == 0
    error_message = "memory_size must be between 128 and 10240 inclusive and divisible by 64."
  }
}

variable "timeout" {
  description = "The amount of time your Lambda Function has to run in seconds. The maximum lifetime of a Lambda function execution is 15 minutes (900 seconds)."
  type        = number
  default     = 3

  validation {
    condition     = var.timeout >= 1 && var.timeout <= 900
    error_message = "timeout must be between 1 and 900 inclusive."
  }
}

# Packaging®ca

variable "create_package" {
  description = "Controls whether Lambda package should be created"
  type        = bool
  default     = false
}

variable "source_path" {
  description = "The absolute path to a local file or directory containing your Lambda source code. Only valid if `create_package` is set to `true`."
  type        = any
  default     = null
}

variable "zip_file_path" {
  description = "Path of the source zip file with respect to module root"
  type        = string
  default     = null
}

variable "store_on_s3" {
  description = "Whether to store produced artifacts on S3 or locally."
  type        = bool
  default     = false
}

variable "s3_existing_package" {
  description = "The S3 bucket object with keys bucket, key, version pointing to an existing zip-file to use. Only valid if `create_package` is set to `false`."
  type        = map(string)
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket to store artifacts. Required if `store_on_s3` is set to `true`, ignored otherwise."
  type        = string
  default     = null
}

variable "s3_prefix" {
  description = "Directory name where artifacts should be stored in the S3 bucket. Defaults to `builds`. Required if `store_on_s3` is set to `true`, ignored otherwise."
  type        = string
  default     = "builds"
}

variable "layers" {
  description = "List of Lambda Layer Version ARNs (maximum of 5) to attach to your Lambda Function."
  type        = list(string)
  default     = null

  validation {
    condition     = var.layers == null ? true : length(var.layers) <= 5
    error_message = "Lambda Function layer attachment allows a maximum of 5 layers."
  }
}

variable "hash_extra" {
  description = "The string to add into hashing function. Useful when building same source path for different functions."
  type        = string
  default     = ""
}

variable "ignore_source_code_hash" {
  description = "Whether to ignore changes to the function's source code hash. Set to true if you manage infrastructure and code deployments separately."
  type        = bool
  default     = false
}

# Function URL

variable "authorization_type" {
  description = "The type of authentication that the Lambda Function URL uses. Set to `AWS_IAM` to restrict access to authenticated IAM users only. Set to `NONE` to bypass IAM authentication and create a public endpoint (default)."
  type        = string
  default     = "NONE"
}

variable "cors" {
  description = "CORS settings to be used by the Lambda Function URL"
  type = object({
    allow_credentials = optional(bool, false)
    allow_headers     = optional(list(string), null)
    allow_methods     = optional(list(string), null)
    allow_origins     = optional(list(string), null)
    expose_headers    = optional(list(string), null)
    max_age           = optional(number, 0)
  })
  default = {}
}

variable "create_lambda_function_url" {
  description = "Whether the Lambda Function URL resource should be created (default true)."
  type        = bool
  default     = true
}

variable "invoke_mode" {
  description = "Invoke mode of the Lambda Function URL. Valid values are `BUFFERED` (default) and `RESPONSE_STREAM`."
  type        = string
  default     = "BUFFERED"
}

# Policy

variable "attach_policy_statements" {
  description = "Controls whether `policy_statements` should be added to IAM role for Lambda Function"
  type        = bool
  default     = false
}

variable "policy_statements" {
  description = "Map of dynamic policy statements to attach to Lambda Function role"
  type        = map(string)
  default     = {}
}

variable "attach_policy" {
  description = "Controls whether `policy` should be added to IAM role for Lambda Function"
  type        = bool
  default     = false
}

variable "policy" {
  description = "Policy statement ARN to attach to Lambda Function role"
  type        = string
  default     = null
}

variable "attach_policies" {
  description = "Controls whether `policies` should be added to IAM role for Lambda Function"
  type        = bool
  default     = false
}

variable "policies" {
  description = "List of policy statement ARNs to attach to Lambda Function role"
  type        = list(string)
  default     = []
}

variable "attach_policy_json" {
  description = "Controls whether `policy_json` should be added to IAM role for Lambda Function"
  type        = bool
  default     = false
}

variable "policy_json" {
  description = "An additional policy document as JSON to attach to the Lambda Function role"
  type        = string
  default     = null
}

variable "attach_policy_jsons" {
  description = "Controls whether `policy_jsons` should be added to IAM role for Lambda Function"
  type        = bool
  default     = false
}

variable "policy_jsons" {
  description = "An additional policy documents as JSON to attach to the Lambda Function role"
  type        = list(string)
  default     = []
}

variable "attach_dead_letter_policy" {
  description = "Controls whether SNS/SQS dead letter notification policy should be added to IAM role for Lambda Function. Defaults to `false`."
  type        = bool
  default     = false
}

variable "dead_letter_target_arn" {
  description = "The ARN of an SNS topic or SQS queue to notify when an invocation fails."
  type        = string
  default     = null
}

variable "attach_network_policy" {
  description = "Controls whether VPC/network policy should be added to IAM role for Lambda Function"
  type        = bool
  default     = false
}

variable "attach_async_event_policy" {
  description = "Controls whether async event policy should be added to IAM role for Lambda Function"
  type        = bool
  default     = false
}

variable "attach_tracing_policy" {
  description = "Controls whether X-Ray tracing policy should be added to IAM role for Lambda Function"
  type        = bool
  default     = false
}

variable "assume_role_policy_statements" {
  description = "Map of dynamic policy statements for assuming Lambda Function role (trust relationship)"
  type        = map(string)
  default     = {}
}

variable "trusted_entities" {
  description = "List of additional trusted entities for assuming Lambda Function role (trust relationship)"
  type        = any
  default     = []
}

variable "allowed_triggers" {
  description = "Map of allowed triggers to create Lambda permissions"
  type        = map(any)
  default     = {}
}

# Logging

variable "attach_cloudwatch_logs_policy" {
  description = "Controls whether CloudWatch Logs policy should be added to IAM role for Lambda Function"
  type        = bool
  default     = true
}

variable "attach_create_log_group_permission" {
  description = "Controls whether to add the create log group permission to the CloudWatch logs policy"
  type        = bool
  default     = true
}

variable "cloudwatch_logs_kms_key_id" {
  description = "The ARN of the KMS Key to use when encrypting log data."
  type        = string
  default     = null
}

variable "cloudwatch_logs_log_group_class" {
  description = "Specified the log class of the log group. Possible values are: `STANDARD` (default) or `INFREQUENT_ACCESS`"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "INFREQUENT_ACCESS"], var.cloudwatch_logs_log_group_class)
    error_message = "cloudwatch_logs_log_group_class must be one of STANDARD, INFREQUENT_ACCESS"
  }
}

variable "cloudwatch_logs_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653. Defaults to 30."
  type        = number
  default     = 30

  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.cloudwatch_logs_retention_in_days)
    error_message = "cloudwatch_logs_retention_in_days must be one of 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653"
  }
}

variable "cloudwatch_logs_skip_destroy" {
  description = "Whether to keep the log group (and any logs it may contain) at destroy time. Defaults to false."
  type        = bool
  default     = false
}

variable "cloudwatch_logs_tags" {
  description = "A map of tags to assign to the logs resource."
  type        = map(string)
  default     = {}
}

variable "tracing_mode" {
  description = "Tracing mode of the Lambda Function. Valid value can be either PassThrough (default) or Active."
  type        = string
  default     = "PassThrough"

  validation {
    condition     = contains(["PassThrough", "Active"], var.tracing_mode)
    error_message = "tracing_mode must be one of PassThrough, Active"
  }
}

# VPC Settings

variable "vpc_security_group_ids" {
  description = "List of security group ids when Lambda Function should run in the VPC."
  type        = list(string)
  default     = null
}

variable "vpc_subnet_ids" {
  description = "List of subnet ids when Lambda Function should run in the VPC. Usually private or intra subnets."
  type        = list(string)
  default     = null
}

# Lambda@Edge

variable "lambda_at_edge" {
  description = "Set this to true if using Lambda@Edge, to enable publishing, limit the timeout, and allow edgelambda.amazonaws.com to invoke the function"
  type        = bool
  default     = false
}

variable "lambda_at_edge_logs_all_regions" {
  description = "Whether to specify a wildcard in IAM policy used by Lambda@Edge to allow logging in all regions"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Map of tags to apply to this resource."
  type        = map(string)
  default     = {}
}

variable "create" {
  description = " Controls whether resources should be created."
  type        = bool
  default     = false
}
