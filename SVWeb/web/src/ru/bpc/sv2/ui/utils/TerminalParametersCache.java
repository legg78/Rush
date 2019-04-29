package ru.bpc.sv2.ui.utils;

import org.apache.log4j.Logger;
import org.infinispan.Cache;
import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.ui.utils.cache.CacheManager;
import ru.bpc.sv2.utils.SystemException;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class TerminalParametersCache {
	private static final Logger logger = Logger.getLogger("COMMON");

	private static final int SYNC_TIME = 60; // 60 minutes
	private Map<String, Map<String, Object>> terminalParamsMap;
	private Map<String, Terminal> terminalsMap;

	private static volatile TerminalParametersCache instance;

//	private boolean loaded;
	private Date lastSync;
	
	private Cache<String, Object> terminalParametersCache;
	
	public static TerminalParametersCache getInstance() {
		if (instance == null) {
			synchronized (TerminalParametersCache.class) {
				if (instance == null) {
					instance = new TerminalParametersCache();
					instance.reload();
				}
			}
		}
		return instance;
	}
	
	public void stopCache() {
		try {
			if (terminalParametersCache != null) terminalParametersCache.stop();
		} catch (Exception e) {
			logger.error("", e);
		}		
	}
	
	public static void destroyInstance(){
		instance = null;
	}

	public TerminalParametersCache() {
	}

	public synchronized void reload() {
		//Use lazy-loading
		terminalParamsMap = new HashMap<String, Map<String, Object>>();
		terminalsMap = new HashMap<String, Terminal>();
		if (terminalParametersCache == null) {
			try {
				terminalParametersCache = CacheManager.getCacheManager().getCache(
						"terminalParametersCache");
			} catch (SystemException e) {
				logger.error("", e);
				return;
			}
		} else {
			terminalParametersCache.clear();
		}
	}


	@SuppressWarnings("unchecked")
	public Map<String, Object> getTerminalParameters(String terminalNumber) {
		if (isNeedSync()) {
			reload();
		}
		Map<String, Object> paramsMap;
		if (terminalParametersCache.get("terminalParamsMap") == null) {
			paramsMap = loadTerminalParams(terminalNumber);
		} else {
			paramsMap = ((Map<String, Map<String, Object>>) terminalParametersCache
					.get("terminalParamsMap")).get(terminalNumber);
			if (paramsMap == null) {
				// Try to load parameters
				paramsMap = loadTerminalParams(terminalNumber);
			}
		}
		return paramsMap;
	}
	
	@SuppressWarnings("unchecked")
	public Terminal getTerminal(String terminalNumber) {
		Terminal terminal;
		if (terminalParametersCache.get("terminalsMap") == null) {
			terminal = loadTerminal(terminalNumber);
		} else {
			terminal = ((Map<String, Terminal>) terminalParametersCache.get("terminalsMap"))
					.get(terminalNumber);
			if (terminal == null) {
				// Try to load parameters
				terminal = loadTerminal(terminalNumber);
			}
		}
		return terminal;
	}

	public void reloadTerminalParams(String terminalNumber) {
		loadTerminalParams(terminalNumber);
		loadTerminal(terminalNumber);
	}
	
	private synchronized Map<String, Object> loadTerminalParams(String terminalNumber) {
		AcquiringDao acqDao = new AcquiringDao();
		Parameter[] params = acqDao.getTerminalParameters(terminalNumber);
		Map<String, Object> paramsMap = new HashMap<String, Object>();
		for (Parameter param : params) {
			paramsMap.put(param.getSystemName(), param.getValue());
		}
		terminalParamsMap.put(terminalNumber, paramsMap);
		if (lastSync == null) {
			lastSync = new Date();
		} else {
			lastSync.setTime(System.currentTimeMillis());
		}
		terminalParametersCache.put("terminalParamsMap", terminalParamsMap);
		return paramsMap;
	}
	
	private synchronized Terminal loadTerminal(String terminalNumber) {
		AcquiringDao acqDao = new AcquiringDao();

		SelectionParams params = new SelectionParams();
		Filter[] filters = new Filter[2];
		filters[0] = new Filter("terminalNumber", terminalNumber);
		filters[1] = new Filter("lang", SystemConstants.ENGLISH_LANGUAGE);
		params.setFilters(filters);

		Terminal[] terminals = acqDao.getTerminals(params);
		for (Terminal terminal : terminals) {
			terminalsMap.put(terminalNumber, terminal);
		}
		if (lastSync == null) {
			lastSync = new Date();
		} else {
			lastSync.setTime(System.currentTimeMillis());
		}
		terminalParametersCache.put("terminalsMap", terminalsMap);
		return terminals[0];
	}

	private boolean isNeedSync() {
		try {
			if (lastSync != null &&
					(System.currentTimeMillis() - lastSync.getTime() > SYNC_TIME * 60 * 1000)) {
				return true;
			}
		} catch (Exception e) {
			logger.error("", e);
		}
		return false;
	}

}
