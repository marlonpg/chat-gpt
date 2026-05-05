package com.dailyjesus.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

@Service
public class ClaudeCodeService {
    private static final Logger logger = LoggerFactory.getLogger(ClaudeCodeService.class);
    private static final int TIMEOUT_SECONDS = 60;

    @Value("${app.claude.command:claude}")
    private String command;

    /**
     * Calls Claude Code CLI with the given prompt
     * @param prompt The prompt to send to Claude
     * @return Claude's response text
     */
    public String ask(String prompt) {
        logger.info("Calling Claude Code CLI with prompt (length={})", prompt.length());
        try {
            ProcessBuilder pb = new ProcessBuilder(command, "-p", prompt);
            pb.redirectErrorStream(true);
            pb.redirectInput(new File("NUL")); // Close stdin to prevent hanging
            pb.environment().put("CLAUDE_NO_INTERACTIVE", "1");

            Process process = pb.start();
            ExecutorService executor = Executors.newSingleThreadExecutor();
            Future<String> outputFuture = executor.submit(() -> {
                try (BufferedReader reader = new BufferedReader(
                        new InputStreamReader(process.getInputStream(), StandardCharsets.UTF_8))) {
                    return reader.lines().collect(Collectors.joining("\n"));
                }
            });

            boolean finished = process.waitFor(TIMEOUT_SECONDS, TimeUnit.SECONDS);
            if (!finished) {
                logger.warn("Claude Code CLI call timed out after {} seconds", TIMEOUT_SECONDS);
                process.destroyForcibly();
                executor.shutdownNow();
                throw new RuntimeException("Claude Code call timed out");
            }

            try {
                String output = outputFuture.get(5, TimeUnit.SECONDS).trim();
                int exitCode = process.exitValue();
                if (exitCode != 0) {
                    logger.warn("Claude Code CLI failed with exit code: {}", exitCode);
                    throw new RuntimeException("Claude Code exited with code " + exitCode);
                }
                logger.info("Claude Code returned {} characters", output.length());
                return output;
            } catch (java.util.concurrent.TimeoutException e) {
                logger.warn("Failed to read Claude Code output within 5 seconds");
                throw new RuntimeException("Failed to read Claude response", e);
            } finally {
                executor.shutdownNow();
            }
        } catch (InterruptedException e) {
            logger.warn("Claude Code call was interrupted");
            Thread.currentThread().interrupt();
            throw new RuntimeException("Claude Code call interrupted", e);
        } catch (Exception ex) {
            logger.error("Exception calling Claude Code: {}", ex.getMessage(), ex);
            throw new RuntimeException("Failed to call Claude Code", ex);
        }
    }
}
