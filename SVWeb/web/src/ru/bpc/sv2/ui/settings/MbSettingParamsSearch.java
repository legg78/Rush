package ru.bpc.sv2.ui.settings;

import com.bpcbt.sv.utils.StringCrypter;
import org.apache.commons.lang3.ObjectUtils;
import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;
import ru.bpc.sv2.WebApplication;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.jmx.MonitoringScheduler;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.mastercom.api.MasterCom;
import ru.bpc.sv2.mastercom.api.MasterComEnvironment;
import ru.bpc.sv2.settings.SettingParam;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.LogoUtils;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.KeyLabelItem;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.io.File;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.regex.Pattern;

@ViewScoped
@ManagedBean (name = "MbSettingParamsSearch")
public class MbSettingParamsSearch extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("SETTINGS");
	private static final String AUT_MERGE_AMOUNT_AND_STTL_TYPE = "MRVA0002";

	private SettingsDao _settingsDao = new SettingsDao();

	private SettingParam currentNode; // node we are working with
	private SettingParam newNode;
	private boolean treeLoaded = true;

	private SettingParam filter;
	
	private TreePath nodePath;
	private MbSettingParams settingParamsBean;
	private ArrayList<SettingParam> coreItems;

	public MbSettingParamsSearch() {
		pageLink = "system|list_settings";
		Menu menu = ManagedBeanWrapper.getManagedBean("menu");
		settingParamsBean = ManagedBeanWrapper.getManagedBean("MbSettingParams");
		if (menu.isKeepState()) {
			nodePath = settingParamsBean.getNodePath();
			if (nodePath != null) {
				currentNode = (SettingParam) nodePath.getValue();
			}
		}
		curMode = VIEW_MODE;
	}

	public SettingParam getNode() {
		if (currentNode == null) {
			currentNode = new SettingParam();
		}
		return currentNode;
	}

	public void setNode(SettingParam node) {
		if (node == null)
			return;
		this.currentNode = node;
	}

	private void loadTree() {
		coreItems = new ArrayList<>();

		if (!searching && !LevelNames.SYSTEM.equals(getFilter().getParamLevel()))
			return;
		
		try {

			setFilters();
			SettingParam[] params;
			if (getFilter().getParamLevel() == null || getFilter().getParamLevel().equals("")) {
				getFilter().setParamLevel(LevelNames.USER);
			}
			if (LevelNames.SYSTEM.equals(getFilter().getParamLevel())
					|| LevelNames.USER.equals(getFilter().getParamLevel())
					|| (getFilter().getLevelValue() != null && !getFilter().getLevelValue().equals(""))) {
				params = _settingsDao.getSettingParams(userSessionId, null, true, getFilter());

				if (params != null && params.length > 0) {
					addNodes(0, coreItems, params);
					if (nodePath == null) {
						if (currentNode == null) {
							currentNode = coreItems.get(0);
							setNodePath(new TreePath(currentNode, null));
						} else {
							if (currentNode.getParentId() != null) {
								setNodePath(formNodePath(params));
							} else {
								setNodePath(new TreePath(currentNode, null));
							}
						}
					}
				}
			}
			treeLoaded = true;
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	private TreePath formNodePath(SettingParam[] items) {
		ArrayList<SettingParam> pathItems = new ArrayList<>();
		pathItems.add(currentNode);
		SettingParam node = currentNode;
		while (node.getParentId() != null) {
			for (SettingParam item: items) {
				if (item.getId().equals(node.getParentId())) {
					pathItems.add(item);
					node = item;
					break;
				}
			}
		}

		Collections.reverse(pathItems); // make current node last and its very first parent - first

		TreePath nodePath = null;
		for (SettingParam pathItem: pathItems) {
			nodePath = new TreePath(pathItem, nodePath);
		}

		return nodePath;
	}

	public void search() {
		searching = true;
		loadTree();
	}

	private int addNodes(int startIndex, ArrayList<SettingParam> branches, SettingParam[] params) {
		int i;
		int level = params[startIndex].getLevel();

		for (i = startIndex; i < params.length; i++) {
			if (params[i].getLevel() != level) {
				break;
			}
			branches.add(params[i]);
			if ((i + 1) != params.length && params[i + 1].getLevel() > level) {
				params[i].setChildren(new ArrayList<SettingParam>());
				i = addNodes(i + 1, params[i].getChildren(), params);
			}
		}
		return i - 1;
	}

	public ArrayList<SettingParam> getNodeChildren() {
		SettingParam param = getSettingParam();
		if (param == null) {
			if (!treeLoaded || coreItems == null) {
				loadTree();
			}
			return coreItems;
		} else {
			return param.getChildren();
		}
	}

	public ArrayList<SettingParam> getNodeChildrenSystem() {
		SettingParam param = getSettingParam();
		if (param == null) {
			if (!treeLoaded || coreItems == null) {
				coreItems = new ArrayList<>();
				SettingParam systFilter = new SettingParam();
				systFilter.setParamLevel(LevelNames.SYSTEM);
				setFilter(systFilter);
				loadTree();
				treeLoaded = true;
			}
			if (coreItems == null)
				coreItems = new ArrayList<>();
			return coreItems;
		} else {
			return param.getChildren();
		}

	}

	public SettingParam getNewNode() {
		if (newNode == null) {
			newNode = new SettingParam();
		}
		return newNode;
	}

	public void setNewNode(SettingParam newNode) {
		this.newNode = newNode;
	}

	public void edit() {
		try {
			newNode = (SettingParam) currentNode.clone();
		} catch (CloneNotSupportedException e) {
			newNode = currentNode;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			checkNewNode(newNode);
			if (newNode.isEncrypted()) {
				newNode.setValueV((new StringCrypter()).encrypt(newNode.getValue().toString()));
			}
			newNode.setParamLevel(getFilter().getParamLevel());
			newNode.setLevelValue(getFilter().getLevelValue());
			currentNode = _settingsDao.setParamValue(userSessionId, newNode);
			reloadCache();
			if ("PATH_TO_LOGO".equalsIgnoreCase(newNode.getSystemName())){
				LogoUtils logUtils = ManagedBeanWrapper.getManagedBean("MbLogo");
				logUtils.nullImage();
			}

			curMode = VIEW_MODE;
			treeLoaded = false;
			nodePath = null;

			loadTree();
			if (SettingsConstants.LANGUAGE.equals(newNode.getSystemName())) {
				UserSession us = ManagedBeanWrapper.getManagedBean("usession");
				us.flushUserLang();
				us.flushUserDatePattern();
				Menu menu = ManagedBeanWrapper.getManagedBean("menu");
				menu.reloadMenu();
			}
			if (SettingsConstants.ARTICLE_FORMAT.equals(newNode.getSystemName())) {
				UserSession us = ManagedBeanWrapper.getManagedBean("usession");
				us.flushArticleFormat();
			}
			if (SettingsConstants.DIGIT_GROUP_SEPARATOR.equals(newNode.getSystemName())) {
				UserSession us = ManagedBeanWrapper.getManagedBean("usession");
				us.flushGroupSeparator();
			}
			if (SettingsConstants.AUTHENTICATION_USE_SSO_MODULE.equals(newNode.getSystemName())
					&& ObjectUtils.notEqual(currentNode.getLovValue(), newNode.getLovValue())) {
				FacesUtils.addWarningMessage(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "setting_needs_restart"));
			}
            if (SettingsConstants.AUTHENTICATION_USE_SSO_MODULE.equals(newNode.getSystemName())
                    && ObjectUtils.notEqual(currentNode.getLovValue(), newNode.getLovValue())) {
                FacesUtils.addWarningMessage(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "setting_needs_restart"));
            }

            if (SettingsConstants.JMX_MONITORING.equals(newNode.getSystemName())) {
                MonitoringScheduler scheduler = WebApplication.getApplicationContext().getBean(MonitoringScheduler.class);
                scheduler.restart();
            }

            if (SettingsConstants.MASTERCOM_PRODUCTION_MODE.equals(newNode.getSystemName())) {
	            MasterComEnvironment env;
	            if (Boolean.TRUE.equals(SettingsCache.getInstance().getParameterBooleanValue(SettingsConstants.MASTERCOM_PRODUCTION_MODE))) {
		            env = MasterComEnvironment.PRODUCTION;
	            } else {
		            env = MasterComEnvironment.SANDBOX;
	            }
	            MasterCom.initEnvironment(env);
            }
            if (SettingsConstants.MASTERCOM_CONSUMER_KEY.equals(newNode.getSystemName())
		            || SettingsConstants.MASTERCOM_KEY_ALIAS.equals(newNode.getSystemName())
		            || SettingsConstants.MASTERCOM_KEY_PASSWORD.equals(newNode.getSystemName())
		            || SettingsConstants.MASTERCOM_PRIVATE_KEY_PATH.equals(newNode.getSystemName())) {
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
            }
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void checkNewNode(SettingParam newNode) throws Exception{
		if (SettingsConstants.SPLIT_DEGREE.equals(newNode.getSystemName()) ||
			SettingsConstants.PARALLEL_DEGREE.equals(newNode.getSystemName()) ||
			SettingsConstants.FILE_PARALLEL_DEGREE.equals(newNode.getSystemName()) ||
			SettingsConstants.PASSWORD_LENGTH.equals(newNode.getSystemName())) {
			if(newNode.getValueN().longValue() <= 0){
				throw new Exception(FacesUtils.getMessage(
						"ru.bpc.sv2.ui.bundles.Msg", "min_value_field",0));
			}
		} else if(SettingsConstants.REPORTS_SAVE_PATH.equals(newNode.getSystemName()) || SettingsConstants.REPORTS_BANNER_HOME.equals(newNode.getSystemName())){  
			File newPath = new File(newNode.getValueV());
			if (!newPath.exists()){
				throw  new Exception(FacesUtils.getMessage(
						"ru.bpc.sv2.ui.bundles.Msg", "path_not_found"));
				
			}
		}else if(SettingsConstants.REPORTS_JASPER_LIB_PATH.equals(newNode.getSystemName())){
			File newPath = new File(newNode.getValueV());
			if (!newPath.exists()){
				throw  new Exception(FacesUtils.getMessage(
						"ru.bpc.sv2.ui.bundles.Msg", "files_not_found"));
				
			}
		} else if (SettingsConstants.DATE_PATTERN.equals(newNode.getSystemName())) {
			checkDatePattern(newNode.getValueV());
		} else if(SettingsConstants.AUT_MERGE_REVERSAL.equals(newNode.getSystemName())) {
			checkAutMergeReversal(newNode);
		} else if(SettingsConstants.AUT_MERGE_STTL_TYPE_ID.equals(newNode.getSystemName())) {
			checkAutMergeSttlTypeId(newNode);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	private SettingParam getSettingParam() {
		return (SettingParam) Faces.var("settingParam");
	}

	public boolean getNodeHasChildren() {
		SettingParam message = getSettingParam();
		return message != null && message.hasChildren();
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		settingParamsBean.setNodePath(nodePath);
		this.nodePath = nodePath;
	}

	public SettingParam getFilter() {
		if (filter == null)
			filter = new SettingParam();
		return filter;
	}

	public void setFilter(SettingParam filter) {
		this.filter = filter;
	}

	public void setFilters() {
		filters = new ArrayList<>();
		if (getFilter().getLevelValue() != null && !getFilter().getLevelValue().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("levelValue");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getLevelValue());
			filters.add(paramFilter);
		}
		if (getFilter().getParamLevel() != null && !getFilter().getParamLevel().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("paramLevel");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getParamLevel());
			filters.add(paramFilter);
		}

	}

	public SelectItem[] getListValues() {

		if (newNode != null && newNode.getLovId() != null && !newNode.getLovId().equals(LovConstants.NAME_FORMATS)) {
			SelectItem[] siArr = new SelectItem[newNode.getLov().length];
			for (int i = 0; i < newNode.getLov().length; i++) {
				KeyLabelItem item = newNode.getLov()[i];
				SelectItem si = new SelectItem(item.getValue(), item.getLabel());
				siArr[i] = si;
			}
			return siArr;
		} else if (newNode != null && newNode.getLovId() != null && newNode.getLovId().equals(LovConstants.NAME_FORMATS)) {
			SelectItem[] siArr = new SelectItem[newNode.getLov().length+1];
			siArr[0] = new SelectItem("","");
			for (int i = 0; i < newNode.getLov().length; i++) {
				KeyLabelItem item = newNode.getLov()[i];
				SelectItem si = new SelectItem(item.getValue(), item.getLabel());
				siArr[i+1] = si;
			}
			return siArr;
		}
		return new SelectItem[0];
	}

	public void clearFilter() {
		curMode = VIEW_MODE;
		currentNode = null;
		filter = null;
		treeLoaded = false;
		searching = false;
	}
	
	public void reloadCache() {
		try {
			SettingsCache.getInstance().reload();
			initialization();
		} catch (Exception e) {
			logger.error("", e);
		}
	}

	private void initialization(){
		try{
			_settingsDao.initialization(userSessionId);
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}
	
	private void checkDatePattern(String pattern) throws Exception {
		try {
			Pattern p = Pattern.compile("[^dMy.\\-/:]");
			// if there are some other symbols except of "dMy.-/:" then
			// pattern is invalid as we need only date (without time) with
			// meaningful separators
			if (p.matcher(pattern).find()) {
				throw new Exception();
			}
			new SimpleDateFormat(pattern); // this'll check some other things (maybe)  
		} catch (Exception e) {
			throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "check_date_format"));
		}
	}

	private SettingParam getSiblingSettingByName(String name) {
		if (nodePath == null) {
			return null;
		}

		TreePath parentPath = nodePath.getParentPath();
		if (parentPath == null || parentPath.getValue() == null) {
			return null;
		}

		SettingParam parentSetting = (SettingParam) parentPath.getValue();
		for (SettingParam param: parentSetting.getChildren()) {
			if (param.getSystemName().equals(name)) {
				return param;
			}
		}

		return null;
	}


	private void checkAutMergeReversal(SettingParam newNode) {
		if (MbSettingParamsSearch.AUT_MERGE_AMOUNT_AND_STTL_TYPE.equals(newNode.getValueV())) {
			return;
		}

		SettingParam param = getSiblingSettingByName(SettingsConstants.AUT_MERGE_STTL_TYPE_ID);
		if (param == null) {
			return;
		}

		if (param.getValueV() == null) {
			return;
		}

		param.setParamLevel(getFilter().getParamLevel());
		param.setLevelValue(getFilter().getLevelValue());
		param.setValueV(null);
		_settingsDao.setParamValue(userSessionId, param);

		FacesUtils.addWarningMessage(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Aut", "setting_sttl_type_cleared", param.getName()));
	}

	private void checkAutMergeSttlTypeId(SettingParam newNode) throws Exception {
		if (newNode.getValueV() == null) {
			return;
		}
		SettingParam param = getSiblingSettingByName(SettingsConstants.AUT_MERGE_REVERSAL);
		if (param == null) {
			return;
		}

		if (MbSettingParamsSearch.AUT_MERGE_AMOUNT_AND_STTL_TYPE.equals(param.getValueV())) {
			return;
		}

		throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Aut", "setting_sttl_type_change", param.getName(), MbSettingParamsSearch.AUT_MERGE_AMOUNT_AND_STTL_TYPE));
	}
}
