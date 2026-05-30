package com.techconnect.backend.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.techconnect.backend.model.DeveloperProfile;
import com.techconnect.backend.model.SubscriptionTier;
import com.techconnect.backend.repository.ProfileRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/v1/webhooks/revenuecat")
@RequiredArgsConstructor
@Slf4j
public class RevenueCatWebhookController {

    private final ProfileRepository profileRepository;
    private final ObjectMapper objectMapper;

    @Value("${revenuecat.webhook.secret:test_webhook_secret}")
    private String webhookSecret;

    @PostMapping
    public ResponseEntity<String> handleWebhook(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestBody String requestBody) {
        
        // Verify signature / authorization token
        if (authHeader == null || !authHeader.equals(webhookSecret)) {
            log.warn("Unauthorized RevenueCat webhook attempt. Header: {}", authHeader);
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid shared secret");
        }

        try {
            JsonNode root = objectMapper.readTree(requestBody);
            JsonNode event = root.get("event");
            if (event == null) {
                return ResponseEntity.badRequest().body("Missing event object");
            }

            String eventType = event.get("type").asText();
            String appUserId = event.get("app_user_id").asText();
            
            log.info("Received RevenueCat webhook. Type: {}, AppUserId: {}", eventType, appUserId);

            UUID userId;
            try {
                userId = UUID.fromString(appUserId);
            } catch (IllegalArgumentException e) {
                log.error("Invalid app_user_id UUID format: {}", appUserId);
                return ResponseEntity.badRequest().body("Invalid UUID format");
            }

            Optional<DeveloperProfile> profileOpt = profileRepository.findById(userId);
            if (profileOpt.isEmpty()) {
                log.warn("User profile not found for UUID: {}", userId);
                return ResponseEntity.notFound().build();
            }

            DeveloperProfile profile = profileOpt.get();
            
            // Check if entitlement list contains "pro"
            boolean hasProEntitlement = false;
            JsonNode entitlementIds = event.get("entitlement_ids");
            if (entitlementIds != null && entitlementIds.isArray()) {
                for (JsonNode ent : entitlementIds) {
                    if ("pro".equalsIgnoreCase(ent.asText())) {
                        hasProEntitlement = true;
                        break;
                    }
                }
            }

            if (hasProEntitlement) {
                if ("EXPIRATION".equalsIgnoreCase(eventType) || "CANCELLATION".equalsIgnoreCase(eventType)) {
                    profile.setSubscriptionTier(SubscriptionTier.FREE);
                    log.info("Setting subscription to FREE for user: {} due to {}", userId, eventType);
                } else {
                    profile.setSubscriptionTier(SubscriptionTier.PRO);
                    log.info("Setting subscription to PRO for user: {} due to {}", userId, eventType);
                }
                profileRepository.save(profile);
            }

            return ResponseEntity.ok("Webhook processed successfully");

        } catch (Exception e) {
            log.error("Error processing RevenueCat webhook: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error processing event");
        }
    }
}
