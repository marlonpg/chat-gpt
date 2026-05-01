package com.dailyjesus;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class DailyDevotionalApplication {
    public static void main(String[] args) {
        SpringApplication.run(DailyDevotionalApplication.class, args);
    }
}
