package com.techconnect.backend.service;

import com.techconnect.backend.config.JwtUtils;
import com.techconnect.backend.dto.AuthRequest;
import com.techconnect.backend.dto.AuthResponse;
import com.techconnect.backend.dto.RegisterRequest;
import com.techconnect.backend.model.*;
import com.techconnect.backend.repository.ProfileRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.*;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.server.ResponseStatusException;

import java.lang.reflect.Field;
import java.util.*;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("AuthService Tests")
class AuthServiceTest {

    @Mock
    private ProfileRepository profileRepository;

    // JwtUtils Java 25'te Mockito Byte Buddy ile mock'lanamıyor.
    // Gerçek instance + reflection ile secret inject ediyoruz.
    private JwtUtils jwtUtils;

    @Mock
    private PasswordEncoder passwordEncoder;

    private AuthService authService;

    private DeveloperProfile mockProfile;
    private final UUID userId = UUID.randomUUID();

    @BeforeEach
    void setUp() throws Exception {
        jwtUtils = new JwtUtils();
        Field secretField = JwtUtils.class.getDeclaredField("jwtSecret");
        secretField.setAccessible(true);
        secretField.set(jwtUtils, "test_super_secret_jwt_key_at_least_256_bits_long_x9k2m7p");

        authService = new AuthService(profileRepository, jwtUtils, passwordEncoder);

        mockProfile = DeveloperProfile.builder()
                .id(userId)
                .email("test@example.com")
                .displayName("Test User")
                .role("iOS Developer")
                .experienceYears(3)
                .sector(Sector.STARTUP)
                .lookingFor(LookingFor.COLLABORATION)
                .city("İstanbul")
                .isRemote(true)
                .techStack("Swift,SwiftUI")
                .photoNames("person.crop.circle.fill")
                .subscriptionTier(SubscriptionTier.FREE)
                .gender(Gender.MALE)
                .preferredGender(PreferredGender.EVERYONE)
                .passwordHash("$2a$10$hashedpassword")
                .githubUsername("octocat")
                .build();
    }

    // ─── LOGIN TESTLER ───────────────────────────────────────────────────────

    @Test
    @DisplayName("Doğru email+şifre ile login başarılı")
    void login_validCredentials_returnsAuthResponse() {
        when(profileRepository.findByEmail("test@example.com")).thenReturn(Optional.of(mockProfile));
        when(passwordEncoder.matches("Test1234!", mockProfile.getPasswordHash())).thenReturn(true);

        AuthRequest request = new AuthRequest();
        request.setEmail("test@example.com");
        request.setPassword("Test1234!");

        AuthResponse response = authService.login(request);

        assertThat(response).isNotNull();
        assertThat(response.getToken()).isNotEmpty();
        assertThat(response.getProfile().getEmail()).isEqualTo("test@example.com");
    }

    @Test
    @DisplayName("Var olmayan email ile login → 401 UNAUTHORIZED")
    void login_nonExistentEmail_throws401() {
        when(profileRepository.findByEmail(anyString())).thenReturn(Optional.empty());

        AuthRequest request = new AuthRequest();
        request.setEmail("noone@example.com");
        request.setPassword("pass");

        assertThatThrownBy(() -> authService.login(request))
                .isInstanceOf(ResponseStatusException.class)
                .extracting(e -> ((ResponseStatusException) e).getStatusCode())
                .isEqualTo(HttpStatus.UNAUTHORIZED);
    }

    @Test
    @DisplayName("Yanlış şifre ile login → 401 UNAUTHORIZED")
    void login_wrongPassword_throws401() {
        when(profileRepository.findByEmail("test@example.com")).thenReturn(Optional.of(mockProfile));
        when(passwordEncoder.matches(anyString(), anyString())).thenReturn(false);

        AuthRequest request = new AuthRequest();
        request.setEmail("test@example.com");
        request.setPassword("WrongPassword");

        assertThatThrownBy(() -> authService.login(request))
                .isInstanceOf(ResponseStatusException.class)
                .extracting(e -> ((ResponseStatusException) e).getStatusCode())
                .isEqualTo(HttpStatus.UNAUTHORIZED);
    }

