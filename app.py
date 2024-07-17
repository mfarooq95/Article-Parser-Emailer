import feedparser
import boto3
from botocore.exceptions import ClientError

def get_latest_article():
    newsfeed = feedparser.parse("https://feeds.feedburner.com/brainpickings/rss")
    latest = newsfeed.entries[0]
    article_title = latest.title
    article_link = latest.link

    sender = ""
    recipients = ""
    region = "us-east-1"
    subject = article_title
    body = ("Here's the latest from The Marginalian. \n\n" + article_link)

    ses_client = boto3.client('ses', region_name = region)

    try:
        response = ses_client.send_email(
            Source = sender,
            Destination = {
                'ToAddresses': [
                    recipients,
                    ]
                },
            Message = {
                'Subject': {
                    'Data': subject
                    },
                'Body': {
                    'Text': {
                        'Data': body
                        }
                    }
                },
            )
    except ClientError as error:
        print(error.response['Error']['Message'])
    else:
        print(['Email sent. Message ID: ']),
        print(response['MessageId'])

def lambda_handler(event, context):
    get_latest_article()
    print("The function is done running.")