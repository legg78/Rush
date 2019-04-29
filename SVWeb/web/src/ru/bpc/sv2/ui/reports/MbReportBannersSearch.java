package ru.bpc.sv2.ui.reports;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.SerializationUtils;
import org.apache.log4j.Logger;
import org.richfaces.event.UploadEvent;
import org.richfaces.model.UploadItem;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.reports.ReportBanner;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.io.*;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbReportBannersSearch")
public class MbReportBannersSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("REPORTS");

	private static String COMPONENT_ID = "1614:bannersTable";

	private ReportsDao _reportsDao = new ReportsDao();

	private SettingsDao _settingsDao = new SettingsDao();

	

	private int uploadsAvailable;
	private ReportBanner filter;
	private ReportBanner _activeReportBanner;
	private ReportBanner newReportBanner;
	private ArrayList<SelectItem> institutions;

	private boolean imageChanged;
	private final DaoDataModel<ReportBanner> _reportBannersSource;

	private final TableRowSelection<ReportBanner> _itemSelection;

	public MbReportBannersSearch() {
		
		pageLink = "reports|banners";
		_reportBannersSource = new DaoDataModel<ReportBanner>() {
			@Override
			protected ReportBanner[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new ReportBanner[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _reportsDao.getReportBanners(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return new ReportBanner[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _reportsDao.getReportBannersCount(userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ReportBanner>(null, _reportBannersSource);
	}

	public DaoDataModel<ReportBanner> getReportBanners() {
		return _reportBannersSource;
	}

	public ReportBanner getActiveReportBanner() {
		return _activeReportBanner;
	}

	public void setActiveReportBanner(ReportBanner activeReportBanner) {
		_activeReportBanner = activeReportBanner;
	}

	public SimpleSelection getItemSelection() {
		if (_activeReportBanner == null && _reportBannersSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeReportBanner != null && _reportBannersSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeReportBanner.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeReportBanner = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_reportBannersSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeReportBanner = (ReportBanner) _reportBannersSource.getRowData();
		selection.addKey(_activeReportBanner.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeReportBanner != null) {
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeReportBanner = _itemSelection.getSingleSelection();
		if (_activeReportBanner != null) {
			setInfo();
		}
	}

	public void setInfo() {

	}

	public void clearBeansStates() {

	}

	public void search() {
		clearState();
		searching = true;
	}

	public void clearFilter() {
		filter = null;
		clearState();
		searching = false;
	}

	public ReportBanner getFilter() {
		if (filter == null) {
			filter = new ReportBanner();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(ReportBanner filter) {
		this.filter = filter;
	}

	private void setFilters() {

		Filter paramFilter;
		filter = getFilter();
		filters = new ArrayList<Filter>();

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().replaceAll("[*]", "%").replaceAll("[?]",
					"_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getDescription() != null && filter.getDescription().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("description");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getDescription().trim().replaceAll("[*]", "%").replaceAll(
					"[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getStatus() != null && filter.getStatus().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("status");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getStatus());
			filters.add(paramFilter);
		}

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
	}

	public void add() {
		uploadsAvailable = 1;
		newReportBanner = new ReportBanner();
		newReportBanner.setLang(userLang);		
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			uploadsAvailable = 2;
			newReportBanner = (ReportBanner) SerializationUtils.clone(_activeReportBanner);
		} catch (Exception e) {
			logger.error("", e);
			newReportBanner = _activeReportBanner;
		}
		curMode = EDIT_MODE;
	}

	public void view() {

	}

	public void upload() {
		imageChanged = true;
	}

	public void save() {

		File file = null;
		FileOutputStream fos = null;
		String name = null;
		String oldName = null;

		newReportBanner = getNewReportBanner();
		try {
			String levelValue = null;
			if (newReportBanner.getInstId() != null) {
				levelValue = newReportBanner.getInstId().toString();
			}
			String path = _settingsDao.getParameterValueV(userSessionId,
					SettingsConstants.REPORTS_BANNER_HOME, LevelNames.INSTITUTION, levelValue);
			if (path == null) {
				path = "";
			}
			if (uploadedFilename != null) { // file has been uploaded
				oldName = newReportBanner.getFilename();

				String baseName = FilenameUtils.getBaseName(uploadItem.getFileName());
				String extension = "." + FilenameUtils.getExtension(uploadItem.getFileName());
				// this means that we want either to create new or change
				// existing file
				SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmssSSS");
				String fileSeparator = System.getProperty("file.separator");
				if (!path.endsWith(fileSeparator)) {
					path += fileSeparator;
				}
				name = path + baseName + "_" + sdf.format(new Date(System.currentTimeMillis()))
						+ extension;

				file = new File(name);
				file.createNewFile();
				fos = new FileOutputStream(file);
				byte[] bytes = getImageBytes(uploadedFilename);
				fos.write(bytes);
				fos.close();
				newReportBanner.setFilename(name);
			} else {
				// this means that we don't want to change file
			}

			if (isNewMode()) {
				newReportBanner = _reportsDao.addReportBanner(userSessionId, newReportBanner);
				_itemSelection.addNewObjectToList(newReportBanner);
			} else if (isEditMode()) {
				newReportBanner = _reportsDao.modifyReportBanner(userSessionId, newReportBanner);
				_reportBannersSource.replaceObject(_activeReportBanner, newReportBanner);
				// delete previous file if filename is not null
				try {
					if (oldName != null && !oldName.equals("")) {
						file = new File(oldName);
						file.delete();
					}
				} catch (Exception e) {
					logger.error("", e);
				}
			}

			// delete temp file if filename is not null
			imageChanged = false;
			try {
				if (uploadedFilename != null) {
					file = new File(uploadedFilename);
					file.delete();
					uploadedFilename = null;
				}
			} catch (Exception e) {
				logger.error("", e);
			}

			_activeReportBanner = newReportBanner;
			setInfo();
			curMode = VIEW_MODE;
		} catch (Exception e) {

			// delete new file if an error has occurred
			if (name != null && !name.equals("")) {
				file = new File(name);
				file.delete();
			}

			FacesUtils.addMessageError(e);
			logger.error("", e);
		} finally {
			if (fos != null) {
				try {
					fos.close();
				} catch (IOException e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
			}
		}
	}

	public void delete() {
		try {
			String oldName = _activeReportBanner.getFilename();

			_reportsDao.removeReportBanner(userSessionId, _activeReportBanner);
			
			_activeReportBanner = _itemSelection.removeObjectFromList(_activeReportBanner);
			if (_activeReportBanner == null) {
				clearState();
			} else {
				setInfo();
			}
			
			try {
				if (oldName != null && !oldName.equals("")) {
					File file = new File(oldName);
					file.delete();
				}
			} catch (Exception e) {
				logger.error("", e);
			}

			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
		imageChanged = false;
		try {
			if (uploadedFilename != null && !uploadedFilename.equals("")) {
				File file = new File(uploadedFilename);
				file.delete();
				uploadedFilename = null;
			}
		} catch (Exception e) {
			logger.error("", e);
		}
	}

	public ReportBanner getNewReportBanner() {
		if (newReportBanner == null) {
			newReportBanner = new ReportBanner();
		}
		return newReportBanner;
	}

	public void setNewReportBanner(ReportBanner newReportBanner) {
		this.newReportBanner = newReportBanner;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeReportBanner = null;
		_reportBannersSource.flushCache();
		curLang = userLang;
	}

	public ArrayList<SelectItem> getReportStatuses() {
		return getDictUtils().getArticles(DictNames.REPORT_STATUSES, false, false);
	}

	public ArrayList<SelectItem> getBannerStatuses() {
		return getDictUtils().getArticles(DictNames.REPORT_BANNER_STATUSES, false, false);
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeReportBanner.getId().toString());
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
			ReportBanner[] banners = _reportsDao.getReportBanners(userSessionId, params);
			if (banners != null && banners.length > 0) {
				_activeReportBanner = banners[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	private String uploadedFilename;
	private UploadItem uploadItem;

	public void fileUploadListener(UploadEvent event) throws Exception {
		UploadItem item = event.getUploadItem();
		if (!checkMaximumFileSize(item.getFileSize())) {
			logger.error("File size is too big");
			FacesUtils.addMessageError("File size is too big");
			return;
		}
		File file = null;
		FileOutputStream fos = null;

		String oldName = uploadedFilename;
		try {
			uploadItem = item;
			String path = _settingsDao.getParameterValueV(userSessionId,
					SettingsConstants.REPORTS_BANNER_HOME, LevelNames.SYSTEM, null);
			if (path == null) {
				path = "";
			}

			FileInputStream fis = new FileInputStream(item.getFile());
			SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmssSSS");
			String name = path + FilenameUtils.getBaseName(item.getFileName())
					+ sdf.format(new Date(System.currentTimeMillis())) + "."
					+ FilenameUtils.getExtension(item.getFileName());

			file = new File(name);
			file.createNewFile();
			fos = new FileOutputStream(file);

			int len;
			byte buf[] = new byte[1024];
			while ((len = fis.read(buf)) > 0) {
				fos.write(buf, 0, len);
			}

			fos.flush();
			fos.close();

			uploadedFilename = name;

			try {
				if (oldName != null) {
					file = new File(oldName);
					file.delete();
				}
			} catch (Exception e) {
				logger.error("Cannot delete old file!", e);
			}

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} finally {
			if (fos != null) {
				fos.close();
			}
		}
	}

	public byte[] getImageData() {
		try {
			if (_activeReportBanner == null || _activeReportBanner.getFilename() == null) {
				return new byte[0];
			}
			byte[] bytes = getImageBytes(_activeReportBanner.getFilename());
			return bytes;
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return new byte[0];
	}

	public int getImageSize(){
		return getImageData().length;
	}

	public byte[] getNewImageData() {
		if (newReportBanner == null || (newReportBanner.getFilename() == null && !imageChanged)) {
			return new byte[0];
		}
		try {
			String name = null;
			if (imageChanged) {
				name = uploadedFilename;
			} else {
				name = newReportBanner.getFilename();
			}
			byte[] bytes = getImageBytes(name);
			return bytes;
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}

		return new byte[0];
	}

	public int getNewImageSize(){
		return getNewImageData().length;
	}

	private byte[] getImageBytes(String filename) throws Exception {
		File file = null;
		InputStream is = null;
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		try {
			file = new File(filename);
			if (file.isFile()) {
				is = new FileInputStream(file);
			} else {
				return new byte[0];
			}
			byte[] buf = new byte[1024];
			int len;
			while ((len = is.read(buf)) > 0) {
				out.write(buf, 0, len);
			}
		} catch (Exception e) {
			logger.error("", e);
			throw e;
		} finally {

			if (is != null) {
				try {
					is.close();
				} catch (IOException e) {
					logger.error("", e);
				}
			}
		}
		return out.toByteArray();
	}

	public void clearUpload() {
		uploadsAvailable = 1;
		imageChanged = false;
		try {
			if (uploadedFilename != null && !uploadedFilename.equals("")) {
				File file = new File(uploadedFilename);
				file.delete();
				uploadedFilename = null;
			}
		} catch (Exception e) {
			logger.error("", e);
		}
	}

	public int getUploadsAvailable() {
		return uploadsAvailable;
	}

	public void setUploadsAvailable(int uploadsAvailable) {
		this.uploadsAvailable = uploadsAvailable;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}
	
	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newReportBanner.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newReportBanner.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			ReportBanner[] banners = _reportsDao.getReportBanners(userSessionId, params);
			if (banners != null && banners.length > 0) {
				newReportBanner = banners[0];
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

}
