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

variable "create_package" {
  description = "Controls whether Lambda package should be created"
  type        = bool
  default     = false
}

variable "handler" {
  description = "Lambda Function entrypoint in your code"
  type        = string
  default     = "index.lambda_handler"
}

variable "zip_file_path" {
  description = "Path of the source zip file with respect to module root"
  type        = string
  default     = null
}
