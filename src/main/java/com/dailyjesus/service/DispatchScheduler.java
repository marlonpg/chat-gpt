package com.dailyjesus.service;

import com.dailyjesus.bot.TelegramDevotionalBot;
import com.dailyjesus.domain.DeliveryEntity;
import com.dailyjesus.repo.DeliveryRepository;
import com.dailyjesus.repo.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.Instant;

@Component
public class DispatchScheduler {
    private static final Logger logger = LoggerFactory.getLogger(DispatchScheduler.class);

    private final UserRepository userRepository;
    private final DeliveryRepository deliveryRepository;
    private final DevotionalService devotionalService;
    private final TelegramDevotionalBot bot;

    public DispatchScheduler(UserRepository userRepository, DeliveryRepository deliveryRepository, DevotionalService devotionalService, TelegramDevotionalBot bot) {
        this.userRepository = userRepository;
        this.deliveryRepository = deliveryRepository;
        this.devotionalService = devotionalService;
        this.bot = bot;
        logger.info("DispatchScheduler initialized - daily dispatch at 12:00 UTC");
    }

    @Scheduled(cron = "0 0 12 * * *", zone = "UTC")
    public void dispatchDaily() {
        logger.info("Starting daily devotional dispatch");
        long startTime = System.currentTimeMillis();
        try {
            var msg = devotionalService.getOrCreateToday();
            var text = "📖 " + msg.getBibleReference() + "\n" + msg.getBibleText() + "\n\n" + msg.getReflectionText();
            var activeUsers = userRepository.findByActiveTrue();
            logger.info("Dispatching devotional to {} active users", activeUsers.size());

            int sent = 0, failed = 0;
            for (var user : activeUsers) {
                DeliveryEntity d = new DeliveryEntity();
                d.setUser(user);
                d.setDailyMessage(msg);
                try {
                    bot.send(user.getTelegramChatId(), text);
                    d.setStatus("SENT");
                    d.setSentAt(Instant.now());
                    sent++;
                    logger.info("Devotional sent to user chatId={}", user.getTelegramChatId());
                } catch (Exception ex) {
                    d.setStatus("FAILED");
                    d.setErrorMessage(ex.getMessage());
                    failed++;
                    logger.warn("Failed to send devotional to user chatId={}: {}", user.getTelegramChatId(), ex.getMessage());
                }
                deliveryRepository.save(d);
            }
            long duration = System.currentTimeMillis() - startTime;
            logger.info("Daily dispatch completed: sent={}, failed={}, duration={}ms", sent, failed, duration);
        } catch (Exception ex) {
            logger.error("Error during daily dispatch", ex);
        }
    }
}
