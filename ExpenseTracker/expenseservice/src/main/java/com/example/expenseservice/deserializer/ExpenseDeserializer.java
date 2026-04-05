package com.example.expenseservice.deserializer;

import com.example.expenseservice.dto.ExpenseDto;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.apache.kafka.common.serialization.Deserializer;

public class ExpenseDeserializer implements Deserializer<ExpenseDto> {

    private static final ObjectMapper mapper = new ObjectMapper()
            .registerModule(new JavaTimeModule())
            .configure(DeserializationFeature.ADJUST_DATES_TO_CONTEXT_TIME_ZONE, false);

    @Override
    public ExpenseDto deserialize(String arg0, byte[] arg1) {
        try {
            return mapper.readValue(arg1, ExpenseDto.class);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}