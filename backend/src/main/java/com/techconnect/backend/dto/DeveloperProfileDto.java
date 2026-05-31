package com.techconnect.backend.dto;

import com.techconnect.backend.model.DeveloperProfile;
import com.techconnect.backend.model.LookingFor;
import com.techconnect.backend.model.Sector;
import com.techconnect.backend.model.SubscriptionTier;
import com.techconnect.backend.model.Gender;
import com.techconnect.backend.model.PreferredGender;
import lombok.*;
import java.util.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DeveloperProfileDto {
    private UUID id;
    private String displayName;
    private String email;
    private String role;
    private Integer experienceYears;
    private Sector sector;
    private String bio;
    private LookingFor lookingFor;
    private String city;
    private Boolean isRemote;
    private List<String> techStack;
    private List<String> photoNames;
    private SubscriptionTier subscriptionTier;
    private String githubUsername;
    private Integer compatibilityScore;
    private Gender gender;
    private PreferredGender preferredGender;

    public static DeveloperProfileDto fromEntity(DeveloperProfile entity) {
        if (entity == null) return null;
        return DeveloperProfileDto.builder()
                .id(entity.getId())
                .displayName(entity.getDisplayName())
                .email(entity.getEmail())
                .role(entity.getRole())
                .experienceYears(entity.getExperienceYears())
                .sector(entity.getSector())
                .bio(entity.getBio())
                .lookingFor(entity.getLookingFor())
                .city(entity.getCity())
                .isRemote(entity.getIsRemote())
                .techStack(entity.getTechStackList())
                .photoNames(entity.getPhotoNamesList())
                .subscriptionTier(entity.getSubscriptionTier())
                .githubUsername(entity.getGithubUsername())
                .gender(entity.getGender())
                .preferredGender(entity.getPreferredGender())
                .build();
    }
}
