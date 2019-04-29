package ru.bpc.sv2.scheduler.process.svng;

import com.bpcbt.sv.camel.converters.AbstractXmlStreamConverter;
import com.bpcbt.sv.camel.converters.MerchConverter;

@SuppressWarnings("unused")
public class MerchFEUnloadFileSaver extends AbstractFeUnloadFileSaver {
	@Override
	protected AbstractXmlStreamConverter createStreamConverter() {
		return new MerchConverter();
	}
}
