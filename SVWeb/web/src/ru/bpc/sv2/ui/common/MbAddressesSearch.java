package ru.bpc.sv2.ui.common;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.common.Address;
import ru.bpc.sv2.common.AddressFilter;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


@ViewScoped
@ManagedBean (name = "MbAddressesSearch")
public class MbAddressesSearch extends AbstractBean {
    private static final Logger logger = Logger.getLogger("COMMON");

    private CommonDao _commonDao = new CommonDao();

    private AddressFilter filter;
    private final DaoDataModel<Address> _addressSource;
    private Address _activeAddress;
    private final TableRowSelection<Address> _itemSelection;
    private Address newAddress;
    private int addressCount = 0;
    private String oldLang;
    private static String COMPONENT_ID = "addressesTable";
    private String tabName;
    private String parentSectionId;
	private ArrayList<SelectItem> addressTypes;

	public MbAddressesSearch() {
        _addressSource = new DaoDataModel<Address>() {
            private static final long serialVersionUID = 1L;
            @Override
            protected Address[] loadDaoData(SelectionParams params) {
                if (!searching) {
                    return new Address[0];
                }
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    Address[] addresses = _commonDao.getAddresses(userSessionId, params, curLang);
                    return addresses;
                } catch (Exception e) {
                    setDataSize(0);
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return new Address[0];
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                int count = 0;
                if (!searching) {
                    return 0;
                }
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    count = _commonDao.getAddressesCount(userSessionId, params, curLang);
                } catch (Exception e) {
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return count;
            }
        };

        _itemSelection = new TableRowSelection<Address>(null, _addressSource);
		addressTypes = getDictUtils().getArticles(DictNames.ADDRESS_TYPE, false, true);
    }

    public void search() {
        clearBean();
        setSearching(true);
    }

    public void setFirstRowActive() {
        _addressSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        _activeAddress = (Address) _addressSource.getRowData();
        selection.addKey(_activeAddress.getModelId());
        _itemSelection.setWrappedSelection(selection);
    }

    public SimpleSelection getItemSelection() {
        if (_activeAddress == null && _addressSource.getRowCount() > 0) {
            setFirstRowActive();
        } else if (_activeAddress != null && _addressSource.getRowCount() > 0) {
            SimpleSelection selection = new SimpleSelection();
            selection.addKey(_activeAddress.getModelId());
            _itemSelection.setWrappedSelection(selection);
            _activeAddress = _itemSelection.getSingleSelection();
        }
        return _itemSelection.getWrappedSelection();
    }

    public void setItemSelection(SimpleSelection selection) {
        _itemSelection.setWrappedSelection(selection);
        _activeAddress = _itemSelection.getSingleSelection();
    }

    public AddressFilter getFilter() {
        if (filter == null) {
            filter = new AddressFilter();
        }
        return filter;
    }

    public void setFilter(AddressFilter filter) {
        this.filter = filter;
    }

    public void setFilters() {
        AddressFilter addressFilter = getFilter();
        Filter paramFilter;

        filters = new ArrayList<Filter>();
        
        filters.add(new Filter("currentLang", curLang));

        if(addressFilter.getObjectId() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("objectId");
            paramFilter.setValue(addressFilter.getObjectId());
            filters.add(paramFilter);
        }

        if(addressFilter.getEntityType() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("entityType");
            paramFilter.setValue(addressFilter.getEntityType());
            filters.add(paramFilter);
        }

        if(addressFilter.getAddressType() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("addressType");
            paramFilter.setValue(addressFilter.getAddressType());
            filters.add(paramFilter);
        }

        if(addressFilter.getAddressString() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("addressString");
            paramFilter.setValue("%"
                    + addressFilter.getAddressString().trim().toUpperCase().replaceAll("[*]", "%")
                    .replaceAll("[?]", "_") + "%");
            filters.add(paramFilter);
        }

        if(addressFilter.getTypeIdPairs() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("typeIdPairs");
            paramFilter.setValue(addressFilter.getTypeIdPairs());
            filters.add(paramFilter);
        }
    }

    public String getComponentId() {
        return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
    }

    public void fullCleanBean() {
        clearFilter();
        clearBean();
    }

    public void clearBean() {
        _addressSource.flushCache();
        _itemSelection.clearSelection();
        _activeAddress = null;
    }


    public void clearState() {
        _itemSelection.clearSelection();
        _activeAddress = null;
        _addressSource.flushCache();
        curLang = userLang;
    }

    public void setParentSectionId(String parentSectionId) {
        this.parentSectionId = parentSectionId;
    }

    public void setTabName(String tabName) {
        this.tabName = tabName;
    }

    public void clearFilter() {
        curLang = userLang;
        setFilter(null);
        setSearching(false);
        clearBean();
    }

    public void changeAddressLang() {
        _addressSource.flushCache();
    }

