import boto3

def create_hs_table(dynamodb=None):
    if not dynamodb:
        dynamodb = boto3.resource('dynamodb',region_name='us-east-1')

    table = dynamodb.create_table(
        TableName='Rover',
        KeySchema=[
            {
                'AttributeName': 'position',
                'KeyType': 'HASH'  # Partition key
            },
            {
                'AttributeName': 'time',
                'KeyType': 'RANGE'  # Sort key
            }

        ],
        AttributeDefinitions=[
            {
                'AttributeName': 'position',
                'AttributeType': 'N'
            },
            {
                'AttributeName': 'time',
                'AttributeType': 'N'
            }

        ],
        ProvisionedThroughput={
            'ReadCapacityUnits': 10,
            'WriteCapacityUnits': 10
        }
    )
    
    return table


if __name__ == '__main__':
    Rover = create_hs_table()
    print("Table status:", Rover.table_status)

