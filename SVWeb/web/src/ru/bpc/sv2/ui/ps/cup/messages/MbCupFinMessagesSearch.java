package ru.bpc.sv2.ui.ps.cup.messages;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CupDao;
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
@ManagedBean(name = "MbCupFinMessagesSearch")
public class MbCupFinMessagesSearch extends AbstractBean {
	private static final long serialVersionUID = 9180917082872879256L;
	private static final Logger logger = Logger.getLogger("OPER_RPOCESSING");

	private CupDao cupDao = new CupDao();

	private CupFinMessage filter;
	private final DaoDataModel<CupFinMessage> messageSource;

	private CupFinMessage activeItem;
	private final TableRowSelection<CupFinMessage> itemSelection;
	private Map<String, Object> paramMap;

	public MbCupFinMessagesSearch() {
		pageLink = "cup|financial_messages";
		messageSource = new DaoDataModel<CupFinMessage>() {
			private static final long serialVersionUID = 6886825197574225937L;

			@Override
			protected CupFinMessage[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new CupFinMessage[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return cupDao.getFinMessages(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new CupFinMessage[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return cupDao.getFinMessagesCount(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		itemSelection = new TableRowSelection<CupFinMessage>(null, messageSource);
	}

	@PostConstruct
	public void init() {
		setDefaultValues();
	}

	private void setFilters() {
		CupFinMessage messageFilter = getFilter();
		filters = new ArrayList<Filter>();
		
		filters.add(new Filter("lang", userLang));

		if (messageFilter.getOperId() != null) {
			filters.add(new Filter("operId", messageFilter.getOperId()));
		}
		if (messageFilter.getPan() != null && messageFilter.getPan().trim().length() > 0) {
			filters.add(new Filter("pan", messageFilter.getPan()));
		}
		if (messageFilter.getSessionId() != null) {
			filters.add(new Filter("sessionId", messageFilter.getSessionId()));
		}
		if (messageFilter.getTransAmount() != null) {
			filters.add(new Filter("transAmountFrom", messageFilter.getTransAmount()));
		}
		if (messageFilter.getTransAmountTo() != null) {
			filters.add(new Filter("transAmountTo", messageFilter.getTransAmountTo()));
		}
		if (messageFilter.getTransDate() != null) {
			filters.add(new Filter("transDateFrom", messageFilter.getTransDate()));
		}
		if (messageFilter.getTransDateTo() != null) {
			filters.add(new Filter("transDateTo", messageFilter.getTransDateTo()));
		}
		if (messageFilter.getRefNum() != null && !messageFilter.getRefNum().isEmpty()) {
			filters.add(new Filter("refNum", messageFilter.getRefNum()));
		}
	}

	public SimpleSelection getItemSelection() {
		if (activeItem != null && messageSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(activeItem.getModelId());
			itemSelection.setWrappedSelection(selection);
			activeItem = itemSelection.getSingleSelection();
		}
		return itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		itemSelection.setWrappedSelection(selection);
		activeItem = itemSelection.getSingleSelection();
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

	public void setFilter(CupFinMessage filter) {
		this.filter = filter;
	}

	public CupFinMessage getFilter() {
		if (filter == null) {
			filter = new CupFinMessage();
		}
		return filter;
	}

	public DaoDataModel<CupFinMessage> getItems() {
		return messageSource;
	}

	public CupFinMessage getActiveItem() {
		return activeItem;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

	public int getRowsNum() {
		return rowsNum;
	}

	public String getComponentId() {
		return "2336:cup_fin_messages";
	}

	public Logger getLogger() {
		return logger;
	}

	private void setDefaultValues() {
		filter = new CupFinMessage();
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
