package ru.bpc.sv2.ui.pmo;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.openfaces.util.Faces;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.PaymentOrdersDao;
import ru.bpc.sv2.pmo.PmoTemplateParameter;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbPmoTemplateParameters")
public class MbPmoTemplateParameters extends AbstractBean {
	private static final Logger logger = Logger.getLogger("COMMON");
	
	
	private PmoTemplateParameter filter;
	private final DaoDataModel<PmoTemplateParameter> _templateParameterSource;
	private final TableRowSelection<PmoTemplateParameter> _itemSelection;
	private PmoTemplateParameter _activeTemplateParameter;
	private PaymentOrdersDao _paymentOrderDao = new PaymentOrdersDao();
	
	public MbPmoTemplateParameters() {
				
		
		_templateParameterSource = new DaoDataModel<PmoTemplateParameter>() {
			@Override
			protected PmoTemplateParameter[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new PmoTemplateParameter[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					PmoTemplateParameter[] listParam = _paymentOrderDao.getTemplateParameters(userSessionId, params);
					for(PmoTemplateParameter param : listParam) {
						//set old param value
						param.setOldParamValue(param.getParamValue());
					}
					return listParam;
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					setDataSize(0);
					logger.error("", e);
				}
				return new PmoTemplateParameter[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _paymentOrderDao.getTemplateParametersCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<PmoTemplateParameter>(null, _templateParameterSource);
	}
	
	public void saveTemplateParameter() {
		try {
			List<PmoTemplateParameter> templateParameters = getTemplateParameters().getActivePage();

			// check all mandatory parameters are filled.
			for (PmoTemplateParameter templateParameter : templateParameters) {
				if (templateParameter.getFixed()) {
					if (templateParameter.getParamValue() == null || templateParameter.getParamValue().length() == 0) {
						 FacesUtils.addMessageError(new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
					     	"not_all_mandatory_parameters_are_filled")));
						 return;
					}
				}
			}
			
			for (PmoTemplateParameter templateParameter : templateParameters) {
				if (templateParameter.getId() != null) {
					if (templateParameter.getParamValue() != null && templateParameter.getParamValue().length() != 0) { 
						if (!templateParameter.getParamValue().equals(templateParameter.getOldParamValue())) {
							_paymentOrderDao.editTemplateParameter(userSessionId, templateParameter);
						}
					} else {
						_paymentOrderDao.removeTemplateParameter(userSessionId, templateParameter);
					}
				} else {
					if (templateParameter.getParamValue() != null && templateParameter.getParamValue().trim().length() != 0)
					_paymentOrderDao.addTemplateParameter(userSessionId, templateParameter);
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public SimpleSelection getItemSelection() {
		if (_activeTemplateParameter == null && _templateParameterSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeTemplateParameter != null && _templateParameterSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeTemplateParameter.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeTemplateParameter = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_templateParameterSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeTemplateParameter = (PmoTemplateParameter) _templateParameterSource.getRowData();
		selection.addKey(_activeTemplateParameter.getModelId());
		_itemSelection.setWrappedSelection(selection);
//		if (_activeTranslation != null) {
//			setInfo();
//		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeTemplateParameter = _itemSelection.getSingleSelection();
//		if (_activeCard != null) {
//			setInfo();
//		}
	}
	
	public void clearState() {
		_itemSelection.clearSelection();
		_activeTemplateParameter = null;
		_templateParameterSource.flushCache();
		curLang = userLang;
//		loadedTabs.clear();

//		clearBeansStates();
	}
	
	public PmoTemplateParameter getFilter() {
		if (filter == null) {
			filter = new PmoTemplateParameter();
//			filter.setInstId(userInstId);
		}
		return filter;
	}
	
	public void setFilter(PmoTemplateParameter filter) {
		this.filter = filter;
	}
	
	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filter.getTemplateId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("templateId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getTemplateId());
			filters.add(paramFilter);
		}
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		
		filters.add(new Filter("isEditable", 1));

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);
	}
	
	public void search() {
		clearState();
//		clearBeansStates();
		searching = true;
	}
	
	public void cancel() {
		
	}
	
	public DaoDataModel<PmoTemplateParameter> getTemplateParameters() {
		return _templateParameterSource;
	}
	
	public PmoTemplateParameter getActiveTemplateParameter() {
		return _activeTemplateParameter;
	}

	public void setActiveTemplateParameter(PmoTemplateParameter activeTemplateParameter) {
		_activeTemplateParameter = activeTemplateParameter;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}

	public List<SelectItem> getActiveParameterListValues() {
		List<SelectItem> list = null;
		try {
			PmoTemplateParameter param = (PmoTemplateParameter) Faces.var("item");
			if (param != null && param.getLovId() != null) {
				list = getDictUtils().getLov(param.getLovId());
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		if (list == null) {
			list = new ArrayList<SelectItem>(0);
		}
		return list;
	}
}
