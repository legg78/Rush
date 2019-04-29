package ru.bpc.sv2.ui.process.monitoring;

import org.ajax4jsf.model.ExtendedDataModel;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.io.IOUtils;
import org.apache.commons.vfs.FileObject;
import org.apache.commons.vfs.FileSelector;
import org.apache.commons.vfs.FileSystemManager;
import org.apache.commons.vfs.FileType;
import org.apache.commons.vfs.VFS;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.common.CommonWizardStepInfo;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.logic.utility.JndiUtils;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.utils.DBUtils;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.process.ProcessLaunchParameter;
import ru.bpc.sv2.process.SessionFile;
import ru.bpc.sv2.scheduler.OutgoingFilesGenerator;
import ru.bpc.sv2.scheduler.process.AsyncProcessHandler;
import ru.bpc.sv2.scheduler.process.FileSaver;
import ru.bpc.sv2.scheduler.process.svng.ActiveMQSaver;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbOperTypeSelectionStep;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.utils.MaskFileSelector;
import ru.bpc.sv2.utils.NamedFileInputStream;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.SystemUtils;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;
import util.servlet.FileServlet;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.servlet.http.HttpSession;
import javax.sql.DataSource;
import java.io.File;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

@ViewScoped
@ManagedBean(name = "MbSessionFiles")
public class MbSessionFiles extends AbstractBean {
	private static final Logger logger = Logger.getLogger("PROCESSES");
	private static Logger loggerDB = Logger.getLogger("PROCESSES_DB");

	private ProcessDao processDAO = new ProcessDao();

	private Long sessionId;
	private SessionFile activeItem;
	private final DaoDataModel<SessionFile> daoDataModel;
	private String fileLink = null;
	private final TableRowSelection<SessionFile> tableRowSelection;
	private String action = null;

	private static final String COMPONENT_ID = "filesTable";
	private String tabName;
	private String parentSectionId;
	private Integer containerId;
	private boolean canDownload;

