package ru.bpc.sv2.ui.common.dictionary;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.common.Dictionary;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;



@ViewScoped
@ManagedBean (name = "MbDictionary")
public class MbDictionary extends AbstractBean implements Serializable {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("COMMON");

	private CommonDao _commonDao = new CommonDao();
	
	private SettingsDao settingsDao = new SettingsDao();

	private Dictionary _activeDict;
	private Dictionary _activeArticle;
	private Dictionary newDict;
	private Dictionary newArticle;

	private final DaoDataModel<Dictionary> _dictSource;
	private final DaoDataModel<Dictionary> _articleSource;

	private TableRowSelection<Dictionary> _dictSelection;
	private final TableRowSelection<Dictionary> _articleSelection;

	private boolean _managingNewDict;
	private boolean _managingNewArticle;
	private String curLang;
	private String curLangArticle;
	private String userLang;

	private List<Filter> dictFilters;
	private List<Filter> articleFilters;
	private Dictionary filterDict;
	private Dictionary filterArticle;
	private Integer dictPage;
	private int dictRowNum = 20;
	private int articleRowNum = 10;
	private boolean searching = false;

	private transient DictUtils dictUtils;

	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> moduleCodes;

	private Long userSessionId = null;
	private String headerName;
	private boolean externalMode; // whether article is saved outside of
									// "Dictionaries" form

	private static String COMPONENT_ID = "articlesTable";
	private String tabName;
	private String parentSectionId;
	private Dictionary synchronizationResult;
	
