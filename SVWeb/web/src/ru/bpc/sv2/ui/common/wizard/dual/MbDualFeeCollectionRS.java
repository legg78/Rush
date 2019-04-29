package ru.bpc.sv2.ui.common.wizard.dual;

import org.apache.log4j.Logger;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.operations.MbOperations;
import ru.bpc.sv2.ui.rules.MbFreqApplications;
import ru.bpc.sv2.ui.session.StoreFilter;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.HashMap;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbDualFeeCollectionRS")
public class MbDualFeeCollectionRS extends AbstractWizardStep {
	private static final Logger logger = Logger.getLogger(MbDualFeeCollectionRS.class);
	private static final String PAGE = "/pages/common/wizard/callcenter/dualCardFeeCollectionRS.jspx";
	private static final String STATUS = "STATUS";
	private static final String APPLICATION_ID = "APPLICATION_ID";
	private static final String BACKLINK = "issuing|finrequests";

	private String status;
	private Long appId;

	@Override
	public void init(Map<String, Object> context) {
		logger.trace("init...");
		super.init(context, PAGE);
		setMakerCheckerMode(Mode.CHECKER);

		if (getContext().containsKey(STATUS)) {
			status = (String) context.get(STATUS);
		}
		if (getContext().containsKey(APPLICATION_ID)) {
			appId = (Long) context.get(APPLICATION_ID);
		}
		getContext().put(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);
	}

	@Override
	public Map<String, Object> release(Direction direction) {
		logger.trace("release...");
		if (direction == Direction.FORWARD) {
			if (appId != null) {
				HashMap<String, Object> queueFilter = new HashMap<String,Object>();
				queueFilter.put("backLink", BACKLINK);
				queueFilter.put("id", appId);

				StoreFilter storeFilter = ManagedBeanWrapper.getManagedBean(StoreFilter.class);
				storeFilter.addFilter(BACKLINK, "MbFreqApplications", queueFilter);

				Menu menu = (Menu) ManagedBeanWrapper.getManagedBean(Menu.class);
				menu.externalSelect(BACKLINK);
			}
		}
		MbOperations operSearch = ManagedBeanWrapper.getManagedBean("MbOperations");
		operSearch.setOnlyUpdate(true);

		return getContext();
	}

	@Override
	public boolean validate() {
		return false;
	}

	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}

	public Long getAppId() {
		return appId;
	}
	public void setAppId(Long appId) {
		this.appId = appId;
	}

	public String getResultMessage() {
		return FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
									 (appId != null) ? "financial_request_has_been_created"
													 : "dispute_has_been_created");
	}
}
