package util.servlet.listener;

import com.bpcbt.sv.utils.StringCrypter;
import com.bpcbt.svng.auth.AuthParamsHolder;
import org.apache.log4j.Logger;
import org.quartz.SchedulerException;
import org.springframework.util.StringUtils;
import ru.bpc.sv2.mastercom.api.MasterCom;
import ru.bpc.sv2.mastercom.api.MasterComEnvironment;
import ru.bpc.sv2.scheduler.WebSchedule;
import ru.bpc.sv2.scheduler.cbs.CbsReporter;
import ru.bpc.sv2.scheduler.cbs.MultiCbsReporter;
import ru.bpc.sv2.scheduler.eWallet.EWalletReporter;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.system.MbSystemInfo;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.ui.utils.cache.CacheManager;
import ru.bpc.sv2.ui.utils.cache.DictCache;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.SystemException;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.lang.reflect.Field;
import java.math.BigDecimal;

public class ContextInitializedListener implements ServletContextListener {

	private static final Integer MAX_SAVE_POST_SIZE_WL_12 = 32768;

	private static final Logger logger = Logger.getLogger("SYSTEM");

	private final CbsReporter cbsReporter = new CbsReporter();
	private final MultiCbsReporter multiCbsReporter = new MultiCbsReporter();
	private final EWalletReporter eWalletReporter = new EWalletReporter();

	@Override
	public void contextDestroyed(ServletContextEvent ctxEvent) {
		try {
			WebSchedule.getInstance().cancel();
			if (CacheManager.isCacheManagerCreated()) {
				destroyCaches();
				CacheManager.destroyCacheManager();
			}
			cbsReporter.stop();
			multiCbsReporter.stop();
			eWalletReporter.stop();
		} catch (SchedulerException | SystemException e) {
			logger.error("", e);
		}
	}

	@Override
	public void contextInitialized(ServletContextEvent ctxEvent) {
		ServletContext sc = ctxEvent.getServletContext();

		MbSystemInfo.SERVER_NAME = sc.getServerInfo();

		if (MbSystemInfo.weblogic()) {
			// We need to increase maximal saved POST size for WebLogic 12.x and higher
			try {
				//noinspection JavaReflectionMemberAccess
				Field sessionConfigManager = sc.getClass().getDeclaredField("sessionConfigManager");
				sessionConfigManager.setAccessible(true);
				Field maxSavePostSize = sessionConfigManager.get(sc).getClass().getDeclaredField("maxSavePostSize");
				maxSavePostSize.setAccessible(true);
				maxSavePostSize.set(sessionConfigManager.get(sc), MAX_SAVE_POST_SIZE_WL_12);
			} catch (NoSuchFieldException e) {
				logger.debug("Failed to get ServletContext.sessionConfigManager. Weblogic version is below 12 probably", e);
			} catch (Exception e) {
				logger.debug("Failed to set MAX_SAVE_POST_SIZE: " + e);
			}
		}

		activateCaches();
		configureForSso();
		cbsReporter.start();
		multiCbsReporter.start();
		eWalletReporter.start();

		initializeMasterCom();
	}

	private void activateCaches() {
		try {
			logger.info("initializing dictCache...");
			DictCache.getInstance();
			logger.info("dictCache initialized.");
		} catch (Exception e) {
			logger.error("", e);
		}
		try {
			logger.info("initializing appElementsCache...");
			AppElementsCache.getInstance();
			logger.info("appElementsCache initialized.");
		} catch (Exception e) {
			logger.error("", e);
		}
		try {
			logger.info("initializing settingsCache...");
			SettingsCache.getInstance();
			logger.info("settingsCache initialized.");
		} catch (Exception e) {
			logger.error("", e);
		}
		try {
			logger.info("initializing countryCache...");
			CountryCache.getInstance();
			logger.info("countryCache initialized.");
		} catch (Exception e) {
			logger.error("", e);
		}
		try {
			logger.info("initializing currencyCache...");
			CurrencyCache.getInstance();
			logger.info("currencyCache initialized.");
		} catch (Exception e) {
			logger.error("", e);
		}

		try {
			logger.info("initializing EntityIcons...");
			EntityIcons.getInstance();
			logger.info("EntityIcons initialized.");
		} catch (Exception e) {
			logger.error("", e);
		}

		try {
			logger.info("initializing terminalParametersCache...");
			TerminalParametersCache.getInstance();
			logger.info("terminalParametersCache initialized.");
		} catch (Exception e) {
			logger.error("", e);
		}
	}


	private void configureForSso() {
		BigDecimal useSso = SettingsCache.getInstance().getParameterNumberValue(SettingsConstants.AUTHENTICATION_USE_SSO_MODULE);
		AuthParamsHolder.setUseSso(useSso != null && useSso.intValue() > 0);
		String authModuleUrl = System.getProperty("auth_module_url");
		if (StringUtils.hasText(authModuleUrl)) {
			logger.info("System parameter auth_module_url is set. Will use its value " + authModuleUrl);
		} else {
			authModuleUrl = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.AUTHENTICATION_SSO_MODULE_URL);
		}
		AuthParamsHolder.setSsoServer(StringUtils.hasText(authModuleUrl) ? authModuleUrl : null);
	}

	private void destroyCaches() {
		DictCache.getInstance().stopCache();
		DictCache.destroyInstance();
		AppElementsCache.destroyInstance();
		SettingsCache.getInstance().stopCache();
		SettingsCache.destroyInstance();
		CountryCache.getInstance().stopCache();
		CountryCache.destroyInstance();
		CurrencyCache.getInstance().stopCache();
		CurrencyCache.destroyInstance();
		EntityIcons.destroyInstance();
		TerminalParametersCache.getInstance().stopCache();
		TerminalParametersCache.destroyInstance();
	}

	private void initializeMasterCom() {
		try {
			MasterComEnvironment env;
			if (Boolean.TRUE.equals(SettingsCache.getInstance().getParameterBooleanValue(SettingsConstants.MASTERCOM_PRODUCTION_MODE))) {
				env = MasterComEnvironment.PRODUCTION;
			} else {
				env = MasterComEnvironment.SANDBOX;
			}

			MasterCom.initEnvironment(env);

			String consumerKey = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.MASTERCOM_CONSUMER_KEY);
			if (consumerKey != null) {
				consumerKey = (new StringCrypter()).decrypt(consumerKey);
			}
			String keyAlias = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.MASTERCOM_KEY_ALIAS);
			String keyPassword = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.MASTERCOM_KEY_PASSWORD);
			if (keyPassword != null) {
				keyPassword = (new StringCrypter()).decrypt(keyPassword);
			}
			String privateKeyPath = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.MASTERCOM_PRIVATE_KEY_PATH);

			MasterCom.initDefaultAuthentication(consumerKey, keyAlias, keyPassword, privateKeyPath);
		} catch (Exception e) {
			logger.warn("MasterCom initialization failed", e);
		}
	}
}
