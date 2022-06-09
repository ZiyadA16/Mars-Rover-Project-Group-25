import boto3
from boto3.dynamodb.conditions import Key



#Adds new row
def put_row(time, position, date, dynamodb=None):
    if not dynamodb:
        dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

    table = dynamodb.Table('Rover')
    response = table.put_item(
       Item={
            'time': time,
            'position': position,
            'date': date

        }
    )
    return response#[0]#["ResponseMetadata"]#["HTTPStatusCode"]

#NEED ONE TO EDIT SCORE - AND CHECK IF A SCORE EXISTS BEFORE
#i.e. if score exists edit, else put a new entry


#Retrieves most recent row
def query_rq(dynamodb=None):
    if not dynamodb:
        dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

    table = dynamodb.Table('Rover')
    '''
    response = table.query(
        KeyConditionExpression=Key('time').eq('time'), ScanIndexForward=True
    )
    '''
    response = table.scan(FilterExpression=Key('time').between(0,100000))
    return response['Items']
