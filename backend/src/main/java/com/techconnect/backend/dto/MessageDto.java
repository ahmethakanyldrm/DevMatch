package com.techconnect.backend.dto;

import com.techconnect.backend.model.Message;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MessageDto {
    private UUID id;
    private UUID senderId;
    private String content;
    private LocalDateTime sentAt;
    private boolean isRead;

    public static MessageDto fromEntity(Message entity) {
        if (entity == null) return null;
        return MessageDto.builder()
                .id(entity.getId())
                .senderId(entity.getSenderId())
                .content(entity.getContent())
                .sentAt(entity.getSentAt())
                .isRead(entity.getIsRead())
                .build();
    }
}
