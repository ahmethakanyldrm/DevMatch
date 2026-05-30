package com.techconnect.backend.service;

import com.techconnect.backend.config.JwtUtils;
import com.techconnect.backend.dto.AuthRequest;
import com.techconnect.backend.dto.AuthResponse;
import com.techconnect.backend.dto.DeveloperProfileDto;
import com.techconnect.backend.dto.RegisterRequest;
import com.techconnect.backend.model.*;
import com.techconnect.backend.repository.ProfileRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.server.ResponseStatusException;
import java.util.*;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final ProfileRepository profileRepository;
    private final JwtUtils jwtUtils;
    private final PasswordEncoder passwordEncoder;
    private final RestTemplate restTemplate = new RestTemplate();

    private void verifyGithubUser(String username) {
        if (username == null || username.trim().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "GitHub kullanıcı adı zorunludur.");
        }
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.set("User-Agent", "TechConnect-Backend-App");
            HttpEntity<String> entity = new HttpEntity<>(headers);
            
            String url = "https://api.github.com/users/" + username.trim();
            restTemplate.exchange(url, HttpMethod.GET, entity, String.class);
        } catch (org.springframework.web.client.HttpClientErrorException.NotFound e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, 
                "Girdiğiniz GitHub kullanıcı adı bulunamadı. Lütfen geçerli bir IT profili doğrulamak için gerçek GitHub kullanıcı adınızı girin.");
        } catch (Exception e) {
            // Log warning but fallback to true (success) if GitHub is rate-limited or down
            // to prevent blocking users from signing up due to external API failures.
            System.err.println("Warning: GitHub API verification failed but fallback succeeded: " + e.getMessage());
        }
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        String email = request.getEmail().toLowerCase().trim();
        
        if (profileRepository.findByEmail(email).isPresent()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Bu e-posta adresi zaten kullanımda.");
        }
        
        // Verify GitHub username to restrict to IT sector
        verifyGithubUser(request.getGithubUsername());
        
        DeveloperProfile profile = DeveloperProfile.builder()
                .id(UUID.randomUUID())
                .email(email)
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .displayName(request.getDisplayName())
                .githubUsername(request.getGithubUsername().trim())
                .role(request.getRole())
                .experienceYears(request.getExperienceYears())
                .sector(request.getSector())
                .lookingFor(request.getLookingFor())
                .city(request.getCity())
                .isRemote(request.getIsRemote())
                .techStack(request.getTechStack() != null ? String.join(",", request.getTechStack()) : "")
                .photoNames(request.getPhotoNames() != null ? String.join(",", request.getPhotoNames()) : "person.crop.circle.fill")
                .subscriptionTier(SubscriptionTier.FREE)
                .build();
                
        profileRepository.save(profile);
        
        String token = jwtUtils.generateToken(profile.getId());
        return AuthResponse.builder()
                .token(token)
                .profile(DeveloperProfileDto.fromEntity(profile))
                .build();
    }

    @Transactional
    public AuthResponse login(AuthRequest request) {
        String email = request.getEmail().toLowerCase().trim();
        
        DeveloperProfile profile = profileRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "E-posta veya şifre hatalı."));
                
        if (profile.getPasswordHash() != null) {
            if (request.getPassword() == null || !passwordEncoder.matches(request.getPassword(), profile.getPasswordHash())) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "E-posta veya şifre hatalı.");
            }
        } else {
            // For mock users created without a password, we allow passwordless login for demo
            // or if a password isn't supplied, otherwise we can optionally throw an error.
            if (request.getPassword() != null && !request.getPassword().isEmpty()) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Bu e-posta adresi şifreli giriş için yapılandırılmamış.");
            }
        }

        String token = jwtUtils.generateToken(profile.getId());
        return AuthResponse.builder()
                .token(token)
                .profile(DeveloperProfileDto.fromEntity(profile))
                .build();
    }
}
