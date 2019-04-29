package ru.bpc.sv2.ui.utils;

import org.apache.log4j.Logger;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.invocation.SelectionParams;

import java.util.ArrayList;
import java.util.List;

/**
 * Class for load all data (without checking size and pagination)
 */
public abstract class DaoDataListAllModel<T extends ModelIdentifiable> extends DaoDataModel<T> {
    private Logger logger;

    transient protected List<T> listData = null;

    protected abstract List<T> loadDaoListData(SelectionParams params);

    public DaoDataListAllModel(Logger logger) {
        this.logger = logger;
    }

    protected void loadListData(SelectionParams params, boolean force) {
        try {
            if (listData == null || force) {
                listData = loadDaoListData(params);
            }
        } catch (Exception e) {
            listData = new ArrayList<T>();
            logger.error(e.getMessage(), e);
            FacesUtils.addMessageError(e);
        } finally {
            if (listData == null) listData = new ArrayList<T>();
        }
    }

    @Override
    protected int loadDaoDataSize(SelectionParams params) {
        loadListData(params, false);
        return listData == null ? 0 : listData.size();
    }

    @Override
    public List<T> loadData(SelectionParams params) {
        loadListData(params, false);
        return listData;
    }

    @Override
    public void flushCache() {
        super.flushCache();
        listData = null;
    }


    @Override
    @Deprecated
    protected final T[] loadDaoData(SelectionParams params) {
        throw new UnsupportedOperationException("Loading data as array is unsupported for DaoDataListAllModel");
    }
}
