package ru.bpc.sv2.scheduler.process.svng;

import com.bpcbt.sv.camel.converters.AbstractXmlStreamConverter;
import com.bpcbt.sv.camel.converters.DbalConverter;

@SuppressWarnings("unused")
public class DbalFEUnloadFileSaver extends AbstractFeUnloadFileSaver {
	@Override
	protected AbstractXmlStreamConverter createStreamConverter() {
		return new DbalConverter();
	}
}
