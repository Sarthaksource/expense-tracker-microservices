package com.example.expenseservice.consumer;

import com.example.expenseservice.dto.ExpenseDto;
import com.example.expenseservice.service.ExpenseService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class ExpenseConsumer {
    private ExpenseService expenseService;

    @Autowired
    ExpenseConsumer(ExpenseService expenseService)
    {
        this.expenseService = expenseService;
    }

    @KafkaListener(topics = "${spring.kafka.topic-json.name}", groupId = "${spring.kafka.consumer.group-id}")
    public void listen(ExpenseDto expenseDto) {
        try{
            // Todo: Make it transactional, and check if duplicate event (Handle idempotency)
            expenseService.createExpense(expenseDto);
        }catch(Exception ex){
            ex.printStackTrace();
            System.out.println("AuthServiceConsumer: Exception is thrown while consuming kafka event");
        }
    }
}
