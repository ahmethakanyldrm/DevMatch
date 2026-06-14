package com.techconnect.backend.config;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.assertj.core.api.Assertions.*;

@DisplayName("JwtUtils Tests")
class JwtUtilsTest {

    private JwtUtils jwtUtils;

    @BeforeEach
    void setUp() throws Exception {
        jwtUtils = new JwtUtils();
        // Inject test secret via reflection (field: jwtSecret)
        var field = JwtUtils.class.getDeclaredField("jwtSecret");
        field.setAccessible(true);
        field.set(jwtUtils, "test_super_secret_jwt_key_at_least_256_bits_long_x9k2m7p");
    }

    @Test
    @DisplayName("Token üretilip parse edilince aynı UUID geri gelmeli")
    void generateToken_thenParseBack_returnsSameUserId() {
        UUID userId = UUID.randomUUID();

        String token = jwtUtils.generateToken(userId);
        UUID parsed = jwtUtils.getUserIdFromToken(token);

        assertThat(parsed).isEqualTo(userId);
    }

    @Test
    @DisplayName("Geçerli token doğrulanmalı")
    void validateToken_validToken_returnsTrue() {
        UUID userId = UUID.randomUUID();
        String token = jwtUtils.generateToken(userId);

        assertThat(jwtUtils.validateToken(token)).isTrue();
    }

    @Test
    @DisplayName("Tamamen geçersiz string doğrulanmamalı")
    void validateToken_invalidString_returnsFalse() {
        assertThat(jwtUtils.validateToken("not.a.jwt")).isFalse();
    }

    @Test
    @DisplayName("Boş string doğrulanmamalı")
    void validateToken_emptyString_returnsFalse() {
        assertThat(jwtUtils.validateToken("")).isFalse();
    }

    @Test
    @DisplayName("Token null ise doğrulanmamalı")
    void validateToken_null_returnsFalse() {
        assertThat(jwtUtils.validateToken(null)).isFalse();
    }

    @Test
    @DisplayName("İmzası bozulmuş token doğrulanmamalı")
    void validateToken_tamperedToken_returnsFalse() {
        UUID userId = UUID.randomUUID();
        String token = jwtUtils.generateToken(userId);
        // Payload kısmını boz
        String tampered = token.substring(0, token.lastIndexOf('.') - 5) + "AAAAA" + token.substring(token.lastIndexOf('.'));

        assertThat(jwtUtils.validateToken(tampered)).isFalse();
    }
}
