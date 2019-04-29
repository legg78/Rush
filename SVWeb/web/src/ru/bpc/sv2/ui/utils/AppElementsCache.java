package ru.bpc.sv2.ui.utils;

import org.apache.log4j.Logger;
import org.infinispan.Cache;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationFlow;
import ru.bpc.sv2.application.ApplicationFlowStage;
import ru.bpc.sv2.application.ApplicationFlowTransition;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.ws.ApplicationsWsDao;
import ru.bpc.sv2.ui.utils.cache.CacheManager;
import ru.bpc.sv2.utils.SystemException;

import javax.annotation.Resource;
import javax.xml.ws.WebServiceContext;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public class AppElementsCache {
	private static final Logger logger = Logger.getLogger("APPLICATIONS");

	private static final int SYNC_TIME = 60; // 60 minutes
	private Map<String, ApplicationElement> elementsMap;
	private Map<Integer, ApplicationFlow> flowsMap;
	// <Flow, <Status, Handler>>
	private Map<Integer, Map<String, String>> handlersMap;
	// <Flow, <StatusAfterHandler||HandlerResult, TransitionStatus>>
	private Map<Integer, Map<String, String>> transitionsMap;

	private static volatile AppElementsCache instance;

	private boolean elementsLoaded;
	private boolean flowsLoaded;
	private boolean handlersLoaded;
	private boolean transitionsLoaded;
	private long lastSync;
	private long lastSyncElements;
	private long lastSyncFlows;
	private long lastSyncHandlers;
	private long lastSyncTransitions;
	
	@Resource
	private WebServiceContext wsContext;
	

	private Cache<String, Object> appElementsCache;
	
	public static AppElementsCache getInstance() {
		if (instance == null) {
			synchronized (AppElementsCache.class) {
				if (instance == null) {
					instance = new AppElementsCache();
					instance.reload();
				}
			}
		}
		return instance;
	}
	
	public static void destroyInstance(){
		instance = null;
	}

	public AppElementsCache() {
	}

	@SuppressWarnings("unchecked")
	public Map<String, ApplicationElement> getElementsMap() {
		if (!elementsLoaded || isNeedSync(lastSyncElements)) {
			loadElements();
		}
		return (Map<String, ApplicationElement>) appElementsCache.get("elementsMap");
	}

	@SuppressWarnings("unchecked")
	public Map<Integer, ApplicationFlow> getFlowsMap() {
		if (!flowsLoaded || isNeedSync(lastSyncFlows)) {
			loadFlows();
		}
		return (Map<Integer, ApplicationFlow>) appElementsCache.get("flowsMap");
	}

	@SuppressWarnings("unchecked")
	public Map<Integer, Map<String,String>> getFlowHandlersMap() {
		if (!handlersLoaded || isNeedSync(lastSyncHandlers)) {
			loadHandlers();
		}
		return (Map<Integer, Map<String,String>>) appElementsCache.get("handlersMap");
	}

	@SuppressWarnings("unchecked")
	public Map<Integer, Map<String,String>> getFlowTransitionsMap() {
		if (!transitionsLoaded || isNeedSync(lastSyncTransitions)) {
			loadTransitions();
		}
		return (Map<Integer, Map<String,String>>) appElementsCache.get("transitionsMap");
	}

	public void reload() {
		if (appElementsCache == null) {
			try {
				appElementsCache = CacheManager.getCacheManager().getCache("appElementsCache");
			} catch (SystemException e) {
				logger.error("", e);
				return;
			}
		} else {
			appElementsCache.clear();
		}
		loadElements();
		loadFlows();
		loadHandlers();
		loadTransitions();
		lastSync = System.currentTimeMillis();
	}

	private synchronized void loadElements() {
		try {
			logger.trace("Loading application elements...");
			long startTime = System.currentTimeMillis();
			ApplicationDao appDao = new ApplicationDao();
			ApplicationsWsDao appWsDao = new ApplicationsWsDao();
			appWsDao.registerSession(null, null);
			ApplicationElement[] elements = appDao.getAllElements();
			elementsMap = Collections.synchronizedMap(new HashMap<String, ApplicationElement>(
					elements.length + 10));
			for (ApplicationElement element : elements) {
				elementsMap.put(element.getName(), element);
			}
			lastSyncElements = System.currentTimeMillis();
			elementsLoaded = true;
			logger.trace("Loading application elements finished. Time (ms):" +
					(System.currentTimeMillis() - startTime));
		} catch (Exception e) {
			logger.error("Error when loading application elements!", e);
		} finally {
			if (elementsMap == null) {
				elementsMap = Collections
						.synchronizedMap(new HashMap<String, ApplicationElement>(0));
			}
		}
		appElementsCache.put("elementsMap", elementsMap);
	}

	private synchronized void loadFlows() {
		try {
			logger.trace("Loading application flows...");
			long startTime = System.currentTimeMillis();
			ApplicationDao appDao = new ApplicationDao();
			ApplicationFlow[] flows = appDao.getAllFlows();
			flowsMap = Collections.synchronizedMap(new HashMap<Integer, ApplicationFlow>(
					flows.length));
			for (ApplicationFlow flow : flows) {
				flowsMap.put(flow.getId(), flow);
			}
			lastSyncFlows = System.currentTimeMillis();
			flowsLoaded = true;
			logger.trace("Loading application flows finished. Time (ms):" +
					(System.currentTimeMillis() - startTime));
		} catch (Exception e) {
			logger.error("Error when loading application flows!", e);
		} finally {
			if (flowsMap == null) {
				flowsMap = Collections.synchronizedMap(new HashMap<Integer, ApplicationFlow>(0));
			}
		}
		appElementsCache.put("flowsMap", flowsMap);
	}

	private synchronized void loadHandlers() {
		try {
			logger.trace("Loading application transition handlers...");
			long startTime = System.currentTimeMillis();
			ApplicationDao appDao = new ApplicationDao();
			ApplicationFlowStage[] stages = appDao.getAllApplicationFlowStages();
			handlersMap = Collections.synchronizedMap(new HashMap<Integer, Map<String, String>>(
					stages.length));
			Map<String, String> map = null;
			boolean found = true;
			for (ApplicationFlowStage stage : stages) {
				found = true;
				map = handlersMap.get(stage.getFlowId());
				if (map == null) {
					found = false;
					map = new HashMap<String, String>();
				}
				map.put(stage.getAppStatus(), stage.getHandler());
				if (!found) {
					handlersMap.put(stage.getFlowId(), map);
				}
			}
			lastSyncHandlers = System.currentTimeMillis();
			handlersLoaded = true;
			logger.trace("Loading application transition handlers finished. Time (ms):" +
					(System.currentTimeMillis() - startTime));
		} catch (Exception e) {
			logger.error("Error when loading application transition handlers!", e);
		} finally {
			if (handlersMap == null) {
				handlersMap = Collections
						.synchronizedMap(new HashMap<Integer, Map<String, String>>(0));
			}
		}
		appElementsCache.put("handlersMap", handlersMap);
	}

	private synchronized void loadTransitions() {
		try {
			logger.trace("Loading application transitions...");
			long startTime = System.currentTimeMillis();
			ApplicationDao appDao = new ApplicationDao();
			ApplicationFlowTransition[] transitions = appDao.getAllApplicationFlowTransitions();
			transitionsMap = Collections.synchronizedMap(new HashMap<Integer, Map<String, String>>(
					transitions.length));
			Map<String, String> map = null;
			boolean found = true;
			for (ApplicationFlowTransition transition : transitions) {
				found = true;
				map = transitionsMap.get(transition.getFlowId());
				if (map == null) {
					found = false;
					map = new HashMap<String, String>();
				}
				map.put(transition.getPreStatus() + transition.getStageResult(), transition.getAppStatus());
				if (!found) {
					transitionsMap.put(transition.getFlowId(), map);
				}
			}
			lastSyncTransitions = System.currentTimeMillis();
			transitionsLoaded = true;
			logger.trace("Loading application transitions finished. Time (ms):" +
					(System.currentTimeMillis() - startTime));
		} catch (Exception e) {
			logger.error("Error when loading application transitions!", e);
		} finally {
			if (transitionsMap == null) {
				transitionsMap = Collections
						.synchronizedMap(new HashMap<Integer, Map<String, String>>(0));
			}
		}
		appElementsCache.put("transitionsMap", transitionsMap);
	}

	public ApplicationElement getElement(String elementName) {
		ApplicationElement element = getElementsMap().get(elementName);
		if (element == null) {
			element = new ApplicationElement();
		}
		return element;
	}

	public ApplicationFlow getFlow(Integer flowId) {
		ApplicationFlow flow = getFlowsMap().get(flowId);
		if (flow == null) {
			flow = new ApplicationFlow();
		}
		return flow;
	}

	public Map<String, String> getHandlersMap(Integer flowId) {
		Map<String, String> handlers = getFlowHandlersMap().get(flowId);
		return handlers;
	}

	public Map<String, String> getTransitionsMap(Integer flowId) {
		Map<String, String> transitions = getFlowTransitionsMap().get(flowId);
		return transitions;
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
