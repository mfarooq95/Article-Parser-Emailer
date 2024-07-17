# Create Lambda layer and tie it to the zip file/artifcat
resource "aws_lambda_layer_version" "python-feedparser-layer" {
  filename            = "layers/python_feedparser.zip"
  layer_name          = "python_feedparser"
  source_code_hash    = filebase64sha256("layers/python_feedparser.zip")
  compatible_runtimes = ["python3.8", "python3.9", "python3.12"]
}