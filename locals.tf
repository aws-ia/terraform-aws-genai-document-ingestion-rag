locals {
  merged_api_id = trimspace(data.local_file.merged_api_id.content)
  merged_api_url = trimspace(data.local_file.merged_api_url.content)
}
