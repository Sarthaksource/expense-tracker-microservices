package com.example.expenseservice.service;

import com.example.expenseservice.dto.ExpenseDto;
import com.example.expenseservice.entities.Expense;
import com.example.expenseservice.repository.ExpenseRepository;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.apache.logging.log4j.util.Strings;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.time.Instant;

@Service
public class ExpenseService
{

    private final ExpenseRepository expenseRepository;

    private final ObjectMapper objectMapper = new ObjectMapper().registerModule(new JavaTimeModule());

    @Autowired
    ExpenseService(ExpenseRepository expenseRepository){
        this.expenseRepository = expenseRepository;
    }

    public boolean createExpense(ExpenseDto expenseDto){
        try{
            boolean exists = expenseRepository.existsByUserIdAndAmountAndCreatedAt(
                    expenseDto.getUserId(),
                    expenseDto.getAmount(),
                    expenseDto.getCreatedAt()
            );
            if (exists) {
                System.out.println("Duplicate expense detected, skipping insert.");
                return false;
            }
            expenseRepository.save(objectMapper.convertValue(expenseDto, Expense.class));
            return true;
        }catch(Exception ex){
            ex.printStackTrace();
            return false;
        }
    }

    public boolean updateExpense(ExpenseDto expenseDto){
        Optional<Expense> expenseFoundOpt = expenseRepository.findByUserIdAndExternalId(expenseDto.getUserId(), expenseDto.getExternalId());
        if(expenseFoundOpt.isEmpty()){
            return false;
        }
        Expense expense = expenseFoundOpt.get();
        expense.setAmount(expenseDto.getAmount());
        expense.setMerchant(Strings.isNotBlank(expenseDto.getMerchant()) ? expenseDto.getMerchant() : expense.getMerchant());
        expenseRepository.save(expense);
        return true;
    }

    public List<ExpenseDto> getExpenses(String userId){
        List<Expense> expenseOpt = expenseRepository.findByUserId(userId);
        return objectMapper.convertValue(expenseOpt, new TypeReference<List<ExpenseDto>>() {});
    }
}