package com.dailyjesus.service;

import com.dailyjesus.domain.DailyMessageEntity;
import com.dailyjesus.repo.DailyMessageRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.time.LocalDate;
import java.util.List;

@Service
public class DevotionalService {
    private final DailyMessageRepository dailyMessageRepository;
    private final String model;

    public DevotionalService(DailyMessageRepository dailyMessageRepository,
                             @Value("${app.llm.model:openai/gpt-4o-mini}") String model) {
        this.dailyMessageRepository = dailyMessageRepository;
        this.model = model;
    }

    public DailyMessageEntity getOrCreateToday() {
        return dailyMessageRepository.findByMessageDate(LocalDate.now()).orElseGet(this::generateForToday);
    }

    private DailyMessageEntity generateForToday() {
        String prompt = "Create one short Christian devotional with fields: TOPIC, VERSE_REF, VERSE_TEXT, REFLECTION.";
        String output;
        try {
            ProcessBuilder pb = new ProcessBuilder(List.of("gh", "models", "run", "--max-tokens", "220", model, prompt));
            pb.redirectErrorStream(true);
            pb.environment().put("GH_PROMPT_DISABLED", "1");
            Process process = pb.start();
            if (!process.waitFor(40, java.util.concurrent.TimeUnit.SECONDS) || process.exitValue() != 0) {
                output = fallback();
            } else {
                try (BufferedReader br = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                    output = br.lines().reduce("", (a,b) -> a + "\n" + b).trim();
                }
            }
        } catch (Exception ex) {
            output = fallback();
        }

        DailyMessageEntity entity = new DailyMessageEntity();
        entity.setMessageDate(LocalDate.now());
        entity.setTopic(extract(output, "TOPIC", "Hope"));
        entity.setBibleReference(extract(output, "VERSE_REF", "Matthew 11:28"));
        entity.setBibleText(extract(output, "VERSE_TEXT", "Come to me, all who are weary and burdened, and I will give you rest."));
        entity.setReflectionText(extract(output, "REFLECTION", "Today, bring your burdens to Jesus. He sees you, loves you, and gives peace."));
        entity.setLlmModel(model);
        return dailyMessageRepository.save(entity);
    }

    private String extract(String raw, String key, String fallback) {
        for (String line : raw.split("\\R")) {
            if (line.toUpperCase().startsWith(key + ":")) return line.substring((key + ":").length()).trim();
        }
        return fallback;
    }

    private String fallback() {
        return "TOPIC: Hope\nVERSE_REF: Matthew 11:28\nVERSE_TEXT: Come to me, all who are weary and burdened, and I will give you rest.\nREFLECTION: Today, pause and pray. Jesus welcomes your heart and renews your strength.";
    }
}
