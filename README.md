# Article-A-Day
An AWS lambda-based cloud app that pulls the latest article from an RSS feed and emails it once a day. Provisioned in Terraform.

## Project Overview
The goal of this project was to gain Terraform and AWS experience and exposure while performing a microservice that could be seen as useful for me or others. I enjoy articles from a few sites and routinely check the site for new articles daily. With this, I could get them sent to me once a day without having to manually check or run a script.

While the scale of the project is not incredibly large, the scope of the project's technologies are. Exposing myself to new technologies such as AWS, its services like Lambda, SES, and EventBridge, as well as Infrustructure as Code (IAC) technology like Terraform, I believe, has given me new skills to work with in a real-world setting. With this project I'm better suited to now elevate my own projects to a higher level than before in a cloud-based world and industry.

## Installation Overview
*Article-A-Day* is an AWS Lambda-based cloud app that's been provsioned in Terraform. To "install" or use the app, simply download or clone the repo and then update the required information. Finally, init, plan and then apply the Terraform code.


## Requirements
The app is built in Python (v3.12). It uses AWS services to perform its microservice, and the cloud infrustructure itself is handled by Terraform. Below is a list of non-library requirements as well as the list of libraries and dependencies the app uses and the AWS services it will create and utilize in your AWS account. All packages are saved in the requirements.txt file and can be installed via the terminal prompt `pip install -r requirements.txt`.

   > ### NOTE❗️
   > *The services used in AWS are all under the Free-Tier, so no charges showed be accrued. However, it's in your best interest to ensure you monitor the usage of these services and the life of the applications used. You can always run `terraform destroy` to kill the services.*
> 
> *It's unlikely you'll use any service with this app anywhere near the amount required for a charge to begin as the rates the application will work will fall within the Free-Tier's allocated free amount. Please refer to AWS' pricing guide for its services and a list of its Free-Tier services for more information.*

| AWS Services              | Libraries/Packages | Other
| :-----------              | :------- | :-------
| Lambda                    | Boto3 | Terraform
| Simple Email Service (SES)| Feedparser
| Cloudwatch (Eventbridge)


## Installation & Run Guide
Once the repo is cloned or downloaded, it's important that several steps are taken before initializing the cloud infrustructure. Below is a guide on the necessary steps required before the app is prepared to be initialized and run.

1. **Install the required packages from the `requirements.txt` into the provided empty directory:**

   `/python/lib/python3.xx/site-packages`

   > ### NOTE❗️
   > *It's important that you install the third-party libraries into the above listed directory as you will need to zip/archive the libraries so the Lambda layer may make use of the libraries in the Lambda function itself.*
   > 
   > *At this time Python3.12 is the current version, and the version the code was written with. This is reflected in AWS' Lambda service as its runtime. You may update the runtime you'd like the app to run with in the `lambda.tf` file:*

   ```terraform
   resource "aws_lambda_function" "terraform_lambda_func" {
   filename         = "my_lambda_function.zip"
   function_name    = "from_the_margin"
   role             = aws_iam_role.lambda_role.arn
   handler          = "app.lambda_handler"
   runtime          = "python3.12" # Update runtime here. Must be available in AWS Lambda's runtime list.
   depends_on       = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
   source_code_hash = filebase64sha256("my_lambda_function.zip")
   layers           = [aws_lambda_layer_version.python-feedparser-layer.arn]
   timeout          = 60
   }
   ```

   > *You will also need to update the Lambda's layer to accept the same runtime. This can be updated in the `lambda_layers.tf` file. Please note that AWS' Lambda has its own list of runtimes that it allows. Entering an unsupported runtime for either the Lambda or its layer will throw a runtime error in Lambda. Please refer to AWS' documentation for the available runtimes.*

   ```terraform
   resource "aws_lambda_layer_version" "python-feedparser-layer" {
   filename            = "layers/python_feedparser.zip"
   layer_name          = "python_feedparser"
   source_code_hash    = filebase64sha256("layers/python_feedparser.zip")
   compatible_runtimes = ["python3.8", "python3.9", "python3.12"] # Update runtime here. Must be available in AWS Lambda's runtime list.
   }
   ```

2. Update the `sender` and `recipient` variables in `app.py` so SES can appropriately send the email with the article from a verified email address to a list of recipients. To send the article to yourself, simply list or enter your email. **You must have a verified email or domain in SES before running the app!**

   ```python
   sender = "" # Add SES verified email address or domain here.
   recipients = "" # Add list of recipients or a single recipient here.
   region = "us-east-1"
   subject = article_title
   ```

3. Enter your AWS credentials' path in `lambda.tf` under the provider init block. Update the region if you need

   ```terraform
   provider "aws" {
   region                   = "us-east-1"
   shared_credentials_files = [""] # Add your path to your AWS credentials here.
   }
   ```
   > ### NOTE❗️
   > 
   > *Without your AWS credentials path shared appropraitely, Terraform will not be able to create the resources requried to create the cloud app.*
   > *You can also use environment variables that store your AWS secret key and access key if you've set that up.*

4. Change the RSS feed in `app.py`. As a default, the app will pull the latest article from The Marginalian and use that.

   ```python
   def get_latest_article():
    newsfeed = feedparser.parse("https://feeds.feedburner.com/brainpickings/rss") # Change RSS feed string here.
    latest = newsfeed.entries[0]
    article_title = latest.title
    article_link = latest.link
   ```
   > ### NOTE❗️
   > 
   > *You can also target more elements and items from the RSS feed with feedparser. Please refer to the library's documentation to learn more and update the function in `app.py` to reflect your targets.*

5. Zip the `app.py` file using the terminal, manually, or Terraform's `data archive` data block and save the zip as `my_lambda_function.zip` to the root of the app's directory. Any changes to this lambda function's zip name must be reflected in the Terraform code

   Terminal Prompt:
   
   `zip -r my_lambda_function.zip app.py`

   Terraform:

   ```terraform
   data "archive_file" "my_lambda_function_zip" {
   type = "zip"
   source_dir = "/app.py"
   output_path = "/my_lambda_function.zip"
   ```
   > ### NOTE❗️
   > 
   > *Bear in mind that if you utilize Terraform's archive_file data block, you'll need to update the Terraform code for `lambda.tf` to target the data block so Terraform understands where the filename and source of the app.py zip file is.*

6. Zip the third-party library directory into a zip file titled `python_feedparser.zip` into the provided empty directory `layers`. Any changes to the name of this zip file or the location of it outside of the provided `layers` directory must be reflected in the Terraform code
   > ### NOTE❗️
   > 
   > *If you utilize the Terraform `data_archive` data method, just as last time, you'll need to update the terraform code for `lambda_layers.tf` to target the data block so Terraform understands where the filename and the source of the zipped packages/layer is.*

7. Once the information has been updated, and the `app.py` file and the libraries have been zipped, you can `terraform init`, `terraform plan`, and then `terraform apply` the code to create the AWS services and instances


Terraform will create the Lambda function using the `my_lambda_function` zip artifact, and it will create and attach a Lambda layer to the function using the dependencies/packages zipepd into the `layers/python_feedparser.zip` file. An Eventbridge rule will be created and tied to the Lambda function to fire the lambda once a day to pull the latest article from the provided RSS feed and email it to you (or another email address). The set timeout for the Lambda function is 1 minute. This can be updated in the `lambda.tf` file itself under the lambda resource and its timeout parameter.
