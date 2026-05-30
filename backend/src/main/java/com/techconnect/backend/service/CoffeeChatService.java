package com.techconnect.backend.service;

import com.techconnect.backend.dto.CoffeeChatRequestDto;
import com.techconnect.backend.model.*;
import com.techconnect.backend.repository.CoffeeChatRepository;
import com.techconnect.backend.repository.MatchRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CoffeeChatService {

    private final CoffeeChatRepository coffeeChatRepository;
    private final MatchRepository matchRepository;

    @Transactional
    public CoffeeChatRequestDto proposeCoffeeChat(UUID currentUserId, UUID matchId, LocalDateTime proposedTime) {
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new RuntimeException("Match not found: " + matchId));

        CoffeeChatRequest request = CoffeeChatRequest.builder()
                .id(UUID.randomUUID())
                .match(match)
                .requesterId(currentUserId)
                .proposedTime(proposedTime)
                .status(CoffeeChatStatus.PENDING)
                .build();

        return CoffeeChatRequestDto.fromEntity(coffeeChatRepository.save(request));
    }

    @Transactional
    public CoffeeChatRequestDto updateStatus(UUID id, CoffeeChatStatus status) {
        CoffeeChatRequest request = coffeeChatRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Coffee chat request not found: " + id));

        request.setStatus(status);
        return CoffeeChatRequestDto.fromEntity(coffeeChatRepository.save(request));
    }

    public List<CoffeeChatRequestDto> getRequestsForMatch(UUID matchId) {
        return coffeeChatRepository.findByMatchId(matchId).stream()
                .map(CoffeeChatRequestDto::fromEntity)
                .collect(Collectors.toList());
    }
}
