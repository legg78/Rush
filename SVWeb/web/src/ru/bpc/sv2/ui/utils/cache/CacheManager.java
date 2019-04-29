package ru.bpc.sv2.ui.utils.cache;

import org.apache.log4j.Logger;
import org.infinispan.configuration.global.GlobalConfigurationBuilder;
import org.infinispan.configuration.parsing.ConfigurationBuilderHolder;
import org.infinispan.configuration.parsing.ParserRegistry;
import org.infinispan.jmx.JmxDomainConflictException;
import org.infinispan.manager.DefaultCacheManager;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.utils.SystemException;

import java.io.InputStream;

public class CacheManager {
	private static final Logger logger = Logger.getLogger("SYSTEM");
	private static DefaultCacheManager manager;

	public static DefaultCacheManager getCacheManager() throws SystemException {
		if (manager == null) {
			try {
				try {
					manager = new DefaultCacheManager(getCacheConfigStream());
				} catch (JmxDomainConflictException e) {
					logger.error("Could not initialize Infinispan cache properly, trying a fallback. (" + e.getMessage() + ")", e);
					ConfigurationBuilderHolder holder = new ParserRegistry(Thread.currentThread().getContextClassLoader())
							.parse(getCacheConfigStream());
					GlobalConfigurationBuilder builder = holder.getGlobalConfigurationBuilder();
					builder.globalJmxStatistics().allowDuplicateDomains(true);
					manager = new DefaultCacheManager(holder, true);
				}
			} catch (Exception e) {
				throw new SystemException(e);
			}
		}
		return manager;
	}

	private static InputStream getCacheConfigStream() {
		return DefaultCacheManager.class.getClassLoader().getResourceAsStream(SystemConstants.INFINISPAN_CONF_PATH);
	}

	public static boolean isCacheManagerCreated() {
		return manager != null;
	}

	public static void destroyCacheManager() throws SystemException {
		CacheManager.getCacheManager().stop();
		manager = null;
	}
}
