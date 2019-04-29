package ru.bpc.sv2.ui.utils;

import org.apache.log4j.Logger;
import org.openfaces.util.AjaxUtil;
import ru.bpc.sv2.common.Dictionary;
import ru.bpc.sv2.common.Lov;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.cache.DictCache;
import ru.bpc.sv2.utils.KeyLabelItem;
import ru.bpc.sv2.utils.SystemException;
import util.auxil.SessionWrapper;


import javax.faces.bean.ApplicationScoped;
import javax.faces.bean.ManagedBean;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ApplicationScoped
@ManagedBean(name = "DictUtils")
public class DictUtils implements Serializable {
	private static final long serialVersionUID = 1L;
	private static final Logger logger = Logger.getLogger("COMMON");

	private CommonDao commonDao = new CommonDao();

	private String lang;

	private static RequestScopeCache<KeyLabelItem[]> lovCache = new RequestScopeCache<KeyLabelItem[]>();

	public DictUtils() {
	}

	public Map<String, Dictionary> getAllArticles() {
		try {
			String userLang = SessionWrapper.getField("language");
			return DictCache.getInstance().getAllArticles().get(userLang);
		} catch (Exception e) {
			processDictCacheException(e);
			return new HashMap<String, Dictionary>();
		}
	}

	public void flush() {
		try {
			DictCache.getInstance().readAllArticles();
		} catch (Exception e) {
			processDictCacheException(e);
		}
	}

	public void readAllArticles() {
		try {
			DictCache.getInstance().readAllArticles();
		} catch (Exception e) {
			processDictCacheException(e);
		}
	}

	public Map<String, String> getAllArticlesDesc() {
		try {
			String userLang = SessionWrapper.getField("language");
			return DictCache.getInstance().getAllArticlesDescByLang().get(userLang);
		} catch (Exception e) {
			processDictCacheException(e);
			return new HashMap<String, String>();
		}
	}

	public Map<String, Map<String, String>> getAllArticlesDescByLang() {
		try {
			return DictCache.getInstance().getAllArticlesDescByLang();
		} catch (Exception e) {
			processDictCacheException(e);
			return new HashMap<String, Map<String, String>>();
		}
	}

	public Map<String, String> getArticles() {
		String articleFormat = SessionWrapper.getField("articleFormat");
		String userLang = SessionWrapper.getField("language");
		try {
			return DictCache.getInstance().getFormattedArticles(articleFormat).get(userLang);
		} catch (Exception e) {
			processDictCacheException(e);
			return new HashMap<String, String>();
		}
	}

	public Map<String, Map<String, String>> getArticlesByLang() {
		String articleFormat = SessionWrapper.getField("articleFormat");
		try {
			return DictCache.getInstance().getFormattedArticles(articleFormat);
		} catch (Exception e) {
			processDictCacheException(e);
			return new HashMap<String, Map<String, String>>();
		}
	}

	private void processDictCacheException(Throwable e) {
		logger.error(e);
		if (AjaxUtil.isAjaxRequest(FacesContext.getCurrentInstance()) || AjaxUtil.isAjax4jsfRequest()) {
			FacesUtils.addSystemError(new SystemException(
					"Error on access to dictionary cache (" + e.getMessage() + "). " +
							"It's probably failed to initialize properly during application startup. " +
							"Please refer to server logs.", e));
		} else if (e instanceof RuntimeException) {
			throw (RuntimeException) e;
		} else {
			throw new RuntimeException(e);
		}
	}

	public List<SelectItem> getOperTypes() {
		return getArticles("OPTP");
	}

	public Map<String, String> getOperTypesMap() {
		return getArticlesMap("OPTP");
	}

	public Map<String, String> getRejectStatusesMap() {
		return getArticlesMap("RJST");
	}

	public List<SelectItem> getRejectStatuses() {
		return getArticles("RJST");
	}

