package ru.bpc.sv2.ui.ps.visa.vssreports;

import ru.bpc.sv2.logic.VisaDao;
import ru.bpc.sv2.ps.visa.AbstractVisaVssReportDetail;
import ru.bpc.sv2.ui.utils.CountryUtils;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

import java.util.HashMap;
import java.util.Map;

class VssReportProcessorBase<T extends AbstractVisaVssReportDetail> {
	public static final String VITC = "VITC";
	public static final String VISJ = "VISJ";
	public static final String VITT = "VITT";
	public static final String VICT = "VICT";
	public static final String VITD = "VITD";

	/* Section 4 summaries */
	public static final String SUMMARY_LEVEL_BUS_MODE_TOTAL = "01";
	public static final String SUMMARY_LEVEL_BUS_MODE_NET = "02";
	public static final String SUMMARY_LEVEL_CHARGE_TYPE_TOTAL = "03";
	public static final String SUMMARY_LEVEL_CHARGE_TYPE_NET = "04";
	public static final String SUMMARY_LEVEL_BUS_TRAN_TOTAL = "05";
	public static final String SUMMARY_LEVEL_BUS_TRAN_NET = "06";
	public static final String SUMMARY_LEVEL_BUS_CYCLE_TOTAL = "07";
	public static final String SUMMARY_LEVEL_JURISDICTION_TOTAL = "08";
	public static final String SUMMARY_LEVEL_ROUTING_TOTAL = "09";
	public static final String SUMMARY_LEVEL_DETAIL = "10";
	public static final String SUMMARY_LEVEL_FINAL_TOTAL = "11";
	public static final String SUMMARY_LEVEL_FINAL_NET = "12";

	/* Section 6 summaries */
	public static final String SUMMARY_LEVEL6_PROC_TOTAL = "01";
	public static final String SUMMARY_LEVEL6_BIN_TOTAL = "02";
	public static final String SUMMARY_LEVEL6_STTL_SVC_TOTAL = "03";
	public static final String SUMMARY_LEVEL6_SRE_TOTAL = "04";
	public static final String SUMMARY_LEVEL6_CLR_CURR_TOTAL = "05";
	public static final String SUMMARY_LEVEL6_BUS_MODE_TOTAL = "06";
	public static final String SUMMARY_LEVEL6_BUS_TRAN_TOTAL = "07";
	public static final String SUMMARY_LEVEL6_DETAIL_LINE = "08";
	public static final String SUMMARY_LEVEL6_STTL_TYPE_TOTAL= "10";
	public static final String SUMMARY_LEVEL6_FINANCIAL_TOTAL = "11";

	protected VisaDao visaDao;
	protected DictUtils dictUtils;
	protected CountryUtils countryUtils;
	protected Map<String, String> businessModes;
	protected Map<String, String> amountTypes;
	protected Map<String, String> dictVitt;
	protected Map<String, String> dictVitc;
	protected Map<String, String> dictVisj;
	protected Map<String, String> dictVict;
	protected Map<String, String> dictVitd;
	protected Map<String, String> countryMap;

	public VssReportProcessorBase(VisaDao visaDao) {
		this.visaDao = visaDao;
		dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		countryUtils = (CountryUtils) ManagedBeanWrapper.getManagedBean("CountryUtils");
		dictVitc = dictUtils.getArticlesMap(VITC);
		dictVisj = dictUtils.getArticlesMap(VISJ);
		dictVitt = dictUtils.getArticlesMap(VITT);
		dictVict = dictUtils.getArticlesMap(VICT);
		dictVitd = dictUtils.getArticlesMap(VITD);
		countryMap = countryUtils.getCountryMap();
		initBusinessModes();
		initAmountTypes();
	}

	public boolean equals(Object o1, Object o2) {
		return o1 == null && o2 == null
				|| o1 != null && o2 != null && o1.equals(o2);
	}

	public boolean in(Object o1, Object... objects) {
		for (Object object : objects)
			if (equals(o1, object))
				return true;
		return false;
	}

	private void initBusinessModes() {
		businessModes = new HashMap<String, String>();
		businessModes.put("1", FacesUtils.getMessage(MbVisaVssReports.LOCALE_VIS, "bus_aquirer"));
		businessModes.put("2", FacesUtils.getMessage(MbVisaVssReports.LOCALE_VIS, "bus_issuer"));
		businessModes.put("3", FacesUtils.getMessage(MbVisaVssReports.LOCALE_VIS, "bus_other"));
	}

	private void initAmountTypes() {
		amountTypes = new HashMap<String, String>();
		amountTypes.put("I", FacesUtils.getMessage(MbVisaVssReports.LOCALE_VIS, "amount_type_interchange"));
		amountTypes.put("F", FacesUtils.getMessage(MbVisaVssReports.LOCALE_VIS, "amount_type_reimb"));
		amountTypes.put("C", FacesUtils.getMessage(MbVisaVssReports.LOCALE_VIS, "amount_type_charge"));
		amountTypes.put("T", FacesUtils.getMessage(MbVisaVssReports.LOCALE_VIS, "amount_type_total"));
	}
}
