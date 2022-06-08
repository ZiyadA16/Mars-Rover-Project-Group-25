import boto3
from botocore.exceptions import ClientError


def delete_rover_table(dynamodb=None):
    if not dynamodb:
        dynamodb = boto3.resource('dynamodb', region_name="us-east-1")

    table = dynamodb.Table('Rover')
    table.delete()


if __name__ == '__main__':
    try:
        delete_rover_table()
        print("Rover table deleted.")
    except ClientError:
        print("Not Found")
