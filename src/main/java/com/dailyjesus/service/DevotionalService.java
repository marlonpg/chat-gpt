package com.dailyjesus.service;

import com.dailyjesus.domain.DailyMessageEntity;
import com.dailyjesus.repo.DailyMessageRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import java.time.LocalDate;

@Service
public class DevotionalService {
    private static final Logger logger = LoggerFactory.getLogger(DevotionalService.class);

    private final DailyMessageRepository dailyMessageRepository;
    private final ClaudeCodeService claudeCodeService;

    public DevotionalService(DailyMessageRepository dailyMessageRepository,
                             ClaudeCodeService claudeCodeService) {
        this.dailyMessageRepository = dailyMessageRepository;
        this.claudeCodeService = claudeCodeService;
        logger.info("DevotionalService initialized with Claude Code");
    }

    public DailyMessageEntity getOrCreateToday() {
        logger.info("Checking for devotional for today");
        var existing = dailyMessageRepository.findByMessageDate(LocalDate.now());
        if (existing.isPresent()) {
            logger.info("Found existing devotional for today");
            return existing.get();
        }
        logger.info("Generating new devotional for today");
        return generateForToday();
    }

    public DailyMessageEntity generateNew() {
        logger.info("Generating fresh devotional without cache check");
        return generateForToday();
    }

    private DailyMessageEntity generateForToday() {
        String prompt = "Output a Christian devotional in this exact format, with each field on a new line:\nTOPIC: [topic]\nVERSE_REF: [verse reference]\nVERSE_TEXT: [verse text]\nREFLECTION: [reflection]";
        String output;
        try {
            logger.info("Calling Claude Code to generate devotional");
            output = claudeCodeService.ask(prompt);
        } catch (Exception ex) {
            logger.error("Exception calling Claude Code: {}", ex.getMessage(), ex);
            output = fallback();
        }

        logger.info("Claude Code output:\n{}", output);

        DailyMessageEntity entity = new DailyMessageEntity();
        entity.setMessageDate(LocalDate.now());
        entity.setTopic(extract(output, "TOPIC", "Hope"));
        entity.setBibleReference(extract(output, "VERSE_REF", "Matthew 11:28"));
        entity.setBibleText(extract(output, "VERSE_TEXT", "Come to me, all who are weary and burdened, and I will give you rest."));
        entity.setReflectionText(extract(output, "REFLECTION", "Today, bring your burdens to Jesus. He sees you, loves you, and gives peace."));
        entity.setLlmModel("claude-opus-4-6");
        logger.info("Created devotional: topic='{}', reference='{}'", entity.getTopic(), entity.getBibleReference());
        DailyMessageEntity saved = dailyMessageRepository.save(entity);
        logger.info("Devotional saved to database with id={}", saved.getId());
        return saved;
    }

    private String extract(String raw, String key, String fallback) {
        for (String line : raw.split("\\R")) {
            if (line.toUpperCase().startsWith(key + ":")) {
                String value = line.substring((key + ":").length()).trim();
                logger.info("Extracted {}='{}'", key, value);
                return value;
            }
        }
        logger.info("Field {} not found, using fallback", key);
        return fallback;
    }

    private String fallback() {
        logger.warn("Using fallback devotional content");
        return "TOPIC: Hope\nVERSE_REF: Matthew 11:28\nVERSE_TEXT: Come to me, all who are weary and burdened, and I will give you rest.\nREFLECTION: Today, pause and pray. Jesus welcomes your heart and renews your strength.";
    }
}
