package ru.bpc.sv2.ui.acquiring.reimbursement;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.acquiring.reimbursement.ReimbursementChannel;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbReimbChannelSearch")
public class MbReimbChannelSearch extends AbstractBean{

	private static String COMPONENT_ID = "1113:mainTable";

	private AcquiringDao _acquiringDao = new AcquiringDao();

	private ReimbursementChannel _activeChannel;
	private ReimbursementChannel newChannel;
	private ReimbursementChannel detailChannel;
	
	private ReimbursementChannel filter;
	private String backLink;
	private boolean showModal;
	private boolean selectMode;
	private MbReimbChannel reimbBean;
	private boolean bottomMode;
	private ArrayList<SelectItem> institutions;

	private final DaoDataModel<ReimbursementChannel> _channelsSource;

	private final TableRowSelection<ReimbursementChannel> _itemSelection;
	private static final Logger logger = Logger.getLogger("ACQUIRING");

	public MbReimbChannelSearch() {
		pageLink = "acquiring|reimbursement|list_channels";
		bottomMode = false;
		
		reimbBean = (MbReimbChannel) ManagedBeanWrapper.getManagedBean("MbReimbChannel");

		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		if (!menu.isKeepState()) {
			reimbBean.setTabName("");
		} else {
			_activeChannel = reimbBean.getReimbursementChannel();
			try {
				detailChannel = (ReimbursementChannel) _activeChannel.clone();
			} catch (CloneNotSupportedException e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
			backLink = reimbBean.getBackLink();
			searching = reimbBean.isSearching();
		}

		_channelsSource = new DaoDataModel<ReimbursementChannel>() {
			@Override
			protected ReimbursementChannel[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new ReimbursementChannel[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));

					return _acquiringDao.getReimbursementChannels(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ReimbursementChannel[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching())
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));

					return _acquiringDao.getReimbursementChannelsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		if (_activeChannel != null) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeChannel.getModelId());
			_itemSelection = new TableRowSelection<ReimbursementChannel>(selection, _channelsSource);
			setInfo();
		} else {
			_itemSelection = new TableRowSelection<ReimbursementChannel>(null, _channelsSource);
		}
	}

	public DaoDataModel<ReimbursementChannel> getChannels() {
		return _channelsSource;
	}

	public ReimbursementChannel getActiveChannel() {
		return _activeChannel;
	}

	public void setActiveChannel(ReimbursementChannel activeChannel) {
		_activeChannel = activeChannel;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeChannel == null && _channelsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeChannel != null && _channelsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeChannel.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeChannel = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		if (_activeChannel == null && _channelsSource.getRowCount() > 0) {
			_channelsSource.setRowIndex(0);
			SimpleSelection selection = new SimpleSelection();
			_activeChannel = (ReimbursementChannel) _channelsSource.getRowData();
			selection.addKey(_activeChannel.getModelId());
			_itemSelection.setWrappedSelection(selection);
			reimbBean.setReimbursementChannel(_activeChannel);
			setInfo();
			detailChannel = (ReimbursementChannel) _activeChannel.clone();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null 
					&& !_itemSelection.getSingleSelection().getId().equals(_activeChannel.getId())) {
				changeSelect = true;
			}
			_activeChannel = _itemSelection.getSingleSelection();
			if (changeSelect) {
				detailChannel = (ReimbursementChannel) _activeChannel.clone();
			}
			reimbBean.setReimbursementChannel(_activeChannel);
			setInfo();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
	}

	public void setInfo() {
		// MbProcessFilesSearch procFileBean =
		// (MbProcessFilesSearch)ManagedBeanWrapper.getManagedBean("MbProcessFilesSearch");
		if (_activeChannel != null) {

		}
	}

	public void search() {
		setSearching(true);
		_channelsSource.flushCache();
		_activeChannel = null;
		reimbBean.setFilter(filter);
	}

	public void clearBean() {
		_channelsSource.flushCache();

		_itemSelection.clearSelection();
		_activeChannel = null;
		detailChannel = null;
		// TODO clear dependent bean
	}

	public void clearFilter() {
		filter = new ReimbursementChannel();
		clearBean();
		searching = false;
	}
	
	public void setFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();

		if (getFilter().getName() != null && !getFilter().getName().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getName());
			filtersList.add(paramFilter);
		}
		if (getFilter().getChannelNumber() != null && !getFilter().getChannelNumber().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("channelNumber");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getChannelNumber());
			filtersList.add(paramFilter);
		}
		if (getFilter().getPaymentMode() != null && !getFilter().getPaymentMode().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("paymentMode");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getPaymentMode());
			filtersList.add(paramFilter);
		}
		if (getFilter().getCurrency() != null && !getFilter().getCurrency().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("currency");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getCurrency());
			filtersList.add(paramFilter);
		}
		if (getFilter().getInstId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getInstId().toString());
			filtersList.add(paramFilter);
		}
		if (getFilter().getId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getId().toString());
			filtersList.add(paramFilter);
		}

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filtersList.add(paramFilter);

		filters = filtersList;
	}

	public ReimbursementChannel getFilter() {
		if (filter == null)
			filter = new ReimbursementChannel();
		return filter;
	}

	public void setFilter(ReimbursementChannel filter) {
		this.filter = filter;
	}

	public void create() {
		try {
			curMode = NEW_MODE;
			newChannel = new ReimbursementChannel();
			newChannel.setInstId(getFilter().getInstId());
			newChannel.setLang(userLang);
			curLang = newChannel.getLang();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void edit() {
		try {
			newChannel = (ReimbursementChannel) detailChannel.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				newChannel = _acquiringDao.addReimbursementChannel(userSessionId, newChannel);
				detailChannel = (ReimbursementChannel) newChannel.clone();
				_itemSelection.addNewObjectToList(newChannel);
			} else {
				newChannel = _acquiringDao.modifyReimbursementChannel(userSessionId, newChannel);
				detailChannel = (ReimbursementChannel) newChannel.clone();
				if (!userLang.equals(newChannel.getLang())) {
					newChannel = getNodeByLang(_activeChannel.getId(), userLang);
				}
				_channelsSource.replaceObject(_activeChannel, newChannel);
			}
			_activeChannel = newChannel;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_acquiringDao.removeReimbursementChannel(userSessionId, _activeChannel);
			_activeChannel = _itemSelection.removeObjectFromList(_activeChannel);
			if (_activeChannel == null) {
				clearBean();
			} else {
				setInfo();
				detailChannel = (ReimbursementChannel) _activeChannel.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isShowModal() {
		return showModal;
	}

	public void setShowModal(boolean showModal) {
		this.showModal = showModal;
	}

	public String cancelSelect() {
		return backLink;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public void clearState() {
		if (_itemSelection.getWrappedSelection() != null) {
			_itemSelection.clearSelection();
		}
	}

	public ArrayList<SelectItem> getPaymentModes() {
		return getDictUtils().getArticles(DictNames.PROCESS_FILE_TYPE, false, false);
	}

	public boolean isBottomMode() {
		return bottomMode;
	}

	public void setBottomMode(boolean bottomMode) {
		this.bottomMode = bottomMode;
	}

	public String selectProcess() {

		return backLink;
	}

	/**
	 * This method return a list of institutions. During Ajax requests list is
	 * not reread from DB. New request to DB happens only if managed bean has
	 * been recreated
	 * 
	 * @return
	 */
	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public ReimbursementChannel getNewChannel() {
		return newChannel;
	}

	public void setNewChannel(ReimbursementChannel newChannel) {
		this.newChannel = newChannel;
	}

	public boolean isManagingNew() {
		return isNewMode();
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailChannel = getNodeByLang(detailChannel.getId(), curLang);
	}
	
	public void confirmEditLanguage() {
		curLang = newChannel.getLang();
		ReimbursementChannel tmp = getNodeByLang(newChannel.getId(), newChannel.getLang());
		if (tmp != null) {
			newChannel.setName(tmp.getName());
		}
	}
	
	public ReimbursementChannel getNodeByLang(Integer id, String lang) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(id);
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(lang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			ReimbursementChannel[] channels = _acquiringDao.getReimbursementChannels(userSessionId, params);
			if (channels != null && channels.length > 0) {
				return channels[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public ReimbursementChannel getDetailChannel() {
		return detailChannel;
	}

	public void setDetailChannel(ReimbursementChannel detailChannel) {
		this.detailChannel = detailChannel;
	}
	
}
