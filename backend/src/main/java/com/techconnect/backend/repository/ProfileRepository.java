package com.techconnect.backend.repository;

import com.techconnect.backend.model.DeveloperProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.*;

@Repository
public interface ProfileRepository extends JpaRepository<DeveloperProfile, UUID> {
    
    Optional<DeveloperProfile> findByEmail(String email);
    
    // Find all profiles that the user hasn't swiped on yet (neither liked nor passed)
    @Query("SELECT p FROM DeveloperProfile p WHERE p.id != :userId AND p.id NOT IN " +
           "(SELECT s.liked.id FROM Swipe s WHERE s.liker.id = :userId)")
    List<DeveloperProfile> findDiscoverableProfiles(@Param("userId") UUID userId);
}
