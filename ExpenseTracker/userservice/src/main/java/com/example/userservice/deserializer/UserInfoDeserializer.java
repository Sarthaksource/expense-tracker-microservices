package com.example.userservice.deserializer;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.kafka.common.serialization.Deserializer;
import com.example.userservice.entities.UserInfoDto;

public class UserInfoDeserializer implements Deserializer<UserInfoDto> {
    @Override
    public UserInfoDto deserialize(String arg0, byte[] arg1) {
        ObjectMapper objectMapper = new ObjectMapper();
        UserInfoDto userInfoDto = null;
        try {
            userInfoDto = objectMapper.readValue(arg1, UserInfoDto.class);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return userInfoDto;
    }
}