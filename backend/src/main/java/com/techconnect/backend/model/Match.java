package com.techconnect.backend.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "matches", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"profile_1_id", "profile_2_id"})
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Match {

    @Id
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "profile_1_id", nullable = false)
    private DeveloperProfile profile1;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "profile_2_id", nullable = false)
    private DeveloperProfile profile2;

    @Column(name = "matched_at", nullable = false)
    @Builder.Default
    private LocalDateTime matchedAt = LocalDateTime.now();
}
