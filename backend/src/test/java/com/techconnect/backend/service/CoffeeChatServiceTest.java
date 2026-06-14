package com.techconnect.backend.service;

import com.techconnect.backend.dto.CoffeeChatRequestDto;
import com.techconnect.backend.model.*;
import com.techconnect.backend.repository.CoffeeChatRepository;
import com.techconnect.backend.repository.MatchRepository;
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
@DisplayName("CoffeeChatService Tests")
class CoffeeChatServiceTest {

    @Mock
    private CoffeeChatRepository coffeeChatRepository;

    @Mock
    private MatchRepository matchRepository;

    @InjectMocks
    private CoffeeChatService coffeeChatService;

    private DeveloperProfile userA;
    private DeveloperProfile userB;
    private Match match;
    private final UUID userAId  = UUID.randomUUID();
    private final UUID userBId  = UUID.randomUUID();
    private final UUID matchId  = UUID.randomUUID();
    private final UUID reqId    = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        userA = DeveloperProfile.builder()
                .id(userAId).displayName("UserA").email("a@test.com")
                .role("Dev").experienceYears(3).sector(Sector.STARTUP)
                .lookingFor(LookingFor.COFFEE_CHAT).isRemote(true)
                .subscriptionTier(SubscriptionTier.FREE)
                .gender(Gender.MALE).preferredGender(PreferredGender.EVERYONE)
                .build();

        userB = DeveloperProfile.builder()
                .id(userBId).displayName("UserB").email("b@test.com")
                .role("Dev").experienceYears(4).sector(Sector.STARTUP)
                .lookingFor(LookingFor.COFFEE_CHAT).isRemote(true)
                .subscriptionTier(SubscriptionTier.FREE)
                .gender(Gender.FEMALE).preferredGender(PreferredGender.EVERYONE)
                .build();

        match = Match.builder()
                .id(matchId)
                .profile1(userA)
                .profile2(userB)
                .matchedAt(LocalDateTime.now().minusHours(1))
                .build();
    }

    // ─── PROPOSE ─────────────────────────────────────────────────────────────

    @Test
    @DisplayName("Coffee chat öner → DTO dönmeli, status PENDING")
    void proposeCoffeeChat_validMatch_returnsDtoWithPendingStatus() {
        when(matchRepository.findById(matchId)).thenReturn(Optional.of(match));

        LocalDateTime proposedTime = LocalDateTime.now().plusDays(1);
        CoffeeChatRequest savedRequest = CoffeeChatRequest.builder()
                .id(reqId)
                .match(match)
                .requesterId(userAId)
                .proposedTime(proposedTime)
                .status(CoffeeChatStatus.PENDING)
                .build();
        when(coffeeChatRepository.save(any(CoffeeChatRequest.class))).thenReturn(savedRequest);

        CoffeeChatRequestDto result = coffeeChatService.proposeCoffeeChat(userAId, matchId, proposedTime);

        assertThat(result).isNotNull();
        assertThat(result.getStatus()).isEqualTo(CoffeeChatStatus.PENDING);
        assertThat(result.getRequesterId()).isEqualTo(userAId);
        verify(coffeeChatRepository, times(1)).save(any(CoffeeChatRequest.class));
    }

    @Test
    @DisplayName("Var olmayan match'e coffee chat öner → RuntimeException")
    void proposeCoffeeChat_matchNotFound_throwsException() {
        when(matchRepository.findById(any())).thenReturn(Optional.empty());

        assertThatThrownBy(() -> coffeeChatService.proposeCoffeeChat(
                userAId, UUID.randomUUID(), LocalDateTime.now().plusDays(1)))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Match not found");
    }

    // ─── UPDATE STATUS ────────────────────────────────────────────────────────

    @Test
    @DisplayName("Status ACCEPTED olarak güncelle → dto'da status ACCEPTED olmalı")
    void updateStatus_toAccepted_updatesSuccessfully() {
        CoffeeChatRequest existingRequest = CoffeeChatRequest.builder()
                .id(reqId)
                .match(match)
                .requesterId(userAId)
                .proposedTime(LocalDateTime.now().plusDays(1))
                .status(CoffeeChatStatus.PENDING)
                .build();

        when(coffeeChatRepository.findById(reqId)).thenReturn(Optional.of(existingRequest));
        when(coffeeChatRepository.save(any(CoffeeChatRequest.class))).thenAnswer(inv -> inv.getArgument(0));

        CoffeeChatRequestDto result = coffeeChatService.updateStatus(reqId, CoffeeChatStatus.ACCEPTED);

        assertThat(result.getStatus()).isEqualTo(CoffeeChatStatus.ACCEPTED);
    }

    @Test
    @DisplayName("Status DECLINED olarak güncelle → dto'da status DECLINED olmalı")
    void updateStatus_toDeclined_updatesSuccessfully() {
        CoffeeChatRequest existingRequest = CoffeeChatRequest.builder()
                .id(reqId)
                .match(match)
                .requesterId(userAId)
                .proposedTime(LocalDateTime.now().plusDays(1))
                .status(CoffeeChatStatus.PENDING)
                .build();

        when(coffeeChatRepository.findById(reqId)).thenReturn(Optional.of(existingRequest));
        when(coffeeChatRepository.save(any(CoffeeChatRequest.class))).thenAnswer(inv -> inv.getArgument(0));

        CoffeeChatRequestDto result = coffeeChatService.updateStatus(reqId, CoffeeChatStatus.DECLINED);

        assertThat(result.getStatus()).isEqualTo(CoffeeChatStatus.DECLINED);
    }

    @Test
    @DisplayName("Var olmayan istek güncelle → RuntimeException")
    void updateStatus_notFound_throwsException() {
        when(coffeeChatRepository.findById(any())).thenReturn(Optional.empty());

        assertThatThrownBy(() -> coffeeChatService.updateStatus(UUID.randomUUID(), CoffeeChatStatus.ACCEPTED))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Coffee chat request not found");
    }

    // ─── GET REQUESTS FOR MATCH ───────────────────────────────────────────────

    @Test
    @DisplayName("Match için coffee chat talepleri → liste dönmeli")
    void getRequestsForMatch_returnsList() {
        CoffeeChatRequest req = CoffeeChatRequest.builder()
                .id(reqId).match(match).requesterId(userAId)
                .proposedTime(LocalDateTime.now().plusDays(1))
                .status(CoffeeChatStatus.PENDING)
                .build();
        when(coffeeChatRepository.findByMatchId(matchId)).thenReturn(List.of(req));

        List<CoffeeChatRequestDto> result = coffeeChatService.getRequestsForMatch(matchId);

        assertThat(result).hasSize(1);
        assertThat(result.get(0).getStatus()).isEqualTo(CoffeeChatStatus.PENDING);
    }

    @Test
    @DisplayName("Match için hiç talep yoksa boş liste dönmeli")
    void getRequestsForMatch_noRequests_returnsEmptyList() {
        when(coffeeChatRepository.findByMatchId(matchId)).thenReturn(Collections.emptyList());

        List<CoffeeChatRequestDto> result = coffeeChatService.getRequestsForMatch(matchId);

        assertThat(result).isEmpty();
    }
}
