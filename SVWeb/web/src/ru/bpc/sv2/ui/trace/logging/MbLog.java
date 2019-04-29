package ru.bpc.sv2.ui.trace.logging;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.trace.logging.Trail;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbLog")
public class MbLog extends AbstractBean {

	private Trail _activeTrail;

	private final DaoDataModel<Trail> _logTrailsSource;

	private final TableRowSelection<Trail> _itemSelection;
	private Trail filter;
	

	public MbLog() {
		
		_logTrailsSource = new DaoDataModel<Trail>() {
			@Override
			protected Trail[] loadDaoData(SelectionParams params) {
				try {
					if (!isSearching()) {
						return new Trail[0];
					}
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
//							return _commonDao.getLogTrails( userSessionId, params);
				} catch (DataAccessException ee) {
					FacesUtils.addMessageError(ee);
				} finally {

				}
				return new Trail[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				try {
					if (!isSearching()) {
						return 0;
					}
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
//							return _commonDao.getLogTrailsCount( userSessionId, params);
				} catch (DataAccessException ee) {
					FacesUtils.addMessageError(ee);
				} finally {

				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Trail>(null, _logTrailsSource);
	}

	public DaoDataModel<Trail> getLogTrails() {
		return _logTrailsSource;
	}

	public Trail getActiveTrail() {
		return _activeTrail;
	}

	public void setActiveTrail(Trail activeTrail) {
		_activeTrail = activeTrail;
	}

	public SimpleSelection getItemSelection() {
		if (_activeTrail == null && _logTrailsSource.getRowCount() > 0) {
			_logTrailsSource.setRowIndex(0);
			SimpleSelection selection = new SimpleSelection();
			_activeTrail = (Trail) _logTrailsSource.getRowData();
			selection.addKey(_activeTrail.getModelId());
			_itemSelection.setWrappedSelection(selection);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeTrail = _itemSelection.getSingleSelection();
//		if (_activeTrail != null) {
//			MbLogTrailDetails trailDetailsBean = (MbLogTrailDetails)ManagedBeanWrapper.getManagedBean("MbLogTrailDetails");
//			TrailDetails trailDetails = new TrailDetails();
//			trailDetails.setCycleId(Integer.toString(_activeTrail.getId()));
//			trailDetailsBean.setFilter(trailDetails);
//			trailDetailsBean.search();
//		}
	}

	public void search() {
		setSearching(true);
		_activeTrail = null;
		_logTrailsSource.flushCache();
	}

	public void setFilters() {
		String dbDateFormat = "dd.MM.yyyy";
		SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
		List<Filter> filtersList = new ArrayList<Filter>();
		if (getFilter().getEntityType() != null && !getFilter().getEntityType().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getEntityType());
			filtersList.add(paramFilter);
		}
		if (getFilter().getActionType() != null && !getFilter().getActionType().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("actionType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getActionType());
			filtersList.add(paramFilter);
		}
		if (getFilter().getActionDateFrom() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("actionDateFrom");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(df.format(getFilter().getActionDateFrom()));
			filtersList.add(paramFilter);
		}
		if (getFilter().getActionDateTo() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("actionDateTo");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(df.format(getFilter().getActionDateTo()));
			filtersList.add(paramFilter);
		}
		if (getFilter().getUserId() != null && !getFilter().getUserId().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("userId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getUserId());
			filtersList.add(paramFilter);
		}
		if (getFilter().getObjectId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("objectId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getObjectId().toString());
			filtersList.add(paramFilter);
		}
		if (getFilter().getSessionId() != null && !getFilter().getSessionId().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("sessionId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getSessionId());
			filtersList.add(paramFilter);
		}

		filters = filtersList;
	}

	public Trail getFilter() {
		if (filter == null) {
			filter = new Trail();
		}
		return filter;
	}

	public void setFilter(Trail filter) {
		this.filter = filter;
	}

	public List<SelectItem> getEntityTypes() {
		return getDictUtils().getLov(LovConstants.ENTITY_TYPES);
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub

	}

}
