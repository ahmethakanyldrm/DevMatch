package com.techconnect.backend.repository;

import com.techconnect.backend.model.CoffeeChatRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.*;

@Repository
public interface CoffeeChatRepository extends JpaRepository<CoffeeChatRequest, UUID> {
    
    List<CoffeeChatRequest> findByMatchId(UUID matchId);
}
