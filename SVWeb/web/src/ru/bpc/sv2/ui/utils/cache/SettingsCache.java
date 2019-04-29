package ru.bpc.sv2.ui.utils.cache;

import org.apache.log4j.Logger;
import org.infinispan.Cache;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.settings.SettingParam;
import ru.bpc.sv2.utils.SystemException;

import java.math.BigDecimal;
import java.util.*;

public class SettingsCache {
	private static final Logger logger = Logger.getLogger("APPLICATIONS");

	private static final int SYNC_TIME = 480; // 480 minutes

	private Map<String, Object> systemParametersMap;
	private Map<String, Map<String,Object>> userParametersMap;
	private Map<Integer, Map<String,Object>> instParametersMap;

	private static volatile SettingsCache instance;
	private Cache<String, Object> settingsCache;

	private long lastSyncFlows;

	public static SettingsCache getInstance() {
		if (instance == null) {
			synchronized (SettingsCache.class) {
				if (instance == null) {
					instance = new SettingsCache();
					instance.reload();
				}
			}
		}
		return instance;
	}

	public void stopCache() {
		try {
			if (settingsCache != null) settingsCache.stop();
		} catch (Exception e) {
			logger.error("", e);
		}		
	}
	
	public static void destroyInstance(){
		instance = null;
	}

	public SettingsCache() {}

	public void reload() {
		if (settingsCache == null) {
			try {
				settingsCache = CacheManager.getCacheManager().getCache("settingsCache");
			} catch (SystemException e) {
				logger.error("", e);
				return;
			}
		} else {
			settingsCache.clear();
		}
		loadSystemSettings();
		clearInstSettings();
		clearUserSettings();
	}

	private synchronized void loadSystemSettings() {
		try {
			logger.trace("Loading system settings...");
			SettingsDao settingsDao = new SettingsDao();
			List<SettingParam> params = settingsDao.getAllSystemParams();
			systemParametersMap = Collections.synchronizedMap(new HashMap<String, Object>(params.size()));
			for (SettingParam param : params) {
				systemParametersMap.put(param.getSystemName(), param.getValue() == null ? param.getDefaultValue() : param.getValue());
			}
			lastSyncFlows = System.currentTimeMillis();
			logger.trace("Loading system settings finished.");
		} catch (Exception e) {
			logger.error("Error when loading system settings!", e);
		} finally {
			if (systemParametersMap == null) {
				systemParametersMap = Collections.synchronizedMap(new HashMap<String, Object>(0));
			}
		}
		settingsCache.put("systemParametersMap", systemParametersMap);
	}

	@SuppressWarnings("unchecked")
	private synchronized void clearInstSettings() {
		if (settingsCache.get("instParametersMap") == null) {
			settingsCache.put("instParametersMap", Collections.synchronizedMap(new HashMap<Integer, Map<String, Object>>()));
		} else {
			instParametersMap = (Map<Integer, Map<String, Object>>) settingsCache.get("instParametersMap");
			for (Integer instId : instParametersMap.keySet()) {
				instParametersMap.get(instId).clear();
			}
			instParametersMap.clear();
		}
	}

	@SuppressWarnings("unchecked")
	private synchronized void clearUserSettings() {
		if (settingsCache.get("userParametersMap") == null) {
			settingsCache.put("userParametersMap", Collections.synchronizedMap(new HashMap<Integer, Map<String, Object>>()));
		} else {
			userParametersMap = (Map<String, Map<String, Object>>) settingsCache.get("userParametersMap");
			for (String userName : userParametersMap.keySet()) {
				userParametersMap.get(userName).clear();
			}
			userParametersMap.clear();
		}

	}

	@SuppressWarnings("unchecked")
	private synchronized void loadInstSettings(Integer instId) {
		try {
			if (settingsCache.get("instParametersMap") == null) {
				clearInstSettings();
			} else {
				instParametersMap = (Map<Integer, Map<String, Object>>) settingsCache.get("instParametersMap");
			}
			
			logger.trace("Loading inst settings...");
			long startTime = System.currentTimeMillis();
			SettingsDao settingsDao = new SettingsDao();
			List<SettingParam> params = settingsDao.getAllInstParams(instId);
			Map<String, Object> instParams = instParametersMap.get(instId);
			if (instParams == null) {
				instParams = Collections.synchronizedMap(new HashMap<String, Object>(params.size()));
			}
			for (SettingParam param : params) {
				instParams.put(param.getSystemName(), param.getValue());
			}
			instParametersMap.put(instId, instParams);

			lastSyncFlows = System.currentTimeMillis();
			logger.trace("Loading inst settings finished.");
		} catch (Exception e) {
			logger.error("Error when loading inst settings!", e);
		} finally {}
	}

