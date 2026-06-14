package com.techconnect.backend.service;

import com.techconnect.backend.dto.DeveloperProfileDto;
import com.techconnect.backend.model.*;
import com.techconnect.backend.repository.MatchRepository;
import com.techconnect.backend.repository.MessageRepository;
import com.techconnect.backend.repository.ProfileRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("ProfileService Tests")
class ProfileServiceTest {

    @Mock
    private ProfileRepository profileRepository;

    @Mock
    private MatchRepository matchRepository;

    @Mock
    private MessageRepository messageRepository;

    @InjectMocks
    private ProfileService profileService;

    private DeveloperProfile ahmet;
    private DeveloperProfile merveF;
    private DeveloperProfile canM;
    private final UUID ahmetId = UUID.randomUUID();
    private final UUID merveId = UUID.randomUUID();
    private final UUID canId   = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        ahmet = buildProfile(ahmetId, "Ahmet", Gender.MALE, PreferredGender.EVERYONE,
                SubscriptionTier.PRO, Sector.STARTUP, LookingFor.MENTOR, 4, "Swift,SwiftUI,Java");

        merveF = buildProfile(merveId, "Merve", Gender.FEMALE, PreferredGender.EVERYONE,
                SubscriptionTier.FREE, Sector.STARTUP, LookingFor.MENTEE, 6, "Swift,SwiftUI,Combine");

