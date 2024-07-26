locals {
  combined_tags = merge(
    var.tags,
    {
      Submodule = "networking-resources"
    }
  )
}