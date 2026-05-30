package com.techconnect.backend.dto;

import com.techconnect.backend.model.CoffeeChatRequest;
import com.techconnect.backend.model.CoffeeChatStatus;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CoffeeChatRequestDto {
    private UUID id;
    private UUID matchId;
    private UUID requesterId;
    private LocalDateTime proposedTime;
    private CoffeeChatStatus status;

    public static CoffeeChatRequestDto fromEntity(CoffeeChatRequest entity) {
        if (entity == null) return null;
        return CoffeeChatRequestDto.builder()
                .id(entity.getId())
                .matchId(entity.getMatch().getId())
                .requesterId(entity.getRequesterId())
                .proposedTime(entity.getProposedTime())
                .status(entity.getStatus())
                .build();
    }
}
