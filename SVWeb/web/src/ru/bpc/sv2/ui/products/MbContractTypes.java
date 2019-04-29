package ru.bpc.sv2.ui.products;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.ContractType;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbContractTypes")
public class MbContractTypes extends AbstractBean{
	private static final Logger logger = Logger.getLogger("PRODUCTS");

	private static String COMPONENT_ID = "1841:contractTypesTable";

	private ProductsDao _productsDao = new ProductsDao();

	private ContractType filter;
	private ContractType newContractType;
	

	private final DaoDataModel<ContractType> _contractTypesSource;
	private final TableRowSelection<ContractType> _itemSelection;
	private ContractType _activeContractType;

	private ArrayList<SelectItem> institutions;

	public MbContractTypes() {
		
		pageLink = "products|contractTypes";
		_contractTypesSource = new DaoDataModel<ContractType>() {
			@Override
			protected ContractType[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new ContractType[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _productsDao.getContractTypes(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return new ContractType[0];
				}
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _productsDao.getContractTypesCount(userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return 0;
				}
			}
		};

		_itemSelection = new TableRowSelection<ContractType>(null, _contractTypesSource);
	}

	public DaoDataModel<ContractType> getContractTypes() {
		return _contractTypesSource;
	}

	public ContractType getActiveContractType() {
		return _activeContractType;
	}

	public void setActiveContractType(ContractType activeContractType) {
		_activeContractType = activeContractType;
	}

	public SimpleSelection getItemSelection() {
		if (_activeContractType == null && _contractTypesSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeContractType != null && _contractTypesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeContractType.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeContractType = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeContractType = _itemSelection.getSingleSelection();

		if (_activeContractType != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_contractTypesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeContractType = (ContractType) _contractTypesSource.getRowData();
		selection.addKey(_activeContractType.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
	}

	public void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}
		if (filter.getLabel() != null && filter.getLabel().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("label");
			paramFilter.setValue(filter.getLabel().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getContractType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("contractType");
			paramFilter.setValue(filter.getContractType().toString());
			filters.add(paramFilter);
		}
		if (filter.getCustomerEntityType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("customerEntityType");
			paramFilter.setValue(filter.getCustomerEntityType().toString());
			filters.add(paramFilter);
		}
		if (filter.getProductType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("productType");
			paramFilter.setValue(filter.getProductType().toString());
			filters.add(paramFilter);
		}
	}

	public ContractType getFilter() {
		if (filter == null) {
			filter = new ContractType();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(ContractType filter) {
		this.filter = filter;
	}

	public void clearFilter() {
		filter = null;
		clearBean();

		searching = false;
	}

	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		searching = true;
	}

	public void add() {
		newContractType = new ContractType();
		newContractType.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void delete() {
		try {
			_productsDao.removeContractType(userSessionId, _activeContractType);

			_activeContractType = _itemSelection.removeObjectFromList(_activeContractType);
			if (_activeContractType == null) {
				clearBean();
			} else {
				setBeans();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			newContractType = _productsDao.addContractType(userSessionId, newContractType);
			_itemSelection.addNewObjectToList(newContractType);
			_activeContractType = newContractType;
			curMode = VIEW_MODE;
			setBeans();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public ContractType getNewContractType() {
		if (newContractType == null) {
			newContractType = new ContractType();
		}
		return newContractType;
	}

	public void setNewContractType(ContractType newContractType) {
		this.newContractType = newContractType;
	}

	public void clearBean() {
		curLang = userLang;
		_contractTypesSource.flushCache();
		_itemSelection.clearSelection();
		_activeContractType = null;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(_activeContractType.getId().toString());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(curLang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			ContractType[] types = _productsDao.getContractTypes(userSessionId, params);
			if (types != null && types.length > 0) {
				_activeContractType = types[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public List<SelectItem> getContractTypeArticles() {
		return getDictUtils().getLov(LovConstants.LIST_CONTRACT_TYPES);
	}

	public List<SelectItem> getProductTypes() {
		return getDictUtils().getLov(LovConstants.PRODUCT_TYPES);
	}

	public List<SelectItem> getCustomerTypes() {
		return getDictUtils().getLov(LovConstants.CUSTOMER_TYPES);
	}

	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newContractType.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newContractType.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			ContractType[] types = _productsDao.getContractTypes(userSessionId, params);
			if (types != null && types.length > 0) {
				newContractType = types[0];
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

	public void changeProductType() {
		try {
			newContractType.setProductType(
				_productsDao.getProductType(userSessionId, newContractType));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
}
