package ru.bpc.sv2.ui.network;

import java.util.ArrayList;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.invocation.SortElement.Direction;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.net.CardType;
import ru.bpc.sv2.net.LocalBinRange;
import ru.bpc.sv2.net.Network;
import ru.bpc.sv2.net.NetworkMember;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbLocalBinRanges")
public class MbLocalBinRanges extends AbstractBean {
	private static final long serialVersionUID = -971986124982372909L;

	private static final Logger logger = Logger.getLogger("NETWORKS");

	private static String COMPONENT_ID = "1270:binRangesTable";

	private NetworkDao _networksDao = new NetworkDao();

	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> cardTypes;

	private LocalBinRange filter;
	private LocalBinRange _activeLocalBinRange;
	private LocalBinRange newLocalBinRange;
	private String binNumber;
	private boolean syncLocalBinAfterUpdate;
	
	private final DaoDataModel<LocalBinRange> _binRangeSource;

	private final TableRowSelection<LocalBinRange> _itemSelection;

	public MbLocalBinRanges() {
		pageLink = "net|localBinranges";
		syncLocalBinAfterUpdate = true;
		_binRangeSource = new DaoDataModel<LocalBinRange>() {
			private static final long serialVersionUID = -1228269820926051891L;

			@Override
			protected LocalBinRange[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new LocalBinRange[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _networksDao.getLocalBinRanges(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new LocalBinRange[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _networksDao.getLocalBinRangesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<LocalBinRange>(null, _binRangeSource);
	}

	public DaoDataModel<LocalBinRange> getLocalBinRanges() {
		return _binRangeSource;
	}

	public LocalBinRange getActiveLocalBinRange() {
		return _activeLocalBinRange;
	}

	public void setActiveLocalBinRange(LocalBinRange activeLocalBinRange) {
		_activeLocalBinRange = activeLocalBinRange;
	}

	public SimpleSelection getItemSelection() {
		if (_activeLocalBinRange == null && _binRangeSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeLocalBinRange != null) {
			_binRangeSource.setRowKey(_activeLocalBinRange.getModelId());
			_activeLocalBinRange = (LocalBinRange) _binRangeSource.getRowData();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeLocalBinRange = _itemSelection.getSingleSelection();

		// set entry templates
		if (_activeLocalBinRange != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_binRangeSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeLocalBinRange = (LocalBinRange) _binRangeSource.getRowData();
		selection.addKey(_activeLocalBinRange.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeLocalBinRange != null) {
			setBeans();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
	}

	public void clearFilter() {
		filter = null;
		curLang = userLang;
		binNumber = null;

		clearBean();

		searching = false;
	}

	public void search() {
		curMode = VIEW_MODE;

		clearBean();
		searching = true;
	}

	private void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (binNumber != null && binNumber.trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("bin");
			paramFilter.setValue(binNumber.trim().toUpperCase().replaceAll("[*]", "%").replaceAll(
					"[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getCardTypeId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("cardTypeId");
			paramFilter.setValue(filter.getCardTypeId().toString());
			filters.add(paramFilter);
		}
		if (filter.getCountry() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("country");
			paramFilter.setValue(filter.getCountry());
			filters.add(paramFilter);
		}
		if (filter.getCardNetworkId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("cardNetworkId");
			paramFilter.setValue(filter.getCardNetworkId().toString());
			filters.add(paramFilter);
		}
		if (filter.getCardInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("cardInstId");
			paramFilter.setValue(filter.getCardInstId().toString());
			filters.add(paramFilter);
		}

	}

	public LocalBinRange getFilter() {
		if (filter == null) {
			filter = new LocalBinRange();
			filter.setCardInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(LocalBinRange filter) {
		this.filter = filter;
	}

	public void add() {
		newLocalBinRange = new LocalBinRange();
		newLocalBinRange.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newLocalBinRange = _activeLocalBinRange.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newLocalBinRange = _activeLocalBinRange;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isEditMode()) {
				newLocalBinRange = _networksDao.editLocalBinRange(userSessionId, newLocalBinRange);
				_binRangeSource.replaceObject(_activeLocalBinRange, newLocalBinRange);
			} else {
				newLocalBinRange = _networksDao.addLocalBinRange(userSessionId, newLocalBinRange);
				_itemSelection.addNewObjectToList(newLocalBinRange);
			}

			if (syncLocalBinAfterUpdate){
				synchronizeLocalBin();
			}
			
			_activeLocalBinRange = newLocalBinRange;
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Net",
					"bin_range_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void synchronizeLocalBin(){
		try{
			_networksDao.synchronizeLocalBein(userSessionId);
		} catch (DataAccessException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_networksDao.deleteLocalBinRange(userSessionId, _activeLocalBinRange);
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Net",
					"bin_range_deleted", "(ID = " + _activeLocalBinRange.getId() + ")"));

			_activeLocalBinRange = _itemSelection.removeObjectFromList(_activeLocalBinRange);
			
			if (syncLocalBinAfterUpdate){
				synchronizeLocalBin();
			}
			if (_activeLocalBinRange == null) {
				clearBean();
			} else {
				setBeans();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;

	}

	public LocalBinRange getNewLocalBinRange() {
		if (newLocalBinRange == null) {
			newLocalBinRange = new LocalBinRange();
		}
		return newLocalBinRange;
	}

	public void setNewLocalBinRange(LocalBinRange newLocalBinRange) {
		this.newLocalBinRange = newLocalBinRange;
	}

	public void clearBean() {
		_itemSelection.clearSelection();
		_activeLocalBinRange = null;
		_binRangeSource.flushCache();
	}

	public String getBinNumber() {
		return binNumber;
	}

	public void setBinNumber(String binNumber) {
		this.binNumber = binNumber;
	}

	public ArrayList<SelectItem> getNetworks() {
		SelectionParams params = new SelectionParams();
		Filter[] filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);

		SortElement[] sort = new SortElement[1];
		sort[0] = new SortElement("name", Direction.ASC);
		params.setSortElement(sort);

		params.setRowIndexEnd(-1);
		params.setFilters(filters);

		ArrayList<SelectItem> items = null;
		try {
			Network[] networks = _networksDao.getNetworks(userSessionId, params);
			items = new ArrayList<SelectItem>(networks.length);

			for (Network net : networks) {
				items.add(new SelectItem(net.getId(), net.getId() + " - " + net.getName()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}

		if (items == null) {
			return new ArrayList<SelectItem>(0);
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

	public ArrayList<SelectItem> getIssMembers() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		if (getNewLocalBinRange().getIssNetworkId() != null) {
			try {
				List<Filter> filtersMembers = new ArrayList<Filter>();

				Filter paramFilter = new Filter();
				paramFilter.setElement("lang");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(curLang);
				filtersMembers.add(paramFilter);

				paramFilter = new Filter();
				paramFilter.setElement("networkId");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(getNewLocalBinRange().getIssNetworkId().toString());
				filtersMembers.add(paramFilter);

				SelectionParams params = new SelectionParams();
				params.setRowIndexEnd(-1);
				params.setFilters(filtersMembers.toArray(new Filter[filtersMembers.size()]));

				NetworkMember[] members = _networksDao.getNetworkMembers(userSessionId, params);
				for (NetworkMember member : members) {
					items.add(new SelectItem(member.getInstId(), member.getInstId() + " - "
							+ member.getInstName()));
				}
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			} finally {
				if (items == null)
					items = new ArrayList<SelectItem>();
			}
		}
		return items;
	}

	public ArrayList<SelectItem> getCardMembers() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		if (getNewLocalBinRange().getCardNetworkId() != null) {
			try {
				List<Filter> filtersMembers = new ArrayList<Filter>();

				Filter paramFilter = new Filter();
				paramFilter.setElement("lang");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(curLang);
				filtersMembers.add(paramFilter);

				paramFilter = new Filter();
				paramFilter.setElement("networkId");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(getNewLocalBinRange().getCardNetworkId().toString());
				filtersMembers.add(paramFilter);

				SelectionParams params = new SelectionParams();
				params.setRowIndexEnd(-1);
				params.setFilters(filtersMembers.toArray(new Filter[filtersMembers.size()]));

				NetworkMember[] members = _networksDao.getNetworkMembers(userSessionId, params);
				for (NetworkMember member : members) {
					items.add(new SelectItem(member.getInstId(), member.getInstId() + " - "
							+ member.getInstName()));
				}
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			} finally {
				if (items == null)
					items = new ArrayList<SelectItem>();
			}
		}
		return items;
	}

	public ArrayList<SelectItem> getCardTypes() {
		if (cardTypes == null) {

			ArrayList<SelectItem> items = new ArrayList<SelectItem>();
			try {
				List<Filter> filtersCardTypes = new ArrayList<Filter>();

				Filter paramFilter = new Filter();
				paramFilter.setElement("lang");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(curLang);
				filtersCardTypes.add(paramFilter);

				SelectionParams params = new SelectionParams();
				params.setRowIndexEnd(-1);
				params.setFilters(filtersCardTypes.toArray(new Filter[filtersCardTypes.size()]));

				CardType[] types = _networksDao.getCardTypes(userSessionId, params);
				for (CardType type : types) {
					String name = type.getName();
					for (int i = 1; i < type.getLevel(); i++) {
						name = " -- " + name;
					}
					items.add(new SelectItem(type.getId(), type.getId() + " - " + name, type
							.getName()));
				}
				cardTypes = items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			} finally {
				if (cardTypes == null)
					cardTypes = new ArrayList<SelectItem>();
			}
		}
		return cardTypes;
	}

	public boolean isSyncLocalBinAfterUpdate() {
		return syncLocalBinAfterUpdate;
	}

	public void setSyncLocalBinAfterUpdate(boolean syncLocalBinAfterUpdate) {
		this.syncLocalBinAfterUpdate = syncLocalBinAfterUpdate;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

}
