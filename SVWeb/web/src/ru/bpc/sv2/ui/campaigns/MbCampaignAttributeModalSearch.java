package ru.bpc.sv2.ui.campaigns;

import org.apache.log4j.Logger;
import org.openfaces.util.Faces;
import org.openfaces.component.table.TreePath;
import ru.bpc.sv2.campaign.CampaignAttribute;
import ru.bpc.sv2.campaign.CampaignProduct;
import ru.bpc.sv2.campaign.CampaignAttribute;
import ru.bpc.sv2.campaign.CampaignService;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CampaignDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.Attribute;
import ru.bpc.sv2.products.ProductAttribute;
import ru.bpc.sv2.ui.products.MbAttributes;
import ru.bpc.sv2.ui.products.MbObjectAttributes;
import ru.bpc.sv2.ui.utils.AbstractSearchBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbCampaignAttributeModalSearch")
public class MbCampaignAttributeModalSearch extends MbObjectAttributes {
    private static final Logger logger = Logger.getLogger("CPN");

    private CampaignDao campaignDao = new CampaignDao();

    private CampaignAttribute modalFilter;
    private List<CampaignProduct> products;
    private List<CampaignService> services;

    @Override
    public void search() {
        super.serviceId = getModalFilter().getServiceId().intValue();
        super.curLang = getModalFilter().getLang();
        super.productId = getModalFilter().getProductId().intValue();
        super.entityType = EntityNames.SERVICE;
        super.instId = getModalFilter().getInstId();
        super.setCaching(false);
        super.search();
    }

    public List<SelectItem> getFilterServices() {
        List<SelectItem> list = new ArrayList<SelectItem>();
        if (getModalFilter().getProductId() != null) {
            initCampaignServices();
        }
        if (services != null) {
            for (CampaignService service : services) {
                list.add(new SelectItem(service.getServiceId(), service.getServiceId() + " - " + service.getServiceLabel()));
            }
        }
        return list;
    }
    public List<SelectItem> getFilterProducts() {
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
            if (getModalFilter().getCampaignId() != null) {
                productFilters.add(Filter.create("campaignId", getModalFilter().getCampaignId()));
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
    public void initCampaignServices() {
        try {
            if (getModalFilter().getProductId() != null) {
                List<Filter> serviceFilters = new ArrayList<Filter>();
                if (getModalFilter().getCampaignId() != null) {
                    serviceFilters.add(Filter.create("campaignId", getModalFilter().getCampaignId()));
                }
                serviceFilters.add(Filter.create("productId", getModalFilter().getProductId()));
                serviceFilters.add(Filter.create("lang", userLang));

                SelectionParams params = new SelectionParams(serviceFilters);
                params.setRowIndexStart(0);
                params.setRowIndexEnd(9999);

                services = campaignDao.getServices(userSessionId, params);
            } else {
                services = null;
            }
        } catch (Exception e) {
            logger.error("", e);
        }
    }

    public CampaignAttribute getModalFilter() {
        if (modalFilter == null) {
            modalFilter = new CampaignAttribute();
        }
        return modalFilter;
    }
    public void setModalFilter(CampaignAttribute modalFilter) {
        this.modalFilter = modalFilter;
    }
}