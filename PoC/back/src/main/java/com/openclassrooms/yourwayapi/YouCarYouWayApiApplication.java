package com.openclassrooms.yourwayapi;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;

@SpringBootApplication
public class YouCarYouWayApiApplication {

	public static void main(String[] args) {
		ConfigurableApplicationContext ctx = SpringApplication.run(YouCarYouWayApiApplication.class, args);
		if (Boolean.getBoolean("Ycyw.exitAfterStartup")) {
			ctx.close();
		}
	}

}
