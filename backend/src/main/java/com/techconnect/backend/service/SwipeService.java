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
        
        DeveloperProfile liked = profileRepository.findById(request.getLikedId())
                .orElseThrow(() -> new RuntimeException("Profile not found: " + request.getLikedId()));

        // Save swipe
        Swipe swipe = Swipe.builder()
                .id(UUID.randomUUID())
                .liker(liker)
                .liked(liked)
                .swipeType(request.getSwipeType())
                .createdAt(LocalDateTime.now())
                .build();
        
        swipeRepository.save(swipe);

        // Check if mutual match exists
        if (request.getSwipeType() == SwipeType.LIKE) {
            Optional<Swipe> oppositeSwipe = swipeRepository.findByLikerIdAndLikedId(liked.getId(), liker.getId());
            
            if (oppositeSwipe.isPresent() && oppositeSwipe.get().getSwipeType() == SwipeType.LIKE) {
                // We have a match!
                Match match = Match.builder()
                        .id(UUID.randomUUID())
                        .profile1(liked) // Profile 1
                        .profile2(liker) // Profile 2
                        .matchedAt(LocalDateTime.now())
                        .build();
                
                matchRepository.save(match);
                
                // Return response with the match info
                MatchDto matchDto = MatchDto.fromEntity(match, currentUserId, "You matched! Say hello.");
                return SwipeResponse.builder()
                        .matched(true)
                        .match(matchDto)
                        .build();
            }
        }

        return SwipeResponse.builder()
                .matched(false)
                .match(null)
                .build();
    }
}
