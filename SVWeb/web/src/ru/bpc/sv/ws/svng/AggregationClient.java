package ru.bpc.sv.ws.svng;

import com.bpcbt.sv.aggregation.message.v1.AggrRequest;
import com.bpcbt.sv.aggregation.message.v1.AggrResponse;
import com.bpcbt.sv.aggregation.service.v1.AggrPortType;

import javax.xml.ws.Response;


public class AggregationClient extends JmsWsClient<AggrPortType> {
	private long sessionId;

	public AggregationClient(String mqUrl, String queue, long sessionId) throws Exception {
		super(mqUrl, queue, AggrPortType.class);
		this.sessionId = sessionId;
	}

	public Response<AggrResponse> aggregate(long instId, Long aggrType, Long aggrId) {
		AggrRequest request = new AggrRequest();
		request.setSessionId(sessionId);
		request.setInstId(instId);
		request.setAggrId(aggrId);
		request.setAggrType(aggrType);
		return client.aggregateAsync(request);
	}
}
