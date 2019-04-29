package ru.bpc.sv2.ui.pmo;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.PaymentOrdersDao;
import ru.bpc.sv2.pmo.PmoPurposeHasParameter;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

/**
 * Manage Bean for List PMO Purposes has parameter form.
 */
@RequestScoped
@KeepAlive
@ManagedBean (name = "MbPurposesHasParameter")
public class MbPurposesHasParameter extends AbstractBean {
	private static final Logger logger = Logger.getLogger("PAYMENT_ORDERS");

	private PaymentOrdersDao _paymentOrdersDao = new PaymentOrdersDao();

	private PmoPurposeHasParameter _activePurposeParameter;
	private PmoPurposeHasParameter newPurposeParameter;

	private PmoPurposeHasParameter filter;
	private List<Filter> purposeParameterFilters;

	private boolean selectMode;

	private final DaoDataModel<PmoPurposeHasParameter> _purposeParametersSource;

	private final TableRowSelection<PmoPurposeHasParameter> _purposeParameterSelection;
	
	private static String COMPONENT_ID = "purposeParametersTable";
	private String tabName;
	private String parentSectionId;
	
	public MbPurposesHasParameter() {
		_purposeParametersSource = new DaoDataModel<PmoPurposeHasParameter>() {
			@Override
			protected PmoPurposeHasParameter[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new PmoPurposeHasParameter[0];
				try {
					setPurposeParametersFilters();
					params.setFilters(purposeParameterFilters.toArray(new Filter[purposeParameterFilters.size()]));
					return _paymentOrdersDao.getPurposesHasParameter(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new PmoPurposeHasParameter[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching())
					return 0;
				try {
					setPurposeParametersFilters();
					params.setFilters(purposeParameterFilters.toArray(new Filter[purposeParameterFilters.size()]));
					return _paymentOrdersDao.getPurposesHasParameterCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		_purposeParameterSelection = new TableRowSelection<PmoPurposeHasParameter>(null, _purposeParametersSource);
	}

	public DaoDataModel<PmoPurposeHasParameter> getPurposeParameters() {
		return _purposeParametersSource;
	}

	public PmoPurposeHasParameter getActivePurposeParameter() {
		return _activePurposeParameter;
	}

	public void setActivePurposeParameter(PmoPurposeHasParameter activePurposeParameter) {
		this._activePurposeParameter = activePurposeParameter;
	}

	public SimpleSelection getPurposeParameterSelection() {
		if (_activePurposeParameter == null && _purposeParametersSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		else if (_activePurposeParameter != null && _purposeParametersSource.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activePurposeParameter.getModelId());
			_purposeParameterSelection.setWrappedSelection(selection);
			_activePurposeParameter = _purposeParameterSelection.getSingleSelection();			
		}
		return _purposeParameterSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_purposeParametersSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activePurposeParameter = (PmoPurposeHasParameter) _purposeParametersSource.getRowData();
		selection.addKey(_activePurposeParameter.getModelId());
		_purposeParameterSelection.setWrappedSelection(selection);
		if (_activePurposeParameter != null) {
			setInfo();
		}
	}
	
	public void setInfo() {
		//set param filter for getting list of purpose parameter values
		MbPMOParameterValues parameterValueSearch = (MbPMOParameterValues) ManagedBeanWrapper
				.getManagedBean("MbPMOParameterValues");
		parameterValueSearch.clearFilter();
		parameterValueSearch.getFilter().setPurpParamId(_activePurposeParameter.getId());
		parameterValueSearch.getFilter().setName(_activePurposeParameter.getName());
		parameterValueSearch.getFilter().setSystemName(_activePurposeParameter.getSystemName());
		parameterValueSearch.getFilter().setDataType(_activePurposeParameter.getDataType());
		parameterValueSearch.getFilter().setLovId(_activePurposeParameter.getLovId());
		parameterValueSearch.getFilter().setLovName(_activePurposeParameter.getLovName());
		parameterValueSearch.search();
	}
	
	public void setPurposeParameterSelection(SimpleSelection selection) {
		_purposeParameterSelection.setWrappedSelection(selection);
		_activePurposeParameter = _purposeParameterSelection.getSingleSelection();
		if (_activePurposeParameter != null) {
			setInfo();
		}
	}

	public void search() {
		clearBean();
		clearBeansStates();
		searching = true;
	}
	
	public void clearBeansStates() {
		MbPMOParameterValues parameterValueSearch = (MbPMOParameterValues) ManagedBeanWrapper
			.getManagedBean("MbPMOParameterValues");
		parameterValueSearch.clearFilter();
//		parameterValueSearch.search();
	}
	
	public void clearFilter() {
		filter = null;
		clearBean();
		clearBeansStates();
	}

	public void clearBean() {
		searching = false;
		curLang = userLang;
		_purposeParametersSource.flushCache();
		if (_purposeParameterSelection != null) {
			_purposeParameterSelection.clearSelection();
		}
		_activePurposeParameter = null;
	}

	public void setPurposeParametersFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		if (getFilter().getParamId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("paramId");
			paramFilter.setValue(getFilter().getParamId());
			filtersList.add(paramFilter);
		}
		
		purposeParameterFilters = filtersList;
	}

	public PmoPurposeHasParameter getFilter() {
		if (filter == null)
			filter = new PmoPurposeHasParameter();
		return filter;
	}

	public void setFilter(PmoPurposeHasParameter filter) {
		this.filter = filter;
	}

	public List<Filter> getPurposeParameterFilters() {
		return purposeParameterFilters;
	}

	public void setPurposeParamterFilters(List<Filter> purposeParameterFilters) {
		this.purposeParameterFilters = purposeParameterFilters;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public PmoPurposeHasParameter getNewPurposeParameter() {
		return newPurposeParameter;
	}

	public void setNewPurposeParameter(PmoPurposeHasParameter newPurposeParameter) {
		this.newPurposeParameter = newPurposeParameter;
	}

	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
}
