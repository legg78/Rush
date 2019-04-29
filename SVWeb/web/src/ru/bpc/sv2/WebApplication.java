package ru.bpc.sv2;

import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.support.SpringBootServletInitializer;
import org.springframework.context.ApplicationContext;
import org.springframework.web.WebApplicationInitializer;
import org.springframework.web.context.WebApplicationContext;
import ru.bpc.sv2.system.AppVersion;

import javax.servlet.ServletContext;

public class WebApplication extends SpringBootServletInitializer implements WebApplicationInitializer {
	private static WebApplication instance;
	private ApplicationContext applicationContext;

	@Override
	protected SpringApplicationBuilder configure(SpringApplicationBuilder builder) {
		builder = super.configure(builder);
		builder.sources(WebConfiguration.class)
				.properties("spring.application.name=SVWeb")
				.properties("spring.config.name=svweb")
				.properties("svweb.version=" + AppVersion.getVersion());
		return builder;
	}

	public static ApplicationContext getApplicationContext() {
		if (instance == null) {
			throw new IllegalStateException("Cannot obtain WebApplication instance, it's not initialized yet");
		}
		return instance.applicationContext;
	}

	@Override
	protected WebApplicationContext createRootApplicationContext(ServletContext servletContext) {
		AppVersion.initializeRevision(servletContext);
		applicationContext = super.createRootApplicationContext(servletContext);
		instance = this;
		return (WebApplicationContext) applicationContext;
	}
}
