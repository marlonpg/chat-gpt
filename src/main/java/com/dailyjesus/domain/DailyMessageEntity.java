package com.dailyjesus.domain;

import jakarta.persistence.*;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "daily_messages")
public class DailyMessageEntity {
    @Id
    private UUID id;
    @Column(nullable = false, unique = true)
    private LocalDate messageDate;
    private String topic;
    @Column(nullable = false)
    private String bibleReference;
    @Column(nullable = false, columnDefinition = "TEXT")
    private String bibleText;
    @Column(nullable = false, columnDefinition = "TEXT")
    private String reflectionText;
    private String llmModel;
    private Instant createdAt;
    @PrePersist void onCreate() { id = UUID.randomUUID(); createdAt = Instant.now(); }
    public UUID getId() { return id; }
    public LocalDate getMessageDate() { return messageDate; }
    public void setMessageDate(LocalDate messageDate) { this.messageDate = messageDate; }
    public String getTopic() { return topic; }
    public void setTopic(String topic) { this.topic = topic; }
    public String getBibleReference() { return bibleReference; }
    public void setBibleReference(String bibleReference) { this.bibleReference = bibleReference; }
    public String getBibleText() { return bibleText; }
    public void setBibleText(String bibleText) { this.bibleText = bibleText; }
    public String getReflectionText() { return reflectionText; }
    public void setReflectionText(String reflectionText) { this.reflectionText = reflectionText; }
    public String getLlmModel() { return llmModel; }
    public void setLlmModel(String llmModel) { this.llmModel = llmModel; }
}
