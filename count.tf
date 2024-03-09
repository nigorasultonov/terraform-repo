/*
resource "aws_iam_user" "lb" {
  count = length(var.iam_users)
  name  = var.iam_users[count.index]
  path  = "/system/"

  tags = {
    Owner = "Nigora"
  }
}
variable "iam_users" {
  type        = list(any)
  default     = ["user1", "user2", "user3", "user4"]
  description = "description"
}
*/
