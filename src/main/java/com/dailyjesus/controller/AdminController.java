package com.dailyjesus.controller;

import com.dailyjesus.domain.DeliveryEntity;
import com.dailyjesus.domain.UserEntity;
import com.dailyjesus.repo.DeliveryRepository;
import com.dailyjesus.repo.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/admin")
public class AdminController {
    private final UserRepository userRepository;
    private final DeliveryRepository deliveryRepository;

    public AdminController(UserRepository userRepository, DeliveryRepository deliveryRepository) {
        this.userRepository = userRepository;
        this.deliveryRepository = deliveryRepository;
    }

    @GetMapping("/users")
    public ResponseEntity<List<UserEntity>> listAllUsers() {
        return ResponseEntity.ok(userRepository.findAll());
    }

    @GetMapping("/users/active")
    public ResponseEntity<List<UserEntity>> listActiveUsers() {
        return ResponseEntity.ok(userRepository.findByActiveTrue());
    }

    @GetMapping("/users/{userId}/deliveries")
    public ResponseEntity<List<DeliveryEntity>> getUserDeliveries(@PathVariable UUID userId) {
        return ResponseEntity.ok(deliveryRepository.findByUserId(userId));
    }
}
