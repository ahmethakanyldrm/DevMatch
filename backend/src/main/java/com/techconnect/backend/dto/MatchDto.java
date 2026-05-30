package com.techconnect.backend.dto;

import com.techconnect.backend.model.Match;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MatchDto {
    private UUID id;
    private DeveloperProfileDto profile;
    private LocalDateTime matchedAt;
    private String lastMessage;

    public static MatchDto fromEntity(Match entity, UUID currentUserId, String lastMessage) {
        if (entity == null) return null;
        
        // Determine which profile belongs to the other user
        DeveloperProfileDto otherProfile = currentUserId.equals(entity.getProfile1().getId())
                ? DeveloperProfileDto.fromEntity(entity.getProfile2())
                : DeveloperProfileDto.fromEntity(entity.getProfile1());

        return MatchDto.builder()
                .id(entity.getId())
                .profile(otherProfile)
                .matchedAt(entity.getMatchedAt())
                .lastMessage(lastMessage)
                .build();
    }
}
