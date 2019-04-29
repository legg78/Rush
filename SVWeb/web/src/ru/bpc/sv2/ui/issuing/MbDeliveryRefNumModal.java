package ru.bpc.sv2.ui.issuing;

/**
 * Created by Viktorov on 20.02.2017.
 */

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.deliveries.Delivery;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.DeliveriesDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import ru.bpc.sv2.ui.utils.model.LoadableDetachableModel;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


@ViewScoped
@ManagedBean(name = "MbDeliveryRefNumModal")
public class MbDeliveryRefNumModal extends AbstractBean {
    private static final long serialVersionUID = 1L;

    private static final Logger logger = Logger.getLogger("ISSUING");

    private DeliveriesDao _deliveriesDao = new DeliveriesDao();

    private Delivery filter;

    private final DaoDataModel<Delivery> _deliveriesSource;
    private final TableRowSelection<Delivery> _itemSelection;
    private Delivery _activeDelivery;

    private ArrayList<SelectItem> institutions;
    private LoadableDetachableModel<List<SelectItem>> agentsModel;
    private List<SelectItem> cardTypes;

    private String beanName;
    private String methodName;
    private String rerenderList;
    private String modalPanel = "deliverySearchModalPanel";

    public MbDeliveryRefNumModal() {
        rowsNum = Integer.MAX_VALUE;

        _deliveriesSource = new DaoDataModel<Delivery>() {
            private static final long serialVersionUID = 1L;

            @Override
            protected Delivery[] loadDaoData(SelectionParams params) {
                if (!searching) {
                    return new Delivery[0];
                }
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return _deliveriesDao.getDeliveries(userSessionId, params);
                } catch (Exception e) {
                    setDataSize(0);
                    logger.error("", e);
                    FacesUtils.addMessageError(e);
                }
                return new Delivery[0];
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (!searching) {
                    return 0;
                }
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return _deliveriesDao.getDeliveriesCount(userSessionId, params);
                } catch (Exception e) {
                    logger.error("", e);
                    FacesUtils.addMessageError(e);
                    return 0;
                }
            }
        };

        _itemSelection = new TableRowSelection<Delivery>(null, _deliveriesSource);
        getInstitutions();
        if (userInstId == ApplicationConstants.DEFAULT_INSTITUTION && !institutions.isEmpty()) {
            getFilter().setInstId(Integer.valueOf((String) getInstitutions().get(0).getValue()));
        } else {
            getFilter().setInstId(userInstId);
        }
        agentsModel = new LoadableDetachableModel<List<SelectItem>>() {
            @Override
            protected List<SelectItem> load() {
                Map<String, Object> paramMap = new HashMap<String, Object>();
                paramMap.put("INSTITUTION_ID", getFilter().getInstId());
                return getDictUtils().getLov(LovConstants.AGENTS, paramMap);
            }
        };
    }

    public DaoDataModel<Delivery> getDeliveries() {
        return _deliveriesSource;
    }

    public Delivery getActiveDelivery() {
        return _activeDelivery;
    }

    public void setActiveDelivery(Delivery activeDelivery) {
        _activeDelivery = activeDelivery;
    }

    public SimpleSelection getItemSelection() {
        try {
            if (_activeDelivery == null && _deliveriesSource.getRowCount() > 0) {
                setFirstRowActive();
            } else if (_activeDelivery != null && _deliveriesSource.getRowCount() > 0) {
                SimpleSelection selection = new SimpleSelection();
                selection.addKey(_activeDelivery.getModelId());
                _itemSelection.setWrappedSelection(selection);
                _activeDelivery = _itemSelection.getSingleSelection();
            }
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addMessageError(e);
        }
        return _itemSelection.getWrappedSelection();
    }

    public void setItemSelection(SimpleSelection selection) {
        _itemSelection.setWrappedSelection(selection);
        _activeDelivery = _itemSelection.getSingleSelection();
    }

    public void setFirstRowActive() {
        _deliveriesSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        _activeDelivery = (Delivery) _deliveriesSource.getRowData();
        selection.addKey(_activeDelivery.getModelId());
        _itemSelection.setWrappedSelection(selection);

    }

    public void setFilters() {
        filters = new ArrayList<Filter>();

        Filter paramFilter;

        if (getFilter().getInstId() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("instId");
            paramFilter.setOp(Filter.Operator.eq);
            paramFilter.setValue(getFilter().getInstId());
            filters.add(paramFilter);
        }
        if (getFilter().getAgentId() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("agentId");
            paramFilter.setOp(Filter.Operator.eq);
            paramFilter.setValue(getFilter().getAgentId());
            filters.add(paramFilter);
        }
        if (getFilter().getCardTypeId() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("cardTypeId");
            paramFilter.setOp(Filter.Operator.eq);
            paramFilter.setValue(getFilter().getCardTypeId());
            filters.add(paramFilter);
        }
    }
    public Delivery getFilter() {
        if (filter == null) {
            filter = new Delivery();
        }
        return filter;
    }
    public void setFilter(Delivery filter) {
        this.filter = filter;
    }

    public void clearFilter() {
        filter = null;
        clearBean();
        searching = false;
    }

    public void search() {
        curMode = VIEW_MODE;
        clearBean();
        searching = true;
    }

    public void clearBean() {
        curLang = userLang;
        _deliveriesSource.flushCache();
        _itemSelection.clearSelection();
        _activeDelivery = null;
    }

    public void setRowsNum(int rowsNum) {
        this.rowsNum = rowsNum;
    }

    public void setPageNumber(int pageNumber) {
        this.pageNumber = pageNumber;
    }

    public String getBeanName() {
        return beanName;
    }
    public void setBeanName(String beanName) {
        this.beanName = beanName;
    }

    public String getRerenderList() {
        return rerenderList;
    }
    public void setRerenderList(String rerenderList) {
        this.rerenderList = rerenderList;
    }

    public String getMethodName() {
        if (methodName == null || "".equals(methodName)) {
            return "selectDelivery";
        }
        return methodName;
    }
    public void setMethodName(String methodName) {
        this.methodName = methodName;
    }

    public String getModalPanel() {
        return modalPanel;
    }

    public ArrayList<SelectItem> getInstitutions() {
        if (institutions == null) {
            institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
        }
        if (institutions == null)
            institutions = new ArrayList<SelectItem>();
        return institutions;
    }

    public List<SelectItem> getAgents() {
        return agentsModel.getObject();
    }

    public List<SelectItem> getCardTypes() {
        if (cardTypes == null) {
            cardTypes = getDictUtils().getLov(LovConstants.CARD_TYPES);
        }
        return cardTypes;
    }

    public boolean getSelected() {
        return _activeDelivery != null ? true : false;
    }



}

