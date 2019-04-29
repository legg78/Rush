package ru.bpc.sv2.scheduler.process.svng;

import com.bpcbt.sv.camel.converters.Config;
import com.bpcbt.sv.camel.converters.StreamConverter;
import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.scheduler.process.AbstractFileSaver;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.UserException;

import java.io.File;
import java.io.OutputStream;
import java.util.Properties;

public abstract class AbstractFeBaseFileSaver extends AbstractFileSaver {
	public static final String DEFAULT_CONVERTER_CONFIG_PACKAGE = "ru/bpc/sv2/scheduler/process/svng/converter/config/";

	@Override
	public void save() throws Exception {
		setupTracelevel();
		setupConverterConfigPath(getFileAttributes());
		StreamConverter converter = createStreamConverter();
		OutputStream stream = getOutputStream();
		converter.convert(inputStream, stream);
		stream.close();
	}

	protected abstract OutputStream getOutputStream() throws Exception;

	public static void setupConverterConfigPath(ProcessFileAttribute fileAttributes) throws UserException {
		Config.resetSettings();
		String configFolder = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.SVFE1_CONVERTER_CONFIG_FOLDER_PATH);
		final String propsFileName;
		if (StringUtils.isBlank(configFolder)) {
			configFolder = DEFAULT_CONVERTER_CONFIG_PACKAGE;
			Config.setStreamLoader(new ResourceStreamLoader());
			propsFileName = "converter.properties";
		} else {
			Config.setStreamLoader(null);
			configFolder = configFolder.trim();
			File configFolderFile = new File(configFolder);
			if (!configFolderFile.exists() || !configFolderFile.isDirectory()) {
				throw new UserException(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "error_svfe_converter_config_dir") + " " + configFolder);
			}
			propsFileName = "camel.properties";
		}
		Properties props = null;
		try {
			props = Config.getProperties(configFolder + "/" + propsFileName);
		} catch (Exception ignored) {
		}
		if (props == null) {
			props = new Properties();
		}
		if (fileAttributes != null && StringUtils.isNotBlank(fileAttributes.getCharacterSet())) {
			props.setProperty("svfe_encoding", fileAttributes.getCharacterSet().trim());
			props.setProperty("bus_encoding", fileAttributes.getCharacterSet().trim());
		}
		props.setProperty("useXmlWrapper", "false");
		props.setProperty("config_folder", configFolder);
		props.setProperty("posting_char_addressing", "true");
		Config.setConverterProperties(props);
	}

	protected abstract StreamConverter createStreamConverter();
}
