package com.example.expenseservice.repository;

import com.example.expenseservice.entities.ExpenseInfo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ExpenseInfoRepository extends JpaRepository<ExpenseInfo, Long> {
    Optional<ExpenseInfo> findByUserId(String userId);
}