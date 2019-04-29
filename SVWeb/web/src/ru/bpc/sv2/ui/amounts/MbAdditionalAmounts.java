package ru.bpc.sv2.ui.amounts;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.aup.Amount;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AuthProcessingDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;

@ViewScoped
@ManagedBean(name = "MbAdditionalAmounts")
public class MbAdditionalAmounts extends AbstractBean {
	
	private ArrayList<Amount> _amountSource;
	
	private AuthProcessingDao _aupDao = new AuthProcessingDao();
	
	private Amount filter;
	private Amount activeAmount;
	private SimpleSelection _itemSelection;
	private static String COMPONENT_ID = "amountsTable";
	private String tabName;
	private String parentSectionId;
	
	private static final Logger logger = Logger.getLogger("AUTH_PROCESSING");
	
	
		
	public Amount loadAmounts(Long operId) {
		activeAmount = null;
		
/*
#auth_id#
#amounts_cur
 */

		try {
			List<Filter> filters = new ArrayList<Filter>();
			filters.add(new Filter("operId", operId));
			filters.add(new Filter("lang", userLang));
			SelectionParams selectionParams = new SelectionParams();
			selectionParams.setFilters(filters);
			selectionParams.setRowIndexEnd(-1);
			_amountSource = (ArrayList<Amount>) _aupDao.getAmounts(userSessionId, selectionParams);
			if (!_amountSource.isEmpty()) {
				activeAmount = (Amount) _amountSource.get(0);
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return activeAmount;
	}
		
	public Amount getFilter() {
		if (filter == null) {
			filter = new Amount();
		}
		return filter;
	}

	public void setFilter(Amount filter) {
		this.filter = filter;
	}
	
	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}
	
	public ArrayList<Amount> getAmountSource(){
		return _amountSource;
	}

	public SimpleSelection getItemSelection() {
		return _itemSelection;
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection = selection;
//		activeAmount = _itemSelection.getKeys();
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
