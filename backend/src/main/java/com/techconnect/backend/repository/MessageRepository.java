package com.techconnect.backend.repository;

import com.techconnect.backend.model.Message;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.*;

@Repository
public interface MessageRepository extends JpaRepository<Message, UUID> {
    
    List<Message> findByMatchIdOrderBySentAtAsc(UUID matchId);
}
