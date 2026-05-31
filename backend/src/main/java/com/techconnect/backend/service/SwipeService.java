package com.techconnect.backend.service;

import com.techconnect.backend.dto.MatchDto;
import com.techconnect.backend.dto.SwipeRequest;
import com.techconnect.backend.dto.SwipeResponse;
import com.techconnect.backend.model.*;
import com.techconnect.backend.repository.MatchRepository;
import com.techconnect.backend.repository.ProfileRepository;
import com.techconnect.backend.repository.SwipeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
public class SwipeService {

    private final SwipeRepository swipeRepository;
    private final ProfileRepository profileRepository;
    private final MatchRepository matchRepository;

    @Transactional
    public SwipeResponse swipe(UUID currentUserId, SwipeRequest request) {
        DeveloperProfile liker = profileRepository.findById(currentUserId)
                .orElseThrow(() -> new RuntimeException("Profile not found: " + currentUserId));

        DeveloperProfile liked = profileRepository.findById(request.getTargetUserId())
                .orElseThrow(() -> new RuntimeException("Profile not found: " + request.getTargetUserId()));

        // Limit free users to 10 likes per 24 hours
        if (request.getSwipeType() == SwipeType.LIKE && liker.getSubscriptionTier() == SubscriptionTier.FREE) {
            java.time.LocalDateTime oneDayAgo = java.time.LocalDateTime.now().minusDays(1);
            long recentLikes = swipeRepository.countByLikerIdAndSwipeTypeAndCreatedAtAfter(liker.getId(), SwipeType.LIKE, oneDayAgo);
            if (recentLikes >= 10) {
                throw new org.springframework.web.server.ResponseStatusException(
                        org.springframework.http.HttpStatus.PAYMENT_REQUIRED, "like_limit_exceeded");
            }
        }

        // If this swipe already exists, update it (upsert behaviour)
        Optional<Swipe> existingSwipe = swipeRepository.findByLikerIdAndLikedId(liker.getId(), liked.getId());
        Swipe swipe;
        if (existingSwipe.isPresent()) {
            swipe = existingSwipe.get();
            swipe.setSwipeType(request.getSwipeType());
            swipeRepository.save(swipe);
        } else {
            swipe = Swipe.builder()
                    .id(UUID.randomUUID())
                    .liker(liker)
                    .liked(liked)
                    .swipeType(request.getSwipeType())
                    .createdAt(LocalDateTime.now())
                    .build();
            swipeRepository.save(swipe);
        }

        // Check for mutual match only when the current swipe is LIKE
        if (request.getSwipeType() == SwipeType.LIKE) {
            Optional<Swipe> oppositeSwipe = swipeRepository.findByLikerIdAndLikedId(liked.getId(), liker.getId());

            if (oppositeSwipe.isPresent() && oppositeSwipe.get().getSwipeType() == SwipeType.LIKE) {
                // Check if a match record already exists for this pair
                boolean matchExists = matchRepository
                        .findMatchBetween(liker.getId(), liked.getId())
                        .isPresent();

                if (!matchExists) {
                    Match match = Match.builder()
                            .id(UUID.randomUUID())
                            .profile1(liked)
                            .profile2(liker)
                            .matchedAt(LocalDateTime.now())
                            .build();
                    matchRepository.save(match);

                    MatchDto matchDto = MatchDto.fromEntity(match, currentUserId, "You matched! Say hello.");
                    return SwipeResponse.builder()
                            .matched(true)
                            .match(matchDto)
                            .build();
                }

                // Match already existed — still inform the caller
                return SwipeResponse.builder()
                        .matched(true)
                        .match(null)
                        .build();
            }
        }

        return SwipeResponse.builder()
                .matched(false)
                .match(null)
                .build();
    }
}
