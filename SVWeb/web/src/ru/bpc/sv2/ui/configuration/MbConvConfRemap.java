package ru.bpc.sv2.ui.configuration;

import com.bpcbt.sv.config.message.v1.RemapResult;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv.ws.svng.CamelConfigClient;
import ru.bpc.sv2.configuration.KeyValuePair;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by Nikishkin on 08.09.2015.
 */
@ViewScoped
@ManagedBean(name = "MbConvConfRemap")
public class MbConvConfRemap extends AbstractBean {

	private static final Logger logger = Logger.getLogger(MbConvConfRemap.class);

	// To get from / to put to / to update from
	private String confDir = "/home/weblogic/camel/config/";
	// Extending mappings
	private String remapDir = "/home/weblogic/camel/config/";

	private String selectedFile;

	private CamelConfigClient configClient;

	private RemapResult result;

	private final DaoDataModel<KeyValuePair> _confFilesSource;
	private final TableRowSelection<KeyValuePair> _itemSelection;

	private KeyValuePair _activeConfFile;

	private List<KeyValuePair> configFiles;



	public MbConvConfRemap() {
		try {
			SettingsCache settingParamsCache = SettingsCache.getInstance();
			String camelUrl = settingParamsCache.getParameterStringValue(SettingsConstants.APACHE_CAMEL_LOCATION);
			configClient = new CamelConfigClient(camelUrl + "/services/config");
		} catch (Exception ex) {
			logger.error("Cannot initiate config client", ex);
			FacesUtils.addMessageError(ex);
		}

		_confFilesSource = new DaoDataModel<KeyValuePair>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected KeyValuePair[] loadDaoData(SelectionParams params) {
				if(configFiles == null || configFiles.size() == 0) {
					return new KeyValuePair[0];
				}
				return configFiles.toArray(new KeyValuePair [configFiles.size()]);
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				int count = 0;
				if(configFiles != null) {
					count = configFiles.size();
				}
				return count;
			}
		};
		_itemSelection = new TableRowSelection<KeyValuePair>(null, _confFilesSource);
	}

	public DaoDataModel<KeyValuePair> getConfFiles() {
		return _confFilesSource;
	}

	public KeyValuePair getActiveConfFile() {
		return _activeConfFile;
	}

	public void setActiveConfFile(KeyValuePair activeConfFile) {
		_activeConfFile = activeConfFile;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeConfFile == null && _confFilesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeConfFile != null && _confFilesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeConfFile.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeConfFile = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_confFilesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeConfFile = (KeyValuePair) _confFilesSource.getRowData();
		selection.addKey(_activeConfFile.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeConfFile != null) {
			getContent();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeConfFile = _itemSelection.getSingleSelection();
		if(_activeConfFile != null){
			getContent();
		}
	}

	private void getContent(){
		_activeConfFile.setValue(configClient.getConfig(_activeConfFile.getKey(), true));
	}

	public void search() {
		clearState();
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeConfFile = null;
		_confFilesSource.flushCache();
	}

	public void remapConfig() {

	}

	public void updateConfig() {

	}

	public void remapConfigsAll() {
		try {
			logger.info("Remapping via WS...");
			if(configFiles == null) {
				configFiles = new ArrayList<KeyValuePair>();
			}
			configFiles.clear();
			search();
			result = configClient.remapConfigs(confDir, remapDir);
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "remapping_completed");
			logger.info(result);
			if(result.getResult().equalsIgnoreCase("OK")){
				KeyValuePair pair;
				for(String file : result.getFilesList().getFile()) {
					pair = new KeyValuePair();
					pair.setKey(file);
					pair.setValue("Test");
					configFiles.add(pair);
				}
			}
			FacesUtils.addInfoMessage(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e.getMessage());
			e.printStackTrace();
		}
	}

	public void updateConfigsAll() {

	}

	@Override
	public void clearFilter() {
		_itemSelection.clearSelection();
		_activeConfFile = null;
		_confFilesSource.flushCache();
	}

	public String getRemapDir() {
		return remapDir;
	}

	public void setRemapDir(String remapDir) {
		this.remapDir = remapDir;
	}

	public String getConfDir() {
		return confDir;
	}

	public void setConfDir(String confDir) {
		this.confDir = confDir;
	}

	public String getSelectedFile() {
		return selectedFile;
	}

	public void setSelectedFile(String selectedFile) {
		this.selectedFile = selectedFile;
	}

	public List<String> getFiles() {
		try {
			return configClient.getFiles();
		} catch (Exception ex) {
			FacesUtils.addMessageError("Service is unavailable");
		}
		return null;
	}

	public RemapResult getResult() {
		return result;
	}
}
