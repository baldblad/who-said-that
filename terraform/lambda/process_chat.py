def lambda_handler(event, context):
    import random

    messages = [
        "Hello, world!",
        "How are you today?",
        "Keep pushing forward!",
        "You can do it!",
        "Stay positive and strong!"
    ]

    random_message = random.choice(messages)

    return {
        'statusCode': 200,
        'body': random_message
    }