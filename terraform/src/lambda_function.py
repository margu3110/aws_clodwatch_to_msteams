import json   # Importing json library for parsing JSON data
import urllib.request   # Importing requests library for sending HTTP requests
import os   # Importing os library for accessing environment variables

def lambda_handler(event, context):
    sns_message = event['Records'][0]['Sns']['Message']
    webhook_url = os.environ['MS_TEAMS_WEBHOOK_URL']
    
    headers = {'Content-Type': 'application/json; charset=utf-8'}
    message = {
        'text': sns_message
    }

    alarm_name = json.loads(message)['AlarmName']
    alarm_desc = json.loads(message)['AlarmDescription']
    new_state = json.loads(message)['NewStateValue']
    alarm_time = json.loads(message)['StateChangeTime']
    instance_id = json.loads(message)['Trigger']['Dimensions'][0]['value']
    region = json.loads(message)['Region']
    # account_id = context.invoked_function_arn.split(':')[4]

    # Create url link to view alarm
    alarm_url = f"https://console.aws.amazon.com/cloudwatch/home?region={region}#s=Alarms&alarm={alarm_name}"
    
    # Setting the theme color for the Teams message based on the new state of the alarm
    if new_state == "ALARM":
        colour = "FF0000"
    elif new_state == "OK":
        colour = "00FF00"
    else:
        colour = "0000FF"

        # Constructing the Teams message payload for an alarm
    message_card = {
        "@type": "MessageCard",
        "@context": "http://schema.org/extensions",
        "themeColor": color,
        "title": f"{alarm_name} {new_state} on {instance_id}",
        "text": f"Alarm description: {alarm_desc}\nCurrent state: {new_state}\nTriggered time: {alarm_time}",
        "potentialAction": [
            {
                "@type": "OpenUri",
                "name": "View Alarm",
                "targets": [
                    {
                        "os": "default",
                        "uri": alarm_url
                    }
                ]
            }
        ]
    }

    req = urllib.request.Request(webhook_url, json.dumps(message_card).encode(), headers)
    with urllib.request.urlopen(req) as response:
        return {
            'statusCode': 200,
            'body': json.loads(response.read())
        }
