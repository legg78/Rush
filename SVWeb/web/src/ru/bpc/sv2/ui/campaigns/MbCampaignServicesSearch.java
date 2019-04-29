package ru.bpc.sv2.ui.campaigns;

import org.apache.log4j.Logger;
import ru.bpc.sv2.campaign.CampaignProduct;
import ru.bpc.sv2.campaign.CampaignService;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.FilterBuilder;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CampaignDao;
import ru.bpc.sv2.ui.utils.AbstractSearchBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbCampaignServicesSearch")
public class MbCampaignServicesSearch extends AbstractSearchBean<CampaignService, CampaignService> {
    private static final Logger logger = Logger.getLogger("CPN");

    private CampaignDao campaignDao = new CampaignDao();

    @Override
    protected CampaignService createFilter() {
        return new CampaignService();
    }

    @Override
    protected Logger getLogger() {
        return logger;
    }

    @Override
    public void add() {
        super.add();
        MbCampaignServicesModalSearch bean = ManagedBeanWrapper.getManagedBean(MbCampaignServicesModalSearch.class);
        if (bean != null) {
            bean.getFilter().setCampaignId(getFilter().getCampaignId());
            bean.getFilter().setLang(userLang);
            bean.initCampaignProducts();
        }
    }

    @Override
    public void save() {
        MbCampaignServicesModalSearch bean = ManagedBeanWrapper.getManagedBean(MbCampaignServicesModalSearch.class);
        if (bean != null) {
            if (bean.getActiveItems() != null) {
                for (CampaignService selection : bean.getActiveItems()) {
                    saveSelection(selection);
                }
            } else {
                saveSelection(bean.getActiveItem());
            }
        }
    }

    @Override
    protected CampaignService addItem(CampaignService item) {
        return campaignDao.addService(userSessionId, item);
    }

    @Override
    protected CampaignService editItem(CampaignService item) {
        return item;
    }

    @Override
    protected void deleteItem(CampaignService item) {
        campaignDao.removeService(userSessionId, item);
    }

    @Override
    protected void initFilters(CampaignService filter, List<Filter> filters) {
        filters.addAll(FilterBuilder.createFiltersDatesAsString(filter));
        filters.add(Filter.create(LANGUAGE, userLang));
    }

    @Override
    protected List<CampaignService> getObjectList(Long userSessionId, SelectionParams params) {
        return campaignDao.getServices(userSessionId, params);
    }

    @Override
    protected int getObjectCount(Long userSessionId, SelectionParams params) {
        return campaignDao.getServicesCount(userSessionId, params);
    }

    public boolean isActive() {
        if (activeItem != null) {
            MbCampaignsSearch bean = ManagedBeanWrapper.getManagedBean(MbCampaignsSearch.class);
            if (bean != null) {
                return !bean.isActive();
            }
        }
        return false;
    }

    private void saveSelection(CampaignService selection) {
        if (selection != null) {
            selection.setCampaignId(getFilter().getCampaignId());
            setNewItem(selection);
            super.save();
        } else {
            FacesUtils.addMessageError("No one service selected");
        }
    }
}
