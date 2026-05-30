package com.techconnect.backend.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "swipes", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"liker_id", "liked_id"})
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Swipe {

    @Id
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "liker_id", nullable = false)
    private DeveloperProfile liker;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "liked_id", nullable = false)
    private DeveloperProfile liked;

    @Enumerated(EnumType.STRING)
    @Column(name = "swipe_type", nullable = false, length = 10)
    private SwipeType swipeType;

    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();
}
