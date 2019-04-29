package ru.bpc.sv2;

import org.apache.cxf.Bus;
import org.apache.cxf.jaxws.EndpointImpl;
import org.apache.cxf.transport.servlet.CXFServlet;
import org.apache.cxf.ws.policy.WSPolicyFeature;
import org.apache.cxf.ws.security.SecurityConstants;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.StringUtils;
import ru.bpc.sv.ws.application.ApplicationWs;
import ru.bpc.sv.ws.application.ApplicationWsSecure;
import ru.bpc.sv.ws.integration.*;
import ru.bpc.sv.ws.process.ProcessesWS;
import ru.bpc.sv.ws.process.svng.CallbackService;
import ru.bpc.sv.ws.reports.ReportsWS;
import ru.bpc.sv2.security.WSUsernameTokenValidator;

import javax.jws.WebService;
import javax.xml.ws.WebServiceProvider;
import java.lang.annotation.Annotation;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

@Configuration
public class WsConfiguration {
	@Autowired
	private ConfigurableBeanFactory beanFactory;

	private List wsClasses = Arrays.asList(
			ApplicationWs.class, ApplicationWsSecure.class, AuthWS.class,
			CallbackService.class, CardBatchWebService.class, ClearWebService.class,
			InfoWebService.class, InstagentWebService.class, InstantIssueWebService.class,
			MerchantPortalWebService.class, OperStageWebService.class, ProcessesWS.class,
			ReportsWS.class, DictionaryWebService.class, OmniChannelsWebService.class,
			DppWebService.class, PmoWebService.class);

	@Autowired
	private void initBus(Bus bus) {
		bus.setFeatures(Collections.singletonList(new WSPolicyFeature()));
		bus.getProperties().put(SecurityConstants.USERNAME_TOKEN_VALIDATOR, wsUsernameTokenValidator());
		//noinspection unchecked
		for (Class wsClass : (List<Class>) wsClasses) {
			String name = null;
			for (Annotation annotation : wsClass.getAnnotations()) {
				if (annotation.annotationType() == WebService.class) {
					name = ((WebService) annotation).serviceName();
				} else if (annotation.annotationType() == WebServiceProvider.class) {
					name = ((WebServiceProvider) annotation).serviceName();
				}
			}
			if (!StringUtils.hasText(name)) {
				throw new RuntimeException("Cannot get serviceName for service " + wsClass);
			}
			try {
				EndpointImpl endpoint = new EndpointImpl(bus, wsClass.newInstance());
				endpoint.publish("/" + name);
				beanFactory.registerSingleton("wsEndpoint_" + name, endpoint);
			} catch (Exception e) {
				throw new RuntimeException("Could not register webservice " + wsClass, e);
			}
		}
	}

	@Bean
	public WSUsernameTokenValidator wsUsernameTokenValidator() {
		return new WSUsernameTokenValidator();
	}

	@Bean
	public FilterRegistrationBean cxfServletRegistration() {
		return new FilterRegistrationBean(new CXFServlet());
	}
}
