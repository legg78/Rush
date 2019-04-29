package ru.bpc.sv2.ui.ps.cup.session;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.svng.ModuleDao;
import ru.bpc.sv2.ps.ModuleSession;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbModuleProcessLog")
public class MbModuleProcessLog extends AbstractBean {
	private static final long serialVersionUID = 9180917082872879256L;
	private static final Logger logger = Logger.getLogger("OPER_RPOCESSING");

	private ModuleDao moduleDao = new ModuleDao();

	private ModuleSession filter;
	private final DaoDataModel<ModuleSession> messageSource;

	private ModuleSession activeItem;
	private final TableRowSelection<ModuleSession> itemSelection;
	private Map<String, Object> paramMap;
	private String module;

	public MbModuleProcessLog() {
		messageSource = new DaoDataListModel<ModuleSession>(logger) {
			@Override
			protected List<ModuleSession> loadDaoListData(SelectionParams params) {
				if (!searching) {
					return new ArrayList<ModuleSession>();
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return moduleDao.getSessions(module, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ArrayList<ModuleSession>();
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return moduleDao.getSessionsCount(module, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		itemSelection = new TableRowSelection<ModuleSession>(null, messageSource);
	}

	@PostConstruct
	public void init() {
		setDefaultValues();
	}

	private void setFilters() {
		ModuleSession messageFilter = getFilter();
		filters = new ArrayList<Filter>();

		if (messageFilter.getSessionId() != null) {
			filters.add(new Filter("sessionId", messageFilter.getSessionId()));
		}
		if (messageFilter.getFileName() != null && messageFilter.getFileName().trim().length() > 0) {
			filters.add(new Filter("fileName", messageFilter.getFileName()));
		}
		if (messageFilter.getResult() != null) {
			filters.add(new Filter("result", messageFilter.getResult()));
		}
		if (messageFilter.getCreated() != null) {
			filters.add(new Filter("createdFrom", messageFilter.getCreated()));
		}
		if (messageFilter.getCreatedTo() != null) {
			filters.add(new Filter("createdTo", messageFilter.getCreatedTo()));
		}
		if (messageFilter.getProcess() != null && messageFilter.getProcess().trim().length() > 0) {
			filters.add(new Filter("process", messageFilter.getProcess()));
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
		if (activeItem != null) {
			MbModuleTraceLog traceLog = ((MbModuleTraceLog) ManagedBeanWrapper.getManagedBean("MbModuleTraceLog"));
			traceLog.setSessionId(activeItem.getSessionId().toString());
			traceLog.setFileId(activeItem.getId());
			traceLog.search();
		}
	}

	public String getModule() {
		return module;
	}

	public void setModule(String module) {
		this.module = module;
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

	public void setFilter(ModuleSession filter) {
		this.filter = filter;
	}

	public ModuleSession getFilter() {
		if (filter == null) {
			filter = new ModuleSession();
		}
		return filter;
	}

	public DaoDataModel<ModuleSession> getItems() {
		return messageSource;
	}

	public ModuleSession getActiveItem() {
		return activeItem;
	}

	public String getComponentId() {
		return "";
	}

	public Logger getLogger() {
		return logger;
	}

	private void setDefaultValues() {
		filter = new ModuleSession();
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