	public MbDictionary() {
		pageLink = "common|dictionaries";
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		
		curLangArticle = curLang = userLang = SessionWrapper
				.getField("language");
		_dictSource = new DaoDataModel<Dictionary>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected Dictionary[] loadDaoData(SelectionParams params) {
				if (!searching)
					return new Dictionary[0];
				try {
					setDictFilters();
					params.setFilters(dictFilters
							.toArray(new Filter[dictFilters.size()]));
					return _commonDao.getDictionaries(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Dictionary[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching)
					return 0;
				try {
					setDictFilters();
					params.setFilters(dictFilters
							.toArray(new Filter[dictFilters.size()]));
					return _commonDao.getDictionariesCount(userSessionId,
							params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_dictSelection = new TableRowSelection<Dictionary>(null, _dictSource);

		_articleSource = new DaoDataModel<Dictionary>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected Dictionary[] loadDaoData(SelectionParams params) {
				if (_activeDict == null)
					return new Dictionary[0];
				try {
					setArticleFilters();
					params.setFilters(articleFilters
							.toArray(new Filter[articleFilters.size()]));
					return _commonDao.getArticles(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Dictionary[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (_activeDict == null)
					return 0;
				try {
					setArticleFilters();
					params.setFilters(articleFilters
							.toArray(new Filter[articleFilters.size()]));
					return _commonDao.getArticlesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_articleSelection = new TableRowSelection<Dictionary>(null,
				_articleSource);
		tabName = "articles";
	}

	public DaoDataModel<Dictionary> getDictionaries() {
		return _dictSource;
	}

	public Dictionary getActiveDict() {
		return _activeDict;
	}

	public void setActiveDict(Dictionary activeDict) {
		_activeDict = activeDict;
		_activeArticle = null;
	}

	public SimpleSelection getDictSelection() {
		try {
			if (_activeDict == null && _dictSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeDict != null && _dictSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeDict.getModelId());
				_dictSelection.setWrappedSelection(selection);
				_activeDict = _dictSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _dictSelection.getWrappedSelection();
	}

	public void setDictSelection(SimpleSelection selection) {
		// System.out.println("Set Dict selection: " +
		// System.currentTimeMillis());
		_dictSelection.setWrappedSelection(selection);
		_activeDict = _dictSelection.getSingleSelection();
		if (_activeDict != null) {
			setInfo();
		}
	}

	public void setFirstRowActive() {
		_dictSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeDict = (Dictionary) _dictSource.getRowData();
		selection.addKey(_activeDict.getModelId());
		_dictSelection.setWrappedSelection(selection);
		if (_activeDict != null) {
			setInfo();
		}
	}

	public void clearDict() {
		_dictSelection.clearSelection();
		_activeDict = null;
		_dictSource.flushCache();

		resetArticlesState();
		searching = false;
	}

	public void createDictionary() {
		newDict = new Dictionary();
		newDict.setEditable(true);
		newDict.setLang(userLang);
		_managingNewDict = true;
	}

	public void editDictionary() {
		_managingNewDict = false;
		newDict = _activeDict.clone();
	}

	public void cancel() {

	}

	public void saveDict() {
		try {
			if (_managingNewDict) {
				newDict.setCode(newDict.getCode().toUpperCase());
				newDict = _commonDao.createDictionary(userSessionId, newDict);
				_dictSelection.addNewObjectToList(newDict);

				resetArticlesState();
			} else {
				newDict = _commonDao.modifyDictionary(userSessionId, newDict);
				_dictSource.replaceObject(_activeDict, newDict);

				_articleSource.flushCache();
			}

			_activeDict = newDict;

			getDictUtils().flush();
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public void refresh() {
		try {
			getDictUtils().flush();
		} catch (Exception e) {
			logger.error("", e);
		}
	}

	public boolean isManagingNewDict() {
		return _managingNewDict;
	}

	public void setManagingNewDict(boolean managingNewDict) {
		_managingNewDict = managingNewDict;
	}

	// Articles methods
	public DaoDataModel<Dictionary> getArticles() {
		return _articleSource;
	}

	public Dictionary getActiveArticle() {
		return _activeArticle;
	}

	public void setActiveArticle(Dictionary activeArticle) {
		_activeArticle = activeArticle;
	}

	public SimpleSelection getArticleSelection() {
		if (_activeArticle == null && _articleSource.getRowCount() > 0) {
			setArticleFirstRowActive();
		} else if (_activeArticle != null && _articleSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeArticle.getModelId());
			_articleSelection.setWrappedSelection(selection);
			_activeArticle = _articleSelection.getSingleSelection();
		}
		return _articleSelection.getWrappedSelection();
	}

	public void setArticleSelection(SimpleSelection selection) {
		_articleSelection.setWrappedSelection(selection);
		_activeArticle = _articleSelection.getSingleSelection();
	}

	public void setArticleFirstRowActive() {
		_articleSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeArticle = (Dictionary) _articleSource.getRowData();
		selection.addKey(_activeArticle.getModelId());
		_articleSelection.setWrappedSelection(selection);
		if (_activeArticle != null) {

		}
	}

	public void addArticle() {
		newArticle = new Dictionary();
		newArticle.setLang(curLang);
		externalMode = false;

		if (_activeDict != null) {
			newArticle.setDict(_activeDict.getCode());
			newArticle.setNumeric(_activeDict.isNumeric());
		}
		newArticle.setEditable(true);
		_managingNewArticle = true;
	}

	public void saveArticle() {
		boolean isRepl = false;
		try {
			if (_managingNewArticle) {
				isRepl = true;
				newArticle.setCode(newArticle.getCode().toUpperCase());
				newArticle = _commonDao
						.createArticle(userSessionId, newArticle);
				if (!externalMode) {
					_articleSelection.addNewObjectToList(newArticle);
				}
			} else {
				newArticle = _commonDao
						.modifyArticle(userSessionId, newArticle);
				if (_activeArticle.getLang().equals(newArticle.getLang()) && !externalMode) {
					_articleSource.replaceObject(_activeArticle, newArticle);
					isRepl = true;
				}
			}

			if (isRepl && !externalMode) {
				_activeArticle = newArticle;
			}
			getDictUtils().flush();
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	/**
	 * For saving from other beans
	 */
	// public void saveArticleExt() {
	// try {
	// if (_managingNewArticle) {
	// newArticle.setCode(newArticle.getCode().toUpperCase());
	// _commonDao.createArticle(userSessionId, newArticle);
	// } else {
	// _commonDao.modifyArticle(userSessionId, newArticle);
	// }
	//
	// getDictUtils().flush();
	// } catch (DataAccessException ee) {
	// FacesUtils.addMessageError(ee);
	// logger.error("", ee);
	// }
	// }

	public void resetArticlesState() {
		_activeArticle = null;
		_articleSelection.clearSelection();
		_articleSource.flushCache();
	}

	public void deleteArticle() {
		try {
			_commonDao.deleteArticle(userSessionId, _activeArticle);

			FacesUtils.addMessageInfo("Article \"" + _activeArticle.getCode()
					+ "\" was deleted from dictionary \""
					+ _activeDict.getCode() + "\"");
			_activeArticle = _articleSelection
					.removeObjectFromList(_activeArticle);

			if (_activeArticle == null) {
				resetArticlesState();
			}

			getDictUtils().flush();
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public void deleteDict() {
		try {
			_commonDao.deleteArticle(userSessionId, _activeDict);

			_activeDict = _dictSelection.removeObjectFromList(_activeDict);
			if (_activeDict == null) {
				clearDict();
			} else {
				setInfo();
			}

			getDictUtils().flush();
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public void searchDict() {
		setSearching(true);

		_dictSource.flushCache();
		if (_dictSelection != null)
			_dictSelection.clearSelection();
		_activeDict = null;
		searchArticles();
	}

	public void searchArticles() {
		resetArticlesState();
	}

	public void setDictFilters() {

		List<Filter> filtersList = new ArrayList<Filter>();
		Filter paramFilter = null;
		if (getFilterDict().getCode() != null
				&& !getFilterDict().getCode().trim().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("code");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilterDict().getCode().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filtersList.add(paramFilter);
		}

		if (getFilterDict().getName() != null
				&& getFilterDict().getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(getFilterDict().getName().trim()
					.replaceAll("[*]", "%").replaceAll("[?]", "_")
					.toUpperCase());
			filtersList.add(paramFilter);
		}
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(SessionWrapper.getField("language"));
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("dict");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue("DICT");
		filtersList.add(paramFilter);

		dictFilters = filtersList;
	}

	public void setArticleFilters() {

		List<Filter> filtersList = new ArrayList<Filter>();
		Filter paramFilter = null;
		if (_activeDict != null && _activeDict.getCode() != null
				&& !_activeDict.getCode().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("dict");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(_activeDict.getCode().toUpperCase());
			filtersList.add(paramFilter);
		}

		if (getFilterArticle().getName() != null
				&& getFilterArticle().getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(getFilterArticle().getName().trim()
					.replaceAll("[*]", "%").replaceAll("[?]", "_").toUpperCase()
					+ "%");
			filtersList.add(paramFilter);
		}
		if (getFilterArticle().getDescription() != null
				&& getFilterArticle().getDescription().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("description");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(getFilterArticle().getDescription().trim()
					.replaceAll("[*]", "%").replaceAll("[?]", "_").toUpperCase()
					+ "%");
			filtersList.add(paramFilter);
		}

		if (getFilterArticle().getCode() != null
				&& !getFilterArticle().getCode().trim().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("code");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilterArticle().getCode().trim()
					.replaceAll("[*]", "%").replaceAll("[?]", "_").toUpperCase()
					+ "%");
			filtersList.add(paramFilter);
		}
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLangArticle);
		filtersList.add(paramFilter);
		articleFilters = filtersList;
	}

	public void setInfo() {
		curLangArticle = userLang;
		resetArticlesState();
	}

	public boolean isManagingNewArticle() {
		return _managingNewArticle;
	}

	public void setManagingNewArticle(boolean managingNewArticle) {
		_managingNewArticle = managingNewArticle;
	}

	public Dictionary getFilterDict() {
		if (filterDict == null)
			filterDict = new Dictionary();
		return filterDict;
	}

	public void setFilterDict(Dictionary filterDict) {
		this.filterDict = filterDict;
	}

	public Dictionary getFilterArticle() {
		if (filterArticle == null)
			filterArticle = new Dictionary();
		return filterArticle;
	}

	public void setFilterArticle(Dictionary filterArticle) {
		this.filterArticle = filterArticle;
	}

	public void export() {

	}

	public String getExportText() {
		if (_activeDict != null)
			return _commonDao.getDml(userSessionId, _activeDict.getCode());
		else
			return "";
	}

	/**
	 * <p>
	 * Initiates article creation from outer forms (not from "Dictionaries").
	 * </p>
	 * 
	 * @param dictCode
	 * @throws Exception 
	 */
	public void setNewArticleExt(String dictCode) throws Exception {
		_managingNewArticle = true;
		externalMode = true;

		Dictionary pattern = getDictUtils().getAllArticles().get("DICT" + dictCode);
		if (pattern == null){			
			throw new Exception("Dictionary " + "DICT" + dictCode + " is not found");
		}
		newArticle = new Dictionary();
		newArticle.setDict(dictCode);
		newArticle.setNumeric(pattern.isNumeric());
		newArticle.setEditable(pattern.isEditable());
		newArticle.setLang(curLang);

	}

	public void editArticle() {
		newArticle = _activeArticle.clone();
		_managingNewArticle = false;
	}

	public Integer getDictPage() {
		return dictPage;
	}

	public void setDictPage(Integer dictPage) {
		this.dictPage = dictPage;
	}

	public void close() {
		newDict = null;
		newArticle = null;
	}

	public Dictionary getNewDict() {
		if (newDict == null) {
			newDict = new Dictionary();
		}
		return newDict;
	}

	public void setNewDict(Dictionary newDict) {
		this.newDict = newDict;
	}

	public Dictionary getNewArticle() {
		if (newArticle == null)
			newArticle = new Dictionary();
		return newArticle;
	}

	public void setNewArticle(Dictionary newArticle) {
		this.newArticle = newArticle;
	}

	public int getDictRowNum() {
		return dictRowNum;
	}

	public void setDictRowNum(int dictRowNum) {
		this.dictRowNum = dictRowNum;
	}

	public int getArticleRowNum() {
		return articleRowNum;
	}

	public void setArticleRowNum(int articleRowNum) {
		this.articleRowNum = articleRowNum;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}

	public boolean isSearching() {
		return searching;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeDict.getId().toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		dictFilters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(dictFilters.toArray(new Filter[dictFilters.size()]));
		try {
			Dictionary[] dicts = _commonDao.getDictionaries(userSessionId,
					params);
			if (dicts != null && dicts.length > 0) {
				_activeDict = dicts[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void changeLanguageArticle(ValueChangeEvent event) {
		curLangArticle = (String) event.getNewValue();
		_articleSource.flushCache();
		/*
		 * List<Filter> filtersList = new ArrayList<Filter>();
		 * 
		 * Filter paramFilter = new Filter(); paramFilter.setElement("id");
		 * paramFilter.setOp(Operator.eq);
		 * paramFilter.setValue(_activeArticle.getId().toString());
		 * filtersList.add(paramFilter);
		 * 
		 * paramFilter = new Filter(); paramFilter.setElement("lang");
		 * paramFilter.setOp(Operator.eq); paramFilter.setValue(curLangArticle);
		 * filtersList.add(paramFilter);
		 * 
		 * articleFilters = filtersList; SelectionParams params = new
		 * SelectionParams(); params.setFilters(articleFilters.toArray(new
		 * Filter[articleFilters.size()])); try { Dictionary[] dicts =
		 * _commonDao.getArticles( userSessionId, params); if (dicts != null &&
		 * dicts.length > 0) { _activeArticle = dicts[0]; } } catch (Exception
		 * e) { FacesUtils.addMessageError(e); logger.error("",e); }
		 */
	}

	public void viewArticle() {

	}

	public String getCurLang() {
		return curLang;
	}

	public void setCurLang(String curLang) {
		this.curLang = curLang;
	}

	public String getCurLangArticle() {
		return curLangArticle;
	}

	public void setCurLangArticle(String curLangArticle) {
		this.curLangArticle = curLangArticle;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils()
					.getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public String getHeaderName() {
		return headerName;
	}

	/**
	 * <p>
	 * Sets header name for modal panel where new article is created. Generally
	 * it's better to use facelet parameter <code>headerText</code> inside
	 * corresponding <code>include</code> tag. But in some cases when two
	 * different articles are created from one form (as in case of account
	 * types) the only way to show correct header is to use this field.
	 * </p>
	 * 
	 * @param headerName
	 */
	public void setHeaderName(String headerName) {
		this.headerName = headerName;
	}

	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newDict.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newDict.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Dictionary[] dicts = _commonDao.getDictionaries(userSessionId,
					params);
			if (dicts != null && dicts.length > 0) {
				newDict = dicts[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void confirmEditLanguageArticle() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newArticle.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newArticle.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Dictionary[] dicts = _commonDao.getArticles(userSessionId, params);
			if (dicts != null && dicts.length > 0) {
				newArticle = dicts[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public List<Dictionary> getSelectedItems(){
		return _dictSelection.getMultiSelection();
	}
	
	public List<Object> getEmptyTable() {
		List<Object> arr = new ArrayList<Object>(1);
		arr.add(new Object());
		return arr;
	}
	
	public DictUtils getDictUtils() {
		if (dictUtils == null) {
			dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		}
		return dictUtils;
	}
	
	public String getComponentId() {
		return getSectionId() + ":" + tabName + ":" + COMPONENT_ID;
	}

	@Override
	public void clearFilter() {
		filterDict = new Dictionary();
		clearDict();
		searching = false;
	}
	
	public String getSectionId() {
		return SectionIdConstants.ADMINISTRATION_DICTIONARY;
	}
	
	public String getTabName() {
		return tabName;
	}
	
	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
		
	public String getTableState() {
		setParentSectionId(getSectionId());
		return super.getTableState();
	}
	
	public ArrayList<SelectItem> getModuleCodes() {
		if (moduleCodes == null) {
			moduleCodes = (ArrayList<SelectItem>) getDictUtils()
					.getLov(LovConstants.MODULE_CODE);
		}
		return moduleCodes;
	}

	public Dictionary getSynchronizationResult() {
		return synchronizationResult;
	}

}
