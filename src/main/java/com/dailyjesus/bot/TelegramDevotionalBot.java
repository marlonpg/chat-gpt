package com.dailyjesus.bot;

import com.dailyjesus.domain.UserEntity;
import com.dailyjesus.repo.UserRepository;
import com.dailyjesus.service.DevotionalService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.telegram.telegrambots.client.okhttp.OkHttpTelegramClient;
import org.telegram.telegrambots.longpolling.interfaces.LongPollingUpdateConsumer;
import org.telegram.telegrambots.longpolling.starter.SpringLongPollingBot;
import org.telegram.telegrambots.longpolling.util.LongPollingSingleThreadUpdateConsumer;
import org.telegram.telegrambots.meta.api.methods.send.SendMessage;
import org.telegram.telegrambots.meta.api.objects.Update;
import org.telegram.telegrambots.meta.exceptions.TelegramApiException;
import org.telegram.telegrambots.meta.generics.TelegramClient;

@Component
public class TelegramDevotionalBot implements SpringLongPollingBot, LongPollingSingleThreadUpdateConsumer {
    private static final Logger logger = LoggerFactory.getLogger(TelegramDevotionalBot.class);

    private final String token;
    private final TelegramClient telegramClient;
    private final UserRepository userRepository;
    private final DevotionalService devotionalService;

    public TelegramDevotionalBot(@Value("${telegram.bot.token}") String token,
                                 UserRepository userRepository,
                                 DevotionalService devotionalService) {
        this.token = token;
        this.telegramClient = new OkHttpTelegramClient(token);
        this.userRepository = userRepository;
        this.devotionalService = devotionalService;
        logger.info("TelegramDevotionalBot initialized");
    }

    @Override
    public String getBotToken() { return token; }

    @Override
    public LongPollingUpdateConsumer getUpdatesConsumer() {
        return this;
    }

    @Override
    public void consume(Update update) {
        if (!update.hasMessage() || !update.getMessage().hasText()) return;
        var msg = update.getMessage();
        String text = msg.getText().trim();
        Long chatId = msg.getChatId();
        String username = msg.getFrom().getUserName();

        logger.info("Received message from chat {} (@{}): {}", chatId, username, text);

        if ("/start".equalsIgnoreCase(text)) {
            logger.info("User /start command: chatId={}, username={}, firstName={}",
                chatId, username, msg.getFrom().getFirstName());
            UserEntity user = userRepository.findByTelegramChatId(chatId).orElseGet(UserEntity::new);
            user.setTelegramChatId(chatId);
            user.setFirstName(msg.getFrom().getFirstName());
            user.setUsername(username);
            user.setActive(true);
            userRepository.save(user);
            logger.info("User subscribed: chatId={}", chatId);
            send(chatId, "Welcome! You are subscribed to daily Jesus devotionals.");
        } else if ("/stop".equalsIgnoreCase(text)) {
            logger.info("User /stop command: chatId={}, username={}", chatId, username);
            userRepository.findByTelegramChatId(chatId).ifPresent(u -> {
                u.setActive(false);
                userRepository.save(u);
                logger.info("User unsubscribed: chatId={}", chatId);
            });
            send(chatId, "You are unsubscribed. Send /start anytime to subscribe again.");
        } else if ("#word".equalsIgnoreCase(text) || "#grace".equalsIgnoreCase(text) || "#daily".equalsIgnoreCase(text)) {
            logger.info("User hashtag command: chatId={}, username={}, command={}", chatId, username, text);
            var user = userRepository.findByTelegramChatId(chatId);
            if (user.isEmpty() || !user.get().isActive()) {
                logger.warn("User not subscribed: chatId={}, username={}", chatId, username);
                send(chatId, "You are not subscribed. Send /start to subscribe to daily devotionals.");
            } else {
                var d = devotionalService.getOrCreateToday();
                send(chatId, "📖 " + d.getBibleReference() + "\n" + d.getBibleText() + "\n\n" + d.getReflectionText());
                logger.info("Devotional sent to chatId={}", chatId);
            }
        } else if ("#new-grace".equalsIgnoreCase(text)) {
            logger.info("User #new-grace command: chatId={}, username={}", chatId, username);
            var user = userRepository.findByTelegramChatId(chatId);
            if (user.isEmpty() || !user.get().isActive()) {
                logger.warn("User not subscribed: chatId={}, username={}", chatId, username);
                send(chatId, "You are not subscribed. Send /start to subscribe to daily devotionals.");
            } else {
                var d = devotionalService.generateNew();
                send(chatId, "📖 " + d.getBibleReference() + "\n" + d.getBibleText() + "\n\n" + d.getReflectionText());
                logger.info("Fresh devotional sent to chatId={}", chatId);
            }
        } else {
            logger.info("User sent unknown message: chatId={}, username={}, text={}", chatId, username, text);
            String helpMessage = "I didn't understand that command. Here are the available commands:\n\n"
                    + "#word - Get today's devotional\n"
                    + "#grace - Get today's devotional\n"
                    + "#daily - Get today's devotional\n"
                    + "#new-grace - Get a fresh devotional\n"
                    + "/start - Subscribe to daily devotionals\n"
                    + "/stop - Unsubscribe from devotionals";
            send(chatId, helpMessage);
        }
    }

    public void send(Long chatId, String text) {
        SendMessage send = SendMessage.builder().chatId(chatId).text(text).build();
        try {
            telegramClient.execute(send);
            logger.info("Message sent to chatId={}, length={}", chatId, text.length());
        } catch (TelegramApiException e) {
            logger.error("Failed to send message to chatId={}: {}", chatId, e.getMessage(), e);
        }
    }
}
