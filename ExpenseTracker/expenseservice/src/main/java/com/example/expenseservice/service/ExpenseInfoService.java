package com.example.expenseservice.service;

import com.example.expenseservice.dto.ExpenseInfoDto;
import com.example.expenseservice.entities.ExpenseInfo;
import com.example.expenseservice.repository.ExpenseInfoRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.logging.log4j.util.Strings;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Objects;
import java.util.Optional;

@Service
public class ExpenseInfoService {

    private final ExpenseInfoRepository expenseInfoRepository;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Autowired
    public ExpenseInfoService(ExpenseInfoRepository expenseInfoRepository) {
        this.expenseInfoRepository = expenseInfoRepository;
    }

    public boolean createOrUpdateExpenseInfo(ExpenseInfoDto dto) {
        setDefaults(dto);

        try {
            Optional<ExpenseInfo> existingOpt = expenseInfoRepository.findByUserId(dto.getUserId());

            ExpenseInfo expenseInfo;

            if (existingOpt.isPresent()) {
                expenseInfo = existingOpt.get();
                expenseInfo.setAmountLimit(dto.getAmountLimit());
                expenseInfo.setCurrency(dto.getCurrency());
            } else {
                expenseInfo = objectMapper.convertValue(dto, ExpenseInfo.class);
            }

            expenseInfoRepository.save(expenseInfo);
            return true;

        } catch (Exception e) {
            return false;
        }
    }

    public ExpenseInfoDto getExpenseInfo(String userId) {
        Optional<ExpenseInfo> expenseInfoOpt = expenseInfoRepository.findByUserId(userId);

        return expenseInfoOpt
                .map(info -> objectMapper.convertValue(info, ExpenseInfoDto.class))
                .orElse(null);
    }

    private void setDefaults(ExpenseInfoDto dto) {
        if (Objects.isNull(dto.getCurrency())) {
            dto.setCurrency("INR");
        }

        if (Objects.isNull(dto.getAmountLimit())) {
            dto.setAmountLimit(java.math.BigDecimal.ZERO);
        }
    }
}