package com.dailyjesus.repo;

import com.dailyjesus.domain.DeliveryEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface DeliveryRepository extends JpaRepository<DeliveryEntity, UUID> {
    List<DeliveryEntity> findByUserId(UUID userId);
}
