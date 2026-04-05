package com.example.expenseservice.repository;

import com.example.expenseservice.entities.Expense;
import org.springframework.data.repository.CrudRepository;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.Optional;

public interface ExpenseRepository extends CrudRepository<Expense, Long> {

    List<Expense> findByUserId(String userId);

    List<Expense> findByUserIdAndCreatedAtBetween(String userId, Timestamp startTime, Instant endTime);

    Optional<Expense> findByUserIdAndExternalId(String userId, String externalId);

    boolean existsByUserIdAndAmountAndCreatedAt(String userId, BigDecimal amount, Instant createdAt);
}