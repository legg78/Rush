package ru.bpc.sv2.ui.process.files;

import org.ajax4jsf.model.ExtendedDataModel;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.SessionFile;
import ru.bpc.sv2.ui.utils.*;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.context.FacesContext;
import javax.servlet.http.HttpServletResponse;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

@ViewScoped
@ManagedBean(name = "MbConfigurationFiles")
public class MbConfigurationFiles extends AbstractBean{
	private static final Logger logger = Logger.getLogger("PROCESSES");
	
	private ProcessDao processDAO = new ProcessDao();
	
	private Long sessionId;
	private SessionFile activeItem;
	private final DaoDataModel<SessionFile> daoDataModel;
	private final TableRowSelection<SessionFile> tableRowSelection;
	
	private String comment;

	/* Disabled functionality related to SVN as project is switched to Git
	private SvnCommit commitEditor;
	*/
	
	private boolean monitor;
	private boolean downloading;
	
	public MbConfigurationFiles() {
		daoDataModel = new DaoDataModel<SessionFile>() {
			@Override
			protected SessionFile[] loadDaoData(SelectionParams params) {
				if (sessionId != null) {
					try {
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters.size()]));
						SessionFile[] SessionFiles = processDAO.getSessionFilesContent( userSessionId, params, true);
						return SessionFiles;
					} catch (Exception e) {
						setDataSize(0);
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				}
				return new SessionFile[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (sessionId != null) {
					try {
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters.size()]));
						return processDAO.getSessionFilesCount( userSessionId, params, true);
					} catch (Exception e) {
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				}
				return 0;
			}
		};
		tableRowSelection = new TableRowSelection<SessionFile>(null, daoDataModel);
		
				
	}	


	public ExtendedDataModel getFiles(){
		return daoDataModel;
	}

	public void setFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		Filter paramFilter;
		if (sessionId != null) {
			paramFilter = new Filter();
			paramFilter.setElement("sessionId");
			paramFilter.setValue(sessionId.toString());
			filtersList.add(paramFilter);
		}
		
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filtersList.add(paramFilter);
		
		filters = filtersList;
	}

	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
		clear();
	}
	
	private void clear(){
		daoDataModel.flushCache();
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		clearState();		
	}

	public SessionFile getActiveItem() {
		return activeItem;
	}

	public void setActiveItem(SessionFile activeItem) {
		this.activeItem = activeItem;
	}
	
	public SimpleSelection getItemSelection() {
		if (activeItem == null && daoDataModel.getRowCount() > 0) {
//			prepareItemSelection();
		}
		return tableRowSelection.getWrappedSelection();
	}

	public void prepareItemSelection() {
		daoDataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (SessionFile) daoDataModel.getRowData();
		selection.addKey(activeItem.getModelId());
		tableRowSelection.setWrappedSelection(selection);
		if (activeItem != null) {
			//setBeansState();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		tableRowSelection.setWrappedSelection(selection);
		activeItem = tableRowSelection.getSingleSelection();
		if (activeItem != null) {
			//setBeansState();
		}
	}

	public void clearState() {
		tableRowSelection.clearSelection();
		activeItem = null;
		daoDataModel.flushCache();
		curLang = userLang;
	}
	
	public void clearBean() {
		tableRowSelection.clearSelection();
		activeItem = null;
		daoDataModel.flushCache();
		searching = false;
	}

	public void fullCleanBean() {
		sessionId = null;
		clearBean();
	}
	
	public void viewFile() {
		
	}
	
	public void initCommit() {
		comment = "";
	}
	
	public void commitFiles() {
		/* Disabled functionality related to SVN as project is switched to Git
		List<SessionFile> files = daoDataModel.getActivePage();
		try {
			commitEditor.commitFiles(files, comment);
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		} finally {
			//always stop monitoring
			monitor = false;
		}
		*/
		monitor = false;
	}
	
	public void downloadZip() {
		downloading = true;
		List<SessionFile> files = daoDataModel.getActivePage();
		FacesContext context = FacesContext.getCurrentInstance();
//			HttpServletResponse response = (HttpServletResponse)context.getExternalContext().getResponse();
		HttpServletResponse response = RequestContextHolder.getResponse();
		response.setHeader("Pragma", "no-cache");
		response.setContentType("application/zip");
		response.setHeader("Content-Disposition","attachment; filename=configuration.zip;");
		try {
			OutputStream output = response.getOutputStream();
			byte[] fileBin = getZipConfigurationScript(files);
			output.write(fileBin);
			output.close();
		} catch (IOException e) {
			logger.error("", e);
		}
		context.responseComplete();
		downloading = false;
	}
	
	private byte[] getZipConfigurationScript(List<SessionFile> files) throws IOException{
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		ZipOutputStream zout = new ZipOutputStream(out);
		OutputStreamWriter writer = new OutputStreamWriter(zout);
		
		for (SessionFile file: files) {
			String fileName = file.getFileName();
			String fileContent = file.getFileContents() == null ? "" : file.getFileContents();
			
    		writer.flush();
    		zout.closeEntry();
    		ZipEntry zipEntry = new ZipEntry(fileName);
    		zout.putNextEntry(zipEntry);	        		
			writer.write(fileContent);				
		}
		
		writer.flush();
		zout.closeEntry();
		zout.close();		
		return out.toByteArray();
	}
	

	public String getComment() {
		return comment;
	}

	public void setComment(String comment) {
		this.comment = comment;
	}


	/* Disabled functionality related to SVN as project is switched to Git
	public SvnCommit getCommitEditor() {
		return commitEditor;
	}
	
	public void setCommitEditor(SvnCommit commitEditor) {
		this.commitEditor = commitEditor;
	}
	*/

	public void checkMonitor() {
		logger.debug("Monitor running...");
	}
	
	public void checkDownloading() {
		logger.debug("Downloading zip ...");
	}

	public boolean isMonitor() {
		return monitor;
	}

	public void setMonitor(boolean monitor) {
		this.monitor = monitor;
	}
	
	public void close() {
		if (getFiles().getRowCount() > 0){
			try{
				processDAO.removeFileConfiguration(userSessionId, sessionId);
			}	catch (Exception e) {
				logger.error("", e);
				FacesUtils.addMessageError(e);
			}
		}
		monitor = false;
	}

	public boolean isDownloading() {
		return downloading;
	}

	public void setDownloading(boolean downloading) {
		this.downloading = downloading;
	}

	public void turnonMonitor() {
		monitor = true;
	}
}
