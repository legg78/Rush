package ru.bpc.sv2.ui.process.files;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.process.ProcessFileDirectory;
import ru.bpc.sv2.process.file.LineSeparator;
import ru.bpc.sv2.reports.Report;
import ru.bpc.sv2.reports.ReportTemplate;
import ru.bpc.sv2.scheduler.process.SignatureEncryptor;
import ru.bpc.sv2.ui.utils.*;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamSource;
import java.io.IOException;
import java.io.StringReader;
import java.nio.charset.Charset;
import java.util.*;

@ViewScoped
@ManagedBean (name = "MbFileAttributesSearch")
public class MbFileAttributesSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("PROCESSES");
	private static final long serialVersionUID = 1L;
	private static String COMPONENT_ID = "accountsTable";

	private ProcessDao _processDao = new ProcessDao();
	private ReportsDao _reportsDao = new ReportsDao();
	private SettingsDao _settingsDao = new SettingsDao();

	private ProcessFileAttribute activeFileAttribute;
	private ProcessFileAttribute filter;
	private ProcessFileAttribute newFileAttribute;
	private ArrayList<SelectItem> institutions;

	private final DaoDataModel<ProcessFileAttribute> _fileAttributesSource;
	private final TableRowSelection<ProcessFileAttribute> _itemSelection;

	private String warningMsg;
	private String tabName;
	private String parentSectionId;
	private boolean encryptedLocation;
	private boolean showDialog = false;
	private Long oldLocation;
	private List<SelectItem> directories = null;
	private List<SelectItem> mergeFileModes = null;

	public MbFileAttributesSearch() {
		_fileAttributesSource = new DaoDataModel<ProcessFileAttribute>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected ProcessFileAttribute[] loadDaoData(SelectionParams params) {
				try {
					if (isSearching()) {
						setFilters();
						params.setFilters(filters);
						return _processDao.getFileAttributes(userSessionId, params, true);
					}
				} catch (Exception ee) {
					setDataSize(0);
					FacesUtils.addMessageError(ee);
					logger.error("", ee);
				}
				return new ProcessFileAttribute[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				try {
					if (isSearching()) {
						setFilters();
						params.setFilters(filters);
						return _processDao.getFileAttributesCount(userSessionId, params, true);
					}
				} catch (Exception ee) {
					FacesUtils.addMessageError(ee);
					logger.error("", ee);
				}
				return 0;
			}
		};
		_itemSelection = new TableRowSelection<ProcessFileAttribute>(null, _fileAttributesSource);
	}

	public DaoDataModel<ProcessFileAttribute> getProcessFileAttributes() {
		return _fileAttributesSource;
	}

	public ProcessFileAttribute getActiveProcessFileAttribute() {
		return activeFileAttribute;
	}

	public void setActiveProcessFileAttribute(ProcessFileAttribute activeProcessFileAttribute) {
		this.activeFileAttribute = activeProcessFileAttribute;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (activeFileAttribute == null && _fileAttributesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (activeFileAttribute != null && _fileAttributesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(activeFileAttribute.getModelId());
				_itemSelection.setWrappedSelection(selection);
				activeFileAttribute = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_fileAttributesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeFileAttribute = (ProcessFileAttribute) _fileAttributesSource.getRowData();
		selection.addKey(activeFileAttribute.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		activeFileAttribute = _itemSelection.getSingleSelection();
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();
		filters.add(Filter.create("lang", curLang));

		if (getFilter().getFileId() != null) {
			filters.add(Filter.create("fileId", getFilter().getFileId().toString()));
		}
		if (getFilter().getContainerId() != null) {
			filters.add(Filter.create("containerId", getFilter().getContainerId().toString()));
		}
		if (getFilter().getInstId() != null) {
			filters.add(Filter.create("instId", getFilter().getInstId().toString()));
		}
	}

	public ProcessFileAttribute getFilter() {
		if (filter == null) {
			filter = new ProcessFileAttribute();
		}
		return filter;
	}

	public void setFilter(ProcessFileAttribute filter) {
		this.filter = filter;
	}

	public ProcessFileAttribute getActiveFileAttribute() {
		return activeFileAttribute;
	}

	public void setActiveFileAttribute(ProcessFileAttribute activeFileAttribute) {
		this.activeFileAttribute = activeFileAttribute;
	}

	public void add() {
		curMode = NEW_MODE;
		newFileAttribute = new ProcessFileAttribute();
		newFileAttribute.setCharacterSet(SystemConstants.DEFAULT_CHARSET);
	}

	public void delete() {
		try {
			_processDao.deleteFileAttribute(userSessionId, activeFileAttribute);
			activeFileAttribute = _itemSelection.removeObjectFromList(activeFileAttribute);
			if (activeFileAttribute == null) {
				clearState();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void view() {
		curMode = VIEW_MODE;
	}

	public void edit() {
		try {
			newFileAttribute = activeFileAttribute.clone();
			oldLocation = newFileAttribute.getLocationId();
			checkLocationId();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newFileAttribute = activeFileAttribute;
		}
		if (newFileAttribute.getId() == null) {
			curMode = NEW_MODE;
			newFileAttribute.setCharacterSet(SystemConstants.DEFAULT_CHARSET);
		} else {
			curMode = EDIT_MODE;
		}
	}
	
	private void checkLocationId(){
		if (newFileAttribute.getLocationId() != null){
			setEncryptedLocation(_processDao.checkDirectory(userSessionId,
					newFileAttribute.getLocationId()));
		} else {
			setEncryptedLocation(false);
		}
	}

	public void save() {
		warningMsg = "";
		if (!checkLocation() || !checkEncoding()) {
			return;
		}
		finishSaving();
	}

	public void finishSaving() {
		warningMsg = "";
		if (!checkXslt()) {
			return;
		}
		try {
			String fileEncryptionKey = null;
			if (newFileAttribute.isModifyEncryptionKey()) {
				Class<?> classDefinition = Class.forName(newFileAttribute.getEncryptionPlugin());
				SignatureEncryptor sigEnc = (SignatureEncryptor) classDefinition.newInstance();
				fileEncryptionKey = sigEnc.encryptKey(newFileAttribute.getFileEncryptionKey());
			}

			if (isNewMode()) {
				newFileAttribute = _processDao.addFileAttribute(userSessionId, newFileAttribute, userLang, fileEncryptionKey);
				_itemSelection.addNewObjectToList(newFileAttribute);
				_fileAttributesSource.removeObjectFromList(activeFileAttribute);
			} else if (isEditMode()) {
				newFileAttribute = _processDao.modifyFileAttribute(userSessionId, newFileAttribute, userLang, fileEncryptionKey);
				_fileAttributesSource.replaceObject(activeFileAttribute, newFileAttribute);
			}

			activeFileAttribute = newFileAttribute;
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public void close() {
		warningMsg = "";
	}

	public void clearState() {
		_fileAttributesSource.flushCache();
		_itemSelection.clearSelection();
		activeFileAttribute = null;

		curLang = userLang;
	}

	public ProcessFileAttribute getNewProcessFileAttribute() {
		if (newFileAttribute == null) {
			newFileAttribute = new ProcessFileAttribute();
		}
		return newFileAttribute;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public List<SelectItem> getNameFormats() {
		Integer instId = null;
		if (getFilter().getInstId() == null) {
			instId = 9999;
		} else {
			instId = getFilter().getInstId();
		}
		Map<String, Object> params = new HashMap<String, Object>(2);
		params.put("ENTITY_TYPE", EntityNames.FILE);
		params.put("INSTITUTION_ID", instId);
		return getDictUtils().getLov(LovConstants.NAME_FORMATS, params);
	}

	public void checkEncryptedLocation(){
		if (encryptedLocation) {
			setEncryptedLocation(_processDao.checkDirectory(userSessionId, newFileAttribute.getLocationId()));
			if (!encryptedLocation){
				showDialog = true;
			}
		}
	}

	private boolean checkLocation() {
		refreshLocation();
		if (newFileAttribute.getLocation() == null) {
			return true;
		}
		String location = _processDao.resolvePath(newFileAttribute.getLocation(), userSessionId);
		try {
			CommonUtils.checkFilepath(location, true, newFileAttribute.isIncoming(), newFileAttribute.isOutgoing());
		} catch (IOException e) {		
			setWarningMsg(e.getMessage());
			return false;
		}
		return true;		
	}
	
	private boolean checkEncoding() {
		String charSet = newFileAttribute.getCharacterSet();
		Set<String> acs = Charset.availableCharsets().keySet();
		if (StringUtils.isEmpty(charSet)) {
		    warningMsg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "charset_empty");
			return (false);
		}
		if (!acs.contains(charSet)) {
			warningMsg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
					"charset_not_supported", charSet, StringUtils.abbreviate(acs.toString(), 4000) + "]");	
			return false;
		}
		return true;
	}
	
	
	private void refreshLocation(){
		try {
			ProcessFileDirectory []fd = null;
			SelectionParams params = SelectionParams.build("lang", curLang, "id", newFileAttribute.getLocationId());			
			params.setRowIndexEnd(1);
			fd = _processDao.getProcessFileDirectories(userSessionId, params);
			if ((fd != null) && (fd.length > 0)){
				newFileAttribute.setLocation(fd[0].getDirectoryPath());
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("Cannot get location information!", e);
		}
	}

	public String getWarningMsg() {
		return warningMsg;
	}

	public void setWarningMsg(String warningMsg) {
		this.warningMsg = warningMsg;
	}
	
	public List<SelectItem> getReports() {
		if (getNewProcessFileAttribute() != null && getFilter().getInstId() != null) {
			Filter[] filters = new Filter[2];
			filters[0] = new Filter("lang", curLang);
			filters[1] = new Filter("instId", filter.getInstId());
						
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(Integer.MAX_VALUE);
			params.setFilters(filters);
			try {
				Report[] reports = _reportsDao.getReportsLight(userSessionId, params);
				List<SelectItem> items = new ArrayList<SelectItem>(reports.length);
				for (Report report : reports) {
					items.add(new SelectItem(report.getId(), report.getName()));
				}
				return items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			}
		}
		return new ArrayList<SelectItem>(0);
	}
	
	public List<SelectItem> getReportTemplates() {
		if (getNewProcessFileAttribute() != null && getNewProcessFileAttribute().getReportId() != null) {
			Filter[] filters = new Filter[2];
			filters[0] = new Filter("lang", curLang);
			filters[1] = new Filter("reportId", newFileAttribute.getReportId());
			
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(Integer.MAX_VALUE);
			params.setFilters(filters);
			try {
				ReportTemplate[] templates = _reportsDao.getReportTemplates(userSessionId, params);
				List<SelectItem> items = new ArrayList<SelectItem>(templates.length);
				for (ReportTemplate template : templates) {
					items.add(new SelectItem(template.getId(), template.getName()));
				}
				return items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			}
		}
		return new ArrayList<SelectItem>(0);
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
	}

	private boolean checkXslt() {
		boolean result = true;
		if (newFileAttribute.getXsltSource() != null) {
			newFileAttribute.setXsltSource(newFileAttribute.getXsltSource().trim());
			if (newFileAttribute.getXsltSource().length() > 0) {
				try {
					TransformerFactory tFactory = TransformerFactory.newInstance();
					tFactory.newTransformer(new StreamSource(new StringReader(newFileAttribute
							.getXsltSource())));
				} catch (TransformerConfigurationException e) {
					result = false;
					logger.error("", e);
					FacesUtils.addMessageError(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
							"malformed_xslt"));
				}
			} else {
				newFileAttribute.setXsltSource(null);
			}
		}
		return result;
	}

	public List<SelectItem> getSignatureTypes() {
		return getDictUtils().getArticles(DictNames.FILE_SIGNATURE_TYPE);
	}

	public void resetEncPlugin() {
		if (!newFileAttribute.isSigned()) {
			newFileAttribute.setEncryptionPlugin(null);
		}
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

	public boolean isEncryptedLocation() {
		return encryptedLocation;
	}

	public void setEncryptedLocation(boolean encryptedLocation) {
		this.encryptedLocation = encryptedLocation;
	}

	public boolean isShowDialog() {
		return showDialog;
	}

	public void setShowDialog(boolean showDialog) {
		this.showDialog = showDialog;
	}

	public Long getOldLocation() {
		return oldLocation;
	}

	public void setOldLocation(Long oldLocation) {
		this.oldLocation = oldLocation;
	}

	public void replaceLocation(){
		newFileAttribute.setLocationId(oldLocation);
	}

	public List<SelectItem> getDirectories() {
		if (directories == null){
			directories = getDictUtils().getLov(LovConstants.DIRECTORIES);
			for (SelectItem dir : directories) {
				dir.setLabel(_processDao.resolvePath(dir.getLabel(), null));
			}
		}
		return directories;
	}

	public void setDirectories(List<SelectItem> directories) {
		this.directories = directories;
	}

	public LineSeparator[] getLineSeparators() {
		return LineSeparator.values();
	}

	public void resetPasswordProtect() {
		if (!newFileAttribute.isReportSet()) {
			newFileAttribute.setIsPasswordProtect(Boolean.FALSE);
		}
	}

	public List<SelectItem> getMergeFileModes() {
		if (mergeFileModes == null) {
			mergeFileModes = getDictUtils().getLov(LovConstants.MERGE_FILES_MODE);
		}
		return mergeFileModes;
	}

	public boolean isMergeFileModeEnable() {
		if (newFileAttribute != null) {
			return StringUtils.isNotBlank(newFileAttribute.getPostSaverClass());
		}
		return false;
	}
}
