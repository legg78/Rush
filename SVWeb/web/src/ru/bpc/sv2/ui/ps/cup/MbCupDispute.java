package ru.bpc.sv2.ui.ps.cup;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CupDao;
import ru.bpc.sv2.ps.cup.CupAuth;
import ru.bpc.sv2.ps.cup.CupDispute;
import ru.bpc.sv2.ps.cup.CupDisputeFilter;
import ru.bpc.sv2.ps.cup.CupFinMessage;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbCupDispute")
public class MbCupDispute extends AbstractBean {
	private static final long serialVersionUID = 9180917082872879256L;
	private static Logger logger = Logger.getLogger("OPER_RPOCESSING");

	private CupDao cupDao = new CupDao();

	private CupDisputeFilter filter;
	private final DaoDataModel<CupDispute> messageSource;

	private CupDispute activeItem;
	private CupAuth selAuth;
	private CupFinMessage selOp;
	private final TableRowSelection<CupDispute> itemSelection;
	private Map<String, Object> paramMap;

	public MbCupDispute() {
		pageLink = "cup|disputes";
		messageSource = new DaoDataModel<CupDispute>() {
			private static final long serialVersionUID = 6886825197574225937L;

			@Override
			protected CupDispute[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new CupDispute[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return cupDao.getDisputes(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new CupDispute[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return (int) cupDao.getDisputesCount(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		itemSelection = new TableRowSelection<CupDispute>(null, messageSource);
	}

	@PostConstruct
	public void init() {
		setDefaultValues();
	}

	private void setFilters() {
		CupDisputeFilter disputeFilter = getFilter();
		filters = new ArrayList<Filter>();
		if (disputeFilter.getPan() != null && disputeFilter.getPan().trim().length() > 0) {
			filters.add(new Filter("pan", disputeFilter.getPan()));
		}
		if (disputeFilter.getSessionId() != null) {
			filters.add(new Filter("sessionId", disputeFilter.getSessionId()));
		}
		if (disputeFilter.getTransAmount() != null) {
			filters.add(new Filter("transAmountFrom", disputeFilter.getTransAmount() * 100));
		}
		if (disputeFilter.getTransAmountTo() != null) {
			filters.add(new Filter("transAmountTo", disputeFilter.getTransAmountTo() * 100));
		}
		if (disputeFilter.getTransmissionDate() != null) {
			filters.add(new Filter("transmissionDate", disputeFilter.getTransmissionDate()));
		}
		if (disputeFilter.getTransmissionDateTo() != null) {
			filters.add(new Filter("transmissionDateTo", disputeFilter.getTransmissionDateTo()));
		}
		if (disputeFilter.getRrn() != null && !disputeFilter.getRrn().isEmpty()) {
			filters.add(new Filter("rrn", disputeFilter.getRrn()));
		}
	}

	public SimpleSelection getItemSelection() {
		if (activeItem != null && messageSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(activeItem.getModelId());
			itemSelection.setWrappedSelection(selection);
		}
		return itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		itemSelection.setWrappedSelection(selection);
		activeItem = itemSelection.getSingleSelection();
		if (activeItem != null) {
			selOp = cupDao.getClearingOperation(userSessionId, activeItem.getRrn());
			selAuth = cupDao.getAuth(userSessionId, activeItem.getRrn());
		}
	}

	public CupAuth getSelAuth() {
		return selAuth;
	}

	public CupFinMessage getSelOp() {
		return selOp;
	}

	public void search() {
		setSearching(true);
		clearBean();
		paramMap = new HashMap<String, Object>();
	}

	private void clearBean() {
		messageSource.flushCache();
		itemSelection.clearSelection();
		activeItem = null;
	}

	public void clearFilter() {
		filter = null;
		setSearching(false);
		clearBean();
		setDefaultValues();
	}

	public String getSectionId() {
		return SectionIdConstants.ISSUING_CREDIT_DEBT;
	}

	public boolean getSearching() {
		return searching;
	}

	public void setFilter(CupDisputeFilter filter) {
		this.filter = filter;
	}

	public CupDisputeFilter getFilter() {
		if (filter == null) {
			filter = new CupDisputeFilter();
		}
		return filter;
	}

	public DaoDataModel<CupDispute> getItems() {
		return messageSource;
	}

	public CupDispute getActiveItem() {
		return activeItem;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

	public int getRowsNum() {
		return rowsNum;
	}

	public String getComponentId() {
		return "2336:cup_dispute";
	}

	public Logger getLogger() {
		return logger;
	}

	private void setDefaultValues() {
		filter = new CupDisputeFilter();
	}

	public Map<String, Object> getParamMap() {
		if (paramMap == null) {
			paramMap = new HashMap<String, Object>();
		}
		return paramMap;
	}

	public void setParamMap(Map<String, Object> paramMap) {
		this.paramMap = paramMap;
	}
}
