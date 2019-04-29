package ru.bpc.sv2.scheduler.process.svng;

import ru.bpc.sv2.svng.DataTypes;

@SuppressWarnings("UnusedDeclaration")
public class PostingMqSaver extends LoadMqSaver {

	@Override
	protected DataTypes getDataType() {
		return DataTypes.POSTING;
	}

	@Override
	public boolean isRequiredInFiles() {
		return false;
	}
}
