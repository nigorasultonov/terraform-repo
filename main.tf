
resource "aws_instance" "ansible" {
  ami           = "ami-08978028fd061067a" #Redhat AMI
  instance_type = "t2.micro"
  key_name      = var.key_pair_name
  tags = {
    Owner = "Nigora"
    Name  = "ansible_managed_host"
  }
}
#Create ec2 instance with key pair generation

resource "aws_key_pair" "new_key_pair" {
  key_name   = var.key_pair_name2
  public_key = var.public_key
}
resource "aws_instance" "ansible2" {
  ami           = "ami-08978028fd061067a" #Redhat
  instance_type = "t2.micro"
  key_name      = aws_key_pair.new_key_pair.key_name
  tags = {
    Owner = "Nigora"
    Name  = "ansible_new"
  }
}
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "stop_instance.py"
  output_path = "stop_instance.zip"
}

resource "aws_lambda_function" "stop_instance" {
  filename      = data.archive_file.lambda.output_path
  function_name = "stop_instance"
  role          = aws_iam_role.lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  source_code_hash = filebase64("stop_instance.zip")
  environment {
    variables = {
      INSTANCE_ID = "i-06d463b8e025d9c75, i-076a121fb843936b7"
    }
  }
}
resource "aws_iam_role" "lambda" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "lambda" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda.name
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_instance.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_instance.arn
}
resource "aws_cloudwatch_event_rule" "stop_instance" {
  name                = "stop_instance"
  description         = "Stop instance at 10pm on Tuesdays and Thursdays"
  schedule_expression = "cron(0 22 ? * TUE,THU *)"
  } 
resource "aws_cloudwatch_event_rule" "stop_instance_weekend" {
  name                = "stop-instance-weekend"
  description         = "Stop EC2 instance at 1pm at the weekends"
  schedule_expression = "cron(0 13 ? * SAT,SUN *)"
}

resource "aws_cloudwatch_event_target" "stop_instance" {
  rule      = aws_cloudwatch_event_rule.stop_instance.name
  arn       = aws_lambda_function.stop_instance.arn
  target_id = "stop_instance"
}
resource "aws_cloudwatch_event_target" "stop_instance2" {
  rule      = aws_cloudwatch_event_rule.stop_instance_weekend.name
  arn       = aws_lambda_function.stop_instance.arn
  target_id = "stop_instance"
}


   

  


