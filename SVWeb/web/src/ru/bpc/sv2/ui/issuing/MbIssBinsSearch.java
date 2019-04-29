package ru.bpc.sv2.ui.issuing;

import java.io.ByteArrayOutputStream;
import java.io.PrintWriter;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.Security;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.security.auth.x500.X500Principal;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;
import org.bouncycastle.jce.PKCS10CertificationRequest;
import org.bouncycastle.openssl.PEMWriter;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.acs.reqCert.BpcThalesKeyPairGeneratorParams;
import ru.bpc.sv2.acs.reqCert.BpcThalesProvider;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.IssuerBin;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.net.CardType;
import ru.bpc.sv2.net.Network;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.aup.MbAupSchemeObjects;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.fraud.MbFraudObjects;
import ru.bpc.sv2.ui.security.MbDesKeysBottom;
import ru.bpc.sv2.ui.security.MbHmacKey;
import ru.bpc.sv2.ui.security.MbRsaKey;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;
import util.servlet.FileServlet;

@ViewScoped
@ManagedBean(name = "MbIssBinsSearch")
public class MbIssBinsSearch extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("ISSUING");

	private static String COMPONENT_ID = "1393:binTable";

	private IssuingDao _issuingDao = new IssuingDao();

	private NetworkDao _networkDao = new NetworkDao();
	
	private SettingsDao _settingsDao = new SettingsDao();

	private IssuerBin filter;
	private IssuerBin _activeBin;
	private IssuerBin newBin;

	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> networks;
	
	private final DaoDataModel<IssuerBin> _binsSource;
	private final TableRowSelection<IssuerBin> _itemSelection;
	
	private String oldLang;
	
	private ContextType ctxType;
	private String ctxItemEntityType;
	private boolean generated;
	private Boolean useHsm;
	private String tabName;
	private Map<String, Object> paramMap;

	public MbIssBinsSearch() {
		pageLink = "issuing|issBins";
		tabName = "detailsTab";
		_binsSource = new DaoDataModel<IssuerBin>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected IssuerBin[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new IssuerBin[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _issuingDao.getIssBinsCur(userSessionId, params, getParamMap());
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new IssuerBin[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _issuingDao.getIssBinsCurCount(userSessionId, getParamMap());
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<IssuerBin>(null, _binsSource);
	}

	public DaoDataModel<IssuerBin> getBins() {
		return _binsSource;
	}

	public IssuerBin getActiveBin() {
		return _activeBin;
	}

	public void setActiveBin(IssuerBin activeBin) {
		_activeBin = activeBin;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeBin == null && _binsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeBin != null && _binsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeBin.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeBin = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_binsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeBin = (IssuerBin) _binsSource.getRowData();
		selection.addKey(_activeBin.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeBin != null) {
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeBin = _itemSelection.getSingleSelection();
		if (_activeBin != null) {
			setInfo();
		}
	}

	public void setInfo() {
		MbIssBinIndexRangesSearch rangesSearch = (MbIssBinIndexRangesSearch) ManagedBeanWrapper
				.getManagedBean("MbIssBinIndexRangesSearch");
		rangesSearch.fullCleanBean();
		rangesSearch.getFilter().setBinId(_activeBin.getId());
		rangesSearch.setInstId(_activeBin.getInstId());
		rangesSearch.setEntityType(EntityNames.CARD);
		rangesSearch.search();

		MbDesKeysBottom keys = (MbDesKeysBottom) ManagedBeanWrapper.getManagedBean("MbDesKeysBottom");
		keys.fullCleanBean();
		keys.getFilter().setEntityType(EntityNames.ISSUING_BIN);
		keys.getFilter().setObjectId(_activeBin.getId().longValue());
		keys.setNetworkId(_activeBin.getNetworkId());
		keys.setInstId(_activeBin.getInstId());
		keys.search();

		MbAupSchemeObjects schemeBean = (MbAupSchemeObjects) ManagedBeanWrapper.getManagedBean("MbAupSchemeObjects");
		schemeBean.fullCleanBean();
		schemeBean.setObjectId(_activeBin.getId().longValue());
		schemeBean.setDefaultEntityType(EntityNames.ISSUING_BIN);
		schemeBean.setInstId(_activeBin.getInstId());
		schemeBean.search();
		
		MbRsaKey mbRsaKey = (MbRsaKey) ManagedBeanWrapper.getManagedBean("MbRsaKey");
		mbRsaKey.clearFilter();
		mbRsaKey.setObjectId(_activeBin.getId().longValue());
		mbRsaKey.setSubjectId(_activeBin.getBin());
		mbRsaKey.setEntityType(EntityNames.ISSUING_BIN);
		mbRsaKey.setBottom(true);
		mbRsaKey.search();
		
		MbHmacKey mbHmacKey = (MbHmacKey) ManagedBeanWrapper.getManagedBean("MbHmacKey");
		mbHmacKey.clearFilter();
		mbHmacKey.getFilter().setObjectId(_activeBin.getId().longValue());
		mbHmacKey.getFilter().setEntityType(EntityNames.ISSUING_BIN);
		mbHmacKey.search();
		
		MbFraudObjects fraudObjectsBean = (MbFraudObjects) ManagedBeanWrapper.getManagedBean("MbFraudObjects");
		fraudObjectsBean.setObjectId(_activeBin.getId().longValue());
		fraudObjectsBean.setEntityType(EntityNames.ISSUING_BIN);
		fraudObjectsBean.search();

	}

	public void search() {
		clearState();
		clearBeansStates();
		getParamMap().clear();
		searching = true;		
	}

	public void clearFilter() {
		filter = null;
		clearState();
		searching = false;
	}

	public IssuerBin getFilter() {
		if (filter == null) {
			filter = new IssuerBin();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(IssuerBin filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("LANG");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("INST_ID");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}

		if (filter.getCardTypeId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("CARD_TYPE_ID");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getCardTypeId());
			filters.add(paramFilter);
		}

		if (filter.getNetworkId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("NETWORK_ID");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getNetworkId());
			filters.add(paramFilter);
		}

		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("DESCRIPTION");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().replaceAll("[*]", "%").replaceAll("[?]",
					"_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getBin() != null && filter.getBin().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("BIN");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getBin().trim().replaceAll("[*]", "%").replaceAll("[?]",
					"_").toUpperCase());
			filters.add(paramFilter);
		}
		getParamMap().put("param_tab", filters.toArray(new Filter[filters.size()]));
		getParamMap().put("tab_name", "BIN");
	}

	public void add() {
		newBin = new IssuerBin();
		newBin.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newBin = (IssuerBin) _activeBin.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newBin = _activeBin;
		}
		curMode = EDIT_MODE;
	}

	public void view() {

	}

	public void save() {
		try {
			if (isNewMode()) {
				newBin = _issuingDao.addIssBin(userSessionId, newBin);
				_itemSelection.addNewObjectToList(newBin);
			} else if (isEditMode()) {
				newBin = _issuingDao.modifyIssBin(userSessionId, newBin);
				_binsSource.replaceObject(_activeBin, newBin);
			}

			_activeBin = newBin;
			setInfo();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_issuingDao.deleteIssBin(userSessionId, _activeBin);
			_activeBin = _itemSelection.removeObjectFromList(_activeBin);

			if (_activeBin == null) {
				clearState();
			} else {
				setInfo();
			}
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void generateCert(){
		PEMWriter csrWriter = null;
		generated = false;
		X500Principal principal = null;
		try {
			principal = new X500Principal("CN=Duke, OU=JavaSoft, O=Sun Microsystems, C=US");
		} catch (IllegalArgumentException iae) {
			iae.printStackTrace();
		}
		
		
		try {

			final String SIGNATURE_ALGORITHM = "SHA1withRSA";

			Security.removeProvider("BpcThalesProvider");
			Security.addProvider(new BpcThalesProvider());

		 
			KeyPairGenerator generator = KeyPairGenerator.getInstance("RSA", "BpcThalesProvider");
			 
			BpcThalesKeyPairGeneratorParams params = new BpcThalesKeyPairGeneratorParams();
			params.setParam("bin_id", _activeBin.getId().toString());
			generator.initialize(params);
		
			KeyPair pair = generator.generateKeyPair();
			if (pair==null){
				FacesUtils.addMessageError(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Sec", "not_found_public_key", getDictUtils().getLovMap(LovConstants.ENCRYPTION_KEY_TYPES).get("ENKTACSC")));
				return;
			}
			PublicKey publicKey = pair.getPublic();
			PrivateKey privateKey = pair.getPrivate();

			@SuppressWarnings("deprecation")
			PKCS10CertificationRequest reqCert = new PKCS10CertificationRequest(SIGNATURE_ALGORITHM, principal, publicKey, null, privateKey, "BpcThalesProvider");

			HttpServletRequest request = RequestContextHolder.getRequest();
			HttpSession session = request.getSession();
			
			ByteArrayOutputStream outStream = new ByteArrayOutputStream();
			try{
				csrWriter = new PEMWriter(new PrintWriter(outStream));
				csrWriter.writeObject(reqCert);
				csrWriter.flush();
			}finally{
				csrWriter.close();
			}

			session.setAttribute(FileServlet.FILE_SERVLET_CONTENT_TYPE, "application/x-download");
			session.setAttribute(FileServlet.FILE_SERVLET_FILE_CONTENT, outStream.toByteArray());
			generated = true;
			
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} 
	}
	


	public boolean isGenerated() {
		return generated;
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public IssuerBin getNewBin() {
		if (newBin == null) {
			newBin = new IssuerBin();
		}
		return newBin;
	}

	public void setNewBin(IssuerBin newBin) {
		this.newBin = newBin;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeBin = null;
		_binsSource.flushCache();
		curLang = userLang;

		clearBeansStates();
	}

	public void clearBeansStates() {
		MbIssBinIndexRangesSearch rangesSearch = (MbIssBinIndexRangesSearch) ManagedBeanWrapper
				.getManagedBean("MbIssBinIndexRangesSearch");
		rangesSearch.clearState();
		rangesSearch.setFilter(null);
		rangesSearch.setSearching(false);

		MbDesKeysBottom keys = (MbDesKeysBottom) ManagedBeanWrapper.getManagedBean("MbDesKeysBottom");
		keys.fullCleanBean();

		MbAupSchemeObjects schemeBean = (MbAupSchemeObjects) ManagedBeanWrapper.getManagedBean("MbAupSchemeObjects");
		schemeBean.fullCleanBean();
		
		MbRsaKey mbRsaKey = (MbRsaKey) ManagedBeanWrapper.getManagedBean("MbRsaKey");
		mbRsaKey.clearFilter();
		
		MbHmacKey mbHmacKey = (MbHmacKey) ManagedBeanWrapper.getManagedBean("MbHmacKey");
		mbHmacKey.clearFilter();
		
		MbFraudObjects suiteObjectBean = (MbFraudObjects) ManagedBeanWrapper.getManagedBean("MbFraudObjects");
		suiteObjectBean.fullCleanBean();
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeBin.getId().toString());
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
			IssuerBin[] bins = _issuingDao.getIssBins(userSessionId, params);
			if (bins != null && bins.length > 0) {
				_activeBin = bins[0];
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

	public ArrayList<SelectItem> getNetworks() {
		if (networks == null) {
			ArrayList<SelectItem> items = new ArrayList<SelectItem>();
			try {
				SelectionParams params = new SelectionParams();
				params.setRowIndexEnd(-1);

				List<Filter> filtersList = new ArrayList<Filter>();
				Filter paramFilter = new Filter();
				paramFilter.setElement("lang");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(userLang);
				filtersList.add(paramFilter);

				params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));

				Network[] nets = _networkDao.getNetworks(userSessionId, params);
				for (Network net: nets) {
					items.add(new SelectItem(net.getId(), net.getId() + " - " + net.getName(), net
							.getDescription()));
				}
				networks = items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			} finally {
				if (networks == null)
					networks = new ArrayList<SelectItem>();
			}
		}
		return networks;
	}

	public ArrayList<SelectItem> getCardTypes() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		if (newBin == null) return items;
		try {
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(-1);

			List<Filter> filtersList = new ArrayList<Filter>();
			Filter paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setValue(userLang);
			filtersList.add(paramFilter);

			paramFilter = new Filter();
			paramFilter.setElement("networkId");
			paramFilter.setValue(newBin.getNetworkId());
			filtersList.add(paramFilter);

			params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));

			CardType[] types = _networkDao.getCardTypes(userSessionId, params);
			for (CardType type : types) {
				String name = type.getName();
				for (int i = 1; i < type.getLevel(); i++) {
					name = " -- " + name;
				}
				SelectItem item = new SelectItem(type.getId(), type.getId() + " - " + name);
				if (type.getLevel() == 1){
					item.setDisabled(true);
				}
				items.add(item);
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}
		return items;
	}

	public void editLanguage(ValueChangeEvent event) {
		oldLang = (String) event.getOldValue();
	}

	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newBin.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newBin.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			IssuerBin[] items = _issuingDao.getIssBins(userSessionId, params);
			if (items != null && items.length > 0) {
				newBin.setName(items[0].getName());
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancelEditLanguage() {
		newBin.setLang(oldLang);
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}
	
	public String[] getDataImageCss() {
		return new String[]{"", "flag af", "flag al", "flag dz", "flag as", "flag ad", "flag ao", "flag ai", "flag aq", "flag ag", "flag ar", "flag am", "flag aw", "flag au", "flag at", "flag az", "flag bs", "flag bh", "flag bd", "flag bb", "flag by", "flag be", "flag bz", "flag bj", "flag bm", "flag bt", "flag bo", "flag ba", "flag bw", "flag bv", "flag br", "flag io", "flag bn", "flag bg", "flag bf", "flag bi", "flag kh", "flag cm", "flag ca", "flag ??", "flag cv", "flag ky", "flag cf", "flag td", "flag cl", "flag cn", "flag cx", "flag cc", "flag co", "flag km", "flag cg", "flag cg", "flag ck", "flag cr", "flag ci", "flag hr", "flag cu", "flag cy", "flag cz", "flag ??", "flag dk", "flag dj", "flag dm", "flag do", "flag ec", "flag eg", "flag sv", "flag gq", "flag er", "flag ee", "flag et", "flag fk", "flag fo", "flag fj", "flag fi", "flag fr", "flag gf", "flag pf", "flag tf", "flag ga", "flag gm", "flag ge", "flag ??", "flag de", "flag gh", "flag gi", "flag gr", "flag gl", "flag gd", "flag gp", "flag gu", "flag gt", "flag gn", "flag gw", "flag gy", "flag ht", "flag hm", "flag va", "flag hn", "flag hk", "flag hu", "flag is", "flag in", "flag id", "flag ir", "flag iq", "flag ie", "flag il", "flag it", "flag jm", "flag jp", "flag ??", "flag jo", "flag kz", "flag ke", "flag ki", "flag kp", "flag kr", "flag ??", "flag kw", "flag kg", "flag la", "flag lv", "flag lb", "flag ls", "flag lr", "flag ly", "flag li", "flag lt", "flag lu", "flag mo", "flag mk", "flag mg", "flag mw", "flag my", "flag mv", "flag ml", "flag mt", "flag mh", "flag mq", "flag mr", "flag mu", "flag mx", "flag ??", "flag ??", "flag md", "flag mc", "flag mn", "flag ??", "flag ms", "flag ma", "flag mz", "flag mm", "flag na", "flag nr", "flag np", "flag nl", "flag an", "flag ??", "flag nc", "flag nz", "flag ni", "flag ne", "flag ng", "flag nu", "flag nf", "flag mp", "flag no", "flag om", "flag ??", "flag pk", "flag pw", "flag ps", "flag pa", "flag pg", "flag py", "flag pe", "flag ph", "flag pn", "flag pl", "flag pt", "flag pr", "flag qa", "flag cs", "flag re", "flag ro", "flag ru", "flag rw", "flag sh", "flag kn", "flag lc", "flag pm", "flag ws", "flag sm", "flag st", "flag sa", "flag sn", "flag sc", "flag sl", "flag sg", "flag sk", "flag si", "flag sb", "flag so", "flag za", "flag es", "flag lk", "flag ??", "flag sd", "flag sr", "flag sj", "flag sz", "flag se", "flag ch", "flag sy", "flag tw", "flag tj", "flag tz", "flag th", "flag tl", "flag tg", "flag tk", "flag to", "flag tt", "flag tn", "flag tr", "flag tm", "flag tc", "flag tv", "flag ug", "flag ua", "flag ??", "flag ae", "flag uk", "flag us", "flag ??", "flag uy", "flag um", "flag uz", "flag vu", "flag ve", "flag vn", "flag vg", "flag vi", "flag ??", "flag wf", "flag eh", "flag ye", "flag ??", "flag yu", "flag zm", "flag zw"};
	}
	
	public String getCtxItemEntityType() {
		return ctxItemEntityType;
	}

	public void setCtxItemEntityType() {
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		String ctx = ctxBean.getEntityType();
		if (ctx == null || !ctx.equals(this.ctxItemEntityType)){
			ctxType = ContextTypeFactory.getInstance(ctx);
		}
		this.ctxItemEntityType = ctx;
	}
	
	public ContextType getCtxType(){
		if (ctxType == null) return null;
		Map <String, Object> map = new HashMap<String, Object>();

		if (EntityNames.INSTITUTION.equals(ctxItemEntityType)) {
			 if (_activeBin != null)
				 map.put("id", _activeBin.getInstId());
			 	 map.put("instId", _activeBin.getInstId());
		}

		ctxType.setParams(map);
		return ctxType;
	}
	
	public boolean isForward(){
		return true;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		if (tabName.equalsIgnoreCase("rangeTab")) {
			MbIssBinIndexRangesSearch bean = (MbIssBinIndexRangesSearch) ManagedBeanWrapper
					.getManagedBean("MbIssBinIndexRangesSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("keysTab")) {
			MbDesKeysBottom bean = (MbDesKeysBottom) ManagedBeanWrapper
					.getManagedBean("MbDesKeysBottom");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("schemesTab")) {
			MbAupSchemeObjects bean = (MbAupSchemeObjects) ManagedBeanWrapper
					.getManagedBean("MbAupSchemeObjects");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("rsaKeysTab")) {
			MbRsaKey bean = (MbRsaKey) ManagedBeanWrapper
					.getManagedBean("MbRsaKey");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("hmacKeysTab")) {
			MbHmacKey bean = (MbHmacKey) ManagedBeanWrapper
					.getManagedBean("MbHmacKey");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("suitesTab")) {
			MbFraudObjects bean = (MbFraudObjects) ManagedBeanWrapper.getManagedBean("MbFraudObjects");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.ISSUING_CONFIG_BIN;
	}

	public Map<String, Object> getParamMap() {
		if (paramMap == null){
			paramMap = new HashMap<String, Object>();
		}
		return paramMap;
	}

	public void setParamMap(Map<String, Object> paramMap) {
		this.paramMap = paramMap;
	}
	
	public boolean isUseHsm(){
		if (useHsm == null) {
			Double value = _settingsDao.getParameterValueN(null,
				SettingsConstants.USE_HSM, LevelNames.SYSTEM, null);
			useHsm = (value == 1);
		}
		return useHsm;
	}
}
