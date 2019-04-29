package ru.bpc.sv2.ui.rules.disputes;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.DspScale;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean(name = "MbDspScales")
public class MbDspScales extends AbstractBean {
	private static final long serialVersionUID = 1L;
	private static final String COMPONENT_ID = "2417:dspScaleSelectionTable";

	private static final Logger logger = Logger.getLogger("RULES");

	private RulesDao rulesDao = new RulesDao();

	private DspScale filter;
	private DspScale activeDspScale;
	private DspScale newDspScale;
	private DspScale detailDspScale;

	private ArrayList<SelectItem> scaleTypes;
	private ArrayList<SelectItem> modifiers;

	private String scaleType;
	private boolean updateModifiers;

	private final DaoDataModel<DspScale> dspScaleSource;
	private final TableRowSelection<DspScale> itemSelection;

	public MbDspScales() {
		thisBackLink = "dispute|scaleSelection";
		dspScaleSource = new DaoDataModel<DspScale>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected DspScale[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new DspScale[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return rulesDao.getDspScales(userSessionId, params);
				}
				catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new DspScale[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return rulesDao.getDspScalesCount(userSessionId, params);
				}
				catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		itemSelection = new TableRowSelection<DspScale>(null, dspScaleSource);
	}

	public SimpleSelection getItemSelection() {
		try {
			if (activeDspScale == null && dspScaleSource.getRowCount() > 0) {
				setFirstRowActive();
			}
			else if (activeDspScale != null && dspScaleSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(activeDspScale.getModelId());
				itemSelection.setWrappedSelection(selection);
				activeDspScale = itemSelection.getSingleSelection();
			}
		}
		catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		itemSelection.setWrappedSelection(selection);
		activeDspScale = itemSelection.getSingleSelection();
		if (activeDspScale != null) {
			try {
				detailDspScale = (DspScale) activeDspScale.clone();
			}
			catch (CloneNotSupportedException e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		dspScaleSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeDspScale = (DspScale) dspScaleSource.getRowData();
		selection.addKey(activeDspScale.getModelId());
		itemSelection.setWrappedSelection(selection);
		if (activeDspScale != null) {
			detailDspScale = (DspScale) activeDspScale.clone();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void clearFilter() {
		filter = null;
		curLang = userLang;
		clearBean();
		searching = false;
	}

	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		searching = true;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>() {{
			if (filter.getId() != null) {
				add(new Filter("id", filter.getId()));
			}
			if (filter.getSeqnum() != null) {
				add(new Filter("seqnum", filter.getSeqnum()));
			}
			if (StringUtils.isNotEmpty(filter.getScaleType())) {
				add(new Filter("scaleType", filter.getScaleType()));
			}
			if (StringUtils.isNotEmpty(filter.getLabel())) {
				add(new Filter("label", filter.getLabel().toUpperCase().replace('*', '%')));
			}
			if (StringUtils.isNotEmpty(filter.getDescription())) {
				add(new Filter("description", filter.getDescription().toUpperCase().replace('*', '%')));
			}
			if (filter.getModId() != null) {
				add(new Filter("modId", filter.getModId()));
			}
			if (StringUtils.isNotEmpty(filter.getModName())) {
				add(new Filter("modName", filter.getModName().toUpperCase().replace('*', '%')));
			}
			if (filter.getInitRuleId() != null) {
				add(new Filter("initRuleId", filter.getInitRuleId()));
			}
			if (StringUtils.isNotEmpty(filter.getInitRuleName())) {
				add(new Filter("initRuleName", filter.getInitRuleName().toUpperCase().replace('*', '%')));
			}
			add(new Filter("lang", userLang));
		}};
	}

	public void add() {
		newDspScale = new DspScale() {{
			setLang(userLang);
		}};
		curLang = userLang;
		curMode = NEW_MODE;
		modifiers = new ArrayList<SelectItem>();
	}

	public void edit() {
		try {
			newDspScale = (DspScale) detailDspScale.clone();
			scaleType = newDspScale.getScaleType();
			updateModifiers = true;
		}
		catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isEditMode()) {
				newDspScale = rulesDao.modifyDspScale(userSessionId, newDspScale);
				detailDspScale = (DspScale) newDspScale.clone();
				if (!userLang.equals(newDspScale.getLang())) {
					newDspScale = getNodeByLang(activeDspScale.getId(), userLang);
				}
				dspScaleSource.replaceObject(activeDspScale, newDspScale);
			}
			else {
				newDspScale = rulesDao.addDspScale(userSessionId, newDspScale);
				detailDspScale = (DspScale) newDspScale.clone();
				itemSelection.addNewObjectToList(newDspScale);
			}
			activeDspScale = newDspScale;
			curMode = VIEW_MODE;
		}
		catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}

	}

	public void delete() {
		try {
			rulesDao.deleteDspScale(userSessionId, activeDspScale);
			curMode = VIEW_MODE;
			activeDspScale = itemSelection.removeObjectFromList(activeDspScale);
			if (activeDspScale == null) {
				clearBean();
			}
			else {
				detailDspScale = (DspScale) activeDspScale.clone();
			}
		}
		catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}

	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailDspScale = getNodeByLang(detailDspScale.getId(), curLang);
	}

	public DspScale getNodeByLang(final Integer id, final String lang) {
		try {
			DspScale[] dspScales = rulesDao.getDspScales(userSessionId, new SelectionParams() {{
				setFilters(new Filter("id", id), new Filter("lang", lang));
			}});
			if (dspScales != null && dspScales.length > 0) {
				return dspScales[0];
			}
		}
		catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public void clearBean() {
		itemSelection.clearSelection();
		activeDspScale = null;
		detailDspScale = null;
		dspScaleSource.flushCache();
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public DspScale getDetailDspScale() {
		return detailDspScale;
	}

	public void setDetailDspScale(DspScale detailDspScale) {
		this.detailDspScale = detailDspScale;
	}

	public ArrayList<SelectItem> getScaleTypes() {
		if (scaleTypes == null) {
			scaleTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.SCALE_TYPE);
		}
		return scaleTypes;
	}

	public ArrayList<SelectItem> getModifiers() {
		if (scaleType == null) {
			modifiers = new ArrayList<SelectItem>();
			return modifiers;
		}
		if (modifiers == null || updateModifiers) {
			Map<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("SCALE_TYPE", scaleType);
			modifiers = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.MODIFIER_LIST, paramMap);
			updateModifiers = false;
		}
		return modifiers;
	}

	public void changeScaleType(ValueChangeEvent event) {
		scaleType = (String) event.getNewValue();
		updateModifiers = true;
	}

	public DaoDataModel<DspScale> getDspScales() {
		return dspScaleSource;
	}

	public DspScale getActiveDspScale() {
		return activeDspScale;
	}

	public void setActiveModScale(DspScale activeDspScale) {
		this.activeDspScale = activeDspScale;
	}

	public DspScale getFilter() {
		if (filter == null) {
			filter = new DspScale();
		}
		return filter;
	}

	public void setFilter(DspScale filter) {
		this.filter = filter;
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public DspScale getNewDspScale() {
		if (newDspScale == null) {
			newDspScale = new DspScale();
		}
		return newDspScale;
	}

	public void setNewDspScale(DspScale newDspScale) {
		this.newDspScale = newDspScale;
	}
}
