package org.example.service;

import lombok.AllArgsConstructor;
import lombok.Data;
import org.example.entities.UserInfo;
import org.example.eventProducer.UserInfoEvent;
import org.example.eventProducer.UserInfoProducer;
import org.example.model.UserInfoDto;
import org.example.repository.UserRepository;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.HashSet;
import java.util.Objects;
import java.util.Optional;
import java.util.UUID;
import java.util.logging.Logger;

@Component
@AllArgsConstructor
@Data
public class UserDetailsServiceImpl implements UserDetailsService
{
    @Autowired
    private final UserRepository userRepository;

    @Autowired
    private final PasswordEncoder passwordEncoder;

    @Autowired
    private final UserInfoProducer userInfoProducer;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException
    {

        UserInfo user = userRepository.findByEmail(email);
        if(user == null){
//            log.error("Username not found: " + username);
            throw new UsernameNotFoundException("could not found user..!!");
        }
//        log.info("User Authenticated Successfully..!!!");
        return new CustomUserDetails(user);
    }

    public UserInfo checkIfUserAlreadyExist(UserInfoDto userInfoDto){
        return userRepository.findByEmail(userInfoDto.getEmail());
    }

    public String signupUser(UserInfoDto userInfoDto){
        if(Objects.nonNull(checkIfUserAlreadyExist(userInfoDto))){
            return null;
        }
        String userId = UUID.randomUUID().toString();
        String encodedPassword = passwordEncoder.encode(userInfoDto.getPassword());
        userRepository.save(new UserInfo(userId, userInfoDto.getEmail(), encodedPassword, new HashSet<>()));
        userInfoProducer.sendEventToKafka(userInfoEventToPublish(userInfoDto, userId));
        return userId;
    }

    public String getUserByEmail(String email){
        return Optional.ofNullable(userRepository.findByEmail(email)).map(UserInfo::getUserId).orElse(null);
    }

    private UserInfoEvent userInfoEventToPublish(UserInfoDto userInfoDto, String userId){
        return UserInfoEvent.builder()
                .userId(userId)
                .firstName(userInfoDto.getFirstName())
                .lastName(userInfoDto.getLastName())
                .email(userInfoDto.getEmail())
                .build();
    }
}
