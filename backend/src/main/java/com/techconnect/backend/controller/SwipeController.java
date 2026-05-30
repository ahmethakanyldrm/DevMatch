package com.techconnect.backend.controller;

import com.techconnect.backend.dto.SwipeRequest;
import com.techconnect.backend.dto.SwipeResponse;
import com.techconnect.backend.service.SwipeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/swipes")
@RequiredArgsConstructor
public class SwipeController {

    private final SwipeService swipeService;

    @PostMapping
    public ResponseEntity<SwipeResponse> swipe(
            @AuthenticationPrincipal UUID userId,
            @RequestBody SwipeRequest request) {
        return ResponseEntity.ok(swipeService.swipe(userId, request));
    }
}
