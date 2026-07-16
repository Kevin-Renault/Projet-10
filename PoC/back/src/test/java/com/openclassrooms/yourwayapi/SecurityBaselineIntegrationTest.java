package com.openclassrooms.yourwayapi;

import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;

import com.openclassrooms.yourwayapi.ApiEndpoints;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class SecurityBaselineIntegrationTest extends AbstractIntegrationTest {

        @Test
        void secured_endpoints_without_auth_are_rejected() {
                assertUnauthorized(rest.exchange(
                                ApiEndpoints.CHATS,
                                HttpMethod.GET,
                                new HttpEntity<>(null, jsonHeaders()),
                                String.class));

                assertUnauthorized(rest.exchange(
                                ApiEndpoints.USERS,
                                HttpMethod.GET,
                                new HttpEntity<>(null, jsonHeaders()),
                                String.class));

                assertUnauthorized(rest.exchange(
                                ApiEndpoints.AUTH_ME,
                                HttpMethod.GET,
                                new HttpEntity<>(null, jsonHeaders()),
                                String.class));

                assertUnauthorized(rest.exchange(
                                ApiEndpoints.CHATS + "/1",
                                HttpMethod.GET,
                                new HttpEntity<>(null, jsonHeaders()),
                                String.class));
        }

        private static void assertUnauthorized(ResponseEntity<?> response) {
                Assertions.assertThat(response.getStatusCode().value()).isIn(401, 403);
        }
}
