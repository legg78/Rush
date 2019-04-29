package ru.bpc.sv2.ui.ps.visa.vssreports;

import ru.bpc.sv2.logic.VisaDao;
import ru.bpc.sv2.ps.visa.*;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.SessionWrapper;

import java.util.ArrayList;
import java.util.List;

class VssReportProcessor extends VssReportProcessorBase<VisaVssReportDetailV4> {

	public VssReportProcessor(VisaDao visaDao) {
		super(visaDao);
	}

	public List<? extends AbstractVisaVssReportDetail<?>> buildTree(VisaVssReport report) {
		if (report.getReportIdNum().equals("110"))
			return buildTree110(report);
		if (report.getReportIdNum().equals("120"))
			return buildTree120(report);
		else if (report.getReportIdNum().equals("130"))
			return buildTree130(report);
		else if (report.getReportIdNum().equals("140"))
			return buildTree140(report);
		else if (report.getReportIdNum().equals("900"))
			return buildTree900(report);
		return new ArrayList<VisaVssReportDetailV4>();
	}

	public List<VisaVssReportDetailV2> buildTree110(VisaVssReport report) {
		List<VisaVssReportDetailV2> reps = visaDao.getVisaVssReportsV2(SessionWrapper.getRequiredUserSessionId(), report.getId());
		String oldAmountType = null;
		List<VisaVssReportDetailV2> result = new ArrayList<VisaVssReportDetailV2>();
		VisaVssReportDetailV2 amountTypeParent = null;
		for (VisaVssReportDetailV2 rep : reps) {
			if (!equals(oldAmountType, rep.getAmountType())) {
				amountTypeParent = new VisaVssReportDetailV2();
				amountTypeParent.assignFakeId();
				amountTypeParent.setText(amountTypes.get(rep.getAmountType()));
				result.add(amountTypeParent);
			}
			if (amountTypeParent != null) {
				String name = equals(rep.getBusinessMode(), "9") ?
						(equals(rep.getAmountType(), "T") ? "" : amountTypeParent.getText()) :
						businessModes.get(rep.getBusinessMode());
				rep.setText(getTotalString(name));
				amountTypeParent.addChild(rep);
			}
			oldAmountType = rep.getAmountType();
		}
		return result;
	}

	public List<VisaVssReportDetailV4> buildTree120(VisaVssReport report) {
		List<VisaVssReportDetailV4> reps = visaDao.getVisaVssReportsV4(SessionWrapper.getRequiredUserSessionId(), report.getId());

		String oldBusinessMode = null;
		String oldBusinessTran = null;

		List<VisaVssReportDetailV4> result = new ArrayList<VisaVssReportDetailV4>();
		VisaVssReportDetailV4 busModeParent = null;
		VisaVssReportDetailV4 busTranParent = null;
		for (VisaVssReportDetailV4 rep : reps) {
			if (in(rep.getSummaryLevel(), SUMMARY_LEVEL_DETAIL,
					SUMMARY_LEVEL_BUS_MODE_TOTAL, SUMMARY_LEVEL_BUS_MODE_NET,
					SUMMARY_LEVEL_BUS_TRAN_TOTAL, SUMMARY_LEVEL_BUS_TRAN_NET)) {
				if (rep.getBusinessMode() != null && !equals(oldBusinessMode, rep.getBusinessMode())) {
					VisaVssReportDetailV4 expandCollapse = new VisaVssReportDetailV4();
					expandCollapse.assignFakeId();
					expandCollapse.setExpandCollapseNode(true);
					result.add(expandCollapse);
					busModeParent = new VisaVssReportDetailV4();
					busModeParent.assignFakeId();
					busModeParent.setText(businessModes.get(rep.getBusinessMode()) + " " + FacesUtils.getMessage(MbVisaVssReports.LOCALE_VIS, "transactions"));
					result.add(busModeParent);
					oldBusinessMode = rep.getBusinessMode();
				}
				if (rep.getBusinessTransType() != null && !equals(oldBusinessTran, rep.getBusinessTransType())) {
					busTranParent = new VisaVssReportDetailV4();
					busTranParent.setText(getBusTransType(rep));
					assert busModeParent != null;
					busModeParent.addChild(busTranParent);
					oldBusinessTran = rep.getBusinessTransType();
				}
				if (in(rep.getSummaryLevel(), SUMMARY_LEVEL_DETAIL) && busTranParent != null) {
					if (rep.getBusinessTransCycle() == null || rep.getBusinessTransCycle().equals("0"))
						rep.setText(busTranParent.getText());
					else
						rep.setText(dictVitc.get(VITC + rep.getBusinessTransCycle()));
					busTranParent.addChild(rep);
				}
			}
			if (in(rep.getSummaryLevel(), SUMMARY_LEVEL_BUS_MODE_TOTAL, SUMMARY_LEVEL_BUS_MODE_NET)) {
				assert busModeParent != null;
				rep.setText(getTotalString(rep.getSummaryLevel(), busModeParent.getText()));
				busModeParent.addChild(rep);
			} else if (in(rep.getSummaryLevel(), SUMMARY_LEVEL_BUS_TRAN_TOTAL, SUMMARY_LEVEL_BUS_TRAN_NET)) {
				assert busTranParent != null;
				rep.setText(getTotalString(rep.getSummaryLevel(), busTranParent.getText()));
				busTranParent.addChild(rep);
			}
		}
		return result;
	}

