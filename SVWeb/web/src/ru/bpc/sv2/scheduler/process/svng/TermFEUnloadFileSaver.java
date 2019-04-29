package ru.bpc.sv2.scheduler.process.svng;

import com.bpcbt.sv.camel.converters.AbstractXmlStreamConverter;
import com.bpcbt.sv.camel.converters.TermConverter;

@SuppressWarnings("unused")
public class TermFEUnloadFileSaver extends AbstractFeUnloadFileSaver {
	@Override
	protected AbstractXmlStreamConverter createStreamConverter() {
		return new TermConverter();
	}
}
