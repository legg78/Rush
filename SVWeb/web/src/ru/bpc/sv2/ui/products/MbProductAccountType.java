package ru.bpc.sv2.ui.products;

import java.util.*;


import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.products.Product;
import ru.bpc.sv2.products.ProductAccountType;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbProductAccountType")
@SuppressWarnings("serial")
public class MbProductAccountType extends AbstractBean {

	private ProductsDao productDao = new ProductsDao();

	private final static int ACQ_PRODUCT = 0;
	private final static int ISS_PRODUCT = 1;
	private final static int ORG_PRODUCT = 2;

	private static final Logger logger = Logger.getLogger("PRODUCT");
	private ProductAccountType filter;
	private ProductAccountType activeItem;
	private ProductAccountType editProductAccountType;
	private int productType;

	private int productId;
	private String prodName;

	private final DaoDataModel<ProductAccountType> dataModel;
	private final TableRowSelection<ProductAccountType> itemSelection;
	
	private static String COMPONENT_ID = "mainTable";
	private String tabName;
	private String parentSectionId;

	public MbProductAccountType() {
		dataModel = new DaoDataModel<ProductAccountType>() {

			@Override
			protected ProductAccountType[] loadDaoData(SelectionParams params) {
				if (searching) {
					try {
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters.size()]));
						return productDao.getProductAccountTypes(userSessionId, params);
					} catch (DataAccessException e) {
						setDataSize(0);
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
					return new ProductAccountType[0];
				} else {
					return new ProductAccountType[0];
				}
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (searching) {
					try {
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters.size()]));
						return productDao.getProductAccountTypesCount(userSessionId, params);
					} catch (DataAccessException e) {
						setDataSize(0);
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
					return 0;
				} else {
					return 0;
				}
			}

		};
		itemSelection = new TableRowSelection<ProductAccountType>(null, dataModel);
	}

	public DaoDataModel<ProductAccountType> getDataModel() {
		return dataModel;
	}

	public SimpleSelection getItemSelection() {
		if (activeItem == null && dataModel.getRowCount() > 0) {
			setFirstRowActive();
		} else if (activeItem != null && dataModel.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(activeItem.getModelId());
			itemSelection.setWrappedSelection(selection);
			activeItem = itemSelection.getSingleSelection();
		}
		return itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		itemSelection.setWrappedSelection(selection);
		activeItem = itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		dataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (ProductAccountType) dataModel.getRowData();
		selection.addKey(activeItem.getModelId());
		itemSelection.setWrappedSelection(selection);
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if ((filter != null) && (filter.getProductId() >= 0)) {
			paramFilter = new Filter();
			paramFilter.setElement("productId");
			paramFilter.setValue(filter.getProductId());
			filters.add(paramFilter);
		}
	}

	private ProductAccountType getFilter() {
		if (filter == null) {
			return new ProductAccountType();
		} else {
			return filter;
		}

	}

	public List<SelectItem> getProduct() {
		List<SelectItem> result;
		if (productType == ACQ_PRODUCT) {
			result = getDictUtils().getLov(LovConstants.ACQUIRING_PRODUCTS);

		} else {
			result = getDictUtils().getLov(LovConstants.ISSUING_PRODUCTS);
		}
		return result;
	}

	public List<SelectItem> getAccountType() {
		List<SelectItem> result = Collections.emptyList();

		try {
			HashMap<String, Object> map = new HashMap<String, Object>(1);
			if (productId > 0) {
				Product prod = productDao.getProductById(userSessionId, productId, curLang);
				if (prod != null)
					map.put("inst_id", prod.getInstId());
			}

			if (productType == ACQ_PRODUCT) {
				result = getDictUtils().getLov(LovConstants.ACQUIRING_ACCOUNT_TYPES, map);
			} else if(productType == ISS_PRODUCT){
				result = getDictUtils().getLov(LovConstants.ISSUING_ACCOUNT_TYPES, map);
			} else{
				result = getDictUtils().getLov(LovConstants.ORG_ACCOUNT_TYPES, map);
			}
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}
		return result;
	}

	public List<SelectItem> getScheme() {
		return getDictUtils().getLov(LovConstants.APPLICATION_SCHEMES);
	}

	public List<SelectItem> getService() {
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("PRODUCT_ID", getFilter().getProductId());
		paramMap.put("ENTITY_TYPE", EntityNames.ACCOUNT);
		paramMap.put("IS_INITIAL", 1);
		return getDictUtils().getLov(LovConstants.SERVICE_PRODUCT, paramMap);
	}

	public void setFilter(ProductAccountType filter) {
		this.filter = filter;
	}

	public ProductAccountType getActiveItem() {
		return activeItem;
	}

	public void add() {
		editProductAccountType = new ProductAccountType();
		editProductAccountType.setProductId(productId);
		curMode = NEW_MODE;
	}

	public void edit() {

		editProductAccountType = activeItem;
		curMode = EDIT_MODE;
	}

	public void cancel() {
		editProductAccountType = null;
		curMode = VIEW_MODE;
	}

	public void save() {
		try {
			editProductAccountType.setLang(curLang);
			switch (curMode) {
			case NEW_MODE:
				editProductAccountType = productDao.addProductAccountType(userSessionId, editProductAccountType);
				if (editProductAccountType != null) {
					itemSelection.addNewObjectToList(editProductAccountType);
				}
				break;

			case EDIT_MODE:
				editProductAccountType = productDao.editProductAccountType(userSessionId, editProductAccountType);
				if (editProductAccountType != null) {
					dataModel.replaceObject(activeItem, editProductAccountType);
				}
				break;
			}
			editProductAccountType = null;
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			productDao.removeProductAccountType(userSessionId, activeItem);
			curMode = VIEW_MODE;
			activeItem = itemSelection.removeObjectFromList(activeItem);
			
			if (activeItem == null) {
				clearState();
			}

			curMode = VIEW_MODE;

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void clearState() {
		itemSelection.clearSelection();
		activeItem = null;
		dataModel.flushCache();
		curLang = userLang;
	}

	@Override
	public void clearFilter() {
		filter = null;
		clearState();
		searching = false;

	}

	public int getProductType() {
		return productType;
	}

	public void setProductType(int productType) {
		this.productType = productType;
	}

	public ProductAccountType getEditProductAccountType() {
		return editProductAccountType;
	}

	public void setProductId(int id) {
		productId = id;
	}

	public String getProdName() {
		return prodName;
	}

	public void setProdName(String prodName) {
		this.prodName = prodName;
	}

	public List<SelectItem> getAvalAlgorithms() {
		return getDictUtils().getLov(LovConstants.AVAL_BALANCE_CALC_ALGORITHMS);
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

}
