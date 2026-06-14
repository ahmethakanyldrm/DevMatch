package com.techconnect.backend.service;

import com.techconnect.backend.dto.MatchDto;
import com.techconnect.backend.dto.MessageDto;
import com.techconnect.backend.model.*;
import com.techconnect.backend.repository.MatchRepository;
import com.techconnect.backend.repository.MessageRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.*;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("ChatService Tests")
class ChatServiceTest {

    @Mock
    private MatchRepository matchRepository;

    @Mock
    private MessageRepository messageRepository;

    @InjectMocks
    private ChatService chatService;

    private DeveloperProfile userA;
    private DeveloperProfile userB;
    private Match match;
    private final UUID userAId  = UUID.randomUUID();
    private final UUID userBId  = UUID.randomUUID();
    private final UUID matchId  = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        userA = DeveloperProfile.builder()
                .id(userAId).displayName("UserA").email("a@test.com")
                .role("Dev").experienceYears(3).sector(Sector.STARTUP)
                .lookingFor(LookingFor.COLLABORATION).isRemote(true)
                .subscriptionTier(SubscriptionTier.FREE)
                .gender(Gender.MALE).preferredGender(PreferredGender.EVERYONE)
                .build();

        userB = DeveloperProfile.builder()
                .id(userBId).displayName("UserB").email("b@test.com")
                .role("Dev").experienceYears(2).sector(Sector.STARTUP)
                .lookingFor(LookingFor.COLLABORATION).isRemote(true)
                .subscriptionTier(SubscriptionTier.FREE)
                .gender(Gender.FEMALE).preferredGender(PreferredGender.EVERYONE)
                .build();

        match = Match.builder()
                .id(matchId)
                .profile1(userA)
                .profile2(userB)
                .matchedAt(LocalDateTime.now())
                .build();
    }

    // ─── GET MATCHES ─────────────────────────────────────────────────────────

    @Test
    @DisplayName("Kullanıcının match listesini getir → MatchDto listesi dönmeli")
    void getMatchesForUser_returnsMatchList() {
        when(matchRepository.findMatchesByUserId(userAId)).thenReturn(List.of(match));

        Message lastMsg = Message.builder()
                .id(UUID.randomUUID()).match(match)
                .senderId(userBId).content("Merhaba!")
                .sentAt(LocalDateTime.now()).isRead(false)
                .build();
        when(messageRepository.findByMatchIdOrderBySentAtAsc(matchId)).thenReturn(List.of(lastMsg));

        List<MatchDto> result = chatService.getMatchesForUser(userAId);

        assertThat(result).hasSize(1);
        assertThat(result.get(0).getId()).isEqualTo(matchId);
    }

    @Test
    @DisplayName("Hiç mesaj yoksa lastMessage → 'Şimdi eşleştiniz!' default metni")
    void getMatchesForUser_noMessages_defaultLastMessage() {
        when(matchRepository.findMatchesByUserId(userAId)).thenReturn(List.of(match));
        when(messageRepository.findByMatchIdOrderBySentAtAsc(matchId)).thenReturn(Collections.emptyList());

        List<MatchDto> result = chatService.getMatchesForUser(userAId);

        assertThat(result).hasSize(1);
        assertThat(result.get(0).getLastMessage()).contains("Şimdi eşleştiniz");
    }

    @Test
    @DisplayName("Hiç match yoksa boş liste dönmeli")
    void getMatchesForUser_noMatches_returnsEmptyList() {
        when(matchRepository.findMatchesByUserId(userAId)).thenReturn(Collections.emptyList());

        List<MatchDto> result = chatService.getMatchesForUser(userAId);

        assertThat(result).isEmpty();
    }

    // ─── GET MESSAGES ─────────────────────────────────────────────────────────

    @Test
    @DisplayName("Match için mesajları getir → MessageDto listesi dönmeli")
    void getMessagesForMatch_returnsMessageList() {
        Message msg1 = Message.builder()
                .id(UUID.randomUUID()).match(match).senderId(userAId)
                .content("Merhaba").sentAt(LocalDateTime.now().minusMinutes(10)).isRead(true)
                .build();
        Message msg2 = Message.builder()
                .id(UUID.randomUUID()).match(match).senderId(userBId)
                .content("Selam!").sentAt(LocalDateTime.now()).isRead(false)
                .build();

        when(messageRepository.findByMatchIdOrderBySentAtAsc(matchId)).thenReturn(List.of(msg1, msg2));

        List<MessageDto> result = chatService.getMessagesForMatch(matchId);

        assertThat(result).hasSize(2);
        assertThat(result.get(0).getContent()).isEqualTo("Merhaba");
        assertThat(result.get(1).getContent()).isEqualTo("Selam!");
    }

    // ─── SEND MESSAGE ─────────────────────────────────────────────────────────

    @Test
    @DisplayName("Mesaj gönder → MessageDto dönmeli, isRead=false")
    void sendMessage_validMatch_returnsMessageDto() {
        when(matchRepository.findById(matchId)).thenReturn(Optional.of(match));

        Message savedMsg = Message.builder()
                .id(UUID.randomUUID()).match(match).senderId(userAId)
                .content("Test mesajı").sentAt(LocalDateTime.now()).isRead(false)
                .build();
        when(messageRepository.save(any(Message.class))).thenReturn(savedMsg);

        MessageDto result = chatService.sendMessage(userAId, matchId, "Test mesajı");

        assertThat(result).isNotNull();
        assertThat(result.getContent()).isEqualTo("Test mesajı");
        assertThat(result.isRead()).isFalse();
    }

    @Test
    @DisplayName("Var olmayan match'e mesaj gönder → RuntimeException")
    void sendMessage_matchNotFound_throwsException() {
        when(matchRepository.findById(any())).thenReturn(Optional.empty());

        assertThatThrownBy(() -> chatService.sendMessage(userAId, UUID.randomUUID(), "Merhaba"))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Match not found");
    }
}
