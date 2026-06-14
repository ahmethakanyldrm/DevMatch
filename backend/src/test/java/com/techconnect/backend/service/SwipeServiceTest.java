package com.techconnect.backend.service;

import com.techconnect.backend.dto.SwipeRequest;
import com.techconnect.backend.dto.SwipeResponse;
import com.techconnect.backend.model.*;
import com.techconnect.backend.repository.MatchRepository;
import com.techconnect.backend.repository.ProfileRepository;
import com.techconnect.backend.repository.SwipeRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.*;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("SwipeService Tests")
class SwipeServiceTest {

    @Mock
    private SwipeRepository swipeRepository;

    @Mock
    private ProfileRepository profileRepository;

    @Mock
    private MatchRepository matchRepository;

    @InjectMocks
    private SwipeService swipeService;

    private DeveloperProfile userA;
    private DeveloperProfile userB;
    private final UUID userAId = UUID.randomUUID();
    private final UUID userBId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        userA = buildProfile(userAId, SubscriptionTier.FREE);
        userB = buildProfile(userBId, SubscriptionTier.FREE);
    }

    // ─── LIKE SENARYOLARI ────────────────────────────────────────────────────

    @Test
    @DisplayName("Karşılıklı LIKE → match oluşturulmalı, matched=true")
    void swipe_mutualLike_createsMatch() {
        when(profileRepository.findById(userAId)).thenReturn(Optional.of(userA));
        when(profileRepository.findById(userBId)).thenReturn(Optional.of(userB));
        when(swipeRepository.countByLikerIdAndSwipeTypeAndCreatedAtAfter(any(), any(), any())).thenReturn(0L);
        when(swipeRepository.findByLikerIdAndLikedId(userAId, userBId)).thenReturn(Optional.empty());

        // B daha önce A'yı beğenmiş
        Swipe bLikedA = Swipe.builder()
                .id(UUID.randomUUID())
                .liker(userB)
                .liked(userA)
                .swipeType(SwipeType.LIKE)
                .createdAt(LocalDateTime.now().minusHours(1))
                .build();
        when(swipeRepository.findByLikerIdAndLikedId(userBId, userAId)).thenReturn(Optional.of(bLikedA));
        when(matchRepository.findMatchBetween(userAId, userBId)).thenReturn(Optional.empty());
        when(matchRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        SwipeRequest request = new SwipeRequest();
        request.setTargetUserId(userBId);
        request.setSwipeType(SwipeType.LIKE);

        SwipeResponse response = swipeService.swipe(userAId, request);

        assertThat(response.isMatched()).isTrue();
        assertThat(response.getMatch()).isNotNull();
        verify(matchRepository, times(1)).save(any(Match.class));
    }

    @Test
    @DisplayName("Tek taraflı LIKE → match oluşmamalı, matched=false")
    void swipe_oneSidedLike_noMatch() {
        when(profileRepository.findById(userAId)).thenReturn(Optional.of(userA));
        when(profileRepository.findById(userBId)).thenReturn(Optional.of(userB));
        when(swipeRepository.countByLikerIdAndSwipeTypeAndCreatedAtAfter(any(), any(), any())).thenReturn(0L);
        when(swipeRepository.findByLikerIdAndLikedId(userAId, userBId)).thenReturn(Optional.empty());
        // B henüz A'yı beğenmemiş
        when(swipeRepository.findByLikerIdAndLikedId(userBId, userAId)).thenReturn(Optional.empty());

        SwipeRequest request = new SwipeRequest();
        request.setTargetUserId(userBId);
        request.setSwipeType(SwipeType.LIKE);

        SwipeResponse response = swipeService.swipe(userAId, request);

        assertThat(response.isMatched()).isFalse();
        verify(matchRepository, never()).save(any());
    }

    @Test
    @DisplayName("PASS → match oluşmamalı, matched=false")
    void swipe_dislike_noMatch() {
        when(profileRepository.findById(userAId)).thenReturn(Optional.of(userA));
        when(profileRepository.findById(userBId)).thenReturn(Optional.of(userB));
        when(swipeRepository.findByLikerIdAndLikedId(userAId, userBId)).thenReturn(Optional.empty());

        SwipeRequest request = new SwipeRequest();
        request.setTargetUserId(userBId);
        request.setSwipeType(SwipeType.PASS);

        SwipeResponse response = swipeService.swipe(userAId, request);

        assertThat(response.isMatched()).isFalse();
        verify(matchRepository, never()).save(any());
    }

    @Test
    @DisplayName("Zaten match varsa → tekrar kaydedilmemeli, matched=true")
    void swipe_mutualLikeButMatchAlreadyExists_noNewMatch() {
        when(profileRepository.findById(userAId)).thenReturn(Optional.of(userA));
        when(profileRepository.findById(userBId)).thenReturn(Optional.of(userB));
        when(swipeRepository.countByLikerIdAndSwipeTypeAndCreatedAtAfter(any(), any(), any())).thenReturn(0L);
        when(swipeRepository.findByLikerIdAndLikedId(userAId, userBId)).thenReturn(Optional.empty());

        Swipe bLikedA = Swipe.builder()
                .id(UUID.randomUUID())
                .liker(userB)
                .liked(userA)
                .swipeType(SwipeType.LIKE)
                .createdAt(LocalDateTime.now())
                .build();
        when(swipeRepository.findByLikerIdAndLikedId(userBId, userAId)).thenReturn(Optional.of(bLikedA));

        // Match zaten mevcut
        Match existingMatch = Match.builder()
                .id(UUID.randomUUID())
                .profile1(userB)
                .profile2(userA)
                .matchedAt(LocalDateTime.now())
                .build();
        when(matchRepository.findMatchBetween(userAId, userBId)).thenReturn(Optional.of(existingMatch));

        SwipeRequest request = new SwipeRequest();
        request.setTargetUserId(userBId);
        request.setSwipeType(SwipeType.LIKE);

        SwipeResponse response = swipeService.swipe(userAId, request);

        assertThat(response.isMatched()).isTrue();
        // Yeni match kaydedilmemeli
        verify(matchRepository, never()).save(any());
    }

    @Test
    @DisplayName("Var olan swipe → güncellenmeli (upsert)")
    void swipe_existingSwipe_updatesInsteadOfCreating() {
        when(profileRepository.findById(userAId)).thenReturn(Optional.of(userA));
        when(profileRepository.findById(userBId)).thenReturn(Optional.of(userB));
        when(swipeRepository.countByLikerIdAndSwipeTypeAndCreatedAtAfter(any(), any(), any())).thenReturn(0L);

        // Önceki swipe mevcut (örn. DISLIKE → LIKE'a çevrilecek)
        Swipe existingSwipe = Swipe.builder()
                .id(UUID.randomUUID())
                .liker(userA)
                .liked(userB)
                .swipeType(SwipeType.PASS)
                .createdAt(LocalDateTime.now())
                .build();
        when(swipeRepository.findByLikerIdAndLikedId(userAId, userBId)).thenReturn(Optional.of(existingSwipe));
        when(swipeRepository.findByLikerIdAndLikedId(userBId, userAId)).thenReturn(Optional.empty());

        SwipeRequest request = new SwipeRequest();
        request.setTargetUserId(userBId);
        request.setSwipeType(SwipeType.LIKE);

        swipeService.swipe(userAId, request);

        // save() var olan swipe üzerinde çağrılmış olmalı
        verify(swipeRepository).save(existingSwipe);
        assertThat(existingSwipe.getSwipeType()).isEqualTo(SwipeType.LIKE);
    }

    // ─── LIMIT SENARYOLARI ───────────────────────────────────────────────────

    @Test
    @DisplayName("FREE user 10 LIKE limitini aşarsa → 402 PAYMENT_REQUIRED")
    void swipe_freeUserExceedsLikeLimit_throws402() {
        when(profileRepository.findById(userAId)).thenReturn(Optional.of(userA));
        when(profileRepository.findById(userBId)).thenReturn(Optional.of(userB));
        // 10 beğeni zaten kullanılmış
        when(swipeRepository.countByLikerIdAndSwipeTypeAndCreatedAtAfter(
                eq(userAId), eq(SwipeType.LIKE), any())).thenReturn(10L);

        SwipeRequest request = new SwipeRequest();
        request.setTargetUserId(userBId);
        request.setSwipeType(SwipeType.LIKE);

        assertThatThrownBy(() -> swipeService.swipe(userAId, request))
                .isInstanceOf(ResponseStatusException.class)
                .extracting(e -> ((ResponseStatusException) e).getStatusCode())
                .isEqualTo(HttpStatus.PAYMENT_REQUIRED);
    }

    @Test
    @DisplayName("FREE user 9 LIKE ile 10. atabilmeli")
    void swipe_freeUserAt9Likes_allowsTenth() {
        when(profileRepository.findById(userAId)).thenReturn(Optional.of(userA));
        when(profileRepository.findById(userBId)).thenReturn(Optional.of(userB));
        // 9 beğeni kullanılmış → 10. geçerli
        when(swipeRepository.countByLikerIdAndSwipeTypeAndCreatedAtAfter(
                eq(userAId), eq(SwipeType.LIKE), any())).thenReturn(9L);
        when(swipeRepository.findByLikerIdAndLikedId(userAId, userBId)).thenReturn(Optional.empty());
        when(swipeRepository.findByLikerIdAndLikedId(userBId, userAId)).thenReturn(Optional.empty());

        SwipeRequest request = new SwipeRequest();
        request.setTargetUserId(userBId);
        request.setSwipeType(SwipeType.LIKE);

        SwipeResponse response = swipeService.swipe(userAId, request);

        assertThat(response).isNotNull();
    }

    @Test
    @DisplayName("PRO user LIKE limitine tabi değil")
    void swipe_proUser_noLikeLimit() {
        DeveloperProfile proUser = buildProfile(userAId, SubscriptionTier.PRO);
        when(profileRepository.findById(userAId)).thenReturn(Optional.of(proUser));
        when(profileRepository.findById(userBId)).thenReturn(Optional.of(userB));
        when(swipeRepository.findByLikerIdAndLikedId(userAId, userBId)).thenReturn(Optional.empty());
        when(swipeRepository.findByLikerIdAndLikedId(userBId, userAId)).thenReturn(Optional.empty());

        SwipeRequest request = new SwipeRequest();
        request.setTargetUserId(userBId);
        request.setSwipeType(SwipeType.LIKE);

        SwipeResponse response = swipeService.swipe(userAId, request);

        assertThat(response).isNotNull();
        // PRO kullanıcı için limit kontrolü yapılmamalı
        verify(swipeRepository, never()).countByLikerIdAndSwipeTypeAndCreatedAtAfter(any(), any(), any());
    }

    // ─── YARDIMCI METODLAR ───────────────────────────────────────────────────

    private DeveloperProfile buildProfile(UUID id, SubscriptionTier tier) {
        return DeveloperProfile.builder()
                .id(id)
                .displayName("User " + id.toString().substring(0, 8))
                .email(id + "@test.com")
                .role("Developer")
                .experienceYears(3)
                .sector(Sector.STARTUP)
                .lookingFor(LookingFor.COLLABORATION)
                .isRemote(true)
                .techStack("Swift")
                .photoNames("person.crop.circle.fill")
                .subscriptionTier(tier)
                .gender(Gender.MALE)
                .preferredGender(PreferredGender.EVERYONE)
                .build();
    }
}
