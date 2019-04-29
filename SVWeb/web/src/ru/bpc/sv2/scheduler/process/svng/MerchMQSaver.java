package ru.bpc.sv2.scheduler.process.svng;

import ru.bpc.sv2.svng.DataTypes;

@SuppressWarnings("UnusedDeclaration")
public class MerchMQSaver extends ActiveMQSaver {

	@Override
	protected DataTypes getDataType() {
		return DataTypes.MERCH;
	}

}
