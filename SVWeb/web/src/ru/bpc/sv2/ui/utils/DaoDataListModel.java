package ru.bpc.sv2.ui.utils;

import org.apache.log4j.Logger;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.ui.utils.model.IPageable;

import java.util.ArrayList;
import java.util.List;

public abstract class DaoDataListModel<T extends ModelIdentifiable> extends DaoDataModel<T> implements IPageable {
	private Logger logger;

	@SuppressWarnings("FieldCanBeLocal")
	private int rowsPerPage = 20;
	private int pageNo = 1;

	public DaoDataListModel(Logger logger) {
	    super(false);
		this.logger = logger;
	}

    public DaoDataListModel(Logger logger, boolean clearSortable) {
        super(clearSortable);
        this.logger = logger;
    }

	protected abstract List<T> loadDaoListData(SelectionParams params);

	@Override
	public List<T> loadData(SelectionParams params) {
		try {
			if (getRowCount() > 0) {
				return new ArrayList<T>(loadDaoListData(params));
			}
		} catch (Exception e) {
			setDataSize(0);
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
		return new ArrayList<T>();
	}

	@Override
	public int getRowCount() {
		try {
			return super.getRowCount();
		} catch (Exception e) {
			setDataSize(0);
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
		return 0;
	}

	@Override
	@Deprecated
	protected final T[] loadDaoData(SelectionParams params) {
		throw new UnsupportedOperationException("Loading data as array is unsupported for DaoDataListModel");
	}

	@Override
	public int getRowsPerPage() {
		return rowsPerPage;
	}

	@Override
	public void setRowsPerPage(int rowsPerPage) {
		this.rowsPerPage = rowsPerPage;
	}

	@Override
	public int getPageNo() {
		return pageNo;
	}

	@Override
	public void setPageNo(int pageNo) {
		this.pageNo = pageNo;
	}
}
