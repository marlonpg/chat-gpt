package com.dailyjesus.repo;

import com.dailyjesus.domain.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<UserEntity, UUID> {
    Optional<UserEntity> findByTelegramChatId(Long chatId);
    List<UserEntity> findByActiveTrue();
}
