package com.example.userservice.consumer;

import com.example.userservice.entities.UserInfo;
import com.example.userservice.entities.UserInfoDto;
import com.example.userservice.repository.UserRepository;
import com.example.userservice.services.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
public class AuthServiceConsumer {
    @Autowired
    private UserService userService;

//    @KafkaListener(topics = "${spring.kafka.topic-json.name}", groupId = "${spring.kafka.consumer.group-id}")
    @KafkaListener(topics = "${spring.kafka.topic-json.name}", groupId = "${spring.kafka.consumer.group-id}")
    public void listen(UserInfoDto userInfoDto)
    {
        try
        {
            userService.createOrUpdateUser(userInfoDto);
        }
        catch (Exception e)
        {
            e.printStackTrace();
            System.out.println("AuthServiceConsumer: Exception is thrown while consuming kafka event");
        }
    }
}

