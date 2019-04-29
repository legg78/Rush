package ru.bpc.sv2.scheduler.process;

import ru.bpc.sv2.ui.utils.cache.SettingsCache;

/**
 * Created by Gasanov on 18.03.2016.
 */
public class ConfigurationProviderImpl implements ConfigurationProvider {
    private SettingsCache settingParamsCache;

    public ConfigurationProviderImpl(SettingsCache settingParamsCache){
        this.settingParamsCache = settingParamsCache;
    }

    @Override
    public String getValue(String name) {
        if(settingParamsCache == null){
            return null;
        }
        return settingParamsCache.getParameterStringValue(name);
    }

    @Override
    public String getValue(String name, String defaultValue) {
        String  value = getValue(name);

        return (value == null ? defaultValue : value);
    }
}
