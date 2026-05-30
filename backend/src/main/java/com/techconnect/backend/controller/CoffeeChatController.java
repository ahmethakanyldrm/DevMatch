package com.techconnect.backend.controller;

import com.techconnect.backend.dto.CoffeeChatRequestDto;
import com.techconnect.backend.model.CoffeeChatStatus;
import com.techconnect.backend.service.CoffeeChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.*;

@RestController
@RequestMapping("/api/v1/coffee-chats")
@RequiredArgsConstructor
public class CoffeeChatController {

    private final CoffeeChatService coffeeChatService;

    @PostMapping
    public ResponseEntity<CoffeeChatRequestDto> proposeCoffeeChat(
            @AuthenticationPrincipal UUID userId,
            @RequestBody Map<String, Object> body) {
        UUID matchId = UUID.fromString((String) body.get("matchId"));
        String timeStr = (String) body.get("proposedTime");
        LocalDateTime proposedTime = LocalDateTime.parse(timeStr);
        return ResponseEntity.ok(coffeeChatService.proposeCoffeeChat(userId, matchId, proposedTime));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<CoffeeChatRequestDto> updateStatus(
            @PathVariable UUID id,
            @RequestParam CoffeeChatStatus status) {
        return ResponseEntity.ok(coffeeChatService.updateStatus(id, status));
    }

    @GetMapping("/match/{matchId}")
    public ResponseEntity<List<CoffeeChatRequestDto>> getRequestsForMatch(
            @PathVariable UUID matchId) {
        return ResponseEntity.ok(coffeeChatService.getRequestsForMatch(matchId));
    }
}
