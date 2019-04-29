package ru.bpc.sv2.scheduler.process.svng;

import ru.bpc.sv2.svng.DataTypes;

public class PersonsUploadMqSaver extends LoadMqSaver {
    @Override
    protected DataTypes getDataType() {
        return DataTypes.PERSONS;
    }
    @Override
    public boolean isRequiredInFiles() {
        return false;
    }
}
