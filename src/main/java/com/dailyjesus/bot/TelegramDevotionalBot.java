package com.dailyjesus.bot;

import com.dailyjesus.domain.UserEntity;
import com.dailyjesus.repo.UserRepository;
import com.dailyjesus.service.DevotionalService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.telegram.telegrambots.longpolling.starter.SpringLongPollingBot;
import org.telegram.telegrambots.meta.api.methods.send.SendMessage;
import org.telegram.telegrambots.meta.api.objects.Message;
import org.telegram.telegrambots.meta.api.objects.Update;
import org.telegram.telegrambots.meta.exceptions.TelegramApiException;
import org.telegram.telegrambots.meta.generics.TelegramClient;

@Component
public class TelegramDevotionalBot implements SpringLongPollingBot {
    private final String token;
    private final UserRepository userRepository;
    private final DevotionalService devotionalService;

    public TelegramDevotionalBot(@Value("${telegram.bot.token}") String token,
                                 UserRepository userRepository,
                                 DevotionalService devotionalService) {
        this.token = token;
        this.userRepository = userRepository;
        this.devotionalService = devotionalService;
    }

    @Override
    public String getBotToken() { return token; }

    @Override
    public void consume(Update update) {
        if (!update.hasMessage() || !update.getMessage().hasText()) return;
        Message msg = update.getMessage();
        String text = msg.getText().trim();
        if ("/start".equalsIgnoreCase(text)) {
            UserEntity user = userRepository.findByTelegramChatId(msg.getChatId()).orElseGet(UserEntity::new);
            user.setTelegramChatId(msg.getChatId()); user.setFirstName(msg.getFrom().getFirstName()); user.setUsername(msg.getFrom().getUserName()); user.setActive(true);
            userRepository.save(user);
            send(msg.getChatId(), "Welcome! You are subscribed to daily Jesus devotionals.");
        } else if ("/stop".equalsIgnoreCase(text)) {
            userRepository.findByTelegramChatId(msg.getChatId()).ifPresent(u -> { u.setActive(false); userRepository.save(u); });
            send(msg.getChatId(), "You are unsubscribed. Send /start anytime to subscribe again.");
        } else if ("/test".equalsIgnoreCase(text)) {
            var d = devotionalService.getOrCreateToday();
            send(msg.getChatId(), "📖 " + d.getBibleReference() + "\n" + d.getBibleText() + "\n\n" + d.getReflectionText());
        }
    }

    public void send(Long chatId, String text) {
        SendMessage send = SendMessage.builder().chatId(chatId).text(text).build();
        TelegramClient client = getTelegramClient();
        try { client.execute(send); } catch (TelegramApiException ignored) {}
    }
}
