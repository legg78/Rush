package ru.bpc.sv2.ui.common.flexible;

import java.util.ArrayList;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;

import ru.bpc.sv2.common.FlexField;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;

@SessionScoped
@ManagedBean (name = "MbFlexFields")
public class MbFlexFields extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("COMMON");

	private CommonDao _commonDao = new CommonDao();

	private FlexField _activeFlexField;

	transient 
	private String backLink;
	private String backLinkSearch;
	private boolean selectMode;

	private boolean _managingNew;
	private ArrayList<SelectItem> dataTypes;

	public MbFlexFields() {
		
	}

	public FlexField getActiveFlexField() {
		return _activeFlexField;
	}

	public void setActiveFlexField(FlexField activeFlexField) {
		_activeFlexField = activeFlexField;
	}

	public String createLimit() {
		_managingNew = true;

		return "open_details";
	}

	public String editLimit() {
		_managingNew = false;

		return "open_details";
	}

	public String commit() {
		try {
			if (_managingNew) {
				_commonDao.createFlexField(userSessionId, _activeFlexField);
			} else {
				_commonDao.updateFlexField(userSessionId, _activeFlexField, curLang);
			}

			FacesUtils.addMessageInfo("FlexField \"" + _activeFlexField.getId() + "\" saved");

			if (backLink != null && !backLink.equals("")) {
				return backLink;
			}
			return "success";
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
			return "failure";
		}
	}

	public boolean isManagingNew() {
		return _managingNew;
	}

	public void setManagingNew(boolean managingNew) {
		_managingNew = managingNew;
	}

	public ArrayList<SelectItem> getLimitTypes() {
		return getDictUtils().getArticles(DictNames.LIMIT_TYPES, false, true);
	}

	public ArrayList<SelectItem> getDataTypes() {
		if (dataTypes == null){
			dataTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.DATA_TYPES);
		}
		return dataTypes;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public String getBackLinkSearch() {
		return backLinkSearch;
	}

	public void setBackLinkSearch(String backLinkSearch) {
		this.backLinkSearch = backLinkSearch;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}

}
