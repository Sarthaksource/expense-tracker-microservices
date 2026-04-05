package com.example.expenseservice.controller;

import com.example.expenseservice.dto.ExpenseDto;
import com.example.expenseservice.dto.ExpenseInfoDto;
import com.example.expenseservice.service.ExpenseInfoService;
import com.example.expenseservice.service.ExpenseService;
import lombok.NonNull;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/expense/v1")
public class ExpenseController
{
    private final ExpenseService expenseService;

    private final ExpenseInfoService expenseInfoService;

    @Autowired
    ExpenseController(ExpenseService expenseService, ExpenseInfoService expenseInfoService){
        this.expenseService = expenseService;
        this.expenseInfoService = expenseInfoService;
    }

    @GetMapping(path = "/getExpense")
    public ResponseEntity<List<ExpenseDto>> getExpense(@RequestParam(value = "user_id") @NonNull String userId){
        try{
            List<ExpenseDto> expenseDtoList = expenseService.getExpenses(userId);
            return new ResponseEntity<>(expenseDtoList, HttpStatus.OK);
        }catch(Exception ex){
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
        }
    }

    @PostMapping(path="/addExpense")
    public ResponseEntity<Boolean> addExpenses(@RequestHeader(value = "X-User-Id") @NonNull String userId, @RequestBody ExpenseDto expenseDto){
        try{
            expenseDto.setUserId(userId);
            return new ResponseEntity<>(expenseService.createExpense(expenseDto), HttpStatus.OK);
        }catch (Exception ex){
            return new ResponseEntity<>(false, HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/addExpenseInfo")
    public ResponseEntity<Boolean> addExpenseInfo(@RequestHeader("X-User-Id") @NonNull String userId, @RequestBody ExpenseInfoDto expenseInfoDto) {
        try {
            expenseInfoDto.setUserId(userId);
            return new ResponseEntity<>(expenseInfoService.createOrUpdateExpenseInfo(expenseInfoDto), HttpStatus.OK);
        } catch (Exception e) {
            e.printStackTrace();
            return new ResponseEntity<>(false, HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/getExpenseInfo")
    public ResponseEntity<ExpenseInfoDto> getExpenseInfo(@RequestHeader("X-User-Id") @NonNull String userId) {
        try {
            ExpenseInfoDto dto = expenseInfoService.getExpenseInfo(userId);
            if (dto == null) {
                return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
            }
            return new ResponseEntity<>(dto, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}