	private String getBusTransType(VisaVssReportDetailV4 rep) {
		String type = rep.getBusinessTransType();
		if (type != null) {
			try {
				int typeInt = Integer.parseInt(type);
				if (typeInt >= 500 && typeInt < 570)
					return "Fee collection";
				if (typeInt >= 600 && typeInt < 670)
					return "Funds disbursement";
			} catch (NumberFormatException ignored) {
			}
		}
		return dictVitt.get(VITT + type);
	}

	public List<VisaVssReportDetailV4> buildTree130(VisaVssReport report) {
		List<VisaVssReportDetailV4> reps = visaDao.getVisaVssReportsV4(SessionWrapper.getRequiredUserSessionId(), report.getId());

		String oldBusinessMode = null;
		String oldBusinessTran = null;
		String oldTransactionCycle = null;
		String oldJurisdiction = null;
		String oldCountryRegion = null;

		List<VisaVssReportDetailV4> result = new ArrayList<VisaVssReportDetailV4>();
		VisaVssReportDetailV4 busModeParent = null;
		VisaVssReportDetailV4 busTranParent = null;
		VisaVssReportDetailV4 transCycleParent = null;
		VisaVssReportDetailV4 jurisdictionParent = null;
		VisaVssReportDetailV4 countryRegionParent = null;
		for (VisaVssReportDetailV4 rep : reps) {
			if (in(rep.getSummaryLevel(), SUMMARY_LEVEL_BUS_MODE_TOTAL, SUMMARY_LEVEL_BUS_MODE_NET)) {
				assert busModeParent != null;
				rep.setText(getTotalString(rep.getSummaryLevel(), busModeParent.getText()));
				busModeParent.addChild(rep);
			} else if (in(rep.getSummaryLevel(), SUMMARY_LEVEL_BUS_TRAN_TOTAL, SUMMARY_LEVEL_BUS_TRAN_NET)) {
				assert busTranParent != null;
				rep.setText(getTotalString(rep.getSummaryLevel(), busTranParent.getText()));
				busTranParent.addChild(rep);
			} else if (in(rep.getSummaryLevel(), SUMMARY_LEVEL_BUS_CYCLE_TOTAL)) {
				assert transCycleParent != null;
				rep.setText(getTotalString(rep.getSummaryLevel(), transCycleParent.getText()));
				transCycleParent.addChild(rep);
			} else if (in(rep.getSummaryLevel(), SUMMARY_LEVEL_JURISDICTION_TOTAL)) {
				assert jurisdictionParent != null;
				rep.setText(getTotalString(rep.getSummaryLevel(), jurisdictionParent.getText()));
				jurisdictionParent.addChild(rep);
			} else if (in(rep.getSummaryLevel(), SUMMARY_LEVEL_ROUTING_TOTAL)) {
				assert countryRegionParent != null;
				rep.setText(getTotalString(rep.getSummaryLevel(), countryRegionParent.getText()));
				countryRegionParent.addChild(rep);
			} else if (equals(rep.getSummaryLevel(), SUMMARY_LEVEL_DETAIL)) {
				if (!equals(oldBusinessMode, rep.getBusinessMode())) {
					VisaVssReportDetailV4 expandCollapse = new VisaVssReportDetailV4();
					expandCollapse.assignFakeId();
					expandCollapse.setExpandCollapseNode(true);
					result.add(expandCollapse);
					busModeParent = new VisaVssReportDetailV4();
					busModeParent.assignFakeId();
					busModeParent.setText(businessModes.get(rep.getBusinessMode()) + " " + FacesUtils.getMessage(MbVisaVssReports.LOCALE_VIS, "transactions"));
					result.add(busModeParent);
				}
				if (!equals(oldBusinessTran, rep.getBusinessTransType())) {
					busTranParent = new VisaVssReportDetailV4();
					busTranParent.setText(getBusTransType(rep));
					assert busModeParent != null;
					busModeParent.addChild(busTranParent);
				}
				if (!equals(oldTransactionCycle, rep.getBusinessTransCycle())) {
					if (rep.getBusinessTransCycle() == null || rep.getBusinessTransCycle().equals("0")) {
						transCycleParent = busTranParent;
					} else {
						transCycleParent = new VisaVssReportDetailV4();
						transCycleParent.setText(dictVitc.get(VITC + rep.getBusinessTransCycle()));
						assert busTranParent != null;
						busTranParent.addChild(transCycleParent);
					}
				}
				if (!equals(oldJurisdiction, rep.getJurisdiction())) {
					jurisdictionParent = new VisaVssReportDetailV4();
					jurisdictionParent.setText(dictVisj.get(VISJ + rep.getJurisdiction()));
					assert transCycleParent != null;
					transCycleParent.addChild(jurisdictionParent);
				}
				if (!equals(oldCountryRegion, rep.getCountryOrRegion())) {
					countryRegionParent = new VisaVssReportDetailV4();
					if (rep.getSrcCountry() != null) {
						countryRegionParent.setText(countryMap.get(rep.getSrcCountry()) + " - " + countryMap.get(rep.getDstCountry()));
					} else
						countryRegionParent.setText(rep.getSrcRegion() + " - " + rep.getDstRegion());
					assert jurisdictionParent != null;
					jurisdictionParent.addChild(countryRegionParent);
				}
				if (countryRegionParent != null) {
					rep.setText(rep.getFeeLevel());
					countryRegionParent.addChild(rep);
				}
			}
			oldBusinessMode = rep.getBusinessMode();
			oldBusinessTran = rep.getBusinessTransType();
			oldTransactionCycle = rep.getBusinessTransCycle();
			oldJurisdiction = rep.getJurisdiction();
			oldCountryRegion = rep.getCountryOrRegion();
		}
		return result;
	}

