package com.dailyjesus.repo;

import com.dailyjesus.domain.DailyMessageEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

public interface DailyMessageRepository extends JpaRepository<DailyMessageEntity, UUID> {
    Optional<DailyMessageEntity> findByMessageDate(LocalDate messageDate);
}
