package ru.bpc.sv2.process;

import ru.bpc.sv2.invocation.ModelAdapter;
import ru.bpc.sv2.invocation.ModelDTO;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ProcessTraceAdapter implements ModelAdapter {

	@Override
	public void populateDTO(ModelDTO modelDto, ModelIdentifiable model) {
		if (!(modelDto instanceof ProcessTraceDTO) || !(model instanceof ProcessTrace)) {
			return;
		}
		
		ProcessTraceDTO traceDto = (ProcessTraceDTO) modelDto;
		ProcessTrace trace = (ProcessTrace) model;
		
		traceDto.setId(trace.getId());
		traceDto.setThreadNumber(trace.getThreadNumber());
		traceDto.setTraceLevel(trace.getTraceLevel());
		traceDto.setTraceLevelFilter(trace.getTraceLevelFilter());
		traceDto.setTraceText(trace.getTraceText());
		traceDto.setTraceSection(trace.getTraceSection());
		traceDto.setTraceTimestamp(trace.getTraceTimestamp());
		traceDto.setUserId(trace.getUserId());
		traceDto.setSessionId(trace.getSessionId());
		traceDto.setEntityType(trace.getEntityType());
		traceDto.setEntityDescription(trace.getEntityDescription());
		traceDto.setObjectId(trace.getObjectId());
		traceDto.setEventId(trace.getEventId());
		traceDto.setLabelId(trace.getLabelId());
		traceDto.setInstId(trace.getInstId());
		traceDto.setDetails(trace.getDetails());
		traceDto.setObjectId(trace.getObjectId());
		traceDto.setWhoCalled(trace.getWhoCalled());
		traceDto.setText(trace.getText());
	}

}
