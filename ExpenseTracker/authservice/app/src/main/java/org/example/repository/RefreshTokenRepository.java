package org.example.repository;

import org.example.entities.RefreshToken;
import org.example.entities.UserInfo;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import java.sql.Ref;
import java.util.Optional;
import java.util.OptionalInt;

@Repository
public interface RefreshTokenRepository extends CrudRepository<RefreshToken, Integer> {
    Optional<RefreshToken> findByToken(String token);

    Optional<RefreshToken> findByUserInfo(UserInfo userInfo);
}
