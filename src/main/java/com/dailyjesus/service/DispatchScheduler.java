package com.dailyjesus.service;

import com.dailyjesus.bot.TelegramDevotionalBot;
import com.dailyjesus.domain.DeliveryEntity;
import com.dailyjesus.repo.DeliveryRepository;
import com.dailyjesus.repo.UserRepository;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.Instant;

@Component
public class DispatchScheduler {
    private final UserRepository userRepository;
    private final DeliveryRepository deliveryRepository;
    private final DevotionalService devotionalService;
    private final TelegramDevotionalBot bot;

    public DispatchScheduler(UserRepository userRepository, DeliveryRepository deliveryRepository, DevotionalService devotionalService, TelegramDevotionalBot bot) {
        this.userRepository = userRepository;
        this.deliveryRepository = deliveryRepository;
        this.devotionalService = devotionalService;
        this.bot = bot;
    }

    @Scheduled(cron = "0 0 12 * * *", zone = "UTC")
    public void dispatchDaily() {
        var msg = devotionalService.getOrCreateToday();
        var text = "📖 " + msg.getBibleReference() + "\n" + msg.getBibleText() + "\n\n" + msg.getReflectionText();
        userRepository.findByActiveTrue().forEach(user -> {
            DeliveryEntity d = new DeliveryEntity();
            d.setUser(user); d.setDailyMessage(msg);
            try { bot.send(user.getTelegramChatId(), text); d.setStatus("SENT"); d.setSentAt(Instant.now()); }
            catch (Exception ex) { d.setStatus("FAILED"); d.setErrorMessage(ex.getMessage()); }
            deliveryRepository.save(d);
        });
    }
}
