locals {
  combined_tags = merge(
    var.tags,
    {
      Solution = var.solution_prefix
    }
  )
}