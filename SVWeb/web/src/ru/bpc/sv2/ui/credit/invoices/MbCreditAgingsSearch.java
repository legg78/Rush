package ru.bpc.sv2.ui.credit.invoices;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.credit.Aging;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CreditDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbCreditAgingsSearch")
public class MbCreditAgingsSearch extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("CREDIT");
	
	private CreditDao _creditDao = new CreditDao();
	
	private Aging filter;

    private final DaoDataModel<Aging> _agingSource;
	private final TableRowSelection<Aging> _itemSelection;
	private Aging _activeAging;
	
	private static String COMPONENT_ID = "mainTable";
	private String tabName;
	private String parentSectionId;

	public MbCreditAgingsSearch() {
		_agingSource = new DaoDataModel<Aging>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected Aging[] loadDaoData(SelectionParams params) {
				if (!searching || getFilter().getInvoiceId() == null)
					return new Aging[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _creditDao.getInvoiceAgings( userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Aging[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching || getFilter().getInvoiceId() == null)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _creditDao.getInvoiceAgingsCount( userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Aging>(null, _agingSource);
	}

	public DaoDataModel<Aging> getAgings() {
		return _agingSource;
	}

	public Aging getActiveAging() {
		return _activeAging;
	}

	public void setActiveAging(Aging activeAging) {
		_activeAging = activeAging;
	}

	public SimpleSelection getItemSelection() {
		if (_activeAging == null && _agingSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		else if (_activeAging != null && _agingSource.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeAging.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeAging = _itemSelection.getSingleSelection();			
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_agingSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeAging = (Aging) _agingSource.getRowData();
		selection.addKey(_activeAging.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeAging != null) {
			setInfo();
		}
	}
	
	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection( selection );
		_activeAging = _itemSelection.getSingleSelection();
		if (_activeAging != null) {
			setInfo();
		}
	}
	
	public void search() {
		setSearching(true);
		clearBean();
		clearBeansStates();
	}

	public void clearFilter() {
		filter = new Aging();
		clearBean();		
	}

	public void setInfo() {
		
	}
	
	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter = null;
		
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}
		if (filter.getInvoiceId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("invoiceId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInvoiceId().toString());
			filters.add(paramFilter);
		}
		
	}

	public Aging getFilter() {
		if (filter == null) {
			filter = new Aging();
		}
		return filter;
	}

	public void setFilter(Aging filter) {
		this.filter = filter;
	}

	public void clearBean() {
		// search using new criteria
		_agingSource.flushCache();
		// reset selection
		_itemSelection.clearSelection();
		_activeAging = null;		
	}

	public void clearBeansStates() {
		
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
