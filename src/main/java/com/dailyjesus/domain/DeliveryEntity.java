package com.dailyjesus.domain;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "deliveries")
public class DeliveryEntity {
    @Id
    private UUID id;
    @ManyToOne(optional = false)
    private UserEntity user;
    @ManyToOne(optional = false)
    private DailyMessageEntity dailyMessage;
    @Column(nullable = false)
    private String status;
    @Column(columnDefinition = "TEXT")
    private String errorMessage;
    private Instant sentAt;
    private Instant createdAt;
    @PrePersist void onCreate(){ id = UUID.randomUUID(); createdAt = Instant.now(); }
    public void setUser(UserEntity user) { this.user = user; }
    public void setDailyMessage(DailyMessageEntity dailyMessage) { this.dailyMessage = dailyMessage; }
    public void setStatus(String status) { this.status = status; }
    public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }
    public void setSentAt(Instant sentAt) { this.sentAt = sentAt; }
}
