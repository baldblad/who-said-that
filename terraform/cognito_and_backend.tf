resource "aws_api_gateway_method" "process_chat_post" {
  rest_api_id   = aws_api_gateway_rest_api.game_api.id
  resource_id   = aws_api_gateway_resource.process_chat_resource.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id
}

resource "aws_api_gateway_integration" "process_chat_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.game_api.id
  resource_id             = aws_api_gateway_resource.process_chat_resource.id
  http_method             = aws_api_gateway_method.process_chat_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.process_chat.invoke_arn
}

resource "aws_api_gateway_method" "random_message_get" {
  rest_api_id   = aws_api_gateway_rest_api.game_api.id
  resource_id   = aws_api_gateway_resource.random_message_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id
}

resource "aws_api_gateway_integration" "random_message_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.game_api.id
  resource_id             = aws_api_gateway_resource.random_message_resource.id
  http_method             = aws_api_gateway_method.random_message_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_random_message.invoke_arn
}

resource "aws_api_gateway_authorizer" "cognito_auth" {
  name                   = "CognitoAuthorizer"
  rest_api_id            = aws_api_gateway_rest_api.game_api.id
  type                   = "COGNITO_USER_POOLS"
  provider_arns          = [aws_cognito_user_pool.dev_pool.arn]
  identity_source        = "method.request.header.Authorization"
}
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"
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

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "Allow Lambda to access DynamoDB and log to CloudWatch"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = "${aws_dynamodb_table.processed_chats.arn}"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
resource "aws_cognito_user_pool" "dev_pool" {
  name = "dev-user-pool"
}

resource "aws_cognito_user_pool_client" "dev_client" {
  name         = "dev-client"
  user_pool_id = aws_cognito_user_pool.dev_pool.id
  explicit_auth_flows = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  supported_identity_providers = ["Google"]
}

resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = aws_cognito_user_pool.dev_pool.id
  provider_name = "Google"
  provider_type = "Google"
  provider_details = {
    client_id     = var.google_client_id
    client_secret = var.google_client_secret
    authorize_scopes = "openid email profile"
  }
  attribute_mapping = {
    email = "email"
    username = "sub"
  }
}

resource "aws_cognito_user_group" "whitelist" {
  user_pool_id = aws_cognito_user_pool.dev_pool.id
  name         = "whitelisted-users"
  description  = "Users allowed to access dev environment"
}

resource "aws_lambda_function" "process_chat" {
  function_name = "process_chat_export"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "lambda/process_chat.zip"
}

resource "aws_lambda_function" "get_random_message" {
  function_name = "get_random_message"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "lambda/get_random_message.zip"
}

resource "aws_api_gateway_rest_api" "game_api" {
  name        = "twss-api"
  description = "API for WhatsApp guessing game"
}

resource "aws_api_gateway_resource" "process_chat_resource" {
  rest_api_id = aws_api_gateway_rest_api.game_api.id
  parent_id   = aws_api_gateway_rest_api.game_api.root_resource_id
  path_part   = "process-chat"
}

resource "aws_api_gateway_resource" "random_message_resource" {
  rest_api_id = aws_api_gateway_rest_api.game_api.id
  parent_id   = aws_api_gateway_rest_api.game_api.root_resource_id
  path_part   = "random-message"
}
