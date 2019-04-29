package ru.bpc.sv2.ui.common;

import java.util.ArrayList;
import java.util.HashMap;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.common.Label;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.invocation.SortElement.Direction;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.bundles.BaseBundle;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbLabels")
public class MbLabels extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("COMMON");
	
	private static String COMPONENT_ID = "1075:labelsTable";

	private CommonDao _commonDao = new CommonDao();

	private Label labelFilter;
	private Label newLabel;
	private boolean modalMode;
	private ArrayList<Label> newLabels;

    private final DaoDataModel<Label> _labelSource;
	private final TableRowSelection<Label> _itemSelection;
	private Label _activeLabel;

	private HashMap<String, String> langToIso;
	
	public MbLabels() {
		pageLink = "common|labels";
		modalMode = true;

		_labelSource = new DaoDataModel<Label>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected Label[] loadDaoData(SelectionParams params) {
				if (!isSearching()) {
					return new Label[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getLabels( userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Label[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching()) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getLabelsCount( userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Label>(null, _labelSource);
	}

	@PostConstruct
	public void init() {
		getLanguages();
		langToIso = new HashMap<String, String>(languages.size());
		
		Filter[] filters = new Filter[2];
		filters[0] = new Filter("convId", 5003);
		filters[1] = new Filter();
		filters[1].setElement("inValue");
		SelectionParams params = new SelectionParams(filters);
		for (SelectItem lang : languages) {
			filters[1].setValue(lang.getValue());
			String isoLang = null;
			try {
				isoLang = _commonDao.getArrayOutElement(userSessionId, params);
			} catch (Exception e) {
				logger.error("ERROR: couldn't load iso language code for " + lang.getValue(), e);
			}
			if (isoLang == null) {
				// if there's no conversion from current language to ISO language we'll try 
				// to use first two letters of current language 
				isoLang = ((String) lang.getValue()).substring(4, 6).toLowerCase();
			}
			langToIso.put((String) lang.getValue(), isoLang);
		}
	}
	
	public DaoDataModel<Label> getLabels() {
		return _labelSource;
	}

	public Label getActiveLabel() {
		return _activeLabel;
	}

	public void setActiveLabel(Label activeLabel) {
		_activeLabel = activeLabel;
	}

	public SimpleSelection getItemSelection() {
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeLabel = _itemSelection.getSingleSelection();
	}

	public String search() {
		setFilters();

		searching = true;

		// search using new criteria
		_labelSource.flushCache();

		// reset selection
		if (_activeLabel != null) {
			_itemSelection.unselect(_activeLabel);
			_activeLabel = null;
		}

		// reset dependent bean
//		resetBalanceType();

		return "";
	}

	public void clearFilter() {
		curLang = userLang;
		labelFilter = new Label();
		searching = false;
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();
		Filter paramFilter = new Filter();
		getFilter();

		if (labelFilter.getLang() != null) {
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(labelFilter.getLang());
			filters.add(paramFilter);
		} else {
			UserSession us = (UserSession)ManagedBeanWrapper.getManagedBean("usession");

			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(us.getUserLanguage());
			filters.add(paramFilter);
		}

		if (labelFilter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(labelFilter.getId().toString());
			filters.add(paramFilter);
		}

		if (labelFilter.getText() != null && labelFilter.getText().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("text");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(labelFilter.getText().trim().toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (labelFilter.getName() != null && labelFilter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(labelFilter.getName().trim().toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (labelFilter.getLabelType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("labelType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(labelFilter.getLabelType());
			filters.add(paramFilter);
		}
	}

	public void resetBean() {
	}

	public Label getFilter() {
		if (labelFilter == null) {
			labelFilter = new Label();
		}
		return labelFilter;
	}

	public void setFilter(Label labelFilter) {
		this.labelFilter = labelFilter;
	}

	public void add() {
		newLabel = new Label();
		newLabel.setLabelType(labelFilter.getLabelType());
		newLabel.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		newLabel = copyCurrentLabel();
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				_commonDao.addLabel( userSessionId, newLabel);
			} else {
				_commonDao.addLabel( userSessionId, newLabel);
//				_commonDao.modifyLabel( userSessionId, newLabel);
			}
			curMode = VIEW_MODE;

			_labelSource.flushCache();

            BaseBundle.clear(newLabel.getName(), newLabel.getLang());

			FacesUtils.addMessageInfo("Label has been saved.");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
			
		}
	}

	public void delete() {
//		try {
//			_commonDao.deleteLabel( userSessionId, _activeLabel);
//			curMode = VIEW_MODE;
//
//			_labelSource.flushCache();
//			FacesUtils.addMessageInfo("Label (id = " + _activeLabel.getId() + ") has been deleted.");
//			_activeLabel = null;
//		} catch (Exception e) {
//			FacesContext.getCurrentInstance().addMessage(null, new FacesMessage(FacesMessage.SEVERITY_ERROR, e.getMessage(), null));
//		}
	}

	public Label copyCurrentLabel() {
		Label label = new Label();
		label.setId(_activeLabel.getId());
		label.setLang(_activeLabel.getLang());
		label.setName(_activeLabel.getName());
		label.setText(_activeLabel.getText());
		label.setModuleCode(_activeLabel.getModuleCode());
		label.setLabelType(_activeLabel.getLabelType());

		return label;
	}

	public int getRowsNum() {
		return rowsNum;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public String getCurLang() {
		return curLang;
	}

	public void setCurLang(String curLang) {
		this.curLang = curLang;
	}

	public Label getNewLabel() {
		if (newLabel == null) {
			newLabel = new Label();
		}
		return newLabel;
	}

	public void setNewLabel(Label newLabel) {
		this.newLabel = newLabel;
	}

	public String cancel() {
		curMode = VIEW_MODE;
		return "";
	}

	public boolean isModalMode() {
		return modalMode;
	}

	public void setModalMode(boolean modalMode) {
		this.modalMode = modalMode;
	}

	public void changeLang(ValueChangeEvent event) {
		if (newLabel.getId() == null) {
			return;
		}

		String lang = (String) event.getNewValue();
		try {
			Label label = new Label();
			label.setId(newLabel.getId());
			label.setLang(lang);
			label = _commonDao.getLabelById( userSessionId, label);
			
			newLabel.setText(label.getText());
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}
	
	private String prepareLabelName(Label label){
    	return label.getName().substring(label.getName().indexOf(".") > -1 
				? label.getName().indexOf(".") + 1 : 0);
	}
	
	private String prepareLabelValue(Label label){
    	String unicodeString = "";
    	// transform string to UTF codes string
    	for (int i = 0; i < label.getText().length(); i++) {
            String hexCode = Integer.toHexString(
            		label.getText().codePointAt(i)).toUpperCase();

            String hexCodeWithAllLeadingZeros = "0000" + hexCode;
            String hexCodeWithLeadingZeros = hexCodeWithAllLeadingZeros
            			.substring(hexCodeWithAllLeadingZeros.length() - 4);

            unicodeString += "\\u" + hexCodeWithLeadingZeros;
    	}
    	return unicodeString;
	}
	
	private Label[] getLabels(String lang){
		if (lang == null || lang.length() <= 0) {
			throw new IllegalArgumentException("Lang argument cannot be null or have a zero-length");
		}
		// set sorting by label name so that it would be easier to read them
		SelectionParams params = new SelectionParams();
		SortElement[] sorts = new SortElement[1];
		sorts[0] = new SortElement("name", Direction.ASC);		
		params.setSortElement(sorts);
		params.setRowIndexEnd(-1);	// to get whole list, without paging restrictions
		getFilter().setLang(lang);
		
		setFilters();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		Label[] labels = _commonDao.getLabels( userSessionId, params);
		return labels;
	}
	
	private String preparePrefix(Label label){
		// get caption prefix (i.e. in "common.some_label", "common" is prefix)
    	// and check if it's equal to previous one. If it's not current streams 
    	// are closed and new file with new prefix as its name is created.
		String result;
		int pos = label.getName().indexOf(".");
		if (pos > 0){
			result = label.getName().toLowerCase().substring(0, pos);
		} else {
			result = null;
		}
    	return result;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}
	
}
