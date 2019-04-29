package ru.bpc.sv2.ui.process.files;

import java.io.StringReader;
import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.SchemaFactory;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import org.xml.sax.SAXException;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.ProcessFile;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbProcessFilesSearch")
public class MbProcessFilesSearch extends AbstractBean{
	private ProcessDao processDao = new ProcessDao();

	private ProcessFile activeProcessFile;
	
	private ProcessFile filter;
	private ProcessFile newProcessFile;
	
	private final DaoDataModel<ProcessFile> _processFilesSource;

	private final TableRowSelection<ProcessFile> _itemSelection;
	private static final Logger logger = Logger.getLogger("PROCESSES");
	
	private static String COMPONENT_ID = "accountsTable";
	private String tabName;
	private String parentSectionId;
	
	private List<SelectItem> fileNatures;
	private List<SelectItem> filePurposes;
	private List<SelectItem> fileTypes;
	private List<SelectItem> fileSavers;
	
	public MbProcessFilesSearch() {
		
		
		_processFilesSource = new DaoDataModel<ProcessFile>() {
			@Override
			protected ProcessFile[] loadDaoData(SelectionParams params) {
				try {
					if (!isSearching() || getFilter().getProcessId() == null) {
						return new ProcessFile[0];
					}
					setFilters();					
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return processDao.getProcessFiles( userSessionId, params);
				} catch (Exception ee) {
					setDataSize(0);
					FacesUtils.addMessageError(ee);
					logger.error("",ee);
				}
				return new ProcessFile[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				try {
					if (!isSearching() || getFilter().getProcessId() == null) {
						return 0;
					}
					setFilters();					
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return processDao.getProcessFilesCount( userSessionId, params);
				} catch (Exception ee) {
					FacesUtils.addMessageError(ee);
					logger.error("",ee);
				}
				return 0;
			}
		};
		_itemSelection = new TableRowSelection<ProcessFile>(null, _processFilesSource);
	}

	public DaoDataModel<ProcessFile> getProcessFiles() {
		return _processFilesSource;
	}

	public ProcessFile getActiveProcessFile() {
		return activeProcessFile;
	}

	public void setProcessFile(ProcessFile activeProcessFile) {
		this.activeProcessFile = activeProcessFile;
	}

	public SimpleSelection getItemSelection() {
		if (activeProcessFile == null && _processFilesSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		else if (activeProcessFile != null && _processFilesSource.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(activeProcessFile.getModelId());
			_itemSelection.setWrappedSelection(selection);
			activeProcessFile = _itemSelection.getSingleSelection();			
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_processFilesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeProcessFile = (ProcessFile) _processFilesSource.getRowData();
		selection.addKey(activeProcessFile.getModelId());
		_itemSelection.setWrappedSelection(selection);
		setInfo();		
	}
	
	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection( selection );
		activeProcessFile = _itemSelection.getSingleSelection();
		setInfo();		
	}

	public void setInfo() {		
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void setFilters() {
		
		filters = new ArrayList<Filter>();
		filter = getFilter();
		Filter paramFilter = null;
		
		if (filter.getProcessId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("processId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getProcessId().toString());
			filters.add(paramFilter);
		}
		if (filter.getPurpose() != null
				&& filter.getPurpose().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("purpose");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getPurpose());
			filters.add(paramFilter);
		}
		if (filter.getShortDesc() != null && filter.getShortDesc().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("shortDesc");
			paramFilter.setOp(Operator.like);
			String shortDesc = filter.getShortDesc().trim().toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_");
			paramFilter.setValue((!shortDesc.endsWith("%"))?shortDesc.concat("%"):shortDesc);
			
			filters.add(paramFilter);
		}
		
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);		
	}

	public ProcessFile getFilter() {
		if (filter == null)
			filter = new ProcessFile();
		return filter;
	}

	public void setFilter(ProcessFile filter) {
		this.filter = filter;
	}

	public void add() {
		newProcessFile = new ProcessFile();
		newProcessFile.setLang(userLang);
		curMode = NEW_MODE;		
	}

	public void edit() {
		curMode = EDIT_MODE;
		try {
			newProcessFile = activeProcessFile.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("",e);
			newProcessFile = activeProcessFile;
		}
	}

	public void save() {
		if (!checkXsd()) {
			return;
		}
		try {
			newProcessFile.setProcessId(getFilter().getProcessId());
			if (isEditMode()) {
				newProcessFile = processDao.modifyProcessFile( userSessionId, newProcessFile);
				_processFilesSource.replaceObject(activeProcessFile, newProcessFile);
			} else if (isNewMode()) {
				newProcessFile = processDao.addProcessFile( userSessionId, newProcessFile);
				_itemSelection.addNewObjectToList(newProcessFile);
			}
			
			activeProcessFile = newProcessFile;
			setInfo();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}

	public void delete() {
		try {
			processDao.deleteProcessFile( userSessionId, activeProcessFile);
			activeProcessFile = _itemSelection.removeObjectFromList(activeProcessFile);
			if (activeProcessFile == null) {
				clearState();
			} else {
				setInfo();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}

	public void view() {				
		curMode = VIEW_MODE;
	}

	public void clearState() {
		_processFilesSource.flushCache();
		_itemSelection.clearSelection();
		activeProcessFile = null;
		curLang = userLang;
		
		clearBeansStates();
	}

	private void clearBeansStates() {
		MbFileAttributesSearch fileAttrSearchBean = (MbFileAttributesSearch) ManagedBeanWrapper.getManagedBean("MbFileAttributesSearch");
		fileAttrSearchBean.clearState();
	}
	
	public void close() {
		newProcessFile = null;
	}

	public ProcessFile getNewProcessFile() {
		return newProcessFile;
	}

	public List<SelectItem> getFileNatures() {
		if (fileNatures == null) {
			fileNatures = getDictUtils().getLov(LovConstants.FILE_NATURES);
		}
		return fileNatures;
	}

	public List<SelectItem> getProcessFilesTypes() {
		if (fileTypes == null) {
			fileTypes = getDictUtils().getArticles(DictNames.PROCESS_FILE_TYPE, false, true);
		}
		return fileTypes;
	}
	
	public List<SelectItem> getProcessFileSavers() {
		if (fileSavers == null) {
			fileSavers  = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.FILE_SAVERS);
		}
		return fileSavers;
	}

	public List<SelectItem> getProcessPurposes() {
		if (filePurposes == null) {
			filePurposes = getDictUtils().getArticles(DictNames.PROCESS_FILE_PURPOSE, true, true);
		}
		return filePurposes;
	}
	
	public void changeLanguage(ValueChangeEvent event) {	
		curLang = (String)event.getNewValue();
		_processFilesSource.flushCache();
	}

	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newProcessFile.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newProcessFile.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			ProcessFile[] processFiles = processDao.getProcessFiles( userSessionId, params);
			if (processFiles != null && processFiles.length > 0) {
				newProcessFile = processFiles[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}

	private boolean checkXsd() {
		boolean result = true;
		if (newProcessFile.getXsdSource() != null) {
			newProcessFile.setXsdSource(newProcessFile.getXsdSource().trim());
			if (newProcessFile.getXsdSource().length() > 0) {
				try {
					SchemaFactory schemaFactory = SchemaFactory
							.newInstance("http://www.w3.org/2001/XMLSchema");
					schemaFactory.newSchema(new StreamSource(new StringReader(newProcessFile
							.getXsdSource())));
				} catch (SAXException e) {
					result = false;
					logger.error("", e);
					FacesUtils.addMessageError(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
							"malformed_xsd"));
				}
			} else {
				newProcessFile.setXsdSource(null);
			}
		}
		return result;
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