    @Test
    @DisplayName("Şifresiz (mock) kullanıcı boş şifre ile login başarılı")
    void login_mockUserNoPassword_emptyPasswordAllowed() {
        DeveloperProfile mockUserNoHash = DeveloperProfile.builder()
                .id(userId)
                .email("mock@devmatch.com")
                .displayName("Mock User")
                .role("iOS Developer")
                .experienceYears(4)
                .sector(Sector.STARTUP)
                .lookingFor(LookingFor.COLLABORATION)
                .isRemote(true)
                .subscriptionTier(SubscriptionTier.FREE)
                .gender(Gender.MALE)
                .preferredGender(PreferredGender.EVERYONE)
                .passwordHash(null) // Mock user — şifre hash'i yok
                .build();

        when(profileRepository.findByEmail("mock@devmatch.com")).thenReturn(Optional.of(mockUserNoHash));

        AuthRequest request = new AuthRequest();
        request.setEmail("mock@devmatch.com");
        request.setPassword(""); // Boş şifre

        AuthResponse response = authService.login(request);

        assertThat(response.getToken()).isNotEmpty();
    }

    @Test
    @DisplayName("Şifresiz mock kullanıcıya şifre gönderilirse → 401 UNAUTHORIZED")
    void login_mockUserWithPassword_throws401() {
        DeveloperProfile mockUserNoHash = DeveloperProfile.builder()
                .id(userId)
                .email("mock@devmatch.com")
                .displayName("Mock User")
                .role("iOS Developer")
                .experienceYears(4)
                .sector(Sector.STARTUP)
                .lookingFor(LookingFor.COLLABORATION)
                .isRemote(true)
                .subscriptionTier(SubscriptionTier.FREE)
                .gender(Gender.MALE)
                .preferredGender(PreferredGender.EVERYONE)
                .passwordHash(null)
                .build();

        when(profileRepository.findByEmail("mock@devmatch.com")).thenReturn(Optional.of(mockUserNoHash));

        AuthRequest request = new AuthRequest();
        request.setEmail("mock@devmatch.com");
        request.setPassword("SomePassword"); // Şifresiz hesaba şifre gönderiliyor

        assertThatThrownBy(() -> authService.login(request))
                .isInstanceOf(ResponseStatusException.class)
                .extracting(e -> ((ResponseStatusException) e).getStatusCode())
                .isEqualTo(HttpStatus.UNAUTHORIZED);
    }

    // ─── REGISTER TESTLER ────────────────────────────────────────────────────

    @Test
    @DisplayName("Var olan email ile kayıt → 400 BAD_REQUEST")
    void register_duplicateEmail_throws400() {
        when(profileRepository.findByEmail("test@example.com")).thenReturn(Optional.of(mockProfile));

        RegisterRequest request = buildRegisterRequest("test@example.com");

        assertThatThrownBy(() -> authService.register(request))
                .isInstanceOf(ResponseStatusException.class)
                .extracting(e -> ((ResponseStatusException) e).getStatusCode())
                .isEqualTo(HttpStatus.BAD_REQUEST);
    }

    // ─── YARDIMCI METODLAR ───────────────────────────────────────────────────

    private RegisterRequest buildRegisterRequest(String email) {
        RegisterRequest r = new RegisterRequest();
        r.setEmail(email);
        r.setPassword("Test1234!");
        r.setDisplayName("Test User");
        r.setGithubUsername("octocat");
        r.setRole("iOS Developer");
        r.setExperienceYears(3);
        r.setSector(Sector.STARTUP);
        r.setLookingFor(LookingFor.COLLABORATION);
        r.setCity("İstanbul");
        r.setIsRemote(true);
        r.setTechStack(List.of("Swift", "SwiftUI"));
        r.setPhotoNames(List.of("person.crop.circle.fill"));
        r.setGender(Gender.MALE);
        r.setPreferredGender(PreferredGender.EVERYONE);
        return r;
    }
}
