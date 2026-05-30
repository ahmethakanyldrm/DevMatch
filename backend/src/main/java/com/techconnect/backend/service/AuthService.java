package com.techconnect.backend.service;

import com.techconnect.backend.config.JwtUtils;
import com.techconnect.backend.dto.AuthRequest;
import com.techconnect.backend.dto.AuthResponse;
import com.techconnect.backend.dto.DeveloperProfileDto;
import com.techconnect.backend.model.*;
import com.techconnect.backend.repository.ProfileRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.*;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final ProfileRepository profileRepository;
    private final JwtUtils jwtUtils;

    @Transactional
    public AuthResponse login(AuthRequest request) {
        String email = request.getEmail().toLowerCase().trim();
        
        DeveloperProfile profile = profileRepository.findByEmail(email)
                .orElseGet(() -> {
                    // Generate clean display name from email (e.g. ahmet@mail.com -> Ahmet)
                    String namePart = email.split("@")[0];
                    String capitalizedName = namePart.substring(0, 1).toUpperCase() + namePart.substring(1);
                    
                    DeveloperProfile newProfile = DeveloperProfile.builder()
                            .id(UUID.randomUUID())
                            .displayName(capitalizedName)
                            .email(email)
                            .role("Yazılım Geliştirici")
                            .experienceYears(1)
                            .sector(Sector.STARTUP)
                            .lookingFor(LookingFor.COLLABORATION)
                            .city("İstanbul")
                            .isRemote(true)
                            .techStack("Java,Spring Boot")
                            .photoNames("person.crop.circle.fill")
                            .subscriptionTier(SubscriptionTier.FREE)
                            .build();
                    return profileRepository.save(newProfile);
                });

        String token = jwtUtils.generateToken(profile.getId());
        return AuthResponse.builder()
                .token(token)
                .profile(DeveloperProfileDto.fromEntity(profile))
                .build();
    }
}
