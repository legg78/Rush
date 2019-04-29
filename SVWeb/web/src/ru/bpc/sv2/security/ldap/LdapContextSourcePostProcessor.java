package ru.bpc.sv2.security.ldap;

import org.springframework.ldap.core.support.AbstractContextSource;
import org.springframework.security.config.annotation.ObjectPostProcessor;

public class LdapContextSourcePostProcessor implements ObjectPostProcessor<AbstractContextSource> {
	@Override
	public <O extends AbstractContextSource> O postProcess(O object) {
		object.afterPropertiesSet();
		return object;
	}
}
