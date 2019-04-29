package ru.bpc.sv2;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.autoconfigure.jdbc.DataSourceProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.context.annotation.Lazy;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.lookup.JndiDataSourceLookup;
import org.springframework.session.web.http.CookieSerializer;
import org.springframework.session.web.http.DefaultCookieSerializer;
import org.springframework.util.StringUtils;
import ru.bpc.sv2.datasource.LazyDataSource;
import ru.bpc.sv2.logic.utility.JndiUtils;

import javax.sql.DataSource;

@Import({
		AuthConfiguration.class,
		WsConfiguration.class,
        JmxMonitoringConfiguration.class,
		RestConfiguration.class
})
@EnableAutoConfiguration(exclude = {DataSourceAutoConfiguration.class})
@EnableConfigurationProperties(DataSourceProperties.class)
@Configuration
public class WebConfiguration {
	@Bean
	public CookieSerializer cookieSerializer(@Value("${server.session.cookie.name}") String cookieName) {
		DefaultCookieSerializer cookieSerializer = new DefaultCookieSerializer();
		if (StringUtils.hasText(cookieName)) {
			cookieSerializer.setCookieName(cookieName);
		}
		return cookieSerializer;
	}

	@Bean
	@Lazy
	public JdbcTemplate jdbcTemplate(DataSource dataSource) {
		return new JdbcTemplate(dataSource);
	}

	@Bean
	@Lazy
	public DataSource dataSource() {
		return new LazyDataSource() {
			@Override
			protected DataSource initDataSource() {
				JndiDataSourceLookup dataSourceLookup = new JndiDataSourceLookup();
				return dataSourceLookup.getDataSource(JndiUtils.JNDI_NAME);
			}
		};
	}
}