    public Address getActiveAddress() {
        return _activeAddress;
    }

    private void setActiveAddress(Address activeAddress) {
        _activeAddress = activeAddress;
    }

    public DaoDataModel<Address> getAddresses() {
        return _addressSource;
    }

    public ArrayList<SelectItem> getAddressTypes() {
	    return addressTypes;
    }

    public ArrayList<SelectItem> getEntityTypes() {

        return getDictUtils().getArticles(DictNames.ENTITY_TYPES, false, true);
    }

    public boolean isRenderAdd() {
        if (EntityNames.TERMINAL.equals(getFilter().getEntityType()) || EntityNames.MERCHANT.equals(getFilter().getEntityType())) {
            return false;
        }
        return true;
    }

    public boolean isRenderEdit() {
        if (EntityNames.TERMINAL.equals(getFilter().getEntityType()) || EntityNames.MERCHANT.equals(getFilter().getEntityType())) {
            return false;
        }
        return true;
    }

    public boolean isRenderDelete() {
        if (EntityNames.TERMINAL.equals(getFilter().getEntityType()) || EntityNames.MERCHANT.equals(getFilter().getEntityType())) {
            return false;
        }
        return true;
    }

    public void addAddress() {
        newAddress = new Address();
        newAddress.setEntityType(getFilter().getEntityType());
        newAddress.setObjectId(getFilter().getObjectId());
        newAddress.setLang(userLang);
        curMode = NEW_MODE;
    }

    public void editAddress() {
        try {
            newAddress = (Address) _activeAddress.clone();
        } catch (CloneNotSupportedException e) {
            logger.error("", e);
            newAddress = _activeAddress;
        }
        curMode = EDIT_MODE;
    }

    public void deleteAddress() {
        try {
            _commonDao.deleteAddressObject(userSessionId, _activeAddress);
            _activeAddress = _itemSelection.removeObjectFromList(_activeAddress);
            if (_activeAddress == null) {
                clearBean();
            }
            resetCount();
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public String getCount(){
        return String.valueOf(addressCount);
    }

    public void resetCount(){
        addressCount = 0;
    }

    public String getCountry(){
        if (_addressSource.getActivePage() != null){
            if (addressCount < _addressSource.getDataSize() ){
                Address address = _addressSource.getActivePage().get(addressCount);
                addressCount++;
                String country = address.getCountry();
                return country;
            }else {
                return null;
            }
        } else {
            return null;
        }
    }

    public Address getNewAddress() {
        if (newAddress == null) {
            newAddress = new Address();
        }
        return newAddress;
    }

    public void setNewAddress(Address newAddress) {
        this.newAddress = newAddress;
    }

    public void editLanguage(ValueChangeEvent event) {
        oldLang = (String) event.getOldValue();
    }

    public void confirmEditLanguage() {
        Filter[] filters = new Filter[4];
        filters[0] = new Filter();
        filters[0].setElement("objectId");
        filters[0].setValue(getFilter().getObjectId());
        filters[1] = new Filter();
        filters[1].setElement("currentLang");
        filters[1].setValue(newAddress.getLang());
        filters[2] = new Filter();
        filters[2].setElement("entityType");
        filters[2].setValue(getFilter().getEntityType());
        filters[3] = new Filter();
        filters[3].setElement("addressType");
        filters[3].setValue(newAddress.getAddressType());

        SelectionParams params = new SelectionParams();
        params.setFilters(filters);
        try {
            Address[] items = _commonDao.getAddresses(userSessionId, params, curLang);
            if (items != null && items.length > 0) {
                newAddress.setRegion(items[0].getRegion());
                newAddress.setCity(items[0].getCity());
                newAddress.setStreet(items[0].getStreet());
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void cancelEditLanguage() {
        newAddress.setLang(oldLang);
    }

    public void changeLanguage(ValueChangeEvent event) {
        curLang = (String) event.getNewValue();
        newAddress = getNodeByLang(newAddress.getAddressId(), curLang);
    }

    public Address getNodeByLang(Long id, String lang) {
        SelectionParams params = new SelectionParams(new Filter("id", id));
        params.setFilters(filters.toArray(new Filter[filters.size()]));
        try {
            Address[] addrs = _commonDao.getAddresses(getFilter().getObjectId(), params, lang);
            if (addrs != null && addrs.length > 0) {
                return addrs[0];
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        return null;
    }

    public void save() {
        try {
            if (isEditMode()) {
                newAddress = _commonDao.editAddress(userSessionId, newAddress);
                _addressSource.replaceObject(_activeAddress, newAddress);
            } else {
                newAddress = _commonDao.addAddress(userSessionId, newAddress);
                _itemSelection.addNewObjectToList(newAddress);
            }
            _activeAddress = newAddress;
            curMode = VIEW_MODE;
            resetCount();
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void close() {
        curMode = VIEW_MODE;
    }

}
