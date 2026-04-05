package com.example.userservice.repository;

import com.example.userservice.entities.UserInfo;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;
import com.example.userservice.entities.UserInfoDto;

import javax.swing.text.html.Option;
import java.util.Optional;

@Repository
public interface UserRepository extends CrudRepository<UserInfo, String> {
    Optional<UserInfo> findByUserId(String userId);
}
