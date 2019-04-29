package ru.bpc.sv2.scheduler.process.svng;

import com.bpcbt.sv.camel.converters.RejectConverter;
import com.bpcbt.sv.camel.converters.StreamConverter;
import ru.bpc.sv2.constants.schedule.ProcessConstants;

@SuppressWarnings("unused")
public class RejectFELoadFileSaver extends AbstractFeLoadFileSaver {
	@Override
	protected StreamConverter createStreamConverter() {
		return new RejectConverter();
	}

	@Override
	public String getStatusSessionFile(){
		return ProcessConstants.FILE_STATUS_POSTPROCESSING;
	}
}
