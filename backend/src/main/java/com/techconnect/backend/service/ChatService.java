package com.techconnect.backend.service;

import com.techconnect.backend.dto.MatchDto;
import com.techconnect.backend.dto.MessageDto;
import com.techconnect.backend.model.*;
import com.techconnect.backend.repository.MatchRepository;
import com.techconnect.backend.repository.MessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final MatchRepository matchRepository;
    private final MessageRepository messageRepository;

    public List<MatchDto> getMatchesForUser(UUID userId) {
        List<Match> matches = matchRepository.findMatchesByUserId(userId);
        
        return matches.stream()
                .map(match -> {
                    // Fetch the latest message for the lastMessage preview
                    List<Message> history = messageRepository.findByMatchIdOrderBySentAtAsc(match.getId());
                    String lastMessageText = history.isEmpty() 
                            ? "Şimdi eşleştiniz! Merhaba deyin." 
                            : history.get(history.size() - 1).getContent();
                    return MatchDto.fromEntity(match, userId, lastMessageText);
                })
                .collect(Collectors.toList());
    }

    public List<MessageDto> getMessagesForMatch(UUID matchId) {
        return messageRepository.findByMatchIdOrderBySentAtAsc(matchId).stream()
                .map(MessageDto::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional
    public MessageDto sendMessage(UUID senderId, UUID matchId, String content) {
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new RuntimeException("Match not found: " + matchId));

        Message message = Message.builder()
                .id(UUID.randomUUID())
                .match(match)
                .senderId(senderId)
                .content(content)
                .sentAt(LocalDateTime.now())
                .isRead(false)
                .build();

        return MessageDto.fromEntity(messageRepository.save(message));
    }
}