	public MbSessionFiles() {
		daoDataModel = new DaoDataModel<SessionFile>() {
			@Override
			protected SessionFile[] loadDaoData(SelectionParams params) {
				if (sessionId == null) {
					return filesInDir();
				}
				try {
					setFilters();
					params.setFilters(filters);
					return processDAO.getSessionFiles(userSessionId, params, true);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new SessionFile[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (sessionId == null) {
					return filesInDir().length;
				}
				try {
					setFilters();
					params.setFilters(filters);
					return processDAO.getSessionFilesCount(userSessionId, params, true);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		tableRowSelection = new TableRowSelection<SessionFile>(null, daoDataModel);
	}

	public ExtendedDataModel getFiles() {
		return daoDataModel;
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();
		filters.add(Filter.create("lang", userLang));
		filters.add(Filter.create("notStatus", ProcessConstants.FILE_STATUS_MERGED));
		if (sessionId != null) {
			filters.add(Filter.create("sessionId", sessionId.toString()));
		}
	}

	public void setSessionId(Long sessionId) {
		if (sessionId == null || !sessionId.equals(this.sessionId)) {
			this.sessionId = sessionId;
			clear();
		}
		this.sessionId = sessionId;
	}

	public Long getSessionId() {
		return sessionId;
	}


	private void clear() {
		daoDataModel.flushCache();
		setActiveItem(null);
	}

	public void search() {
		daoDataModel.flushCache();
		tableRowSelection.clearSelection();
		activeItem = null;
		searching = true;
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
			prepareItemSelection();
		}
		return tableRowSelection.getWrappedSelection();
	}

	public void prepareItemSelection() {
		daoDataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (SessionFile) daoDataModel.getRowData();
		selection.addKey(activeItem.getModelId());
		tableRowSelection.setWrappedSelection(selection);
		}

	public void setItemSelection(SimpleSelection selection) {
		tableRowSelection.setWrappedSelection(selection);
		activeItem = tableRowSelection.getSingleSelection();
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

	public void link() {
		setCanDownload(false);
		if (activeItem == null) {
			FacesUtils.addMessageError(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "no_file_selected"));
			return;
		}
		File file = null;
		boolean isIncoming = activeItem.getFilePurpose().equals(ProcessConstants.FILE_PURPOSE_INCOMING);
		
		if (!isIncoming)
		{
			if (isAsyncProcess()) {
				setCanDownload(false);
				FacesUtils.addMessageError("Can't download file from this process.");
				return;
			}
			reExportFiles(activeItem.getId());
			if (activeItem.getLocation() == null || activeItem.getLocation().trim().isEmpty()) {
				FacesUtils
						.addMessageError(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "file_location_empty"));
				return;
			}
		}
		
		// try to get the file from file system
		file = getFileLocation(activeItem);	

		// if the file has not been not found in the file system,
		// and it's an incoming file, try to get it from DB
		if (file == null || !file.exists()) {
			if (isIncoming) {
				file = readFileFromDB();
			}
		}
		
		if (file != null && file.exists()) {
			try {
				action = "click";
				fileLink = URLEncoder.encode(activeItem.getFileName() != null ? FilenameUtils.getName(activeItem.getFileName()) : file.getName(), "UTF-8");
			} catch (UnsupportedEncodingException ignored) {
			}
		} else {
			String separator = System.getProperty("file.separator");
			action = "show";
			FacesUtils.addMessageError(FacesUtils.getMessage(
					"ru.bpc.sv2.ui.bundles.Msg", "file_not_found",
					(file != null) ? file.getPath() : activeItem.getLocation() + 
							((!activeItem.getLocation().endsWith(separator))? separator : "") + 
							activeItem.getFileName()));
			return;
		}
		HttpSession session = RequestContextHolder.getRequest().getSession();
		session.setAttribute(FileServlet.FILE_SERVLET_CONTENT_TYPE, "application/x-download");
		session.setAttribute(FileServlet.FILE_SERVLET_FILE_PATH, file.getPath());		
		//do not delete the downloaded file
		
		setCanDownload(true);
	}

	private File readFileFromDB() {
		NamedFileInputStream stream = SystemUtils.recreateInputStreamAsTempFile(processDAO.getSessionFileContentsStream(userSessionId, null, activeItem.getId()));
		try {
			if (stream != null)
				return new File(stream.getFilePath());
		} finally {
			IOUtils.closeQuietly(stream);
		}
		return null;
	}

	private ProcessFileAttribute[] getFileOutAttributes(Long sessionId) throws SystemException {
		ProcessFileAttribute[] result;

		Map<String, Object> params = new HashMap<String, Object>(3);
		params.put("lang", SystemConstants.ENGLISH_LANGUAGE);
		params.put("sessionId", sessionId);

		try {
			result = processDAO.getOutgoingProcessFiles(userSessionId, params);
		} catch (DataAccessException e) {
			logger.error("", e);
			throw new SystemException(e.getMessage());
		}
		return result;
	}

	public void reExportFiles(Long fileId) {
		try {
			ProcessFileAttribute[] outFileAttrs = getFileOutAttributes(sessionId);
			for (ProcessFileAttribute fileAttr : outFileAttrs) {
				if (fileAttr.getId().equals(fileId)) {
				    outFileAttrs = new ProcessFileAttribute[]{fileAttr};
					break;
				}
			}
			resetMqSaver(outFileAttrs);
			OutgoingFilesGenerator outfilesGenerator = new OutgoingFilesGenerator(processDAO, outFileAttrs, userSessionId,
																				  getUserName(), null, "archive");
			outfilesGenerator.setSessionId(sessionId);
			outfilesGenerator.setLoggerDb(loggerDB);
			outfilesGenerator.generate(getParameters());
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}

	private Map<String, Object> getParameters(){
		ProcessLaunchParameter[] params = processDAO.getProcessLaunchParameters(userSessionId, SelectionParams.build("sessionId", sessionId, "lang", SystemConstants.ENGLISH_LANGUAGE));
		Map<String, Object> parameters = new HashMap<String, Object>();
		for (ProcessLaunchParameter param : params) {
			parameters.put(param.getParamName(), param.getValue());
		}
		return parameters;
	}

	private void resetMqSaver(ProcessFileAttribute[] attrs) throws ClassNotFoundException, IllegalAccessException, InstantiationException {
		FileSaver saver;
		for(ProcessFileAttribute attr : attrs){
			if(attr.getSaverClass() != null){
				saver = (FileSaver)(Class.forName(attr.getSaverClass()).newInstance());
				if(saver instanceof ActiveMQSaver){
					attr.setSaverClass(null);
				}
			}
		}
	}

	private File getFileLocation(SessionFile item) {
		String subDir = "";
		String location = item.getLocation();
		String fileName = item.getFileName();

		if (location == null || fileName == null){
			return null;
		}

		if (item.getFilePurpose().equals(ProcessConstants.FILE_PURPOSE_INCOMING)) {
			subDir = "processed";
			String path = location + (location.endsWith("/") ? "" : "/") + subDir + "/" + fileName;
			File file = new File(path);
			if (!file.exists()) {
				subDir = "rejected";
			}
		}
		String path = location + (location.endsWith("/") ? "" : "/") + subDir + "/" + fileName;
		return new File(path);
	}

	public String getAction() {
		return action;
	}

	public String getFileLink() {
		return fileLink;
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

	public SessionFile[] filesInDir() {
		if (containerId == null) {
			return new SessionFile[0];
		}
		List<SessionFile> list = new ArrayList<SessionFile>();
		try {
			ProcessFileAttribute[] fileAttrs = getFileInAttributes(containerId);
			FileSystemManager fsManager = VFS.getManager();

			SessionFile sessionFile;
			long fileId = 1;
			for (ProcessFileAttribute file : fileAttrs) {
				if (file.getLocation() != null) {
					FileObject locationV = fsManager.resolveFile(file.getLocation());
					boolean isDirectory = FileType.FOLDER.equals(locationV.getType());

					if (isDirectory) {
						if (file.getFileNameMask() == null) {
							file.setFileNameMask("");
						}
						try {
							// Just to check pattern is correct
							//noinspection ResultOfMethodCallIgnored
							Pattern.compile(file.getFileNameMask());
						} catch (PatternSyntaxException e) {
							String m = "Regular expression error: " + e.getMessage();
							throw new UserException(m, e);
						}

						FileSelector selector = new MaskFileSelector(file.getFileNameMask());
						FileObject[] fileObjects = locationV.findFiles(selector);
						locationV.close();
						if (fileObjects.length != 0) {
							for (FileObject fileObject : fileObjects) {
								sessionFile = new SessionFile();
								sessionFile.setId(fileId++);
								sessionFile.setFileName(fileObject.getName().getBaseName());
								sessionFile.setLocation(file.getLocation());
								list.add(sessionFile);

							}
						}
					}
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
		}

		return list.toArray(new SessionFile[list.size()]);
	}

	private ProcessFileAttribute[] getFileInAttributes(Integer containerBindId) throws SystemException {
		ProcessFileAttribute[] result;
		try {
			result = processDAO.getIncomingFilesForProcess(userSessionId,
					null,
					containerBindId);
		} catch (DataAccessException e) {
			logger.error("", e);
			throw new SystemException(e.getMessage());
		}
		return result;
	}


	public Integer getContainerId() {
		return containerId;
	}

	public void setContainerId(Integer containerId) {
		this.containerId = containerId;
	}

	public void updateSessionFiles() {
		SessionFile updatedSessionFile = null;
		SelectionParams params = SelectionParams.build("id", activeItem.getId());
		SessionFile[] sessionFiles = processDAO.getSessionFiles(userSessionId, params, true);
		if (sessionFiles.length != 0) {
			updatedSessionFile = sessionFiles[0];
		}
		try {
			daoDataModel.replaceObject(activeItem, updatedSessionFile);
			activeItem = updatedSessionFile;
		} catch (Exception e) {
			throw new IllegalStateException(e);
		}
	}

	public void setupOperTypeSelection() {
		CommonWizardStepInfo step = new CommonWizardStepInfo();
		step.setOrder(0);
		step.setSource(MbOperTypeSelectionStep.class.getSimpleName());
		step.setName(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Opr", "select_oper_type"));
		List<CommonWizardStepInfo> stepsList = new ArrayList<CommonWizardStepInfo>();
		stepsList.add(step);
		Map<String, Object> context = new HashMap<String, Object>();
		context.put(MbCommonWizard.STEPS, stepsList);

		context.put(MbOperTypeSelectionStep.ENTITY_TYPE, EntityNames.SESSION_FILE);
		context.put(MbOperTypeSelectionStep.OBJECT_ID, activeItem.getId());
		context.put(MbOperTypeSelectionStep.OBJECT_TYPE, Participant.ISS_PARTICIPANT);
        context.put(MbOperTypeSelectionStep.INST_ID, activeItem.getInstId());

		MbCommonWizard wizard = ManagedBeanWrapper.getManagedBean(MbCommonWizard.class);
		wizard.init(context);
	}

	@SuppressWarnings("UnusedDeclaration")
	public boolean getCanDownload() {
		return canDownload;
	}

	public void setCanDownload(boolean canDownload) {
		this.canDownload = canDownload;
	}

    private boolean isAsyncProcess() {
        try {
            Connection con = null;
            try {
                con = JndiUtils.getConnection();
                con.setAutoCommit(false);

                final PreparedStatement stm = con.prepareStatement("SELECT procedure_name FROM prc_process WHERE id=(SELECT process_id FROM prc_session WHERE id=?)");
                stm.setLong(1, sessionId);
                final ResultSet rs = stm.executeQuery();

                if (rs.next()) {
                    final String procedureName = rs.getString(1);
                    try {
                        final Object obj = Class.forName(procedureName).newInstance();
                        return (obj instanceof AsyncProcessHandler);

                    } catch (IllegalAccessException ignored) { // ignored, because of oracle procedures flood.
                    } catch (InstantiationException ignored) {
                    } catch (ClassNotFoundException ignored) {
                    }
                }
            } finally {
                DBUtils.close(con);
            }
        } catch (SQLException e) {
            logger.error("", e);
        }
        return false;
    }
}
