package org.example.serializer;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.json.JsonMapper;
import org.apache.kafka.common.serialization.Serializer;
import org.example.eventProducer.UserInfoEvent;

public class UserInfoSerializer implements Serializer<UserInfoEvent> {

    private final ObjectMapper objectMapper = JsonMapper.builder()
            .propertyNamingStrategy(PropertyNamingStrategies.SNAKE_CASE)
            .build();

    @Override
    public byte[] serialize(String topic, UserInfoEvent event) {
        try {
            return objectMapper.writeValueAsBytes(event);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}