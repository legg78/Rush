package ru.bpc.sv2.ui.campaigns;

import org.apache.log4j.Logger;
import ru.bpc.sv2.campaign.Campaign;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.FilterBuilder;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CampaignDao;
import ru.bpc.sv2.ui.products.MbObjectAttributes;
import ru.bpc.sv2.ui.utils.AbstractSearchBean;
import ru.bpc.sv2.ui.utils.AbstractSearchTabbedBean;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbCampaignsSearch")
public class MbCampaignsSearch extends AbstractSearchTabbedBean<Campaign, Campaign> {
    private static final Logger logger = Logger.getLogger("CPN");

    private static final String PRODUCT_TAB = "productsTab";
    private static final String SERVICE_TAB = "servicesTab";
    private static final String TERMS_TAB = "serviceTermsTab";

    private CampaignDao campaignDao = new CampaignDao();

    private List<SelectItem> campaignTypes;
    private List<SelectItem> institutions;

    @Override
    protected Campaign createFilter() {
        return new Campaign();
    }

    @Override
    protected Logger getLogger() {
        return logger;
    }

    @Override
    protected void initFilters(Campaign filter, List<Filter> filters) {
        filters.addAll(FilterBuilder.createFiltersDatesAsString(filter));
        filters.add(Filter.create(LANGUAGE, userLang));
    }

    @Override
    protected List<Campaign> getObjectList(Long userSessionId, SelectionParams params) {
        return campaignDao.getCampaigns(userSessionId, params);
    }

    @Override
    protected int getObjectCount(Long userSessionId, SelectionParams params) {
        return campaignDao.getCampaignsCount(userSessionId, params);
    }

    @Override
    protected Campaign addItem(Campaign item) throws UserException {
        checkDates(item);
        return campaignDao.addCampaign(userSessionId, item);
    }

    @Override
    protected Campaign editItem(Campaign item) throws UserException {
        checkDates(item);
        return campaignDao.modifyCampaign(userSessionId, item);
    }

    @Override
    protected void deleteItem(Campaign item) {
        campaignDao.removeCampaign(userSessionId, item);
    }

    @Override
    public void add() {
        super.add();
        setNewItem(new Campaign());
    }

    @Override
    protected void onLoadTab(String tabName) {
        if (PRODUCT_TAB.equals(tabName)) {
            MbCampaignProductsSearch bean = ManagedBeanWrapper.getManagedBean(MbCampaignProductsSearch.class);
            if (bean != null) {
                bean.clearState();
                bean.clearFilter();
                bean.setTabName(tabName);
                bean.getFilter().setCampaignId(getActiveItem().getId());
                bean.getFilter().setInstId(getActiveItem().getInstId());
                bean.getFilter().setLang(userLang);
                bean.search();
            }
        } else if (SERVICE_TAB.equals(tabName)) {
            MbCampaignServicesSearch bean = ManagedBeanWrapper.getManagedBean(MbCampaignServicesSearch.class);
            if (bean != null) {
                bean.clearState();
                bean.clearFilter();
                bean.setTabName(tabName);
                bean.getFilter().setCampaignId(getActiveItem().getId());
                bean.getFilter().setLang(userLang);
                bean.search();
            }
        } else if (TERMS_TAB.equals(tabName)) {
            MbCampaignAttributeSearch bean = ManagedBeanWrapper.getManagedBean(MbCampaignAttributeSearch.class);
            if (bean != null) {
                bean.clearState();
                bean.clearFilter();
                bean.setTabName(tabName);
                bean.getFilter().setCampaignId(getActiveItem().getId());
                bean.getFilter().setInstId(getActiveItem().getInstId());
                bean.getFilter().setLang(userLang);
                bean.search();
            }
        }
    }

    public List<SelectItem> getCampaignTypes() {
        if (campaignTypes == null) {
            campaignTypes = getDictUtils().getLov(LovConstants.CAMPAIGN_TYPES);
            if (campaignTypes == null) {
                campaignTypes = new ArrayList<SelectItem>();
            }
        }
        return campaignTypes;
    }

    public List<SelectItem> getInstitutions() {
        if (institutions == null) {
            institutions = getDictUtils().getLov(LovConstants.INSTITUTIONS);
            if (institutions == null) {
                institutions = new ArrayList<SelectItem>();
            }
        }
        return institutions;
    }

    public boolean isActive() {
        if (activeItem != null) {
            Date now = new Date();
            if (now.compareTo(activeItem.getStartDate()) >= 0) {
                if (now.compareTo(activeItem.getEndDate()) <= 0) {
                    return true;
                }
            }
        } else {
            return true;
        }
        return false;
    }

    private void checkDates(Campaign item) throws UserException {
        Date now = new Date();
        if (isNewMode() && now.compareTo(item.getStartDate()) >= 0) {
            throw new UserException("Start date should be later than current date");
        } else if (now.compareTo(item.getEndDate()) >= 0) {
            throw new UserException("End date should be later than current date");
        } else if (item.getStartDate().compareTo(item.getEndDate()) >= 0) {
            throw new UserException("End date should be later than start date");
        }
    }
}
