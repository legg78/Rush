package ru.bpc.sv2.ui.cmn;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.cmn.CmnStandard;
import ru.bpc.sv2.cmn.Profile;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommunicationDao;
import ru.bpc.sv2.rules.CommunicationConstants;
import ru.bpc.sv2.ui.acquiring.MbTerminalTemplates;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbProfiles")
public class MbProfiles extends AbstractBean {
	private static final long serialVersionUID = -7665235196228197719L;

	private static final Logger logger = Logger.getLogger("COMMUNICATION");

	private static String COMPONENT_ID = "profilesTable";

	private CommunicationDao _cmnDao = new CommunicationDao();

	
	private MbTerminalTemplates terminalTemplates;

	private Profile filter;
	private Profile newProfile;
	private boolean blockEdit = false;

	private final DaoDataModel<Profile> _profilesSource;
	private final TableRowSelection<Profile> _itemSelection;
	private Profile _activeProfile;
	private ArrayList<SelectItem> institutions;

	public MbProfiles() {
		
		terminalTemplates = (MbTerminalTemplates) ManagedBeanWrapper
				.getManagedBean("MbTerminalTemplates");
		terminalTemplates.setSlaveMode(true);

		_profilesSource = new DaoDataModel<Profile>() {
			private static final long serialVersionUID = 4741771840224797467L;

			@Override
			protected Profile[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Profile[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _cmnDao.getProfiles(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Profile[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _cmnDao.getProfilesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Profile>(null, _profilesSource);
	}

	public DaoDataModel<Profile> getProfiles() {
		return _profilesSource;
	}

	public Profile getActiveProfile() {
		return _activeProfile;
	}

	public void setActiveProfile(Profile activeProfile) {
		_activeProfile = activeProfile;
	}

	public SimpleSelection getItemSelection() {
		if (_activeProfile == null && _profilesSource.getRowCount() > 0) {
			blockEdit = false;
			setFirstRowActive();
		} else if (_activeProfile != null && _profilesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeProfile.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeProfile = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		blockEdit = false;

		_itemSelection.setWrappedSelection(selection);
		_activeProfile = _itemSelection.getSingleSelection();

		if (_activeProfile != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_profilesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeProfile = (Profile) _profilesSource.getRowData();
		selection.addKey(_activeProfile.getModelId());
		_itemSelection.setWrappedSelection(selection);

		if (_activeProfile != null) {
			setBeans();
		}
	}

	public void setBeans() {
		MbCmnParamValues values = (MbCmnParamValues) ManagedBeanWrapper
				.getManagedBean("MbCmnParamValues");
		values.fullCleanBean();
		values.setValuesEntityType(EntityNames.STANDARD_PROFILE);
		// values.setInstId(_activeProfile.getInstId());
		values.setObjectId(_activeProfile.getId().longValue());
		values.setStandardId(_activeProfile.getStandardId());
		values.search();

		terminalTemplates.clearFilter();
		terminalTemplates.getFilter().setProfileId(_activeProfile.getId());
		if (terminalTemplates.loadTerminalTemplate() == null) {
			FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
					"ru.bpc.sv2.ui.bundles.Cmn", "no_template_for_profile")));
			blockEdit = true;
		}
	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		filter = null;
		searching = false;
		
		clearBean();
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}
		if (filter.getCaption() != null
				&& filter.getCaption().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("caption");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getCaption().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void add() {
		newProfile = new Profile();
		newProfile.setLang(userLang);
		curMode = NEW_MODE;

		terminalTemplates.add();
	}

	public void edit() {
		try {
			newProfile = _activeProfile.clone();
		} catch (CloneNotSupportedException e) {
			newProfile = _activeProfile;
		}
		curMode = EDIT_MODE;

		terminalTemplates.edit();
	}

	public void delete() {
		try {
			_cmnDao.deleteProfileExt(userSessionId, _activeProfile, terminalTemplates
					.getActiveTemplate());
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Cmn",
					"profile_deleted", "(id = " + _activeProfile.getId() + ")");

			_activeProfile = _itemSelection.removeObjectFromList(_activeProfile);
			if (_activeProfile == null) {
				clearBean();
			} else {
				setBeans();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
		}
	}

	public void save() {
		// set undefined fields for terminal template
		terminalTemplates.getNewTemplate().setLang(newProfile.getLang());
		terminalTemplates.getNewTemplate().setInstId(newProfile.getInstId());

		try {
			if (isNewMode()) {
				newProfile = _cmnDao.addProfileExt(userSessionId, newProfile,
						terminalTemplates.getNewTemplate());
				_itemSelection.addNewObjectToList(newProfile);
			} else {
				newProfile = _cmnDao.editProfileExt(userSessionId, newProfile,
						terminalTemplates.getNewTemplate());
				_profilesSource.replaceObject(_activeProfile, newProfile);
			}
			_activeProfile = newProfile;
			setBeans();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Cmn",
					"profile_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public Profile getFilter() {
		if (filter == null) {
			filter = new Profile();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(Profile profileFilter) {
		this.filter = profileFilter;
	}

	public Profile getnewProfile() {
		if (newProfile == null) {
			newProfile = new Profile();
		}
		return newProfile;
	}

	public void setnewProfile(Profile newProfile) {
		this.newProfile = newProfile;
	}

	public void clearBean() {
		_profilesSource.flushCache();
		_itemSelection.clearSelection();
		_activeProfile = null;

		// clear dependent bean
		clearBeansStates();
	}

	private void clearBeansStates() {
		terminalTemplates.clearState();
		
		MbCmnParamValues values = (MbCmnParamValues) ManagedBeanWrapper
				.getManagedBean("MbCmnParamValues");
		values.fullCleanBean();
	}
	
	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeProfile.getId().toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			Profile[] standards = _cmnDao.getProfiles(userSessionId, params);
			if (standards != null && standards.length > 0) {
				_activeProfile = standards[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error(e.getMessage(), e);
		}
	}

	public ArrayList<SelectItem> getStandards() {
		ArrayList<SelectItem> items;

		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(-1);
		List<Filter> filtersStd = new ArrayList<Filter>();
		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filtersStd.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("standardType");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(CommunicationConstants.TERMINAL_CMN_STANDARD);
		filtersStd.add(paramFilter);

		params.setFilters(filtersStd.toArray(new Filter[filtersStd.size()]));
		CmnStandard[] stds;
		try {
			stds = _cmnDao.getCommStandards(userSessionId, params);
		} catch (Exception e) {
			logger.error("", e);
			return new ArrayList<SelectItem>(0);
		}

		items = new ArrayList<SelectItem>();
		for (CmnStandard std : stds) {
			items.add(new SelectItem(std.getId(), std.getLabel() != null ? std.getLabel()
					: ("{ID = " + std.getId() + "}")));
		}

		return items;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public boolean isBlockEdit() {
		return blockEdit;
	}

	public void setBlockEdit(boolean blockEdit) {
		this.blockEdit = blockEdit;
	}
	
	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newProfile.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newProfile.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Profile[] profiles = _cmnDao.getProfiles(userSessionId, params);
			if (profiles != null && profiles.length > 0) {
				newProfile = profiles[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

}
