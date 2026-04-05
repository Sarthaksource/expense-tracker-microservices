package org.example.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;
import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import java.util.HashSet;
import java.util.Set;

@Entity
@Data
@ToString
@NoArgsConstructor
@AllArgsConstructor
@Table(name="users")
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class UserInfo {
    @Id
    @Column(name = "user_id")
    private String userId;
    private String username;
    private String password;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "users_roles",
            joinColumns = @JoinColumn(name = "user_id"),
            inverseJoinColumns = @JoinColumn(name = "role_id")
    )
    private Set<UserRole> roles = new HashSet<>();
}
