resource "null_resource" "error_trigger" {
  count = length(local.error_messages) > 0 ? 1 : 0

  provisioner "local-exec" {
    command = "echo '${join("\n", local.error_messages)}' && exit 1"
  }
}

resource "aws_vpc" "vpc" {
  cidr_block = local.existing_vpc_bool ? null : var.vpc_props.cidr_block
}

# Security group
resource "aws_security_group" "security_group" {
  name = local.existing_security_group_id_bool ? null : "securityGroup${var.stage}"
  vpc_id = local.existing_security_group_id_bool ? null : aws_vpc.vpc.id
}

# Private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id = local.vpc_id
  cidr_block = local.existing_vpc_bool ? var.vpc_props.cidr_block : aws_vpc.vpc.cidr_block
  map_public_ip_on_launch = false
  tags = {
    Name = "PrivateSubnet-${var.stage}"
  }
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.question_answering_function.arn
  principal     = "events.amazonaws.com"
}
