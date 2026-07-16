package com.openclassrooms.yourwayapi.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.Map;
import com.openclassrooms.yourwayapi.ApiEndpoints;

@RestController
public class EnvController {
    @Value("${spring.profiles.active:dev}")
    private String activeProfile;

    @GetMapping(ApiEndpoints.ENV)
    public Map<String, String> getEnv() {
        // Renvoie le profil actif ("dev", "prod", etc.)
        return Map.of("env", activeProfile);
    }
}
