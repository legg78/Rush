package ru.bpc.sv2.ui.utils.cache;

import org.apache.log4j.Logger;
import org.infinispan.Cache;
import org.infinispan.lifecycle.ComponentStatus;
import ru.bpc.sv2.common.Dictionary;
import ru.bpc.sv2.logic.CommonDao;
import util.auxil.SessionWrapper;

import java.util.HashMap;
import java.util.Map;

public class DictCache {
	private static final Logger logger = Logger.getLogger("COMMON");

	public final static String CODE_NAME = "LVAPCDNM";
	public final static String NAME_CODE = "LVAPNMCD";
	public final static String NAME = "LVAPNAME";
	public final static String CODE = "LVAPCODE";

	private Cache<String, Object> dictCache;

	private String articleFormat;

	private static volatile DictCache instance;

	public static DictCache getInstance() {
		if (instance == null) {
			synchronized (DictCache.class) {
				if (instance == null) {
					instance = new DictCache();
					try {
						instance.reload();
					} catch (Throwable e) {
						destroyInstance();
						throw e instanceof RuntimeException ? (RuntimeException)e : new RuntimeException(e.getMessage(), e);
					}
				}
			}
		}
		return instance;
	}

	public DictCache() {
	}

	public synchronized void stopCache() {
		try {
			if (dictCache != null) {
				dictCache.stop();
				dictCache = null;
			}
		} catch (Exception e) {
			logger.error("", e);
		}
	}

	public static synchronized void destroyInstance() {
		if (instance != null) {
			try {
			instance.stopCache();
			} catch (Exception e) {
				logger.error(e.getMessage(), e);
			}
			instance = null;
		}
	}

	public synchronized void readAllArticles() {
		try {
			articleFormat = SessionWrapper.getField("articleFormat");

			if (dictCache == null) {
				dictCache = CacheManager.getCacheManager().getCache("dictCache");
			}
			if (dictCache.getStatus() == ComponentStatus.TERMINATED)
				dictCache.start();
			dictCache.clear();
			Map<String, Map<String, Dictionary>> allArticles = new HashMap<String, Map<String, Dictionary>>();
			Map<String, Map<String, String>> allArticlesDesc = new HashMap<String, Map<String, String>>();
			Map<String, Map<String, String>> formattedArticles = new HashMap<String, Map<String, String>>();

			CommonDao comDao = new CommonDao();
			String[] languages = comDao.getArticlesByDictNoContext("LANG");

			for (String lang : languages) {
				Dictionary[] articles = comDao.getAllArticles(lang);
				HashMap<String, String> articlesDescMap = new HashMap<String, String>();
				HashMap<String, String> formattedDescMap = new HashMap<String, String>();
				HashMap<String, Dictionary> articlesMap = new HashMap<String, Dictionary>();
				for (Dictionary article : articles) {
					articlesMap.put(article.getDict() + article.getCode(), article);
					articlesDescMap.put(article.getDict() + article.getCode(), article.getName());
					if (CODE_NAME.equals(articleFormat)) {
						formattedDescMap.put(article.getDict() + article.getCode(),
								article.getDict() + article.getCode() + " - " + article.getName());
					} else if (NAME_CODE.equals(articleFormat)) {
						formattedDescMap.put(article.getDict() + article.getCode(),
								article.getName() + " - " + article.getDict() + article.getCode());
					} else if (NAME.equals(articleFormat)) {
						formattedDescMap.put(article.getDict() + article.getCode(),
								article.getName());
					} else if (CODE.equals(articleFormat)) {
						formattedDescMap.put(article.getDict() + article.getCode(),
								article.getCode());
					} else {
						articleFormat = CODE_NAME;
						formattedDescMap.put(article.getDict() + article.getCode(),
								article.getDict() + article.getCode() + " - " + article.getName());
					}
				}
				allArticlesDesc.put(lang, articlesDescMap);
				allArticles.put(lang, articlesMap);
				formattedArticles.put(lang, formattedDescMap);
			}
			// dictCache.clear();
			dictCache.put("allArticlesDesc", allArticlesDesc);
			dictCache.put("allArticles", allArticles);
			dictCache.put("formattedArticles", formattedArticles);
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			throw new RuntimeException(e.getMessage(), e);
		}
	}

	@SuppressWarnings("unchecked")
	public Map<String, Map<String, String>> getAllArticlesDescByLang() {
		return (Map<String, Map<String, String>>) dictCache.get("allArticlesDesc");
	}

	@SuppressWarnings("unchecked")
	public Map<String, Map<String, Dictionary>> getAllArticles() {
		return (Map<String, Map<String, Dictionary>>) dictCache.get("allArticles");
	}

	@SuppressWarnings("unchecked")
	public Map<String, Map<String, String>> getFormattedArticlesByLang() {
		return (Map<String, Map<String, String>>) dictCache.get("formattedArticles");
	}

	@SuppressWarnings("unchecked")
	public Map<String, Map<String, String>> getFormattedArticles(String format) {
		if (articleFormat == null || !articleFormat.equals(format)) {
			articleFormat = format;
			reformatArticles(format);
		}
		return (Map<String, Map<String, String>>) dictCache.get("formattedArticles");
	}

	public void reload() {
		readAllArticles();
	}

	@SuppressWarnings("unchecked")
	private void reformatArticles(String format) {
		Map<String, Map<String, String>> formattedArticles = new HashMap<String, Map<String, String>>();

		Map<String, Map<String, String>> allArticlesDesc = (Map<String, Map<String, String>>) dictCache
				.get("allArticlesDesc");

		if (allArticlesDesc == null) {
			logger.error("Cannot obtain \"allArticlesDesc\" from dictCache...");
			return;
		}
		for (String lang : allArticlesDesc.keySet()) {
			Map<String, String> someLangArticles = allArticlesDesc.get(lang);
			Map<String, String> formattedDescMap = new HashMap<String, String>();
			for (String fullCode : someLangArticles.keySet()) {
				if (CODE_NAME.equals(articleFormat)) {
					formattedDescMap.put(fullCode, fullCode + " - " + someLangArticles.get(fullCode));
				} else if (NAME_CODE.equals(articleFormat)) {
					formattedDescMap.put(fullCode, someLangArticles.get(fullCode) + " - " + fullCode);
				} else if (NAME.equals(articleFormat)) {
					formattedDescMap.put(fullCode, someLangArticles.get(fullCode));
				} else if (CODE.equals(articleFormat)) {
					formattedDescMap.put(fullCode, fullCode);
				} else {
					articleFormat = CODE_NAME;
					formattedDescMap.put(fullCode, fullCode + " - " + someLangArticles.get(fullCode));
				}
			}
			formattedArticles.put(lang, formattedDescMap);
		}
		dictCache.put("formattedArticles", formattedArticles);
	}
}
