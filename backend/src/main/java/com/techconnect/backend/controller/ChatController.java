package com.techconnect.backend.controller;

import com.techconnect.backend.dto.MatchDto;
import com.techconnect.backend.dto.MessageDto;
import com.techconnect.backend.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/matches")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;

    @GetMapping
    public ResponseEntity<List<MatchDto>> getMyMatches(@AuthenticationPrincipal UUID userId) {
        return ResponseEntity.ok(chatService.getMatchesForUser(userId));
    }

    @GetMapping("/{matchId}/messages")
    public ResponseEntity<List<MessageDto>> getMessagesForMatch(
            @PathVariable UUID matchId) {
        return ResponseEntity.ok(chatService.getMessagesForMatch(matchId));
    }

    @PostMapping("/{matchId}/messages")
    public ResponseEntity<MessageDto> sendMessage(
            @AuthenticationPrincipal UUID userId,
            @PathVariable UUID matchId,
            @RequestBody Map<String, String> body) {
        String content = body.get("content");
        if (content == null || content.trim().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.ok(chatService.sendMessage(userId, matchId, content));
    }
}
