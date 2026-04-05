from fastapi import FastAPI, Request, Header
from fastapi.responses import JSONResponse
from .service.messageService import MessageService
from kafka import KafkaProducer
import json
import os

app = FastAPI()

messageService = MessageService()

kafka_host = os.getenv('KAFKA_HOST', 'localhost')
kafka_port = os.getenv('KAFKA_PORT', '9092')
kafka_bootstrap_servers = f"{kafka_host}:{kafka_port}"
print("Kafka server is " + kafka_bootstrap_servers)
producer = KafkaProducer(
    bootstrap_servers=kafka_bootstrap_servers,
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)


@app.post('/ds/v1/message')
async def handle_message(
    request: Request,
    x_user_id: str = Header(default=None, alias="X-User-ID")
):
    body = await request.json()
    message = body.get('message')
    received_at = body.get('datetime')  # ISO string from frontend e.g. "2026-03-30T10:15:00"

    result = messageService.process_message(message)

    if result is None:
        return JSONResponse(
            status_code=400,
            content={"error": "Not a bank SMS or could not parse message"}
        )

    serialized_result = result.serialize()

    if x_user_id:
        serialized_result['user_id'] = x_user_id
    else:
        print("WARNING: No X-User-ID header found in request!")

    if received_at:
        serialized_result['created_at'] = received_at  # consumer will use this over Instant.now()

    producer.send('expense_service', serialized_result)

    return JSONResponse(content=serialized_result)


@app.get('/')
async def handle_get():
    return {"message": "Hello world"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app:app", host="0.0.0.0", port=8010, reload=True)