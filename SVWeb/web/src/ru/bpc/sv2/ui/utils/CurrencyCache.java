package ru.bpc.sv2.ui.utils;

import org.apache.log4j.Logger;
import org.infinispan.Cache;
import ru.bpc.sv2.common.Currency;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.cache.CacheManager;
import ru.bpc.sv2.utils.SystemException;
import util.auxil.ManagedBeanWrapper;

import javax.faces.model.SelectItem;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Unmarshaller;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CurrencyCache {
	private static final Logger logger = Logger.getLogger("COMMON");

	private Cache<String, Object> currencyCache;
	
	private Map<String, Map<String, String>> currencyMapByLang;
	private Map<String, String> currencyShortNamesMap;
	private Map<String, Currency> currencyObjectsMap;
	private Map<String, String> codeMap;
	private Map<String, List<SelectItem>> currenciesByLang;
	private Map<String, Map<String, String>> currencyFlagByLang;

	private Map <String, Map<Number,String>> objectsMap;
	
	private static volatile CurrencyCache instance;

	private Unmarshaller unmarshaller;

	private boolean loaded;
	private List<SelectItem> allCurrencies = null;

	public static CurrencyCache getInstance() {
		if (instance == null) {
			synchronized (CurrencyCache.class) {
				if (instance == null) {
					instance = new CurrencyCache(); 
					instance.reload();
				}
			}
		}
		return instance;
	}
	
	public void stopCache() {
		try {
			if (currencyCache != null) currencyCache.stop();
		} catch (Exception e) {
			logger.error("", e);
		}		
	}
	
	public static void destroyInstance(){
		instance = null;
	}

	public CurrencyCache() {
	}

	@SuppressWarnings("unchecked")
	public Map<String, String> getCurrencyMapByLang(String lang) {
		if (!loaded) {
			loadCurrency();
		}
		Map<String, String> currencyMap = ((Map<String, Map<String, String>>) currencyCache
				.get("currencyMapByLang")).get(lang);
		if (currencyMap == null) {
			return new HashMap<String, String>(0);
		}
		return currencyMap;
	}

	@SuppressWarnings("unchecked")
	public Map<String, String> getCurrencyShortNamesMap() {
		if (!loaded) {
			loadCurrency();
		}
		return (Map<String, String>) currencyCache.get("currencyShortNamesMap");
	}

	@SuppressWarnings("unchecked")
	public Map<String, Currency> getCurrencyObjectsMap() {
		if (!loaded) {
			loadCurrency();
		}
		return (Map<String, Currency>) currencyCache.get("currencyObjectsMap");
	}

	@SuppressWarnings("unchecked")
	public Map<String, String> getCodeMap() {
		if (!loaded) {
			loadCurrency();
		}
		return (Map<String, String>) currencyCache.get("codeMap");
	}
	
	@SuppressWarnings("unchecked")
	public Map<String, String> getCurrencyFlagByLang(String lang){
		Map <String,String> currencyFlagMap = ((Map<String,Map<String,String>>)currencyCache
				.get("currencyFlagByLang")).get(lang);
		if (currencyFlagMap != null){
			return currencyFlagMap;
		}
		else {
			try{ 
				Filter[] filters = new Filter[1];
				filters[0] = new Filter();
				filters[0].setElement("lang");

				SelectionParams params = new SelectionParams();
				params.setRowIndexEnd(Integer.MAX_VALUE);
				

				CommonDao comDao = new CommonDao();
				
				filters[0].setValue(lang);
				params.setFilters(filters);
				
				Currency[] currencies = comDao.getCurrencies( null, params);
				
				currencyFlagMap = new HashMap<String, String>();
				for (Currency currency : currencies){
					try{
						currencyFlagMap.put(currency.getCode(), 
								"curr " + currency.getName()
											.toLowerCase()
												.substring(0,
														currency.getName().length()-1));						
					}catch(Exception e) {
						logger.error("", e);
						continue;
					}
				
				}
				currencyFlagByLang.put(lang, currencyFlagMap);
				currencyCache.put("currencyFlagByLang", currencyFlagByLang);
			}catch (Exception e) {
				logger.error("", e);				
			}
			return currencyFlagMap;
		}
	}

	@SuppressWarnings("unchecked")
	public synchronized List<SelectItem> getAllCurrencies(String userLang) {
		if (userLang == null) {
			DictUtils dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
			allCurrencies = dictUtils.getLov(LovConstants.CURRENCIES);
		} else {
			allCurrencies = ((Map<String, List<SelectItem>>) currencyCache.get("currenciesByLang"))
					.get(userLang);
			if (allCurrencies == null) {
				DictUtils dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
				allCurrencies = dictUtils.getLov(LovConstants.CURRENCIES);
				((Map<String, List<SelectItem>>) currencyCache.get("currenciesByLang")).put(
						userLang, allCurrencies);
			}
		}
		return allCurrencies;
	}

	public void reload() {
		loadObjectsMap();
		loadCurrency();
		createUnmarshaller();
		if (currenciesByLang == null) {
			currenciesByLang = new HashMap<String, List<SelectItem>>();
		} else {
			currenciesByLang.clear();
		}
		allCurrencies = null;		
	}

	private synchronized void createUnmarshaller() {
		try {
			JAXBContext jc = JAXBContext.newInstance("org.ifxforum.xsd._1");
			unmarshaller = jc.createUnmarshaller();
		} catch (JAXBException e) {
			logger.error("", e);
		}
	}

	public Unmarshaller getUnmarshaller() {
		if (unmarshaller == null) {
			createUnmarshaller();
		}
		return unmarshaller;
	}

	private synchronized void loadCurrency() {
		try {
			if (currencyCache == null) {
				try {
					currencyCache = CacheManager.getCacheManager().getCache("currencyCache");
				} catch (SystemException e) {
					logger.error("", e);
					return;
				}
			} else {
				currencyCache.clear();
			}

			currencyMapByLang = new HashMap<String, Map<String, String>>();
			currencyFlagByLang = new HashMap<String, Map<String, String>>();
			currencyShortNamesMap = new HashMap<String, String>();
			currencyObjectsMap = new HashMap<String, Currency>();
			codeMap = new HashMap<String, String>();
			
			// don't fill it so that after synchronize other nodes could see that they 
			// need to reload this Map
			currenciesByLang = new HashMap<String, List<SelectItem>>();
			
			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("lang");

			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(Integer.MAX_VALUE);
			Currency[] currencies = null;
			try {
				CommonDao comDao = new CommonDao();
				String[] languages = comDao.getArticlesByDictNoContext("LANG");
				boolean firstLoaded = false;
				for (String lang : languages) {
					try {
						filters[0].setValue(lang);
						params.setFilters(filters);
						currencies = comDao.getCurrencies(null, params);
						if (currencies == null) {
							continue;
						}
						Map<String, String> currencyMap = new HashMap<String, String>();
						for (Currency currency : currencies) {
							try {
								currencyMap.put(currency.getCode(), currency.getName() + " - " +
										currency.getCurrencyName());
								if (!firstLoaded) {
									currencyShortNamesMap.put(currency.getCode(), currency
											.getName());
									codeMap.put(currency.getName(), currency.getCode());
									currencyObjectsMap.put(currency.getCode(), currency);
								}
							} catch (Exception e) {
								logger.error("", e);
								continue;
							}
						}
						currencyMapByLang.put(lang, currencyMap);
						firstLoaded = true;
					} catch (Exception e) {
						logger.error("", e);
						continue;
					}
					
				}
			} catch (Exception e) {
				logger.error("", e);
			}
			currencyCache.put("currencyMapByLang", currencyMapByLang);
			currencyCache.put("currencyShortNamesMap", currencyShortNamesMap);
			currencyCache.put("currencyObjectsMap", currencyObjectsMap);
			currencyCache.put("codeMap", codeMap);
			currencyCache.put("currenciesByLang", currenciesByLang);
			currencyCache.put("currencyFlagByLang", currencyFlagByLang);
			loaded = true;
		} catch (Exception e) {
			logger.error("", e);
		} finally {
			if (currencyMapByLang == null) {
				currencyMapByLang = new HashMap<String, Map<String, String>>(0);
			}
			if (currencyShortNamesMap == null) {
				currencyShortNamesMap = new HashMap<String, String>(0);
			}
			if (codeMap == null) {
				codeMap = new HashMap<String, String>(0);
			}
		}
	}

	private void loadObjectsMap(){
		Map <Number,String> networksMap = new HashMap<Number, String>();
		networksMap.put(1002, "network mcw");
		networksMap.put(1003, "network visa");
		if (objectsMap == null) {
			objectsMap = new HashMap<String, Map<Number,String>>();	
		} else {
			objectsMap.clear();
		}		
		objectsMap.put(EntityNames.NETWORK, networksMap);
	}

	public Map<String, Map<Number, String>> getObjectsMap() {
		if (!loaded) {
			loadObjectsMap();
		}
		return objectsMap;
	}
}
