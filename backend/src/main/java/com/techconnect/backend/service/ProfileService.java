package com.techconnect.backend.service;

import com.techconnect.backend.dto.DeveloperProfileDto;
import com.techconnect.backend.model.*;
import com.techconnect.backend.repository.MatchRepository;
import com.techconnect.backend.repository.MessageRepository;
import com.techconnect.backend.repository.ProfileRepository;
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

    @PostConstruct
    public void seedDatabase() {
        if (profileRepository.count() == 0) {
            // Seed initial mock developers matching mobile profiles
            
            DeveloperProfile merve = DeveloperProfile.builder()
                    .id(UUID.fromString("11111111-1111-1111-1111-111111111111"))
                    .displayName("Merve Yılmaz")
                    .email("merve@startup.io")
                    .role("Senior iOS Developer")
                    .experienceYears(6)
                    .sector(Sector.STARTUP)
                    .bio("7 yıldır Swift ile mobil uygulamalar geliştiriyorum. Clean Architecture, MVVM ve SwiftUI odak noktalarım. Tecrübelerimi paylaşmak için Mentee'ler arıyorum.")
                    .lookingFor(LookingFor.MENTOR)
                    .city("Ankara")
                    .isRemote(true)
                    .techStack("Swift,SwiftUI,Combine,UIKit,Git,CI/CD")
                    .photoNames("person.crop.circle.badge.checkmark")
                    .subscriptionTier(SubscriptionTier.FREE)
                    .build();

            DeveloperProfile elif = DeveloperProfile.builder()
                    .id(UUID.fromString("22222222-2222-2222-2222-222222222222"))
                    .displayName("Elif Kaya")
                    .email("elif@freelance.net")
                    .role("UI/UX Designer")
                    .experienceYears(3)
                    .sector(Sector.FREELANCE)
                    .bio("Figma ve Adobe XD ile mobil arayüz tasarımları yapıyorum. Yazılımcılarla ortak mobil projelerde (Side Project) iş birliği yapmak istiyorum.")
                    .lookingFor(LookingFor.COLLABORATION)
                    .city("İzmir")
                    .isRemote(true)
                    .techStack("Figma,Sketch,HTML,CSS,UI Design")
                    .photoNames("person.crop.circle.fill")
                    .subscriptionTier(SubscriptionTier.FREE)
                    .build();

            DeveloperProfile can = DeveloperProfile.builder()
                    .id(UUID.fromString("33333333-3333-3333-3333-333333333333"))
                    .displayName("Can Demir")
                    .email("can@corporate.com")
                    .role("Cloud & Architecture Tech Lead")
                    .experienceYears(8)
                    .sector(Sector.CORPORATE)
                    .bio("Kurumsal firmalarda mikroservis mimarileri ve bulut entegrasyonları tasarlıyorum. Go ve Java favorilerim. Kahve sohbetlerine açığım.")
                    .lookingFor(LookingFor.COFFEE_CHAT)
                    .city("İstanbul")
                    .isRemote(false)
                    .techStack("Java,Spring Boot,Go,Docker,Kubernetes,AWS")
                    .photoNames("person.crop.circle.fill")
                    .subscriptionTier(SubscriptionTier.PRO)
                    .build();

            DeveloperProfile selin = DeveloperProfile.builder()
                    .id(UUID.fromString("44444444-4444-4444-4444-444444444444"))
                    .displayName("Selin Yıldız")
                    .email("selin@startup.io")
                    .role("Backend Go Developer")
                    .experienceYears(2)
                    .sector(Sector.STARTUP)
                    .bio("Go, Gin ve Python FastAPI ile backend servisleri geliştiriyorum. PostgreSQL ve Redis kullanıyorum. Mentör arayışındayım.")
                    .lookingFor(LookingFor.MENTEE)
                    .city("İstanbul")
                    .isRemote(true)
                    .techStack("Go,Python,PostgreSQL,Redis,Docker")
                    .photoNames("person.crop.circle.fill")
                    .subscriptionTier(SubscriptionTier.FREE)
                    .build();

            DeveloperProfile ahmet = DeveloperProfile.builder()
                    .id(UUID.fromString("99999999-9999-9999-9999-999999999999"))
                    .displayName("Ahmet Hakan")
                    .email("ahmet@devmatch.com")
                    .role("iOS Geliştirici")
                    .experienceYears(4)
                    .sector(Sector.STARTUP)
                    .bio("SwiftUI, Combine ve Java Spring Boot ile full-stack mobil uygulamalar geliştiriyorum. Yeni insanlarla tanışmak ve projeler üzerine kahve eşliğinde sohbet etmek harika olur!")
                    .lookingFor(LookingFor.COLLABORATION)
                    .city("İstanbul")
                    .isRemote(true)
                    .techStack("Swift,SwiftUI,Combine,Java,Spring Boot,PostgreSQL,WebSocket")
                    .photoNames("person.crop.circle.badge.checkmark")
                    .subscriptionTier(SubscriptionTier.FREE)
                    .build();

            profileRepository.saveAll(Arrays.asList(merve, elif, can, selin, ahmet));

            // Seed Matches
            UUID match1Id = UUID.fromString("11111111-2222-3333-4444-555555555555");
            Match match1 = Match.builder()
                    .id(match1Id)
                    .profile1(merve)
                    .profile2(ahmet)
                    .matchedAt(LocalDateTime.now().minusDays(1))
                    .build();

            UUID match2Id = UUID.fromString("22222222-3333-4444-5555-666666666666");
            Match match2 = Match.builder()
                    .id(match2Id)
                    .profile1(elif)
                    .profile2(ahmet)
                    .matchedAt(LocalDateTime.now().minusHours(1))
                    .build();

            matchRepository.saveAll(Arrays.asList(match1, match2));

            // Seed Messages
            Message msg1 = Message.builder()
                    .id(UUID.randomUUID())
                    .match(match1)
                    .senderId(merve.getId())
                    .content("Merhaba Ahmet Hakan! SwiftUI projen gerçekten çok temiz görünüyor.")
                    .sentAt(LocalDateTime.now().minusHours(24))
                    .isRead(true)
                    .build();

            Message msg2 = Message.builder()
                    .id(UUID.randomUUID())
                    .match(match1)
                    .senderId(ahmet.getId())
                    .content("Çok teşekkürler Merve! Sizin deneyimlerinizden faydalanmak harika olur.")
                    .sentAt(LocalDateTime.now().minusHours(23))
                    .isRead(true)
                    .build();

            Message msg3 = Message.builder()
                    .id(UUID.randomUUID())
                    .match(match1)
                    .senderId(merve.getId())
                    .content("SwiftUI hakkında sorduğun soruya detaylı bakacağım.")
                    .sentAt(LocalDateTime.now().minusHours(22))
                    .isRead(true)
                    .build();

            Message msg4 = Message.builder()
                    .id(UUID.randomUUID())
                    .match(match2)
                    .senderId(ahmet.getId())
                    .content("Selam Elif, tasarımlarını inceledim, DevMatch projesi için bir UI/UX desteği arıyorum.")
                    .sentAt(LocalDateTime.now().minusMinutes(50))
                    .isRead(true)
                    .build();

            Message msg5 = Message.builder()
                    .id(UUID.randomUUID())
                    .match(match2)
                    .senderId(elif.getId())
                    .content("Proje iş birliği için harika bir fikir, konuşalım.")
                    .sentAt(LocalDateTime.now().minusMinutes(40))
                    .isRead(false)
                    .build();

            messageRepository.saveAll(Arrays.asList(msg1, msg2, msg3, msg4, msg5));
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

        return DeveloperProfileDto.fromEntity(profileRepository.save(profile));
    }

    public List<DeveloperProfileDto> getDiscoverableProfiles(UUID userId) {
        DeveloperProfile currentUser = profileRepository.findById(userId)
                .orElseThrow(() -> new org.springframework.web.server.ResponseStatusException(
                        org.springframework.http.HttpStatus.NOT_FOUND, "User profile not found: " + userId));

        List<DeveloperProfile> candidates = profileRepository.findDiscoverableProfiles(userId);

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