	public List<VisaVssReportDetailV4> buildTree140(VisaVssReport report) {
		List<VisaVssReportDetailV4> reps = visaDao.getVisaVssReportsV4(SessionWrapper.getRequiredUserSessionId(), report.getId());

		String oldChargeType = null;
		String oldBusinessMode = null;
		String oldBusinessTran = null;
		String oldTransactionCycle = null;
		String oldJurisdiction = null;

		List<VisaVssReportDetailV4> result = new ArrayList<VisaVssReportDetailV4>();
		VisaVssReportDetailV4 busModeParent = null;
		VisaVssReportDetailV4 chargeTypeParent = null;
		VisaVssReportDetailV4 busTranParent = null;
		VisaVssReportDetailV4 transCycleParent = null;
		VisaVssReportDetailV4 jurisdictionParent = null;
		for (VisaVssReportDetailV4 rep : reps) {
			if (in(rep.getSummaryLevel(), SUMMARY_LEVEL_BUS_MODE_TOTAL, SUMMARY_LEVEL_BUS_MODE_NET)) {
				assert busModeParent != null;
				rep.setText(getTotalString(rep.getSummaryLevel(), busModeParent.getText()));
				busModeParent.addChild(rep);
			} else if (in(rep.getSummaryLevel(), SUMMARY_LEVEL_CHARGE_TYPE_TOTAL, SUMMARY_LEVEL_CHARGE_TYPE_NET)) {
				assert chargeTypeParent != null;
				rep.setText(getTotalString(rep.getSummaryLevel(), chargeTypeParent.getText()));
				chargeTypeParent.addChild(rep);
			} else if (in(rep.getSummaryLevel(), SUMMARY_LEVEL_BUS_TRAN_TOTAL, SUMMARY_LEVEL_BUS_TRAN_NET)) {
				assert busTranParent != null;
				rep.setText(getTotalString(rep.getSummaryLevel(), busTranParent.getText()));
				busTranParent.addChild(rep);
			} else if (in(rep.getSummaryLevel(), SUMMARY_LEVEL_BUS_CYCLE_TOTAL)) {
				assert transCycleParent != null;
				rep.setText(getTotalString(rep.getSummaryLevel(), transCycleParent.getText()));
				transCycleParent.addChild(rep);
			} else if (in(rep.getSummaryLevel(), SUMMARY_LEVEL_JURISDICTION_TOTAL)) {
				assert jurisdictionParent != null;
				rep.setText(getTotalString(rep.getSummaryLevel(), jurisdictionParent.getText()));
				jurisdictionParent.addChild(rep);
			} else if (equals(rep.getSummaryLevel(), SUMMARY_LEVEL_ROUTING_TOTAL)) {
				if (!equals(oldBusinessMode, rep.getBusinessMode())) {
					VisaVssReportDetailV4 expandCollapse = new VisaVssReportDetailV4();
					expandCollapse.assignFakeId();
					expandCollapse.setExpandCollapseNode(true);
					result.add(expandCollapse);
					busModeParent = new VisaVssReportDetailV4();
					busModeParent.assignFakeId();
					busModeParent.setText(businessModes.get(rep.getBusinessMode()) + " " + FacesUtils.getMessage(MbVisaVssReports.LOCALE_VIS, "transactions"));
					result.add(busModeParent);
				}
				if (!equals(oldChargeType, rep.getChargeType())) {
					chargeTypeParent = new VisaVssReportDetailV4();
					chargeTypeParent.setText(dictVict.get(VICT + rep.getChargeType()));
					assert busModeParent != null;
					busModeParent.addChild(chargeTypeParent);
				}
				if (!equals(oldBusinessTran, rep.getBusinessTransType())) {
					busTranParent = new VisaVssReportDetailV4();
					busTranParent.setText(getBusTransType(rep));
					assert chargeTypeParent != null;
					chargeTypeParent.addChild(busTranParent);
				}
				if (!equals(oldTransactionCycle, rep.getBusinessTransCycle())) {
					if (rep.getBusinessTransCycle() == null || rep.getBusinessTransCycle().equals("0")) {
						transCycleParent = busTranParent;
					} else {
						transCycleParent = new VisaVssReportDetailV4();
						transCycleParent.setText(dictVitc.get(VITC + rep.getBusinessTransCycle()));
						assert busTranParent != null;
						busTranParent.addChild(transCycleParent);
					}
				}
				if (!equals(oldJurisdiction, rep.getJurisdiction())) {
					jurisdictionParent = new VisaVssReportDetailV4();
					jurisdictionParent.setText(dictVisj.get(VISJ + rep.getJurisdiction()));
					assert transCycleParent != null;
					transCycleParent.addChild(jurisdictionParent);
				}
				if (jurisdictionParent != null) {
					if (rep.getSrcCountry() != null) {
						rep.setText(countryMap.get(rep.getSrcCountry()) + " - " + countryMap.get(rep.getDstCountry()));
					} else
						rep.setText(rep.getSrcRegion() + " - " + rep.getDstRegion());
					jurisdictionParent.addChild(rep);
				}
			}
			oldBusinessMode = rep.getBusinessMode();
			oldChargeType = rep.getChargeType();
			oldBusinessTran = rep.getBusinessTransType();
			oldTransactionCycle = rep.getBusinessTransCycle();
			oldJurisdiction = rep.getJurisdiction();
		}
		return result;
	}

