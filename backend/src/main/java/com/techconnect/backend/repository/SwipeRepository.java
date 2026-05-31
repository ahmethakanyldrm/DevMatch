package com.techconnect.backend.repository;

import com.techconnect.backend.model.Swipe;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.*;

@Repository
public interface SwipeRepository extends JpaRepository<Swipe, UUID> {
    
    Optional<Swipe> findByLikerIdAndLikedId(UUID likerId, UUID likedId);
    
    long countByLikerIdAndSwipeTypeAndCreatedAtAfter(UUID likerId, com.techconnect.backend.model.SwipeType swipeType, java.time.LocalDateTime after);
}
