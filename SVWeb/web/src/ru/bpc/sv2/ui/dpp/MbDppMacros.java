package ru.bpc.sv2.ui.dpp;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.dpp.DppMacros;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.FilterBuilder;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.DppDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbDppMacros")
public class MbDppMacros extends AbstractBean {
	private static final Logger logger = Logger.getLogger("DPP");

	private DppDao dppDao = new DppDao();

	private final DaoDataModel<DppMacros> dataModel;
	private final TableRowSelection<DppMacros> tableRowSelection;
	private DppMacros filter;
	private DppMacros activeItem;

	public MbDppMacros() {
		dataModel = new DaoDataModel<DppMacros>() {

			@Override
			protected DppMacros[] loadDaoData(SelectionParams params) {
				if (searching) {
					try {
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters.size()]));
						List<DppMacros> data = dppDao.getDppMacroses(userSessionId, params);
						return data.toArray(new DppMacros[data.size()]);
					} catch (Exception e) {
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				}
				return new DppMacros[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try {
						return dppDao.getDppMacrosesCount(userSessionId, params);
					} catch (Exception e) {
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				}
				return 0;
			}

		};
		tableRowSelection = new TableRowSelection<DppMacros>(null, getDataModel());
		filter = new DppMacros();
	}

	private void setFilters() {
		filters = new ArrayList<Filter>();
		filters.addAll(FilterBuilder.createFiltersDatesAsString(getFilter()));
		filters.add(Filter.create("lang", userLang));
	}

	private void reset() {
		getDataModel().flushCache();
	}

	public void search() {
		searching = true;
		reset();
	}

	public void clear() {
		reset();
		searching = false;
		activeItem = null;
		filter = new DppMacros();
		tableRowSelection.clearSelection();
	}

	public void setItemSelection(SimpleSelection itemSelection) {
		tableRowSelection.setWrappedSelection(itemSelection);
		setActiveItem(tableRowSelection.getSingleSelection());
	}

	public SimpleSelection getItemSelection() {
		return tableRowSelection.getWrappedSelection();
	}

	public DaoDataModel<DppMacros> getDataModel() {
		return dataModel;
	}

	public DppMacros getFilter() {
		return filter;
	}

	public void setFilter(DppMacros filter) {
		this.filter = filter;
	}

	public DppMacros getActiveItem() {
		return activeItem;
	}

	public void setActiveItem(DppMacros activeItem) {
		this.activeItem = activeItem;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}
}