	public Map<String, String> getRejectTypesMap() {
		return getArticlesMap("RJTP");
	}

	public List<SelectItem> getRejectTypes() {
		return getArticles("RJTP");
	}

	public Map<String, String> getResolutionModesMap() {
		return getArticlesMap("RJMD");
	}

	public List<SelectItem> getResolutionModes() {
		return getArticles("RJMD");
	}

    public List<SelectItem> getFlexibleFieldUsages() {
        return getArticles("FFUS");
    }

    public Map<String, String> getFlexibleFieldUsagesMap() {
        return getArticlesMap("FFUS");
    }


    public List<SelectItem> getNetworks() {
		return getLov(1019);
	}

	public Map<String, String> getNetworksMap() {
		return getLovMap(1019);
	}

	/**
	 * @param dictName dictionary name
	 * @return articles list of dictionary <code>dictName</code> formatted
	 * corresponding to user's ARTICLE_FORMAT property.
	 */
	public ArrayList<SelectItem> getArticles(String dictName) {
		ArrayList<SelectItem> items = null;
		String articleFormat = SessionWrapper.getField("articleFormat");
		try {
			Long userSessionId = SessionWrapper.getRequiredUserSessionId();
			Dictionary[] itemsArticle = commonDao.getArticlesByDict(userSessionId, dictName);
			SelectItem si;
			items = new ArrayList<SelectItem>(itemsArticle.length);
			String fullCode;
			for (Dictionary dict : itemsArticle) {
				fullCode = dict.getDict() + dict.getCode();
				if (DictCache.CODE_NAME.equals(articleFormat)) {
					si = new SelectItem(fullCode, fullCode + " - " + dict.getName());
				} else if (DictCache.NAME_CODE.equals(articleFormat)) {
					si = new SelectItem(fullCode, dict.getName() + " - " + fullCode);
				} else if (DictCache.NAME.equals(articleFormat)) {
					si = new SelectItem(fullCode, dict.getName());
				} else if (DictCache.CODE.equals(articleFormat)) {
					si = new SelectItem(fullCode, fullCode);
				} else {
					si = new SelectItem(fullCode, fullCode + " - " + dict.getName());
				}

				items.add(si);
			}
			Collections.sort(items, new Comparator<SelectItem>() {
				@Override
				public int compare(SelectItem o1, SelectItem o2) {
					if (o1.getLabel() == null || o1.getLabel().equals("")) {
						return -1;
					}
					if (o2.getLabel() == null || o2.getLabel().equals("")) {
						return 1;
					}
					return o1.getLabel().compareTo(o2.getLabel());
				}
			});
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} finally {
			if (items == null) {
				items = new ArrayList<SelectItem>(0);
			}
		}
		return items;
	}

	public ArrayList<SelectItem> getArticles(String dictName, boolean showCode) {
		ArrayList<SelectItem> items = null;
		try {
			Long userSessionId = SessionWrapper.getRequiredUserSessionId();
			Dictionary[] itemsArticle = commonDao.getArticlesByDict(userSessionId, dictName);
			SelectItem si;
			items = new ArrayList<SelectItem>(itemsArticle.length);
			for (Dictionary dict : itemsArticle) {
				if (showCode) {
					si = new SelectItem(dict.getDict() + dict.getCode(),
							dict.getDict() + dict.getCode() + " - " + dict.getName());
				} else {
					si = new SelectItem(dict.getDict() + dict.getCode(), dict.getName());
				}

				items.add(si);
			}
			Collections.sort(items, new Comparator<SelectItem>() {
				@Override
				public int compare(SelectItem o1, SelectItem o2) {
					if (o1.getLabel() == null || o1.getLabel().equals("")) {
						return -1;
					}
					if (o2.getLabel() == null || o2.getLabel().equals("")) {
						return 1;
					}
					return o1.getLabel().compareTo(o2.getLabel());
				}
			});
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} finally {
			if (items == null) {
				items = new ArrayList<SelectItem>(0);
			}
		}
		return items;
	}

