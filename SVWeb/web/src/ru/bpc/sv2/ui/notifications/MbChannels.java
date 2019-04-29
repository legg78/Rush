package ru.bpc.sv2.ui.notifications;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.NotificationsDao;
import ru.bpc.sv2.notifications.Channel;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbChannels")
public class MbChannels extends AbstractBean{
	private static final Logger logger = Logger.getLogger("NOTIFICATION");

	private static String COMPONENT_ID = "1594:channelsTable";

	private NotificationsDao _notificationsDao = new NotificationsDao();

	

	private Channel filter;
	private Channel newChannel;
	private Channel detailChannel;

	private final DaoDataModel<Channel> _channelSource;
	private final TableRowSelection<Channel> _itemSelection;
	private Channel _activeChannel;
	private String tabName;
	private ArrayList<SelectItem> institutions;

	public MbChannels() {
		
		pageLink = "notifications|channels";
		_channelSource = new DaoDataModel<Channel>() {
			@Override
			protected Channel[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Channel[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _notificationsDao.getChannels(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Channel[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _notificationsDao.getChannelsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Channel>(null, _channelSource);
	}

	public DaoDataModel<Channel> getChannels() {
		return _channelSource;
	}

	public Channel getActiveChannel() {
		return _activeChannel;
	}

	public void setActiveChannel(Channel activeChannel) {
		_activeChannel = activeChannel;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeChannel == null && _channelSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeChannel != null && _channelSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeChannel.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeChannel = _itemSelection.getSingleSelection();
				setBeans();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
		return _itemSelection.getWrappedSelection();
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
	
			if (_activeChannel != null) {
				setBeans();
				if (changeSelect) {
					detailChannel = (Channel) _activeChannel.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_channelSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeChannel = (Channel) _channelSource.getRowData();
		selection.addKey(_activeChannel.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeChannel != null) {
			setBeans();
			detailChannel = (Channel) _activeChannel.clone();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
	}

	public void search() {

		clearBean();
		searching = true;
		curLang = userLang;
	}

	public void clearFilter() {
		curLang = userLang;
		filter = new Channel();
		searching = false;

	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}
		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().toUpperCase().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getAddressPattern() != null && filter.getAddressPattern().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("addressPattern");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getAddressPattern().trim().toUpperCase().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getAddressSource() != null && filter.getAddressSource().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("addressSource");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getAddressSource().trim().toUpperCase().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void add() {
		newChannel = new Channel();
		newChannel.setLang(userLang);
		curLang = newChannel.getLang();
		if (filter.getInstId() != null) {
			newChannel.setInstId(filter.getInstId());
		}
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newChannel = (Channel) detailChannel.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newChannel = _activeChannel;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_notificationsDao.deleteChannel(userSessionId, _activeChannel);

			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Ntf", "channel_deleted",
					"(id = " + _activeChannel.getId() + ")");

			_activeChannel = _itemSelection.removeObjectFromList(_activeChannel);
			if (_activeChannel == null) {
				clearBean();
			} else {
				setBeans();
				detailChannel = (Channel) _activeChannel.clone();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newChannel = _notificationsDao.addChannel(userSessionId, newChannel);
				detailChannel = (Channel) newChannel.clone();
				_itemSelection.addNewObjectToList(newChannel);
			} else {
				newChannel = _notificationsDao.editChannel(userSessionId, newChannel);
				detailChannel = (Channel) newChannel.clone();
				if (!userLang.equals(newChannel.getLang())) {
					newChannel = getNodeByLang(_activeChannel.getId(), userLang);
				}
				_channelSource.replaceObject(_activeChannel, newChannel);
			}
			_activeChannel = newChannel;
			setBeans();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Ntf",
					"channel_saved"));

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public Channel getFilter() {
		if (filter == null) {
			filter = new Channel();
		}
		return filter;
	}

	public void setFilter(Channel filter) {
		this.filter = filter;
	}

	public Channel getNewChannel() {
		if (newChannel == null) {
			newChannel = new Channel();
		}
		return newChannel;
	}

	public void setNewChannel(Channel newChannel) {
		this.newChannel = newChannel;
	}

	public void clearBean() {
		_channelSource.flushCache();
		_itemSelection.clearSelection();
		_activeChannel = null;
		detailChannel = null;
		// clear dependent bean
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void changeLanguage(ValueChangeEvent event) {
		if (_activeChannel != null) {
			curLang = (String) event.getNewValue();
			detailChannel = getNodeByLang(detailChannel.getId(), curLang);
		}
	}
	
	public Channel getNodeByLang(Integer id, String lang) {
		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(id.toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(lang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			Channel[] devices = _notificationsDao.getChannels(userSessionId, params);
			if (devices != null && devices.length > 0) {
				return devices[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public void confirmEditLanguage() {
		curLang = newChannel.getLang();
		Channel tmp = getNodeByLang(newChannel.getId(), newChannel.getLang());
		if (tmp != null) {
			newChannel.setName(tmp.getName());
			newChannel.setDescription(tmp.getDescription());
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public Channel getDetailChannel() {
		return detailChannel;
	}

	public void setDetailChannel(Channel detailChannel) {
		this.detailChannel = detailChannel;
	}

}
