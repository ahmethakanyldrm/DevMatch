package com.techconnect.backend.dto;

import com.techconnect.backend.model.SwipeType;
import lombok.Data;
import java.util.UUID;

@Data
public class SwipeRequest {
    private UUID likedId;
    private SwipeType swipeType;
}