        canM = buildProfile(canId, "Can", Gender.MALE, PreferredGender.FEMALE,
                SubscriptionTier.PRO, Sector.CORPORATE, LookingFor.COFFEE_CHAT, 8, "Java,Go,Docker");
    }

    // ─── GET PROFILE ─────────────────────────────────────────────────────────

    @Test
    @DisplayName("Var olan profil ID ile getir → DTO dönmeli")
    void getProfileById_existing_returnsDto() {
        when(profileRepository.findById(ahmetId)).thenReturn(Optional.of(ahmet));

        DeveloperProfileDto dto = profileService.getProfileById(ahmetId);

        assertThat(dto).isNotNull();
        assertThat(dto.getId()).isEqualTo(ahmetId);
        assertThat(dto.getDisplayName()).isEqualTo("Ahmet");
    }

    @Test
    @DisplayName("Var olmayan profil ID → RuntimeException")
    void getProfileById_notFound_throwsException() {
        when(profileRepository.findById(any())).thenReturn(Optional.empty());

        assertThatThrownBy(() -> profileService.getProfileById(UUID.randomUUID()))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Profile not found");
    }

    // ─── UPDATE PROFILE ───────────────────────────────────────────────────────

    @Test
    @DisplayName("Profil güncelle → güncel DTO dönmeli")
    void updateProfile_validId_returnUpdatedDto() {
        when(profileRepository.findById(ahmetId)).thenReturn(Optional.of(ahmet));
        when(profileRepository.save(any())).thenReturn(ahmet);

        DeveloperProfileDto dto = DeveloperProfileDto.builder()
                .displayName("Ahmet Updated")
                .role("Senior iOS Developer")
                .experienceYears(5)
                .sector(Sector.CORPORATE)
                .lookingFor(LookingFor.MENTEE)
                .city("Ankara")
                .isRemote(false)
                .techStack(List.of("Swift", "Kotlin"))
                .photoNames(List.of("photo.jpg"))
                .subscriptionTier(SubscriptionTier.PRO)
                .gender(Gender.MALE)
                .preferredGender(PreferredGender.EVERYONE)
                .build();

        DeveloperProfileDto result = profileService.updateProfile(ahmetId, dto);

        assertThat(result).isNotNull();
        verify(profileRepository).save(ahmet);
    }

    // ─── DELETE PROFILE ───────────────────────────────────────────────────────

    @Test
    @DisplayName("Profil sil → delete() çağrılmalı")
    void deleteProfile_existing_callsDelete() {
        when(profileRepository.findById(ahmetId)).thenReturn(Optional.of(ahmet));
        doNothing().when(profileRepository).delete(ahmet);

        profileService.deleteProfile(ahmetId);

        verify(profileRepository, times(1)).delete(ahmet);
    }

    @Test
    @DisplayName("Var olmayan profil sil → ResponseStatusException")
    void deleteProfile_notFound_throwsException() {
        when(profileRepository.findById(any())).thenReturn(Optional.empty());

        assertThatThrownBy(() -> profileService.deleteProfile(UUID.randomUUID()))
                .isInstanceOf(ResponseStatusException.class);
    }

    // ─── DISCOVER ─────────────────────────────────────────────────────────────

    @Test
    @DisplayName("FREE user discover → gender filtresi uygulanmaz, herkesi görür")
    void getDiscoverableProfiles_freeUser_noGenderFilter() {
        when(profileRepository.findById(merveId)).thenReturn(Optional.of(merveF));
        when(profileRepository.findDiscoverableProfiles(merveId))
                .thenReturn(List.of(ahmet, canM));

        List<DeveloperProfileDto> result = profileService.getDiscoverableProfiles(merveId);

        // FREE user: hem erkek hem de herkes görünmeli
        assertThat(result).hasSize(2);
    }

    @Test
    @DisplayName("PRO user FEMALE tercih → sadece kadınlar gelmeli")
    void getDiscoverableProfiles_proUserMalePrefersFemale_onlyFemales() {
        // Can → PRO, preferredGender=FEMALE
        when(profileRepository.findById(canId)).thenReturn(Optional.of(canM));
        when(profileRepository.findDiscoverableProfiles(canId))
                .thenReturn(List.of(ahmet, merveF)); // ahmet erkek, merve kadın

        List<DeveloperProfileDto> result = profileService.getDiscoverableProfiles(canId);

        // Sadece merve (FEMALE) gelmeli
        assertThat(result).hasSize(1);
        assertThat(result.get(0).getGender()).isEqualTo(Gender.FEMALE);
    }

    @Test
    @DisplayName("PRO user EVERYONE tercih → gender filtresi uygulanmaz")
    void getDiscoverableProfiles_proUserPrefersEveryone_allVisible() {
        when(profileRepository.findById(ahmetId)).thenReturn(Optional.of(ahmet));
        when(profileRepository.findDiscoverableProfiles(ahmetId))
                .thenReturn(List.of(merveF, canM));

        List<DeveloperProfileDto> result = profileService.getDiscoverableProfiles(ahmetId);

        assertThat(result).hasSize(2);
    }

    @Test
    @DisplayName("Discover — 20'den fazla profil varsa max 20 döner")
    void getDiscoverableProfiles_moreThan20_limitedTo20() {
        List<DeveloperProfile> manyProfiles = new ArrayList<>();
        for (int i = 0; i < 25; i++) {
            manyProfiles.add(buildProfile(UUID.randomUUID(), "User" + i,
                    Gender.MALE, PreferredGender.EVERYONE,
                    SubscriptionTier.FREE, Sector.STARTUP, LookingFor.COLLABORATION, 3, "Java"));
        }
        when(profileRepository.findById(merveId)).thenReturn(Optional.of(merveF));
        when(profileRepository.findDiscoverableProfiles(merveId)).thenReturn(manyProfiles);

        List<DeveloperProfileDto> result = profileService.getDiscoverableProfiles(merveId);

        assertThat(result).hasSizeLessThanOrEqualTo(20);
    }

    // ─── COMPATİBİLİTY SCORE ─────────────────────────────────────────────────

    @Test
    @DisplayName("Ortak tech stack → uyumluluk skoru artar")
    void discover_sharedTechStack_higherCompatibilityScore() {
        // Ahmet: Swift,SwiftUI,Java | Merve: Swift,SwiftUI,Combine → 2 ortak × 3 = 6 puan
        // Can: Java,Go,Docker → 1 ortak × 3 = 3 puan
        when(profileRepository.findById(ahmetId)).thenReturn(Optional.of(ahmet));
        when(profileRepository.findDiscoverableProfiles(ahmetId)).thenReturn(List.of(merveF, canM));

        List<DeveloperProfileDto> result = profileService.getDiscoverableProfiles(ahmetId);

        // Merve daha yüksek skor aldığından liste başında olmalı (descending sort)
        assertThat(result.get(0).getDisplayName()).isEqualTo("Merve");
        assertThat(result.get(0).getCompatibilityScore())
                .isGreaterThanOrEqualTo(result.get(1).getCompatibilityScore());
    }

    @Test
    @DisplayName("MENTOR ↔ MENTEE uyumu → +4 puan")
    void discover_mentorMenteeMatch_addsScore() {
        // Ahmet: MENTOR arayışında | Merve: MENTEE arayışında → uyumlu
        DeveloperProfile mentorSeeker = buildProfile(UUID.randomUUID(), "MentorSeeker",
                Gender.MALE, PreferredGender.EVERYONE, SubscriptionTier.FREE,
                Sector.STARTUP, LookingFor.MENTOR, 4, "Swift");

        DeveloperProfile menteeSeeker = buildProfile(UUID.randomUUID(), "MenteeSeeker",
                Gender.FEMALE, PreferredGender.EVERYONE, SubscriptionTier.FREE,
                Sector.STARTUP, LookingFor.MENTEE, 2, "Swift");

        DeveloperProfile coffeeSeeker = buildProfile(UUID.randomUUID(), "CoffeeSeeker",
                Gender.FEMALE, PreferredGender.EVERYONE, SubscriptionTier.FREE,
                Sector.STARTUP, LookingFor.COFFEE_CHAT, 2, "Swift");

        when(profileRepository.findById(mentorSeeker.getId())).thenReturn(Optional.of(mentorSeeker));
        when(profileRepository.findDiscoverableProfiles(mentorSeeker.getId()))
                .thenReturn(List.of(menteeSeeker, coffeeSeeker));

        List<DeveloperProfileDto> result = profileService.getDiscoverableProfiles(mentorSeeker.getId());

        // menteeSeeker MENTOR-MENTEE uyumlu → daha yüksek skor
        assertThat(result.get(0).getDisplayName()).isEqualTo("MenteeSeeker");
    }

    // ─── YARDIMCI METODLAR ───────────────────────────────────────────────────

    private DeveloperProfile buildProfile(UUID id, String name, Gender gender,
                                          PreferredGender preferredGender,
                                          SubscriptionTier tier, Sector sector,
                                          LookingFor lookingFor, int expYears, String techStack) {
        return DeveloperProfile.builder()
                .id(id)
                .displayName(name)
                .email(name.toLowerCase() + "@test.com")
                .role("Developer")
                .experienceYears(expYears)
                .sector(sector)
                .lookingFor(lookingFor)
                .city("İstanbul")
                .isRemote(true)
                .techStack(techStack)
                .photoNames("person.crop.circle.fill")
                .subscriptionTier(tier)
                .gender(gender)
                .preferredGender(preferredGender)
                .build();
    }
}
