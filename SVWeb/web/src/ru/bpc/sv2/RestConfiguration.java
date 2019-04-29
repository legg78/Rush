package ru.bpc.sv2;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import org.springframework.boot.autoconfigure.web.WebMvcRegistrationsAdapter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.condition.PatternsRequestCondition;
import org.springframework.web.servlet.mvc.method.RequestMappingInfo;
import org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping;
import ru.bpc.sv2.invocation.IAuditableObject;

import java.lang.reflect.Method;
import java.text.SimpleDateFormat;
import java.util.Map;

@Configuration
@ComponentScan("ru.bpc.sv2.rest.v1")
public class RestConfiguration {
	public final static String REST_BASE_PATH = "/rest/v1";
	public final static SimpleDateFormat DATE_FORMATTER = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");

	abstract class IgnoreAuditParameters {
		@JsonIgnore
		abstract Map<String, Object> getAuditParameters();
	}

	@Bean
	public ObjectMapper buildObjectMapper() {
		return new ObjectMapper()
				.setSerializationInclusion(JsonInclude.Include.NON_NULL)
				.enable(SerializationFeature.WRITE_NULL_MAP_VALUES)
				.disable(SerializationFeature.FAIL_ON_EMPTY_BEANS)
				.setDateFormat(DATE_FORMATTER)
				.addMixIn(IAuditableObject.class, IgnoreAuditParameters.class);
	}

	@Bean
	public WebMvcRegistrationsAdapter webMvcRegistrationsHandlerMapping() {
		return new WebMvcRegistrationsAdapter() {
			@Override
			public RequestMappingHandlerMapping getRequestMappingHandlerMapping() {
				return new RequestMappingHandlerMapping() {
					@Override
					protected void registerHandlerMethod(Object handler, Method method, RequestMappingInfo mapping) {
						Class<?> beanType = method.getDeclaringClass();
						RestController restApiController = beanType.getAnnotation(RestController.class);
						if (restApiController != null) {
							PatternsRequestCondition apiPattern = new PatternsRequestCondition(RestConfiguration.REST_BASE_PATH)
									.combine(mapping.getPatternsCondition());

							mapping = new RequestMappingInfo(mapping.getName(), apiPattern,
									mapping.getMethodsCondition(), mapping.getParamsCondition(),
									mapping.getHeadersCondition(), mapping.getConsumesCondition(),
									mapping.getProducesCondition(), mapping.getCustomCondition());
						}

						super.registerHandlerMethod(handler, method, mapping);
					}
				};
			}
		};
	}
}
