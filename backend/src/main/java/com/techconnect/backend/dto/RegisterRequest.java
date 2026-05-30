package com.techconnect.backend.dto;

import com.techconnect.backend.model.LookingFor;
import com.techconnect.backend.model.Sector;
import lombok.Data;
import java.util.List;

@Data
public class RegisterRequest {
    private String email;
    private String password;
    private String displayName;
    private String githubUsername;
    private String role;
    private Integer experienceYears;
    private Sector sector;
    private LookingFor lookingFor;
    private String city;
    private Boolean isRemote;
    private List<String> techStack;
    private List<String> photoNames;
}
