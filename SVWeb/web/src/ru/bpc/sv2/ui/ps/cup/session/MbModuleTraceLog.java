package ru.bpc.sv2.ui.ps.cup.session;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.svng.ModuleDao;
import ru.bpc.sv2.ps.ModuleSessionTrace;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataListModel;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@ViewScoped
@ManagedBean(name = "MbModuleTraceLog")
public class MbModuleTraceLog extends AbstractBean {
	private static Logger logger = Logger.getLogger("OPER_RPOCESSING");
	private ModuleDao moduleDao = new ModuleDao();
	private final DaoDataModel<ModuleSessionTrace> traceSource;
	private String module;
	private String sessionId;
	private Long fileId;
	private Integer traceLevel;
	private List<SelectItem> traceLevels;

	public MbModuleTraceLog() {
		traceSource = new DaoDataListModel<ModuleSessionTrace>(logger) {
			@Override
			protected List<ModuleSessionTrace> loadDaoListData(SelectionParams params) {
				if (searching) {
					try {
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters.size()]));
						return moduleDao.getSessionTrace(module, params);
					} catch (Exception e) {
						setDataSize(0);
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				}
				return new ArrayList<ModuleSessionTrace>();
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return moduleDao.getSessionTraceCount(module, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
	}

	public void setModule(String module) {
		this.module = module;
	}

	private void setFilters() {
		filters = new ArrayList<Filter>();
		if (sessionId != null) {
			filters.add(new Filter("session_id", sessionId));
		}
		if (traceLevel != null) {
			filters.add(new Filter("trace_level", traceLevel));
		}
		if (fileId != null) {
			filters.add(new Filter("file_id", fileId));
		}
	}

	public void search() {
		setSearching(true);
		traceSource.flushCache();
	}

	public List<SelectItem> getTraceLevels() {
		if (traceLevels == null) {
			traceLevels = getDictUtils().getLov(LovConstants.TRACE_LEVELS, null, Collections.singletonList(("code != 1")));
		}
		return traceLevels;
	}

	public Integer getTraceLevel() {
		return traceLevel;
	}

	public void setTraceLevel(Integer traceLevel) {
		this.traceLevel = traceLevel;
	}

	public Long getFileId() {
		return fileId;
	}

	public void setFileId(Long fileId) {
		this.fileId = fileId;
	}

	public void clearFilter() {
		setSearching(false);
	}

	public String getSessionId() {
		return sessionId;
	}

	public void setSessionId(String sessionId) {
		this.sessionId = sessionId;
	}

	public boolean getSearching() {
		return searching;
	}

	public DaoDataModel<ModuleSessionTrace> getTraceSource() {
		return traceSource;
	}

	public String getComponentId() {
		return "";
	}
}
