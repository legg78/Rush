package ru.bpc.sv2.scheduler.process.svng;

import com.bpcbt.sv.camel.converters.AbstractXmlStreamConverter;
import com.bpcbt.sv.camel.converters.RateConverter;

@SuppressWarnings("unused")
public class RateFEUnloadFileSaver extends AbstractFeUnloadFileSaver {
	@Override
	protected AbstractXmlStreamConverter createStreamConverter() {
		return new RateConverter();
	}
}
