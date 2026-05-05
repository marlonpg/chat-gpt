package com.dailyjesus.controller;

import com.dailyjesus.service.ClaudeCodeService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/claude")
public class ClaudeCodeController {
    private final ClaudeCodeService claudeCodeService;

    public ClaudeCodeController(ClaudeCodeService claudeCodeService) {
        this.claudeCodeService = claudeCodeService;
    }

    @PostMapping("/ask")
    public ResponseEntity<String> ask(@RequestBody AskRequest request) {
        try {
            String response = claudeCodeService.ask(request.getPrompt());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error: " + e.getMessage());
        }
    }

    public static class AskRequest {
        private String prompt;

        public String getPrompt() {
            return prompt;
        }

        public void setPrompt(String prompt) {
            this.prompt = prompt;
        }
    }
}
