package com.techconnect.backend.controller;

import com.techconnect.backend.dto.MessageDto;
import com.techconnect.backend.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import java.util.*;

@Controller
@RequiredArgsConstructor
public class WebSocketChatController {

    private final ChatService chatService;
    private final SimpMessagingTemplate messagingTemplate;

    @MessageMapping("/chat.sendMessage/{matchId}")
    public void sendMessage(
            @DestinationVariable UUID matchId,
            @Payload Map<String, String> payload) {
        
        UUID senderId = UUID.fromString(payload.get("senderId"));
        String content = payload.get("content");
        
        MessageDto messageDto = chatService.sendMessage(senderId, matchId, content);
        
        // Broadcast the message to all subscribers of this match
        messagingTemplate.convertAndSend("/topic/messages/" + matchId, messageDto);
    }
}
