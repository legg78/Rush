package ru.bpc.sv2.ui.campaigns;

import org.apache.log4j.Logger;
import ru.bpc.sv2.campaign.CampaignProduct;
import ru.bpc.sv2.campaign.CampaignService;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.FilterBuilder;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CampaignDao;
import ru.bpc.sv2.products.ProductConstants;
import ru.bpc.sv2.ui.utils.AbstractSearchBean;
import ru.bpc.sv2.ui.utils.FacesUtils;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbCampaignServicesModalSearch")
public class MbCampaignServicesModalSearch extends AbstractSearchBean<CampaignService, CampaignService> {
    private static final Logger logger = Logger.getLogger("CPN");

    private CampaignDao campaignDao = new CampaignDao();

    private List<CampaignProduct> products;

    @Override
    protected CampaignService createFilter() {
        return new CampaignService();
    }

    @Override
    protected Logger getLogger() {
        return logger;
    }

    @Override
    protected CampaignService addItem(CampaignService item) {
        return item;
    }

    @Override
    protected CampaignService editItem(CampaignService item) {
        return item;
    }

    @Override
    protected void deleteItem(CampaignService item) {}

    @Override
    protected void initFilters(CampaignService filter, List<Filter> filters) {
        filters.add(Filter.create(LANGUAGE, userLang));
        if (filter.getProductId() != null) {
            filters.add(Filter.create("productId", filter.getProductId()));
        } else if (filter.getCampaignId() != null) {
            filters.add(Filter.create("campaignId", filter.getCampaignId()));
        }
    }

    @Override
    protected List<CampaignService> getObjectList(Long userSessionId, SelectionParams params) {
        return campaignDao.getServiceList(userSessionId, params);
    }

    @Override
    protected int getObjectCount(Long userSessionId, SelectionParams params) {
        return campaignDao.getServiceListCount(userSessionId, params);
    }

    public List<SelectItem> getProducts() {
        List<SelectItem> list = new ArrayList<SelectItem>();
        if (products != null) {
            for (CampaignProduct product : products) {
                list.add(new SelectItem(product.getProductId(), product.getProductId() + " - " + product.getProductLabel()));
            }
        }
        return list;
    }

    public void initCampaignProducts() {
        try {
            List<Filter> productFilters = new ArrayList<Filter>();
            if (getFilter().getCampaignId() != null) {
                productFilters.add(Filter.create("campaignId", getFilter().getCampaignId()));
            }
            productFilters.add(Filter.create("lang", userLang));

            SelectionParams params = new SelectionParams(productFilters);
            params.setRowIndexStart(0);
            params.setRowIndexEnd(9999);

            products = campaignDao.getProducts(userSessionId, params);
        } catch (Exception e) {
            logger.error("", e);
        }
    }
}
