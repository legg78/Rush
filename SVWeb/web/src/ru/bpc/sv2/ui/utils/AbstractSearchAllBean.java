package ru.bpc.sv2.ui.utils;

import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.invocation.SelectionParams;

import javax.annotation.PostConstruct;
import java.util.ArrayList;
import java.util.List;

/**
 * Abstract mbean for pages with search form
 *
 * @param <F> Search filter type
 * @param <R> Table row type
 */
public abstract class AbstractSearchAllBean<F, R extends ModelIdentifiable> extends AbstractSearchBean<F, R> {
    @Override
	@PostConstruct
	public void init() {
		searching = false;
		filter = createFilter();
		dataModel = new DaoDataListAllModel<R>(getLogger()) {
			private static final long serialVersionUID = 1L;
			@Override
			protected List<R> loadDaoListData(SelectionParams params) {
			    if (!isSearching()) return null;
				filters = new ArrayList<Filter>();
				initFilters(getFilter(), filters);
				params.setFilters(filters);
				params.setRowIndexEnd(-1);
				return getObjectList(userSessionId, params);
			}
		};
		tableRowSelection = new TableRowSelection<R>(null, dataModel);
	}

    @Override
    protected int getObjectCount(Long userSessionId, SelectionParams params) {
        throw new UnsupportedOperationException("Getting size is not necessary for All data search");
    }
}
