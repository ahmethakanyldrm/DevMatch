package com.techconnect.backend.controller;

import com.techconnect.backend.dto.DeveloperProfileDto;
import com.techconnect.backend.service.ProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/profiles")
@RequiredArgsConstructor
public class ProfileController {

    private final ProfileService profileService;

    @GetMapping("/me")
    public ResponseEntity<DeveloperProfileDto> getMyProfile(@AuthenticationPrincipal UUID userId) {
        return ResponseEntity.ok(profileService.getProfileById(userId));
    }

    @PutMapping("/me")
    public ResponseEntity<DeveloperProfileDto> updateMyProfile(
            @AuthenticationPrincipal UUID userId,
            @RequestBody DeveloperProfileDto dto) {
        return ResponseEntity.ok(profileService.updateProfile(userId, dto));
    }

    @GetMapping("/discover")
    public ResponseEntity<List<DeveloperProfileDto>> getDiscoverDeck(@AuthenticationPrincipal UUID userId) {
        return ResponseEntity.ok(profileService.getDiscoverableProfiles(userId));
    }
}
