from fastapi import FastAPI, Header
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import List, Optional
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

class MessagePayload(BaseModel):
    message: str
    datetime: Optional[str] = None

@app.post('/ds/v1/message')
async def handle_message(payloads: List[MessagePayload], x_user_id: str = Header(default=None, alias="X-User-ID")):
    if not x_user_id:
        print("WARNING: No X-User-ID header found in request!")

    results = []

    for item in payloads:
        result = messageService.process_message(item.message)

        if result is None:
            results.append({
                "status": "ignored",
                "reason": "Not a bank SMS or could not parse",
                "message": item.message
            })
            continue
        serialized_result = result.serialize()
        if x_user_id:
            serialized_result['user_id'] = x_user_id
        if item.datetime:
            serialized_result['created_at'] = item.datetime
        producer.send('expense_service', serialized_result)
        
        results.append({
            "status": "success",
            "data": serialized_result
        })

    return JSONResponse(content={"batch_results": results})

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app:app", host="0.0.0.0", port=8010, reload=True)