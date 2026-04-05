package org.example.eventProducer;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.annotation.JsonNaming;

@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
@Getter
@Setter
@Builder
@JsonIgnoreProperties(ignoreUnknown = true)
public class UserInfoEvent
{

    private String firstName;

    private String lastName;

    private String email;

    private Long phoneNumber;

    private String userId;

}