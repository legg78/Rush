package ru.bpc.sv2.ui.products;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.acm.AcmAction;
import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.Contract;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.products.Product;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletRequest;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name ="MbCustomersDependent")
public class MbCustomersDependent extends AbstractBean {
	private static final long serialVersionUID = -5402965539705861151L;

	private static final Logger logger = Logger.getLogger("PRODUCTS");

	private ProductsDao _productsDao = new ProductsDao();

	private Customer filter;
	private Card filterCard;
	private Contract filterContract;
	private Account filterAccount;
	private Merchant filterMerchant;
	private Terminal filterTerminal;

	private Customer newCustomer;

	private final DaoDataModel<Customer> _customersSource;
	private final TableRowSelection<Customer> _itemSelection;
	private Customer _activeCustomer;

	private ArrayList<SelectItem> institutions;

	private boolean fromCard;

	private MbCustomersSess sessBean;

	private AcmAction selectedCtxItem;
	private String ctxItemEntityType;
	
	SelectionParams params;
	
	public MbCustomersDependent() {
		sessBean = (MbCustomersSess) ManagedBeanWrapper.getManagedBean("MbCustomersSess");

		_customersSource = new DaoDataModel<Customer>() {
			private static final long serialVersionUID = 6441602290687263971L;

			@Override
			protected Customer[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Customer[0];
				}
				try {
						return new Customer[0];
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return new Customer[0];
				}
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					return 0;					
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return 0;
				}
			}
		};

		_itemSelection = new TableRowSelection<Customer>(null, _customersSource);

		HttpServletRequest req = RequestContextHolder.getRequest();
		String sectionId = req.getParameter("sectionId");
		String filterId = req.getParameter("filterId");

		if (sectionId != null && filterId != null && sectionId.equals("1677")) {
			selectedSectionFilter = Integer.parseInt(filterId);
			applySectionFilter(selectedSectionFilter);
		}
	}

	public DaoDataModel<Customer> getCustomers() {
		return _customersSource;
	}

	public Customer getActiveCustomer() {
		return _activeCustomer;
	}

	public void setActiveCustomer(Customer activeCustomer) {
		_activeCustomer = activeCustomer;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeCustomer == null && _customersSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeCustomer != null && _customersSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeCustomer.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeCustomer = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeCustomer = _itemSelection.getSingleSelection();

		if (_activeCustomer != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_customersSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCustomer = (Customer) _customersSource.getRowData();
		selection.addKey(_activeCustomer.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {

	}

	public void setFilters() {
	}

	public void setFiltersPerson() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("entityType");
		paramFilter.setValue(EntityNames.PERSON);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
		if (filter.getCustomerNumber() != null && filter.getCustomerNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("customerNumber");
			paramFilter.setValue(filter.getCustomerNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		if (filter.getContractNumber() != null && filter.getContractNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("contractNumber");
			paramFilter.setValue(filter.getContractNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getPerson().getFirstName() != null &&
				filter.getPerson().getFirstName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("personFirstName");
			paramFilter.setValue(filter.getPerson().getFirstName().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (filter.getPerson().getSurname() != null &&
				filter.getPerson().getSurname().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("personSurname");
			paramFilter.setValue(filter.getPerson().getSurname().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (filter.getPerson().getSecondName() != null &&
				filter.getPerson().getSecondName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("personSecondName");
			paramFilter.setValue(filter.getPerson().getSecondName().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (filter.getPerson().getGender() != null &&
				filter.getPerson().getGender().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("personGender");
			paramFilter.setValue(filter.getPerson().getGender().trim().toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getPerson().getBirthday() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("personBirthday");
			paramFilter.setValue(filter.getPerson().getBirthday());
			filters.add(paramFilter);
		}

		if (filter.getDocument().getIdType() != null &&
				filter.getDocument().getIdType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("idType");
			paramFilter.setValue(filter.getDocument().getIdType());
			filters.add(paramFilter);
		}
		if (filter.getDocument().getIdSeries() != null &&
				filter.getDocument().getIdSeries().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("idSeries");
			paramFilter.setValue(filter.getDocument().getIdSeries().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getDocument().getIdNumber() != null &&
				filter.getDocument().getIdNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("idNumber");
			paramFilter.setValue(filter.getDocument().getIdNumber().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void setFiltersCustomer() {

		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
		if (filter.getCustomerNumber() != null && filter.getCustomerNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("customerNumber");
			paramFilter.setValue(filter.getCustomerNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		if (filter.getContractNumber() != null && filter.getContractNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("contractNumber");
			paramFilter.setValue(filter.getContractNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
	}

	public void setFiltersCompany() {

		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("entityType");
		paramFilter.setValue(EntityNames.COMPANY);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
		if (filter.getCustomerNumber() != null && filter.getCustomerNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("customerNumber");
			paramFilter.setValue(filter.getCustomerNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		if (filter.getContractNumber() != null && filter.getContractNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("contractNumber");
			paramFilter.setValue(filter.getContractNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getCompany().getLabel() != null &&
				filter.getCompany().getLabel().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("companyName");
			paramFilter.setValue(filter.getCompany().getLabel().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getCompany().getEmbossedName() != null &&
				filter.getCompany().getEmbossedName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("embossedName");
			paramFilter.setValue(filter.getCompany().getEmbossedName().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getDocument().getIdType() != null &&
				filter.getDocument().getIdType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("idType");
			paramFilter.setValue(filter.getDocument().getIdType());
			filters.add(paramFilter);
		}
		if (filter.getDocument().getIdSeries() != null &&
				filter.getDocument().getIdSeries().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("idSeries");
			paramFilter.setValue(filter.getDocument().getIdSeries().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getDocument().getIdNumber() != null &&
				filter.getDocument().getIdNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("idNumber");
			paramFilter.setValue(filter.getDocument().getIdNumber().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void setFiltersContract() {
		getFilterContract();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filterContract.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filterContract.getInstId());
			filters.add(paramFilter);
		}
		if (filterContract.getAgentId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("agentId");
			paramFilter.setValue(filterContract.getAgentId());
			filters.add(paramFilter);
		}
		if (filterContract.getProductId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("productId");
			paramFilter.setValue(filterContract.getProductId());
			filters.add(paramFilter);
		}
		if (filterContract.getContractType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("contractType");
			paramFilter.setValue(filterContract.getContractType());
			filters.add(paramFilter);
		}

		String dbDateFormat = "dd.MM.yyyy";
		SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
		if (filterContract.getStartDate() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("startDate");
			paramFilter.setValue(df.format(filterContract.getStartDate()));
			filters.add(paramFilter);
		}
		if (filterContract.getEndDate() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("endDate");
			paramFilter.setValue(df.format(filterContract.getEndDate()));
			filters.add(paramFilter);
		}
		if (filterContract.getContractNumber() != null &&
				filterContract.getContractNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("contractNumber");
			paramFilter.setValue(filterContract.getContractNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
	}

	public void setFiltersCard() {
		getFilterCard();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filterCard.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filterCard.getInstId());
			filters.add(paramFilter);
		}
		if (filterCard.getCardTypeId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("cardTypeId");
			paramFilter.setValue(filterCard.getCardTypeId());
			filters.add(paramFilter);
		}
		if (filterCard.getProductId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("productId");
			paramFilter.setValue(filterCard.getProductId());
			filters.add(paramFilter);
		}

		if (filterCard.getCardNumber() != null && filterCard.getCardNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("cardNumber");
			paramFilter.setValue(filterCard.getCardNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filterCard.getCardholderName() != null &&
				filterCard.getCardholderName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("cardholderName");
			paramFilter.setValue(filterCard.getCardholderName().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

	}

	public void setFiltersAccount() {
		getFilterAccount();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filterAccount.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filterAccount.getInstId());
			filters.add(paramFilter);
		}
		if (filterAccount.getAccountType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("accountType");
			paramFilter.setValue(filterAccount.getAccountType());
			filters.add(paramFilter);
		}
		if (filterAccount.getAccountNumber() != null &&
				filterAccount.getAccountNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("accountNumber");
			paramFilter.setValue(filterAccount.getAccountNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filterAccount.getStatus() != null && filterAccount.getStatus().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("status");
			paramFilter.setValue(filterAccount.getStatus());
			filters.add(paramFilter);
		}

		if (filterAccount.getCurrency() != null && filterAccount.getCurrency().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("currency");
			paramFilter.setValue(filterAccount.getCurrency());
			filters.add(paramFilter);
		}
	}

	public void setFiltersMerchant() {
		getFilterMerchant();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filterMerchant.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filterMerchant.getInstId());
			filters.add(paramFilter);
		}
		if (filterMerchant.getMerchantNumber() != null &&
				filterMerchant.getMerchantNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("merchantNumber");
			paramFilter.setValue(filterMerchant.getMerchantNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filterMerchant.getMerchantName() != null &&
				filterMerchant.getMerchantName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("merchantName");
			paramFilter.setValue(filterMerchant.getMerchantName().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filterMerchant.getMcc() != null && filterMerchant.getMcc().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("mcc");
			paramFilter.setValue(filterMerchant.getMcc());
			filters.add(paramFilter);
		}
	}

	public void setFiltersTerminal() {
		getFilterTerminal();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filterTerminal.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filterTerminal.getInstId());
			filters.add(paramFilter);
		}
		if (filterTerminal.getTerminalType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("terminalType");
			paramFilter.setValue(filterTerminal.getTerminalType());
			filters.add(paramFilter);
		}
		if (filterTerminal.getTerminalNumber() != null &&
				filterTerminal.getTerminalNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("terminalNumber");
			paramFilter.setValue(filterTerminal.getTerminalNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filterTerminal.getStatus() != null && filterTerminal.getStatus().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("status");
			paramFilter.setValue(filterTerminal.getStatus());
			filters.add(paramFilter);
		}

	}

	public void setFiltersAddress() {

		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
		
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
		
		if (filter.getAddress().getCountry() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("country");
			paramFilter.setValue(filter.getAddress().getCountry());
			filters.add(paramFilter);
		}
		if (filter.getAddress().getCity() != null &&
				filter.getAddress().getCity().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("city");
			paramFilter.setValue(filter.getAddress().getCity().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getAddress().getStreet() != null &&
				filter.getAddress().getStreet().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("street");
			paramFilter.setValue(filter.getAddress().getStreet().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getAddress().getHouse() != null &&
				filter.getAddress().getHouse().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("house");
			paramFilter.setValue(filter.getAddress().getHouse().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getAddress().getPostalCode() != null &&
				filter.getAddress().getPostalCode().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("postalCode");
			paramFilter.setValue(filter.getAddress().getPostalCode());
			filters.add(paramFilter);
		}
	}

	public void setFiltersContact() {

		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
		
		if (filter.getContact().getPhone() != null &&
				filter.getContact().getPhone().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("phone");
			paramFilter.setValue(filter.getContact().getPhone());
			filters.add(paramFilter);
		}
		if (filter.getContact().getMobile() != null &&
				filter.getContact().getMobile().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("mobile");
			paramFilter.setValue(filter.getContact().getMobile());
			filters.add(paramFilter);
		}
		if (filter.getContact().getFax() != null &&
				filter.getContact().getFax().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("fax");
			paramFilter.setValue(filter.getContact().getFax());
			filters.add(paramFilter);
		}
		if (filter.getContact().getEmail() != null &&
				filter.getContact().getEmail().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("email");
			paramFilter.setValue(filter.getContact().getEmail());
			filters.add(paramFilter);
		}
		if (filter.getContact().getImType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("imType");
			paramFilter.setValue(filter.getContact().getImType());
			filters.add(paramFilter);
		}
		if (filter.getContact().getImNumber() != null &&
				filter.getContact().getImNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("imNumber");
			paramFilter.setValue(filter.getContact().getImNumber());
			filters.add(paramFilter);
		}
	}

	public Customer getFilter() {
		if (filter == null) {
			filter = new Customer();
		}
		return filter;
	}

	public void setFilter(Customer filter) {
		this.filter = filter;
	}

	public void clearFilter() {
		filter = new Customer();
		filter.setInstId(userInstId);
		filterTerminal = new Terminal();
		filterTerminal.setInstId(userInstId);
		filterAccount = new Account();
		filterAccount.setInstId(userInstId);
		filterMerchant = new Merchant();
		filterMerchant.setInstId(userInstId);
		filterCard = new Card();
		filterCard.setInstId(userInstId);
		filterContract = new Contract();
		filterContract.setInstId(userInstId);
		clearBean();
		clearSectionFilter();
		// tabName = defaultTabName;
		searching = false;
	}

	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		searching = true;
	}

	public void add() {
		newCustomer = new Customer();
		if (getFilter().getInstId() != null) {
			newCustomer.setInstId(filter.getInstId());
		}
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newCustomer = (Customer) _activeCustomer.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newCustomer = _activeCustomer;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_productsDao.removeCustomer(userSessionId, _activeCustomer);
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Prd", "customer_deleted",
					"(id = " + _activeCustomer.getId() + ")");

			_activeCustomer = _itemSelection.removeObjectFromList(_activeCustomer);
			if (_activeCustomer == null) {
				clearBean();
			} else {
				setBeans();
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
				newCustomer = _productsDao.addCustomer(userSessionId, newCustomer, curLang);
				_itemSelection.addNewObjectToList(newCustomer);
			} else {
				newCustomer = _productsDao.editCustomer(userSessionId, newCustomer, curLang);
				_customersSource.replaceObject(_activeCustomer, newCustomer);
			}
			_activeCustomer = newCustomer;
			curMode = VIEW_MODE;
			setBeans();

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Prd",
					"customer_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public Customer getNewCustomer() {
		if (newCustomer == null) {
			newCustomer = new Customer();
		}
		return newCustomer;
	}

	public void setNewCustomer(Customer newCustomer) {
		this.newCustomer = newCustomer;
	}

	public void clearBean() {
		curLang = userLang;
		_customersSource.flushCache();
		_itemSelection.clearSelection();
		_activeCustomer = null;
		clearBeansStates();
	}

	private void clearBeansStates() {

	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		Filter[] filters = new Filter[2];
		filters[0] = new Filter("id", _activeCustomer.getId());
		filters[1] = new Filter("lang", curLang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Customer[] custArr = new Customer[0];
			if (_activeCustomer.isCompanyCustomer()) {
				custArr = _productsDao.getCompanyCustomers(userSessionId, params, curLang);
			} else if (_activeCustomer.isPersonCustomer()) {
				custArr = _productsDao.getPersonCustomers(userSessionId, params, curLang);
			} else {
				custArr = _productsDao.getUndefinedCustomers(userSessionId, params, curLang);
			}

			if (custArr != null && custArr.length > 0) {
				_activeCustomer = custArr[0];
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

	public List<SelectItem> getCustomerTypes() {
		return getDictUtils().getLov(LovConstants.CUSTOMER_TYPES);
	}

	public List<SelectItem> getPersonIdTypes() {
		try {
			Map<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("CUSTOMER_TYPE", EntityNames.PERSON);
			if (getFilter().getInstId() != null) {
				paramMap.put("INSTITUTION_ID", getFilter().getInstId());
			}
			return getDictUtils().getLov(LovConstants.DOCUMENT_TYPES, paramMap);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return new ArrayList<SelectItem>();
	}

	public List<SelectItem> getCompanyIdTypes() {
		try {
			Map<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("CUSTOMER_TYPE", EntityNames.COMPANY);
			if (getFilter().getInstId() != null) {
				paramMap.put("INSTITUTION_ID", getFilter().getInstId());
			}
			return getDictUtils().getLov(LovConstants.DOCUMENT_TYPES, paramMap);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return new ArrayList<SelectItem>();
	}

	/**
	 * <p>
	 * Loads customer by <code>customerId</code> into bean as <code>activeCustomer</code> and
	 * returns it.
	 * </p>
	 * 
	 * @return found customer or empty customer if no customer was found.
	 */
	public Customer getCustomer(Long customerId) {
		try {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(curLang);
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(customerId);

			params.setFilters(filters);
			params.setPrivilege(getParams().getPrivilege());
			List<Customer> customers = _productsDao.getCustomers(userSessionId, params, curLang);
			if (customers != null && !customers.isEmpty()) {
				_activeCustomer = customers.get(0);
			} else {
				_activeCustomer = null;
			}
			return _activeCustomer;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
		}
		return new Customer();
	}
	
	/**
	 * <p>
	 * Loads customer by <code>customerId</code> and <code>customerType</code> into bean as <code>activeCustomer</code> and
	 * returns it.
	 * </p>
	 * 
	 * @return found customer or empty customer if no customer was found.
	 */
	public Customer getCustomer(Long customerId, String customerType) {
		_activeCustomer = new Customer();
		_activeCustomer.setId(customerId);
		_activeCustomer.setEntityType(customerType);
		
		Filter[] filters = new Filter[2];
		filters[0] = new Filter("id", _activeCustomer.getId());
		filters[1] = new Filter("lang", curLang);
		
		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Customer[] custArr = new Customer[0];
			if (_activeCustomer.isCompanyCustomer()) {
				custArr = _productsDao.getCompanyCustomers(userSessionId, params, curLang);
			} else if (_activeCustomer.isPersonCustomer()) {
				custArr = _productsDao.getPersonCustomers(userSessionId, params, curLang);
			} else {
				custArr = _productsDao.getUndefinedCustomers(userSessionId, params, curLang);
			}

			if (custArr != null && custArr.length > 0) {
				_activeCustomer = custArr[0];
			} else {
				_activeCustomer = null;
			}
			return _activeCustomer;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return new Customer();
	}

	/**
	 * <p>
	 * Gets customer by <code>customerNumber</code> and sets it as <code>activeCustomer</code>.
	 * </p>
	 * 
	 * @return found customer.
	 */
	public Customer getCustomer(String customerNumber) {
		try {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(curLang);
			filters[1] = new Filter();
			filters[1].setElement("customerNumber");
			filters[1].setValue(customerNumber);

			params.setFilters(filters);
			List<Customer> customers = _productsDao.getCustomers(userSessionId, params, curLang);
			if (customers != null && !customers.isEmpty()) {
				_activeCustomer = customers.get(0);
			}
			return _activeCustomer;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
		}
		return new Customer();
	}

	public boolean isFromCard() {
		return fromCard;
	}

	public void setFromCard(boolean fromCard) {
		this.fromCard = fromCard;
	}

	public ArrayList<SelectItem> getGenders() {
		return getDictUtils().getArticles(DictNames.PERSON_GENDER, false, false);
	}

	public Card getFilterCard() {
		if (filterCard == null) {
			filterCard = new Card();
			filterCard.setInstId(userInstId);
		}
		return filterCard;
	}

	public void setFilterCard(Card filterCard) {
		this.filterCard = filterCard;
	}

	public Contract getFilterContract() {
		if (filterContract == null) {
			filterContract = new Contract();
			if (userInstId.intValue() != ApplicationConstants.DEFAULT_INSTITUTION) {
				filterContract.setInstId(userInstId);
			}
		}
		return filterContract;
	}

	public void setFilterContract(Contract filterContract) {
		this.filterContract = filterContract;
	}

	public Account getFilterAccount() {
		if (filterAccount == null) {
			filterAccount = new Account();
			filterAccount.setInstId(userInstId);
		}
		return filterAccount;
	}

	public void setFilterAccount(Account filterAccount) {
		this.filterAccount = filterAccount;
	}

	public Merchant getFilterMerchant() {
		if (filterMerchant == null) {
			filterMerchant = new Merchant();
			filterMerchant.setInstId(userInstId);
		}
		return filterMerchant;
	}

	public void setFilterMerchant(Merchant filterMerchant) {
		this.filterMerchant = filterMerchant;
	}

	public Terminal getFilterTerminal() {
		if (filterTerminal == null) {
			filterTerminal = new Terminal();
			filterTerminal.setInstId(userInstId);
		}
		return filterTerminal;
	}

	public void setFilterTerminal(Terminal filterTerminal) {
		this.filterTerminal = filterTerminal;
	}

	public List<SelectItem> getAgents() {
		if (getFilter().getInstId() == null)
			return new ArrayList<SelectItem>();
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("INSTITUTION_ID", getFilter().getInstId());
		return getDictUtils().getLov(LovConstants.AGENTS, paramMap);
	}

	public List<SelectItem> getCardTypes() {
		return getDictUtils().getLov(LovConstants.CARD_TYPES);
	}

	public List<SelectItem> getAccountTypes() {
		if (getFilterAccount().getInstId() == null)
			return new ArrayList<SelectItem>();
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("INSTITUTION_ID", getFilterAccount().getInstId());
		return getDictUtils().getLov(LovConstants.ACCOUNT_TYPES, paramMap);
	}

	public List<SelectItem> getAccountStatuses() {
		return getDictUtils().getLov(LovConstants.ACCOUNT_STATUSES);
	}

	public List<SelectItem> getTerminalTypes() {
		return getDictUtils().getArticles(DictNames.TERMINAL_TYPE, true, true);
	}

	public List<SelectItem> getTerminalStatuses() {
		return getDictUtils().getArticles(DictNames.TERMINAL_STATUS, true, true);
	}

	public List<SelectItem> getMccs() {
		return getDictUtils().getLov(LovConstants.MCC);
	}

	public ArrayList<SelectItem> getImTypes() {
		return getDictUtils().getArticles(DictNames.IM_TYPE, false, true);
	}

	public ArrayList<SelectItem> getProducts() {
		ArrayList<Filter> filters = new ArrayList<Filter>();
		Filter filter = new Filter();
		filter.setElement("lang");
		filter.setValue(curLang);
		filters.add(filter);

		if (getFilterContract().getInstId() != null) {
			filter = new Filter();
			filter.setElement("instId");
			filter.setValue(getFilterContract().getInstId());
			filters.add(filter);
		}
		if (getFilterContract().getContractType() != null) {
			filter = new Filter();
			filter.setElement("contractType");
			filter.setValue(getFilterContract().getContractType());
			filters.add(filter);
		}

		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(Integer.MAX_VALUE);
		params.setFilters((Filter[]) filters.toArray(new Filter[filters.size()]));
		try {
			Product[] products = _productsDao.getProducts(userSessionId, params);
			ArrayList<SelectItem> items = new ArrayList<SelectItem>(products.length);
			for (Product product : products) {
				String name = product.getName();
				for (int i = 1; i < product.getLevel(); i++) {
					name = " -- " + name;
				}
				items.add(new SelectItem(product.getId(), product.getId() + " - " + name));
			}
			return items;
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}

		return new ArrayList<SelectItem>(0);
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
		sessBean.setRowsNum(rowsNum);
	}

	public void setPageNumber(int pageNumber) {
		sessBean.setPageNumber(pageNumber);
		this.pageNumber = pageNumber;
	}

	public List<SelectItem> getContractTypes() {
		if (getFilterContract().getInstId() != null) {
			return getDictUtils().getArticles(DictNames.CONTRACT_TYPE, false, false, getFilter()
					.getInstId());
		} else {
			return getDictUtils().getArticles(DictNames.CONTRACT_TYPE, false);
		}
	}

	public Logger getLogger() {
		return logger;
	}

	public void initCtxParams() {
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		ctxBean.setSelectedCtxItem(selectedCtxItem);
		ctxBean.initCtxParams(EntityNames.CUSTOMER, _activeCustomer.getId());

		if (EntityNames.PERSON.equals(ctxItemEntityType)) {
			FacesUtils.setSessionMapValue("module", "iss");
		} else if (EntityNames.COMPANY.equals(ctxItemEntityType)) {
			FacesUtils.setSessionMapValue("module", "acq");
		}
		FacesUtils.setSessionMapValue("entityType", EntityNames.CUSTOMER);
		FacesUtils.setSessionMapValue("customerNumber", _activeCustomer.getCustomerNumber());
	}

	public String ctxPageForward() {
		initCtxParams();
		FacesUtils.setSessionMapValue("initFromContext", Boolean.TRUE);
		FacesUtils.setSessionMapValue("backLink", thisBackLink);

		return selectedCtxItem.getAction();
	}

	public AcmAction getSelectedCtxItem() {
		return selectedCtxItem;
	}

	public void setSelectedCtxItem(AcmAction selectedCtxItem) {
		this.selectedCtxItem = selectedCtxItem;
	}

	public String getCtxItemEntityType() {
		return ctxItemEntityType;
	}

	public void setCtxItemEntityType(String ctxItemEntityType) {
		this.ctxItemEntityType = ctxItemEntityType;
	}
	
	public String doDefaultAction() {
		MbContextMenu ctx = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		AcmAction action = ctx.getDefaultAction(_activeCustomer.getInstId());
		
		if (action != null) {
			selectedCtxItem = action;
			return ctxPageForward();
		}
		return "";
	}
	
	public SelectionParams getParams() {
		if (params == null) params = new SelectionParams();
		return params;
	}
}
