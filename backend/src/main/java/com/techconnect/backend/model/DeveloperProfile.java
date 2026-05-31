package com.techconnect.backend.model;

import jakarta.persistence.*;
import lombok.*;
import java.util.*;

@Entity
@Table(name = "developer_profiles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DeveloperProfile {

    @Id
    private UUID id;

    @Column(name = "display_name", nullable = false, length = 100)
    private String displayName;

    @Column(name = "email", unique = true, nullable = false, length = 100)
    private String email;

    @Column(name = "role", nullable = false, length = 100)
    private String role;

    @Column(name = "experience_years", nullable = false)
    private Integer experienceYears;

    @Enumerated(EnumType.STRING)
    @Column(name = "sector", nullable = false, length = 50)
    private Sector sector;

    @Column(name = "bio", length = 300)
    private String bio;

    @Enumerated(EnumType.STRING)
    @Column(name = "looking_for", nullable = false, length = 50)
    private LookingFor lookingFor;

    @Column(name = "city", length = 100)
    private String city;

    @Column(name = "is_remote", nullable = false)
    @Builder.Default
    private Boolean isRemote = false;

    @Column(name = "tech_stack", length = 500)
    private String techStack;

    @Column(name = "photo_names", length = 500)
    private String photoNames;

    @Enumerated(EnumType.STRING)
    @Column(name = "subscription_tier", nullable = false, length = 20)
    @Builder.Default
    private SubscriptionTier subscriptionTier = SubscriptionTier.FREE;

    @Enumerated(EnumType.STRING)
    @Column(name = "gender", nullable = false, length = 20)
    @Builder.Default
    private Gender gender = Gender.MALE;

    @Enumerated(EnumType.STRING)
    @Column(name = "preferred_gender", nullable = false, length = 20)
    @Builder.Default
    private PreferredGender preferredGender = PreferredGender.EVERYONE;
    
    @Column(name = "password_hash", length = 100)
    private String passwordHash;

    @Column(name = "github_username", length = 100)
    private String githubUsername;

    // Helper methods to convert techStack to List
    public List<String> getTechStackList() {
        if (techStack == null || techStack.trim().isEmpty()) {
            return Collections.emptyList();
        }
        return Arrays.asList(techStack.split(","));
    }

    public void setTechStackList(List<String> list) {
        if (list == null || list.isEmpty()) {
            this.techStack = null;
        } else {
            this.techStack = String.join(",", list);
        }
    }

    // Helper methods to convert photoNames to List
    public List<String> getPhotoNamesList() {
        if (photoNames == null || photoNames.trim().isEmpty()) {
            return Collections.emptyList();
        }
        return Arrays.asList(photoNames.split(","));
    }

    public void setPhotoNamesList(List<String> list) {
        if (list == null || list.isEmpty()) {
            this.photoNames = null;
        } else {
            this.photoNames = String.join(",", list);
        }
    }
}