	@SuppressWarnings("unchecked")
	private synchronized void loadUserSettings(String userName) {
		try {
			if (settingsCache.get("userParametersMap") == null) {
				clearUserSettings();
			} else {
				userParametersMap = (Map<String, Map<String, Object>>) settingsCache.get("userParametersMap");
			}

			logger.trace("Loading user settings...");
			SettingsDao settingsDao = new SettingsDao();
			List<SettingParam> params = settingsDao.getAllUserParams(userName);
			Map<String, Object> userParams = userParametersMap.get(userName);
			if (userParams == null) {
				userParams = Collections.synchronizedMap(new HashMap<String, Object>(params.size()));
			}
			for (SettingParam param : params) {
				userParams.put(param.getSystemName(), param.getValue());
			}
			userParametersMap.put(userName, userParams);

			lastSyncFlows = System.currentTimeMillis();
			logger.trace("Loading user settings finished.");
		} catch (Exception e) {
			logger.error("Error when loading inst settings!", e);
		} finally {}
	}

	@SuppressWarnings("unchecked")
	public Object getParameterValue(String paramName) {
		if (settingsCache == null || settingsCache.get("systemParametersMap") == null || isNeedSync(lastSyncFlows)) {
			reload();
		}
		return ((Map<String, Object>) settingsCache.get("systemParametersMap")).get(paramName);
	}

	@SuppressWarnings("unchecked")
	public String getParameterStringValue(String paramName) {
		Object obj = getParameterValue(paramName);
		return (obj == null) ? null : ((String) obj).trim();
	}

	@SuppressWarnings("unchecked")
	public BigDecimal getParameterNumberValue(String paramName) {
		Object obj = getParameterValue(paramName);
		return (obj == null) ? null : (BigDecimal) obj;
	}

	@SuppressWarnings("unchecked")
	public Boolean getParameterBooleanValue(String paramName) {
		Object obj = getParameterValue(paramName);
		return (obj == null) ? null : (((BigDecimal)obj).intValue() == 1) ? true : false;
	}

	@SuppressWarnings("unchecked")
	public Date getParameterDateValue(String paramName) {
		Object obj = getParameterValue(paramName);
		return (obj == null) ? null : (Date) obj;
	}

	@SuppressWarnings("unchecked")
	public String getInstParameterStringValue(Integer instId, String paramName) {
		if (settingsCache.get("instParametersMap") == null) {
			loadInstSettings(instId);
		}
		instParametersMap = (Map<Integer, Map<String,Object>>) settingsCache.get("instParametersMap");
		Map<String, Object> paramsMap = instParametersMap.get(instId);
		if (paramsMap == null) {
			loadInstSettings(instId);
			paramsMap = instParametersMap.get(instId);
		}
		return (String)paramsMap.get(paramName);		
	}

	@SuppressWarnings("unchecked")
	public String getUserParameterStringValue(String userName, String paramName) {
		userName = userName.toUpperCase();
		if (settingsCache.get("userParametersMap") == null) {
			loadUserSettings(userName);
		}
		userParametersMap = (Map<String, Map<String,Object>>) settingsCache.get("userParametersMap");
		Map<String, Object> paramsMap = userParametersMap.get(userName);
		if (paramsMap == null) {
			loadUserSettings(userName);
			paramsMap = userParametersMap.get(userName);
		}
		return (String)paramsMap.get(paramName);
	}

	@SuppressWarnings("unchecked")
	public BigDecimal getUserParameterNumberValue(String userName, String paramName) {
		userName = userName.toUpperCase();
		if (settingsCache.get("userParametersMap") == null) {
			loadUserSettings(userName);
		}
		userParametersMap = (Map<String, Map<String,Object>>) settingsCache.get("userParametersMap");
		Map<String, Object> paramsMap = userParametersMap.get(userName);
		if (paramsMap == null) {
			loadUserSettings(userName);
			paramsMap = userParametersMap.get(userName);
		}
		return (BigDecimal)paramsMap.get(paramName);
	}

	private boolean isNeedSync(long lastTime) {
		try {
			if (System.currentTimeMillis() - lastTime > SYNC_TIME * 60 * 1000) {
				return true;
			}
		} catch (Exception e) {
			logger.error("", e);
		}
		return false;
	}
}
