package ru.bpc.sv2.scheduler.process.svng;

import com.bpcbt.sv.camel.converters.AbstractXmlStreamConverter;
import com.bpcbt.sv.camel.converters.CrefConverter;

@SuppressWarnings("unused")
public class CrefFEUnloadFileSaver extends AbstractFeUnloadFileSaver {
	@Override
	protected AbstractXmlStreamConverter createStreamConverter() {
		return new CrefConverter();
	}
}
