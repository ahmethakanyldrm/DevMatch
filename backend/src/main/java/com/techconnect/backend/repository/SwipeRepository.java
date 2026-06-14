package com.techconnect.backend.repository;

import com.techconnect.backend.model.Swipe;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.*;

@Repository
public interface SwipeRepository extends JpaRepository<Swipe, UUID> {
    
    Optional<Swipe> findByLikerIdAndLikedId(UUID likerId, UUID likedId);
    
    long countByLikerIdAndSwipeTypeAndCreatedAtAfter(UUID likerId, com.techconnect.backend.model.SwipeType swipeType, java.time.LocalDateTime after);

    @org.springframework.data.jpa.repository.Query("SELECT s FROM Swipe s WHERE s.liked.id = :userId AND s.swipeType = com.techconnect.backend.model.SwipeType.LIKE " +
           "AND s.liker.id NOT IN (SELECT m.profile1.id FROM Match m WHERE m.profile2.id = :userId) " +
           "AND s.liker.id NOT IN (SELECT m.profile2.id FROM Match m WHERE m.profile1.id = :userId)")
    List<Swipe> findIncomingLikes(@org.springframework.data.repository.query.Param("userId") UUID userId);
}
