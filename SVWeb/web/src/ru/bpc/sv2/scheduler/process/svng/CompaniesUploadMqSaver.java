package ru.bpc.sv2.scheduler.process.svng;

import ru.bpc.sv2.svng.DataTypes;

public class CompaniesUploadMqSaver extends LoadMqSaver {
    @Override
    protected DataTypes getDataType() {
        return DataTypes.COMPANIES;
    }
    @Override
    public boolean isRequiredInFiles() {
        return false;
    }
}
