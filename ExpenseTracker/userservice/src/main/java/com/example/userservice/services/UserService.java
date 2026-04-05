package com.example.userservice.services;

import com.example.userservice.entities.UserInfo;
import com.example.userservice.entities.UserInfoDto;
import com.example.userservice.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;
import java.util.function.Supplier;
import java.util.function.UnaryOperator;

@Service
@RequiredArgsConstructor
public class UserService
{
    @Autowired
    private final UserRepository userRepository;

    public UserInfoDto createOrUpdateUser(UserInfoDto userInfoDto){
        UnaryOperator<UserInfo> updatingUser = user -> {
            user.setFirstName(userInfoDto.getFirstName());
            user.setLastName(userInfoDto.getLastName());
            user.setPhoneNumber(userInfoDto.getPhoneNumber());
            user.setEmail(userInfoDto.getEmail());
            user.setProfilePicture(userInfoDto.getProfilePicture());

            return userRepository.save(user);
        };

        Supplier<UserInfo> createUser = () -> {
            return userRepository.save(userInfoDto.transformToUserInfo());
        };

        UserInfo userInfo = userRepository.findByUserId(userInfoDto.getUserId())
                .map(updatingUser)
                .orElseGet(createUser);

        return new UserInfoDto(
                userInfo.getUserId(),
                userInfo.getFirstName(),
                userInfo.getLastName(),
                userInfo.getPhoneNumber(),
                userInfo.getEmail(),
                userInfo.getProfilePicture()
        );
    }

    public UserInfoDto getUser(UserInfoDto userInfoDto) throws Exception{
        Optional<UserInfo> userInfoDtoOpt = userRepository.findByUserId(userInfoDto.getUserId());
        if(userInfoDtoOpt.isEmpty()){
            throw new Exception("User not found");
        }
        UserInfo userInfo = userInfoDtoOpt.get();
        return new UserInfoDto(
                userInfo.getUserId(),
                userInfo.getFirstName(),
                userInfo.getLastName(),
                userInfo.getPhoneNumber(),
                userInfo.getEmail(),
                userInfo.getProfilePicture()
        );
    }

}