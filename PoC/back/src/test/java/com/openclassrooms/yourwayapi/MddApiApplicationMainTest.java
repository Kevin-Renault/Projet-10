package com.openclassrooms.yourwayapi;

import org.junit.jupiter.api.Test;
import org.springframework.boot.SpringApplication;
import org.springframework.context.ConfigurableApplicationContext;

import com.openclassrooms.yourwayapi.YouCarYouWayApiApplication;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;

class YouCarYouWayApiApplicationMainTest {

    @Test
    void run_starts_and_closes_context() {
        String key = "Ycyw.exitAfterStartup";
        String previous = System.getProperty(key);

        try {
            System.setProperty(key, "true");

            // Vérifie que l'application démarre sans erreur
            assertThatCode(() -> YouCarYouWayApiApplication.main(new String[] { "--server.port=0" }))
                    .doesNotThrowAnyException();

            // Alternative: Vérifie que le contexte se crée et se ferme proprement
            ConfigurableApplicationContext context = SpringApplication.run(YouCarYouWayApiApplication.class,
                    "--server.port=0");
            assertThat(context).isNotNull();
            assertThat(context.isRunning()).isTrue();
            context.close();
            assertThat(context.isRunning()).isFalse();

        } finally {
            if (previous == null) {
                System.clearProperty(key);
            } else {
                System.setProperty(key, previous);
            }
        }
    }
}
