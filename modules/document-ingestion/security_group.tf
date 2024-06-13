resource "aws_security_group" "this" {
  vpc_id      = aws_vpc.this.id
  name        = "securityGroup-${var.stage}"
  description = "Security group for the RAG app"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

