package com.techconnect.backend.dto;

import com.techconnect.backend.model.SwipeType;
import com.fasterxml.jackson.annotation.JsonAlias;
import lombok.Data;
import java.util.UUID;

@Data
public class SwipeRequest {
    @JsonAlias("likedId")
    private UUID targetUserId;
    private SwipeType swipeType;
}
