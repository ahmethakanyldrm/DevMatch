package com.techconnect.backend.repository;

import com.techconnect.backend.model.Match;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.*;

@Repository
public interface MatchRepository extends JpaRepository<Match, UUID> {
    
    // Find all matches where the user is either profile1 or profile2
    @Query("SELECT m FROM Match m WHERE m.profile1.id = :userId OR m.profile2.id = :userId")
    List<Match> findMatchesByUserId(@Param("userId") UUID userId);
    
    // Find a specific match between two profiles if it exists
    @Query("SELECT m FROM Match m WHERE (m.profile1.id = :p1 AND m.profile2.id = :p2) OR (m.profile1.id = :p2 AND m.profile2.id = :p1)")
    Optional<Match> findMatchBetween(@Param("p1") UUID p1, @Param("p2") UUID p2);
}
