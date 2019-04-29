package ru.bpc.sv2.ui.utils;

import ru.bpc.sv2.ui.session.UserSession;
import util.auxil.ManagedBeanWrapper;

import java.util.Locale;

/**
 * Holder class that associates a LocaleContext instance
 * with the current thread. The LocaleContext will be inherited
 * by any child threads spawned by the current thread
 */
public class LocaleContextHolder {
	private static final ThreadLocal<Locale> localeHolder = new InheritableThreadLocal<Locale>();

	public static Locale getLocale() {
		UserSession usession = ManagedBeanWrapper.getManagedBean("usession");
		Locale locale = null;
		if (usession != null) {
			locale = usession.getCurrentLocale();
		}
		if (locale == null)
			locale = localeHolder.get();
		return locale != null ? locale : Locale.US;
	}

	public static void setLocale(Locale locale) {
		if (locale == null)
			localeHolder.remove();
		else
			localeHolder.set(locale);
	}
}
