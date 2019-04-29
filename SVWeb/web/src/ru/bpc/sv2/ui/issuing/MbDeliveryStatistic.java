package ru.bpc.sv2.ui.issuing;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.deliveries.DeliveryAmount;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.DeliveriesDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;

/**
 * Created by Viktorov on 01.03.2017.
 */

@ViewScoped
@ManagedBean(name = "MbDeliveryStatistic")
public class MbDeliveryStatistic extends AbstractBean {

    private ArrayList<DeliveryAmount> _statisticSource;

    private DeliveriesDao _deliveriesDao = new DeliveriesDao();

    private DeliveryAmount filter;
    private DeliveryAmount activeAmount;
    private SimpleSelection _itemSelection;
    private static String COMPONENT_ID = "statisticTable";
    private String tabName;
    private String parentSectionId;

    private static final Logger logger = Logger.getLogger("ISSUING");



    public DeliveryAmount loadDeliveryStatistic(String deliveryRefNum) {
        activeAmount = null;

        try {
            SelectionParams selectionParams = SelectionParams.build("deliveryRefNum", deliveryRefNum);
            selectionParams.setRowIndexEnd(-1);
            _statisticSource = (ArrayList<DeliveryAmount>) _deliveriesDao.getStatistics(userSessionId, selectionParams);
            if (!_statisticSource.isEmpty()) {
                activeAmount = (DeliveryAmount) _statisticSource.get(0);
            }
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addMessageError(e);
        }
        return activeAmount;
    }

    public DeliveryAmount getFilter() {
        if (filter == null) {
            filter = new DeliveryAmount();
        }
        return filter;
    }

    public void setFilter(DeliveryAmount filter) {
        this.filter = filter;
    }

    @Override
    public void clearFilter() {
        // TODO Auto-generated method stub

    }

    public ArrayList<DeliveryAmount> getStatisticSource(){
        return _statisticSource;
    }

    public SimpleSelection getItemSelection() {
        return _itemSelection;
    }

    public void setItemSelection(SimpleSelection selection) {
        _itemSelection = selection;
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
