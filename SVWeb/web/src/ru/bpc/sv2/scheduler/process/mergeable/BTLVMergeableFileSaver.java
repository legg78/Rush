package ru.bpc.sv2.scheduler.process.mergeable;

import com.bpcbt.sv.camel.converters.Config;
import com.bpcbt.sv.camel.converters.StreamConverter;
import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv2.scheduler.process.mergeable.MergeableFileSaver;
import ru.bpc.sv2.scheduler.process.svng.ResourceStreamLoader;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.UserException;

import java.io.*;
import java.util.Properties;

public abstract class BTLVMergeableFileSaver extends PostFileSaver {
    protected abstract StreamConverter getStreamConverter();

    @Override
    public void save(boolean useParent) throws Exception {
        super.save(useParent);
    }

    @Override
    public void save() throws Exception {
        super.save(true);
    }

    @Override
    protected String convert(String in) throws Exception {
        if (in != null) {
            setupConverterProperties();
            StreamConverter converter = getStreamConverter();
            try (OutputStream out = new ByteArrayOutputStream()) {
                converter.convert(new ByteArrayInputStream(in.getBytes(getCharset())), out);
                return ((ByteArrayOutputStream)out).toString(getCharset());
            }
        }
        return in;
    }

    private void setupConverterProperties() throws UserException {
        Config.resetSettings();
        String configFolder = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.SVFE1_CONVERTER_CONFIG_FOLDER_PATH);
        final String propsFileName;
        if (StringUtils.isBlank(configFolder)) {
            configFolder = "ru/bpc/sv2/scheduler/process/svng/converter/config/";
            Config.setStreamLoader(new ResourceStreamLoader());
            propsFileName = "converter.properties";
            debug("Use inside mapping files for converting");
        } else {
            Config.setStreamLoader(null);
            configFolder = configFolder.trim();
            File configFolderFile = new File(configFolder);
            if (!configFolderFile.exists() || !configFolderFile.isDirectory()) {
                throw new UserException("Failed to read SVFE converters configuration folder: " + configFolder);
            }
            propsFileName = "camel.properties";
            debug("Use outside mapping files for converting");
        }

        Properties props = null;
        try {
            props = Config.getProperties(configFolder + "/" + propsFileName);
        } catch (Exception ignored) {
            warn("Failed to read converters properties file: " + configFolder + "/" + propsFileName);
        }
        if (props == null) {
            props = new Properties();
        }
        if (StringUtils.isNotBlank(getCharset())) {
            props.setProperty("svfe_encoding", getCharset());
            props.setProperty("bus_encoding", getCharset());
        }
        props.setProperty("useXmlWrapper", "false");
        props.setProperty("config_folder", configFolder);
        props.setProperty("posting_char_addressing", "true");
        Config.setConverterProperties(props);
    }
}
