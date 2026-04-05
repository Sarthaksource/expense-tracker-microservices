package com.example.expenseservice.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;

@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
@JsonIgnoreProperties(ignoreUnknown = true)
public class ExpenseDto {

    private String externalId;

    @JsonProperty(value = "amount")
    @NonNull
    private BigDecimal amount;

    @JsonProperty(value = "user_id")
    private String userId;

    @JsonProperty(value = "merchant")
    private String merchant;

    @JsonProperty(value = "created_at")
    private Instant createdAt;

    public ExpenseDto(String json) {
        try {
            ObjectMapper mapper = new ObjectMapper()
                    .registerModule(new JavaTimeModule())
                    .configure(DeserializationFeature.ADJUST_DATES_TO_CONTEXT_TIME_ZONE, false);
            mapper.setPropertyNamingStrategy(PropertyNamingStrategies.SNAKE_CASE);
            ExpenseDto expense = mapper.readValue(json, ExpenseDto.class);
            this.externalId = expense.externalId;
            this.amount = expense.amount;
            this.userId = expense.userId;
            this.merchant = expense.merchant;
            this.createdAt = expense.createdAt;
        } catch (Exception e) {
            throw new RuntimeException("Failed to deserialize ExpenseDto from JSON", e);
        }
    }
}