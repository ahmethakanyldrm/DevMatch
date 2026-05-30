package com.techconnect.backend.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "coffee_chat_requests")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CoffeeChatRequest {

    @Id
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "match_id", nullable = false)
    private Match match;

    @Column(name = "requester_id", nullable = false)
    private UUID requesterId;

    @Column(name = "proposed_time", nullable = false)
    private LocalDateTime proposedTime;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    @Builder.Default
    private CoffeeChatStatus status = CoffeeChatStatus.PENDING;
}
