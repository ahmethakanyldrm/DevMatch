package com.techconnect.backend.service;

import com.techconnect.backend.dto.DeveloperProfileDto;
import com.techconnect.backend.model.*;
import com.techconnect.backend.repository.MatchRepository;
import com.techconnect.backend.repository.MessageRepository;
import com.techconnect.backend.repository.ProfileRepository;
import com.techconnect.backend.repository.SwipeRepository;
import com.techconnect.backend.repository.CoffeeChatRepository;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProfileService {

    private final ProfileRepository profileRepository;
    private final MatchRepository matchRepository;
    private final MessageRepository messageRepository;
    private final SwipeRepository swipeRepository;
    private final CoffeeChatRepository coffeeChatRepository;

    @PostConstruct
    @Transactional
    public void seedDatabase() {
        List<UUID> mockIds = Arrays.asList(
            UUID.fromString("11111111-1111-1111-1111-111111111111"),
            UUID.fromString("22222222-2222-2222-2222-222222222222"),
            UUID.fromString("33333333-3333-3333-3333-333333333333"),
            UUID.fromString("44444444-4444-4444-4444-444444444444"),
            UUID.fromString("99999999-9999-9999-9999-999999999999")
        );
        
        for (UUID mockId : mockIds) {
            if (profileRepository.existsById(mockId)) {
                List<Match> matches = matchRepository.findMatchesByUserId(mockId);
                for (Match m : matches) {
                    coffeeChatRepository.deleteAll(coffeeChatRepository.findByMatchId(m.getId()));
                    messageRepository.deleteAll(messageRepository.findByMatchIdOrderBySentAtAsc(m.getId()));
                    matchRepository.delete(m);
                }
                
                List<Swipe> swipes = swipeRepository.findAll();
                for (Swipe s : swipes) {
                    if (s.getLiker().getId().equals(mockId) || s.getLiked().getId().equals(mockId)) {
                        swipeRepository.delete(s);
                    }
                }
                
                profileRepository.deleteById(mockId);
            }
        }
    }

    public DeveloperProfileDto getProfileById(UUID id) {
        DeveloperProfile profile = profileRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Profile not found: " + id));
        return DeveloperProfileDto.fromEntity(profile);
    }

    @Transactional
    public DeveloperProfileDto updateProfile(UUID id, DeveloperProfileDto dto) {
        DeveloperProfile profile = profileRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Profile not found: " + id));
        
        profile.setDisplayName(dto.getDisplayName());
        profile.setRole(dto.getRole());
        profile.setExperienceYears(dto.getExperienceYears());
        profile.setSector(dto.getSector());
        profile.setBio(dto.getBio());
        profile.setLookingFor(dto.getLookingFor());
        profile.setCity(dto.getCity());
        profile.setIsRemote(dto.getIsRemote());
        profile.setTechStackList(dto.getTechStack());
        profile.setPhotoNamesList(dto.getPhotoNames());
        profile.setSubscriptionTier(dto.getSubscriptionTier());
        if (dto.getGender() != null) {
            profile.setGender(dto.getGender());
        }
        if (dto.getPreferredGender() != null) {
            profile.setPreferredGender(dto.getPreferredGender());
        }

        return DeveloperProfileDto.fromEntity(profileRepository.save(profile));
    }

    public List<DeveloperProfileDto> getDiscoverableProfiles(UUID userId) {
        DeveloperProfile currentUser = profileRepository.findById(userId)
                .orElseThrow(() -> new org.springframework.web.server.ResponseStatusException(
                        org.springframework.http.HttpStatus.NOT_FOUND, "User profile not found: " + userId));

        List<DeveloperProfile> candidates = profileRepository.findDiscoverableProfiles(userId);

        // Filter based on subscription tier gender preferences
        if (currentUser.getSubscriptionTier() == SubscriptionTier.PRO) {
            PreferredGender pref = currentUser.getPreferredGender();
            if (pref == PreferredGender.MALE) {
                candidates = candidates.stream()
                        .filter(p -> p.getGender() == Gender.MALE)
                        .collect(Collectors.toList());
            } else if (pref == PreferredGender.FEMALE) {
                candidates = candidates.stream()
                        .filter(p -> p.getGender() == Gender.FEMALE)
                        .collect(Collectors.toList());
            }
        }

        return candidates.stream()
                .map(candidate -> {
                    DeveloperProfileDto dto = DeveloperProfileDto.fromEntity(candidate);
                    int score = calculateCompatibilityScore(currentUser, candidate);
                    dto.setCompatibilityScore(score);
                    return dto;
                })
                .sorted(Comparator.comparingInt(DeveloperProfileDto::getCompatibilityScore).reversed())
                .limit(20)
                .collect(Collectors.toList());
    }

    private int calculateCompatibilityScore(DeveloperProfile current, DeveloperProfile target) {
        int score = 0;

        // 1. Shared technologies count * 3
        List<String> currentTechs = current.getTechStackList();
        List<String> targetTechs = target.getTechStackList();
        if (currentTechs != null && targetTechs != null && !currentTechs.isEmpty() && !targetTechs.isEmpty()) {
            Set<String> sharedTechs = new HashSet<>(currentTechs);
            sharedTechs.retainAll(targetTechs);
            score += sharedTechs.size() * 3;
        }

        // 2. Same sector ? 2 : 0
        if (current.getSector() != null && current.getSector() == target.getSector()) {
            score += 2;
        }

        // 3. looking_for compatibility ? 4 : 0
        if (current.getLookingFor() != null && target.getLookingFor() != null) {
            if (isLookingForCompatible(current.getLookingFor(), target.getLookingFor())) {
                score += 4;
            }
        }

        // 4. experience_years_diff <= 3 ? 1 : 0
        if (current.getExperienceYears() != null && target.getExperienceYears() != null) {
            if (Math.abs(current.getExperienceYears() - target.getExperienceYears()) <= 3) {
                score += 1;
            }
        }

        return score;
    }

    private boolean isLookingForCompatible(LookingFor a, LookingFor b) {
        if (a == LookingFor.MENTOR) return b == LookingFor.MENTEE;
        if (a == LookingFor.MENTEE) return b == LookingFor.MENTOR;
        return a == b;
    }

    @Transactional
    public DeveloperProfileDto uploadPhoto(UUID userId, MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Dosya boş veya geçersiz.");
        }
        
        DeveloperProfile profile = profileRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Kullanıcı profili bulunamadı: " + userId));
        
        try {
            // Create uploads directory if it does not exist
            File uploadDir = new File("uploads");
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            
            // Generate a unique filename
            String originalFilename = file.getOriginalFilename();
            String extension = "jpg"; // default fallback
            if (originalFilename != null && originalFilename.contains(".")) {
                extension = originalFilename.substring(originalFilename.lastIndexOf(".") + 1);
            }
            String newFilename = UUID.randomUUID().toString() + "." + extension;
            
            // Save file
            Path destination = Paths.get("uploads").resolve(newFilename).toAbsolutePath();
            Files.copy(file.getInputStream(), destination, StandardCopyOption.REPLACE_EXISTING);
            
            // Update profile with the new photo name
            profile.setPhotoNamesList(Collections.singletonList(newFilename));
            
            return DeveloperProfileDto.fromEntity(profileRepository.save(profile));
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Fotoğraf yüklenirken hata oluştu: " + e.getMessage(), e);
        }
    }

    @Transactional
    public void deleteProfile(UUID userId) {
        DeveloperProfile profile = profileRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Kullanıcı profili bulunamadı: " + userId));
        profileRepository.delete(profile);
    }
}
