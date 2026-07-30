package com.openclassrooms.yourwayapi.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.stereotype.Component;

@Component
public class DatabaseStartupCheck implements ApplicationRunner {

    private static final Logger LOGGER = LoggerFactory.getLogger(DatabaseStartupCheck.class);

    private final ConfigurableApplicationContext applicationContext;
    private final String databaseUrl;
    private final String databaseUser;
    private final String databasePassword;

    public DatabaseStartupCheck(
            ConfigurableApplicationContext applicationContext,
            @Value("${spring.datasource.url}") String databaseUrl,
            @Value("${spring.datasource.username}") String databaseUser,
            @Value("${spring.datasource.password}") String databasePassword) {
        this.applicationContext = applicationContext;
        this.databaseUrl = databaseUrl;
        this.databaseUser = databaseUser;
        this.databasePassword = databasePassword;
    }

    @Override
    public void run(ApplicationArguments args) {
        try (Connection connection = DriverManager.getConnection(databaseUrl, databaseUser, databasePassword);
                Statement statement = connection.createStatement()) {
            statement.execute("SELECT 1");
            LOGGER.info("[DB] Connexion PostgreSQL OK: {}", connection.getMetaData().getURL());
        } catch (SQLException ignored) {
            LOGGER.error("[DB] PostgreSQL indisponible sur localhost:5432. Demarrez Docker puis relancez le back.");
            int exitCode = org.springframework.boot.SpringApplication.exit(applicationContext, () -> 1);
            System.exit(exitCode);
        }
    }
}