	public ArrayList<SelectItem> getArticles(String dictName, boolean addEmptyValue, boolean showCode) {
		ArrayList<SelectItem> items = getArticles(dictName, showCode);
		if (addEmptyValue) {
			items.add(0, new SelectItem("", ""));
		}
		return items;
	}

	public ArrayList<SelectItem> getArticles(String dictName, boolean addEmptyValue, boolean showCode, Integer instId) {
		ArrayList<SelectItem> items = null;
		try {
			Long userSessionId = SessionWrapper.getRequiredUserSessionId();
			Dictionary[] itemsArticle = commonDao.getArticlesByDict(userSessionId, dictName);
			SelectItem si;
			items = new ArrayList<SelectItem>(itemsArticle.length);
			if (addEmptyValue) {
				items.add(0, new SelectItem("", ""));
			}
			for (Dictionary dict : itemsArticle) {
				try {
					if (dict.getInstId() != null &&
							((instId == null || dict.getInstId() == 9999 || dict.getInstId().equals(instId)))) {
						if (showCode) {
							si = new SelectItem(dict.getDict() + dict.getCode(),
									dict.getDict() + dict.getCode() + " - " + dict.getName());
						} else {
							si = new SelectItem(dict.getDict() + dict.getCode(), dict.getName());
						}
						items.add(si);
					}
				} catch (Exception e) {
					logger.error("", e);
				}
			}
			Collections.sort(items, new Comparator<SelectItem>() {
				@Override
				public int compare(SelectItem o1, SelectItem o2) {
					if (o1.getLabel() == null || o1.getLabel().equals("")) {
						return -1;
					}
					if (o2.getLabel() == null || o2.getLabel().equals("")) {
						return 1;
					}
					return o1.getLabel().compareTo(o2.getLabel());
				}
			});
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} finally {
			if (items == null) {
				items = new ArrayList<SelectItem>(0);
			}
		}
		return items;
	}

