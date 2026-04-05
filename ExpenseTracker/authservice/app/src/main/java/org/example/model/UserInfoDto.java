package org.example.model;

import lombok.*;
import org.example.entities.UserInfo;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.annotation.JsonNaming;

@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class UserInfoDto extends UserInfo
{
    @NonNull
    private String firstName; // first_name

    @NonNull
    private String lastName; //last_name

    private Long phoneNumber;

    private String email; // email
}

