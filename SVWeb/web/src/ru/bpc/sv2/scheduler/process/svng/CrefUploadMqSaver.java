package ru.bpc.sv2.scheduler.process.svng;

import ru.bpc.sv2.svng.DataTypes;

@SuppressWarnings("UnusedDeclaration")
public class CrefUploadMqSaver extends LoadMqSaver {
    @Override
    protected DataTypes getDataType() {
        return DataTypes.CARDS;
    }
    @Override
    public boolean isRequiredInFiles() {
        return false;
    }
}