	public Map<String, String> getArticlesMap(String dictName) {
		Map<String, String> result = new HashMap<String, String>();
		try {
			Long userSessionId = SessionWrapper.getRequiredUserSessionId();
			Dictionary[] itemsArticle = commonDao.getArticlesByDict(userSessionId, dictName);
			for (Dictionary dict : itemsArticle) {
				result.put(dict.getDict() + dict.getCode(), dict.getName());
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return result;
	}

	public void refresh() {
	}

	@SuppressWarnings("UnusedDeclaration")
	public CommonDao getCommonDao() {
		return commonDao;
	}

	@SuppressWarnings("UnusedDeclaration")
	public void setCommonDao(CommonDao commonDao) {
		this.commonDao = commonDao;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	@SuppressWarnings("UnusedDeclaration")
	public List<SelectItem> getInstitutes() {
		return getLov(LovConstants.INSTITUTIONS_SYS);
	}

	public Map<String, String> getInstitutesMap() {
		return getLovMap(LovConstants.INSTITUTIONS_SYS);
	}

	public List<SelectItem> getNotificationSchemes(final Integer instId) {
		return (getLov(LovConstants.NOTIFICATION_SCHEMES, new HashMap<String, Object>() {{
			put("inst_id", instId);
		}}));
	}

	public List<SelectItem> getLov(final int lovId) {
		List<SelectItem> items = null;
		try {
			final Long userSessionId = SessionWrapper.getRequiredUserSessionId();
			KeyLabelItem[] lovItems = lovCache.getValue(new Object[]{userSessionId, lovId},
					new RequestScopeCache.LoadCallback<KeyLabelItem[]>() {
						@Override
						public KeyLabelItem[] loadDict(Object[] key) {
							return commonDao.getLov(userSessionId, lovId);
						}
					});

			SelectItem si;
			items = new ArrayList<SelectItem>();
			for (KeyLabelItem item : lovItems) {
				si = new SelectItem(item.getValue(), item.getLabel(), item.getLabel());
				items.add(si);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} finally {
			if (items == null) {
				items = new ArrayList<SelectItem>(0);
			}
		}
		return items;
	}

	@SuppressWarnings("UnusedDeclaration")
	public List<SelectItem> getLovNoContext(final int lovId) {
		List<SelectItem> items = null;
		try {
			KeyLabelItem[] lovItems =
					lovCache.getValue(new Object[]{lovId}, new RequestScopeCache.LoadCallback<KeyLabelItem[]>() {
						@Override
						public KeyLabelItem[] loadDict(Object[] key) {
							return commonDao.getLov(lovId);
						}
					});

			SelectItem si;
			items = new ArrayList<SelectItem>();
			for (KeyLabelItem item : lovItems) {
				si = new SelectItem(item.getValue(), item.getLabel(), item.getLabel());
				items.add(si);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} finally {
			if (items == null) {
				items = new ArrayList<SelectItem>(0);
			}
		}
		return items;
	}

	public KeyLabelItem[] getLovItems(final int lovId) {
		try {
			final Long userSessionId = SessionWrapper.getRequiredUserSessionId();
			return lovCache
					.getValue(new Object[]{userSessionId, lovId}, new RequestScopeCache.LoadCallback<KeyLabelItem[]>() {
						@Override
						public KeyLabelItem[] loadDict(Object[] key) {
							return commonDao.getLov(userSessionId, lovId);
						}
					});
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return new KeyLabelItem[0];
	}

	public HashMap<String, String> getLovMap(final int lovId) {
		HashMap<String, String> items = null;
		try {
			final Long userSessionId = SessionWrapper.getRequiredUserSessionId();
			KeyLabelItem[] lovItems = lovCache.getValue(new Object[]{userSessionId, lovId},
					new RequestScopeCache.LoadCallback<KeyLabelItem[]>() {
						@Override
						public KeyLabelItem[] loadDict(Object[] key) {
							return commonDao.getLov(userSessionId, lovId);
						}
					});

			items = new HashMap<String, String>();
			for (KeyLabelItem item : lovItems) {
				items.put(String.valueOf(item.getValue()), item.getLabel());
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} finally {
			if (items == null) {
				items = new HashMap<String, String>(0);
			}
		}
		return items;
	}

	public List<SelectItem> getLov(int lovId, Map<String, Object> params) {
		return getLov(lovId, params, null, null);
	}

	public List<SelectItem> getLov(int lovId, Map<String, Object> params, List<String> where) {
		return getLov(lovId, params, where, null);
	}

	public List<SelectItem> getLov(final int lovId, final Map<String, Object> params, final List<String> where, final String appearance) {
		List<SelectItem> items = null;
		try {
			final Long userSessionId = SessionWrapper.getRequiredUserSessionId();
			KeyLabelItem[] lovItems = lovCache.getValue(new Object[]{userSessionId, lovId, params, where, appearance},
					new RequestScopeCache.LoadCallback<KeyLabelItem[]>() {
						@Override
						public KeyLabelItem[] loadDict(Object[] key) {
							return commonDao.getLov(userSessionId, lovId, params, where, appearance);
						}
					});

			SelectItem si;
			items = new ArrayList<SelectItem>();
			for (KeyLabelItem item : lovItems) {
				si = new SelectItem(item.getValue(), item.getLabel(), item.getLabel());
				items.add(si);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} finally {
			if (items == null) {
				items = new ArrayList<SelectItem>(0);
			}
		}
		return items;
	}

	public List<SelectItem> getLovNoContext(int lovId, Map<String, Object> params) {
		return getLovNoContext(lovId, params, null, null);
	}
	public List<SelectItem> getLovNoContext(final int lovId, final Map<String, Object> params,
											final List<String> where) {
		return getLovNoContext(lovId, params, where, null);
	}

	public List<SelectItem> getLovNoContext(final int lovId, final Map<String, Object> params,
											final List<String> where, final String appearance) {
		List<SelectItem> items = null;
		try {
			KeyLabelItem[] lovItems = lovCache.getValue(new Object[]{lovId, params, where, appearance},
					new RequestScopeCache.LoadCallback<KeyLabelItem[]>() {
						@Override
						public KeyLabelItem[] loadDict(Object[] key) {
							return commonDao.getLovNoContext(lovId, params, where, appearance);
						}
					});

			SelectItem si;
			items = new ArrayList<SelectItem>();
			for (KeyLabelItem item : lovItems) {
				si = new SelectItem(item.getValue(), item.getLabel(), item.getLabel());
				items.add(si);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} finally {
			if (items == null) {
				items = new ArrayList<SelectItem>(0);
			}
		}
		return items;
	}

	public List<SelectItem> getLovsList() {
		List<SelectItem> items;
		try {
			Long userSessionId = SessionWrapper.getRequiredUserSessionId();
			List<Lov> lovs = commonDao.getLovsList(userSessionId, new SelectionParams());
			items = new ArrayList<SelectItem>(lovs.size() + 1);
			items.add(new SelectItem(""));
			for (Lov lov : lovs) {
				items.add(new SelectItem(lov.getId(), lov.getId() + " - " + lov.getName()));
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			items = new ArrayList<SelectItem>(0);
		}
		return items;
	}

	@SuppressWarnings("UnusedDeclaration")
	public List<SelectItem> getLovsListByModule(String moduleCode, String lang) {
		List<SelectItem> items;
		SelectionParams params = new SelectionParams();
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("moduleCode");
		filters[0].setValue(moduleCode);
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(lang);

		params.setFilters(filters);
		try {
			Long userSessionId = SessionWrapper.getRequiredUserSessionId();
			List<Lov> lovs = commonDao.getLovsList(userSessionId, params);
			items = new ArrayList<SelectItem>(lovs.size() + 1);
			for (Lov lov : lovs) {
				items.add(new SelectItem(lov.getId(), lov.getId() + " - " + lov.getName()));
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			items = new ArrayList<SelectItem>(0);
		}
		return items;
	}

	public List<SelectItem> getArray(int arrayId) {
		List<SelectItem> result = new ArrayList<SelectItem>();
		try {
			Long userSessionId = SessionWrapper.getRequiredUserSessionId();
			KeyLabelItem[] arrayItems = commonDao.getArray(userSessionId, arrayId);

			SelectItem si;
			for (KeyLabelItem item : arrayItems) {
				si = new SelectItem(item.getValue(), item.getLabel(), item.getLabel());
				result.add(si);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return result;
	}

	@SuppressWarnings("UnusedDeclaration")
	public KeyLabelItem[] getLovStyleIcon(int lovId) {
		try {
			Long userSessionId = SessionWrapper.getRequiredUserSessionId();
			return commonDao.getLovStyleIcon(userSessionId, lovId);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return new KeyLabelItem[0];
	}

	public List<SelectItem> getLovUI(int lovId) {
		return getLovUI(lovId, null, null);
	}
	public List<SelectItem> getLovUI(int lovId, Map<String, Object> params) {
		return getLovUI(lovId, params, null);
	}
	public List<SelectItem> getLovUI(int lovId, List<SelectItem> list) {
		return getLovUI(lovId, null, list);
	}
	public List<SelectItem> getLovUI(int lovId, Map<String, Object> params, List<SelectItem> list) {
		if (list == null) {
			if (params != null && params.size() > 0) {
				list = getLov(lovId, params);
			} else {
				list = getLov(lovId);
			}
			if (list == null) {
				list = new ArrayList<SelectItem>();
			}
		}
		return list;
	}
}