	public List<VisaVssReportDetailV6> buildTree900(VisaVssReport report) {
		List<VisaVssReportDetailV6> reps = visaDao.getVisaVssReportsV6(SessionWrapper.getRequiredUserSessionId(), report.getId());

		String oldBusinessMode = null;
		String oldBusinessTran = null;
		String oldTransactionCycle = null;

		List<VisaVssReportDetailV6> result = new ArrayList<VisaVssReportDetailV6>();
		VisaVssReportDetailV6 busModeParent = null;
		VisaVssReportDetailV6 busTranParent = null;
		VisaVssReportDetailV6 transCycleParent = null;
		for (VisaVssReportDetailV6 rep : reps) {
			if (in(rep.getSummaryLevel(), SUMMARY_LEVEL6_BUS_MODE_TOTAL, SUMMARY_LEVEL6_BUS_TRAN_TOTAL, SUMMARY_LEVEL6_DETAIL_LINE)) {
				if (!equals(oldBusinessMode, rep.getBusinessMode())) {
					VisaVssReportDetailV6 expandCollapse = new VisaVssReportDetailV6();
					expandCollapse.assignFakeId();
					expandCollapse.setExpandCollapseNode(true);
					result.add(expandCollapse);
					busModeParent = new VisaVssReportDetailV6();
					busModeParent.assignFakeId();
					busModeParent.setText(businessModes.get(rep.getBusinessMode()) + " " + FacesUtils.getMessage(MbVisaVssReports.LOCALE_VIS, "transactions"));
					result.add(busModeParent);
					busTranParent = null;
					transCycleParent = null;
				}
				if (in(rep.getSummaryLevel(), SUMMARY_LEVEL6_BUS_MODE_TOTAL)) {
					assert busModeParent != null;
					rep.setText(dictVitd.get(VITD + rep.getTransDisposition()));
					busModeParent.addChild(rep);
				}
				oldBusinessMode = rep.getBusinessMode();
			}
			if (in(rep.getSummaryLevel(), SUMMARY_LEVEL6_BUS_TRAN_TOTAL, SUMMARY_LEVEL6_DETAIL_LINE)) {
				if (!equals(oldBusinessTran, rep.getBusinessTransType())) {
					busTranParent = new VisaVssReportDetailV6();
					busTranParent.setText(dictVitt.get(VITT + rep.getBusinessTransType()));
					assert busModeParent != null;
					busModeParent.addChild(busTranParent);
					transCycleParent = null;
					oldBusinessTran = rep.getBusinessTransType();
				}
				if (in(rep.getSummaryLevel(), SUMMARY_LEVEL6_BUS_TRAN_TOTAL)) {
					assert busTranParent != null;
					rep.setText(dictVitd.get(VITD + rep.getTransDisposition()));
					busTranParent.addChild(rep);
				}
			}
			if (in(rep.getSummaryLevel(), SUMMARY_LEVEL6_DETAIL_LINE)) {
				if (!equals(oldTransactionCycle, rep.getBusinessTransCycle())) {
					if (rep.getBusinessTransCycle() != null && !rep.getBusinessTransCycle().equals("0")) {
						transCycleParent = new VisaVssReportDetailV6();
						transCycleParent.setText(dictVitc.get(VITC + rep.getBusinessTransCycle()));
						assert busModeParent != null;
						if (busTranParent != null)
							busTranParent.addChild(transCycleParent);
						else
							busModeParent.addChild(transCycleParent);
					} else {
						transCycleParent = busTranParent;
					}
					oldTransactionCycle = rep.getBusinessTransCycle();
				}
				rep.setText(dictVitd.get(VITD + rep.getTransDisposition()));
				if (transCycleParent != null)
					transCycleParent.addChild(rep);
				else if (busTranParent != null)
					busTranParent.addChild(rep);
				else
					busModeParent.addChild(rep);
			}
			if (in(rep.getSummaryLevel(), SUMMARY_LEVEL6_SRE_TOTAL)) {
				rep.setText(dictVitd.get(VITD + rep.getTransDisposition()));
				result.add(rep);
			}
		}
		return result;
	}

	private String getTotalString(String text) {
		return FacesUtils.getMessage(MbVisaVssReports.LOCALE_VIS, "total") + " " + text;
	}

	private String getTotalString(String summaryLevel, String text) {
		if (in(summaryLevel, SUMMARY_LEVEL_BUS_MODE_TOTAL, SUMMARY_LEVEL_CHARGE_TYPE_TOTAL, SUMMARY_LEVEL_BUS_TRAN_TOTAL,
				SUMMARY_LEVEL_BUS_CYCLE_TOTAL, SUMMARY_LEVEL_JURISDICTION_TOTAL, SUMMARY_LEVEL_ROUTING_TOTAL,
				SUMMARY_LEVEL_FINAL_TOTAL))
			return FacesUtils.getMessage(MbVisaVssReports.LOCALE_VIS, "total") + " " + text;
		else if (!equals(summaryLevel, SUMMARY_LEVEL_DETAIL))
			return FacesUtils.getMessage(MbVisaVssReports.LOCALE_VIS, "net") + " " + text;
		else
			return text;
	}
}
