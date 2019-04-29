package ru.bpc.sv2.scheduler.process.svng;

import ru.bpc.sv2.svng.DataTypes;

@SuppressWarnings("UnusedDeclaration")
public class CompaniesUploadWsSaver extends LoadWsSaver {
    @Override
    protected DataTypes getDataType() {
        return DataTypes.COMPANIES;
    }
    @Override
    public boolean isRequiredInFiles() {
        return false;
    }
}
