module "genai_doc_ingestion" {
  source = "../.."

  solution_prefix    = "demo-genai"
  container_platform = "linux/amd64" # "linux/arm64"
  force_destroy      = true
}
