package ru.bpc.sv2.ui.fcl.fees;

import org.ajax4jsf.model.KeepAlive;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.fcl.fees.FeeTier;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.FeesDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.component.UIComponent;
import javax.faces.component.html.HtmlInputText;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

@ViewScoped
@KeepAlive
@ManagedBean(name = "MbFeeTiers")
public class MbFeeTiers extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("FCL");

	public static final String FIXED_VALUE_FEE_RATE = "FEEM0002";
	public static final String PERCENTAGE_FEE_RATE = "FEEM0001";
	public static final String LENGTH_TYPE_YEAR = "LNGT0005";
	private FeesDao _feesDao = new FeesDao();

	private final DaoDataModel<FeeTier> _feeTiersSource;
	private final TableRowSelection<FeeTier> _feeTierSelection;

	private Filter[] tierFilters;
	private FeeTier _activeFeeTier;
	private boolean _managingNew;
	private Integer activeFeeId;
	transient

	private boolean modalMode;
	private boolean feeNeedsLengthType;
	private FeeTier _newFeeTier;

	private List<FeeTier> initialFeeTiers; // to keep initial state
	private List<FeeTier> storedFeeTiers; // for current work
	private ArrayList<SelectItem> lengthTypes = null;
	private List<SelectItem> lengthTypeAlgorithms = null;
	private boolean dontSave;
	private boolean disableAll;
	private int fakeId; // is used for feeRates that are added but not saved yet
	// (required for correct data table behaviour)
	private String feeRateCalc;
	private final BigDecimal maxNumber;
	private String feeCurrency;

	private int wizardStep;
	private List<FeeTier> wizFeeTiers;
	private List<FeeTier> wizPreFeeTiers;
	private List<FeeTier> wizPreFeeTiersCopy;
	private int preTierIndex;

	private static final String COMPONENT_ID = "tiersTable";
	private String tabName;
	private String parentSectionId;

	public MbFeeTiers() {
		fakeId = -1;

		// In database column limit for double numbers is 22 digits
		// including 4 decimals, so it's actually "18,4"
		// 999 999 999 999 999 999.99990
		maxNumber = (new BigDecimal("1.0E18")).subtract(new BigDecimal("1.0E-4"));

		_feeTiersSource = new DaoDataModel<FeeTier>() {
			private static final long serialVersionUID = -157925875968185576L;

			@Override
			protected FeeTier[] loadDaoData(SelectionParams params) {
				if (activeFeeId == null) {
					return new FeeTier[0];
				}
				try {
					setRateFilters();
					params.setFilters(tierFilters);

					if (dontSave) {

						// if we don't want to immediately save all changes that
						// have been done to this fee rates set then we will
						// work with temporary array list which is first
						// initiated with values from DB. To find changes that
						// were made one more array is created and is not changed
						// (actually we could read it from DB again but then we 
						// would have to read it from DB :))

						if (storedFeeTiers == null) {
							FeeTier[] rates = _feesDao.getFeeTiers(userSessionId, params);
							storedFeeTiers = Collections.synchronizedList(new ArrayList<FeeTier>(rates.length));
							initialFeeTiers = Collections.synchronizedList(new ArrayList<FeeTier>(rates.length));
							for (FeeTier rate : rates) {
								storedFeeTiers.add(rate);
								initialFeeTiers.add(rate);
							}
						}

						sortFeeTiers(storedFeeTiers);

						return storedFeeTiers.toArray(new FeeTier[storedFeeTiers.size()]);
					}
					return _feesDao.getFeeTiers(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new FeeTier[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (activeFeeId == null) {
					return 0;
				}
				try {
					setRateFilters();
					params.setFilters(tierFilters);
					if (dontSave && storedFeeTiers != null) {
						return storedFeeTiers.size();
					}
					return _feesDao.getFeeTiersCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_feeTierSelection = new TableRowSelection<FeeTier>(null, _feeTiersSource);
	}

	public DaoDataModel<FeeTier> getFeeTiers() {
		return _feeTiersSource;
	}

	public FeeTier getActiveFeeTier() {
		return _activeFeeTier;
	}
	public void setActiveFeeTier(FeeTier activeFeeTier) {
		_activeFeeTier = activeFeeTier;
	}

	public SimpleSelection getFeeTierSelection() {
		return _feeTierSelection.getWrappedSelection();
	}
	public void setFeeTierSelection(SimpleSelection selection) {
		_feeTierSelection.setWrappedSelection(selection);
		_activeFeeTier = _feeTierSelection.getSingleSelection();
	}

	public Integer getActiveFeeId() {
		return activeFeeId;
	}
	public void setActiveFeeId(Integer activeFeeId) {
		this.activeFeeId = activeFeeId;
	}

	public void setRateFilters() {
		if (activeFeeId != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("feeId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(activeFeeId.toString());
			tierFilters = new Filter[]{paramFilter};
		}
	}

	public void create() {
		_newFeeTier = new FeeTier();
		if (dontSave) {
			_newFeeTier.setId(fakeId--);
			if (storedFeeTiers == null) {
				storedFeeTiers = Collections.synchronizedList(new ArrayList<FeeTier>());
				initialFeeTiers = Collections.synchronizedList(new ArrayList<FeeTier>());
			}
		}
		_newFeeTier.setFeeId(activeFeeId);
		_newFeeTier.setNeedLengthType(feeNeedsLengthType);
		_managingNew = true;
		modalMode = true;
	}

	public void edit() {
		_managingNew = false;
		modalMode = true;
		try {
			_newFeeTier = (FeeTier) _activeFeeTier.clone();
		} catch (CloneNotSupportedException e) {
			_newFeeTier = _activeFeeTier;
		}
	}

	public void save() {
		if (!checkForm()) {
			return;
		}
		try {
			if (_managingNew) {
				if (dontSave) {
					storedFeeTiers.add(_newFeeTier);
				} else {
					_newFeeTier = _feesDao.createFeeTier(userSessionId, _newFeeTier);
				}
				_feeTierSelection.addNewObjectToList(_newFeeTier,
						new Comparator<FeeTier>() {
							// Sorts fee tiers by count threshold and then (if count 
							// thresholds are equal) by sum threshold.
							public int compare(FeeTier t1, FeeTier t2) {
								if (t1.getCountThreshold().equals(t2.getCountThreshold())) {
									return t1.getSumThreshold().compareTo(t2.getSumThreshold());
								}
								return t1.getCountThreshold().compareTo(t2.getCountThreshold());
							}
						});
			} else {
				if (dontSave) {
					storedFeeTiers.remove(_activeFeeTier);
					storedFeeTiers.add(_newFeeTier);
				} else {
					_feesDao.updateFeeTier(userSessionId, _newFeeTier);
				}
				_feeTiersSource.replaceObject(_activeFeeTier, _newFeeTier);
			}
			_activeFeeTier = _newFeeTier;
			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Fcl", "fee_tier_saved"));
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	/**
	 * <p>Sorts fee tiers by count threshold and then (if count thresholds are equal) by
	 * sum threshold.</p>
	 */
	private void sortFeeTiers(List<FeeTier> feeTiers) {
		Collections.sort(feeTiers, new Comparator<FeeTier>() {
			public int compare(FeeTier t1, FeeTier t2) {
				if (t1.getCountThreshold().equals(t2.getCountThreshold())) {
					return t1.getSumThreshold().compareTo(t2.getSumThreshold());
				}
				return t1.getCountThreshold().compareTo(t2.getCountThreshold());
			}
		});
	}

	public void delete() {
		try {
			if (dontSave) {
				storedFeeTiers.remove(_activeFeeTier);
			} else {
				_feesDao.deleteFeeTier(userSessionId, _activeFeeTier);
			}

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Fcl",
					"fee_tier_deleted", "(ID = " + _activeFeeTier.getId() + ")"));

			_activeFeeTier = _feeTierSelection.removeObjectFromList(_activeFeeTier);
			if (_activeFeeTier == null) {
				clearBean();
			}
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	private boolean checkForm() {
		if (_newFeeTier.getMinValue() != null && _newFeeTier.getMaxValue() != null
				&& _newFeeTier.getMaxValue().compareTo(BigDecimal.ZERO) != 0
				&& _newFeeTier.getMinValue().compareTo(_newFeeTier.getMaxValue()) == 1) {
			FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
					"ru.bpc.sv2.ui.bundles.Msg", "min_gt_max")));
			return false;
		}
		return true;
	}

	/**
	 * Checks if tier corresponds to fee rate calculation type.
	 *
	 * @param tier - <code>ru.bpc.sv2.fcl.fees.Tier</code> to check
	 * @return plain copy of <code>tier</code> if it's correct; corrected copy
	 * of <code>tier</code> if there were minor errors (like excess
	 * values); or <code>null</code> if there's a major error (some
	 * needed value is absent).
	 */
	public FeeTier correctTier(FeeTier tier) {
		FeeTier copy = copyTier(tier);
		if (PERCENTAGE_FEE_RATE.equals(feeRateCalc)) {
			if (tier.getPercentRate() == null) {
				return null;
			}
			if (tier.getFixedRate() != null) {
				copy.setFixedRate(null);
				return copy;
			}
		} else if (FIXED_VALUE_FEE_RATE.equals(feeRateCalc)) {
			if (tier.getFixedRate() == null) {
				return null;
			}
			if (tier.getPercentRate() != null) {
				copy.setPercentRate(null);
				return copy;
			}
		} else if (tier.getPercentRate() == null || tier.getFixedRate() == null) {
			return null;
		}
		return copy;
	}

	private FeeTier copyTier(FeeTier tier) {
		try {
			return (FeeTier) tier.clone();
		} catch (CloneNotSupportedException e) {
			// this should never happen
			logger.error("", e);
			return tier;
		}
	}

	public boolean isManagingNew() {
		return _managingNew;
	}

	public void setManagingNew(boolean managingNew) {
		_managingNew = managingNew;
	}

	public void cancel() {

	}

	public FeeTier getNewFeeTier() {
		return _newFeeTier;
	}

	public void setNewFeeTier(FeeTier newFeeTier) {
		_newFeeTier = newFeeTier;
	}

	public ArrayList<SelectItem> getLengthTypes() {
		if (lengthTypes == null) {
			lengthTypes = getDictUtils().getArticles(DictNames.LENGTH_TYPES, true, false);
		}
		return lengthTypes;
	}

	public List<SelectItem> getLengthTypeAlgorithms() {
		if (lengthTypeAlgorithms == null) {
			lengthTypeAlgorithms = getDictUtils().getLov(LovConstants.LENGTH_TYPE_ALGORITHMS);
		}
		return lengthTypeAlgorithms;
	}

	public boolean isModalMode() {
		return modalMode;
	}

	public void setModalMode(boolean modalMode) {
		this.modalMode = modalMode;
	}

	public void clearBean() {
		if (_activeFeeTier != null) {
			_feeTierSelection.unselect(_activeFeeTier);
			_activeFeeTier = null;
		}
		_feeTiersSource.flushCache();
	}

	public void fullCleanBean() {
		activeFeeId = null;
		storedFeeTiers = null;
		feeCurrency = null;
		feeRateCalc = null;
		clearBean();
	}

	public List<FeeTier> getStoredFeeTiers() {
		return storedFeeTiers;
	}

	public void setStoredFeeTiers(ArrayList<FeeTier> storedFeeTiers) {
		this.storedFeeTiers = storedFeeTiers;
	}

	public boolean isDontSave() {
		return dontSave;
	}

	public void setDontSave(boolean dontSave) {
		this.dontSave = dontSave;
	}

	public List<FeeTier> getInitialFeeTiers() {
		return initialFeeTiers;
	}

	public void setInitialFeeTiers(ArrayList<FeeTier> initialFeeTiers) {
		this.initialFeeTiers = initialFeeTiers;
	}

	public boolean isDisableAll() {
		return disableAll;
	}

	public void setDisableAll(boolean disableAll) {
		this.disableAll = disableAll;
	}

	public String getFeeRateCalc() {
		return feeRateCalc;
	}

	public void setFeeRateCalc(String feeRateCalc) {
		this.feeRateCalc = feeRateCalc;
	}

	public boolean isFixedValue() {
		return FIXED_VALUE_FEE_RATE.equals(feeRateCalc);
	}

	public boolean isPercentValue() {
		return PERCENTAGE_FEE_RATE.equals(feeRateCalc);
	}

	public String getFeeCurrency() {
		return feeCurrency;
	}

	public void setFeeCurrency(String feeCurrency) {
		this.feeCurrency = feeCurrency;
	}

	public void validateBigDecimal(FacesContext context, UIComponent toValidate, Object value) {
		try {
			BigDecimal newValue = (BigDecimal) value;

			// as we get converted value before validating it we should convert it back
			Number exponent = null;
			try {
				exponent = (Number) toValidate.getAttributes().get("exponent");
			} catch (NumberFormatException ignored) {
			}
			if (exponent == null || exponent.intValue() < 0) {
				exponent = 2;
			}
			newValue = newValue.divide(BigDecimal.valueOf(Math.pow(10, exponent.intValue())));

			// checks if new value less then maximum allowed value
			if (maxNumber.compareTo(newValue) == -1 || (new BigDecimal(0.0)).compareTo(newValue) == 1) {
				((HtmlInputText) toValidate).setValid(false);

				// String label = ((HtmlInputText) toValidate).getLabel() != null ?
				// ((HtmlInputText) toValidate).getLabel() : ((HtmlInputText)
				// toValidate).getId();
				String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
						"value_mustbe_in_range", 0, maxNumber.toString());
				FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
				context.addMessage(toValidate.getClientId(context), message);
				return;
			}

			final int maxFractionDigits = 4;

			try {
				newValue.setScale(maxFractionDigits);
			} catch (ArithmeticException e) {
				((HtmlInputText) toValidate).setValid(false);

				String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
						"max_fract_digits_exceed", maxFractionDigits);
				FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
				context.addMessage(toValidate.getClientId(context), message);
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}

	public void validatePercentBigDecimal(FacesContext context, UIComponent toValidate, Object value) {
		try {
			BigDecimal newValue = (BigDecimal) value;

			// checks if new value less then maximum allowed value
			if (maxNumber.compareTo(newValue) == -1 || (new BigDecimal(0.0)).compareTo(newValue) == 1) {
				((HtmlInputText) toValidate).setValid(false);

				// String label = ((HtmlInputText) toValidate).getLabel() != null ?
				// ((HtmlInputText) toValidate).getLabel() : ((HtmlInputText)
				// toValidate).getId();
				String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
						"value_mustbe_in_range", 0, maxNumber.toString());
				FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
				context.addMessage(toValidate.getClientId(context), message);
				return;
			}

			final int maxFractionDigits = 4;

			try {
				newValue.setScale(maxFractionDigits);
			} catch (ArithmeticException e) {
				((HtmlInputText) toValidate).setValid(false);

				String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
						"max_fract_digits_exceed", maxFractionDigits);
				FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
				context.addMessage(toValidate.getClientId(context), message);
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}

	public void initWizard() {
		wizardStep = 1;
		wizPreFeeTiersCopy = new ArrayList<FeeTier>();
		wizPreFeeTiers = new ArrayList<FeeTier>();
		FeeTier initTier = new FeeTier();
		initTier.setSumThreshold(new BigDecimal(0.0));
		initTier.setCountThreshold(0L);
		wizPreFeeTiers.add(initTier);
		wizPreFeeTiers.add(new FeeTier());
	}

	public void addPreTier() {
		wizPreFeeTiers.add(preTierIndex + 1, new FeeTier());
	}

	public void removePreTier() {
		wizPreFeeTiers.remove(preTierIndex);
	}

	public void step1() {
		wizardStep = 1;
	}

	public void step2() {
		for (int i = wizPreFeeTiers.size() - 1; i >= 0; i--) {
			if (wizPreFeeTiers.get(i).getCountThreshold() == null
					|| wizPreFeeTiers.get(i).getSumThreshold() == null) {
				// remove empty entries
				wizPreFeeTiers.remove(i);
			}
		}
		sortFeeTiers(wizPreFeeTiers);

		// create new matrix only if wizPreFeeTiers was actually changed
		if (!isSameTiers(wizPreFeeTiers, wizPreFeeTiersCopy)) {
			copyArray(wizPreFeeTiers);
			wizFeeTiers = new ArrayList<FeeTier>(wizPreFeeTiers.size());
			for (FeeTier countTier : wizPreFeeTiers) {
				for (FeeTier sumTier : wizPreFeeTiers) {
					FeeTier tier = new FeeTier();
					tier.setId(fakeId--);
					tier.setCountThreshold(countTier.getCountThreshold());
					tier.setSumThreshold(sumTier.getSumThreshold());
					tier.setFeeId(activeFeeId);
					wizFeeTiers.add(tier);
				}
			}
			sortFeeTiers(wizFeeTiers);
			deleteDuplicates(wizFeeTiers);
		}
		wizardStep = 2;
	}

	private void copyArray(List<FeeTier> toCopy) {
		wizPreFeeTiersCopy = new ArrayList<FeeTier>(toCopy.size());
		try {
			for (FeeTier tier : toCopy) {
				wizPreFeeTiersCopy.add((FeeTier) tier.clone());
			}
		} catch (CloneNotSupportedException e) {
			// this should never happen :)
			logger.error("", e);
		}
	}

	private void deleteDuplicates(List<FeeTier> feeTiers) {
		// suppose that feeTiers are sorted 
		for (int i = feeTiers.size() - 1; i > 0; i--) {
			if (feeTiers.get(i).getCountThreshold().equals(feeTiers.get(i - 1).getCountThreshold())
					&& feeTiers.get(i).getSumThreshold().equals(feeTiers.get(i - 1).getSumThreshold())) {
				feeTiers.remove(i);
			}
		}
	}

	public void saveWizard() {
		if (dontSave) {
			storedFeeTiers = new ArrayList<FeeTier>(wizFeeTiers);
			sortFeeTiers(storedFeeTiers);
		} else {
			try {
				_feesDao.createFeeTiers(userSessionId, wizFeeTiers);
			} catch (Exception e) {
				logger.error("", e);
				FacesUtils.addMessageError(e);
			}
		}
		_feeTiersSource.flushCache();
	}

	public int getWizardStep() {
		return wizardStep;
	}

	public void setWizardStep(int wizardStep) {
		this.wizardStep = wizardStep;
	}

	public List<FeeTier> getWizFeeTiers() {
		return wizFeeTiers;
	}

	public void setWizFeeTiers(List<FeeTier> wizFeeTiers) {
		this.wizFeeTiers = wizFeeTiers;
	}

	public boolean isEmptyFeeTiers() {
		return storedFeeTiers == null || storedFeeTiers.size() == 0;
	}

	public boolean isLengthYear() {
		return _newFeeTier != null && LENGTH_TYPE_YEAR.equals(getNewFeeTier().getLengthType());
	}

	public int getPreTierIndex() {
		return preTierIndex;
	}

	public void setPreTierIndex(int preTierIndex) {
		this.preTierIndex = preTierIndex;
	}

	public List<FeeTier> getWizPreFeeTiers() {
		return wizPreFeeTiers;
	}

	public void setWizPreFeeTiers(List<FeeTier> wizPreFeeTiers) {
		this.wizPreFeeTiers = wizPreFeeTiers;
	}

	private boolean isSameTiers(List<FeeTier> tiersList1, List<FeeTier> tiersList2) {
		if (tiersList1 == null || tiersList2 == null) return false;
		if (tiersList1.size() != tiersList2.size()) return false;

		for (int i = 0; i < tiersList1.size(); i++) {
			if (!tiersList1.get(i).getCountThreshold()
					.equals(tiersList2.get(i).getCountThreshold())
					|| !tiersList1.get(i).getSumThreshold().equals(
					tiersList2.get(i).getSumThreshold())) {
				return false;
			}
		}

		return true;
	}

	public boolean isAllSet() {
		return feeCurrency != null && feeRateCalc != null;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub

	}

	public void initStoredFeeTiers() {
		if (activeFeeId == null) {
			return;
		}
		try {
			setRateFilters();
			SelectionParams params = new SelectionParams(tierFilters);
			params.setRowIndexStart(Integer.MIN_VALUE);
			params.setRowIndexEnd(Integer.MAX_VALUE);

			FeeTier[] rates = _feesDao.getFeeTiers(userSessionId, params);
			storedFeeTiers = Collections.synchronizedList(new ArrayList<FeeTier>(rates.length));
			initialFeeTiers = Collections.synchronizedList(new ArrayList<FeeTier>(rates.length));
			for (FeeTier rate : rates) {
				storedFeeTiers.add(rate);
				initialFeeTiers.add(rate);
			}
			sortFeeTiers(storedFeeTiers);
		} catch (Exception e) {
			storedFeeTiers = null;
			initialFeeTiers = null;
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public boolean isChanged() {
		if (initialFeeTiers == null)
			return storedFeeTiers != null;

		if (storedFeeTiers == null) return true;
		if (initialFeeTiers.isEmpty() && storedFeeTiers.isEmpty()) return false;
		if (initialFeeTiers.size() != storedFeeTiers.size()) return true;

		for (FeeTier tier : initialFeeTiers) {
			if (!storedFeeTiers.contains(tier)) {
				return true;
			}
		}
		return false;
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

	public boolean isFeeNeedsLengthType() {
		return feeNeedsLengthType;
	}
	public void setFeeNeedsLengthType(boolean feeNeedsLengthType) {
		this.feeNeedsLengthType = feeNeedsLengthType;
	}
}
