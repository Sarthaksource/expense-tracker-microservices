package com.example.expenseservice.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import lombok.*;

import java.math.BigDecimal;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
@JsonIgnoreProperties(ignoreUnknown = true)
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class ExpenseInfoDto {
    @JsonProperty(value = "user_id")
    private String userId;

    @JsonProperty(value = "amount_limit")
    private BigDecimal amountLimit;

    @JsonProperty(value = "currency")
    private String currency;

    private ExpenseInfoDto(String json) {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            objectMapper.setPropertyNamingStrategy(PropertyNamingStrategies.SNAKE_CASE);
            ExpenseInfoDto expense = objectMapper.readValue(json, ExpenseInfoDto.class);
            this.amountLimit = expense.amountLimit;
            this.currency = expense.currency;
            this.userId = expense.userId;
        }
        catch (Exception e) {
            throw new RuntimeException("Failed to deserialize ExpenseInfoDto from JSON", e);
        }
    }
}
