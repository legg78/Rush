package ru.bpc.sv.ws.svng;

import com.bpcbt.sv.interchange.message.v1.AmountResponse;
import com.bpcbt.sv.interchange.message.v1.CalculationRequest;
import com.bpcbt.sv.interchange.message.v1.CalculationResponse;
import com.bpcbt.sv.interchange.message.v1.LoadRequest;
import com.bpcbt.sv.interchange.message.v1.LoadResponse;
import com.bpcbt.sv.interchange.message.v1.RollbackRequest;
import com.bpcbt.sv.interchange.service.v1.InterchangePortType;

import javax.xml.ws.Response;


public class InterchangeClient extends JmsWsClient<InterchangePortType> {
	private long sessionId;

	public InterchangeClient(String mqUrl, String queue, long sessionId) throws Exception {
		super(mqUrl, queue, InterchangePortType.class);
		this.sessionId = sessionId;
	}

	public Response<CalculationResponse> rollback(long sessionId, boolean isRollback) {
		RollbackRequest rollback = new RollbackRequest();
		rollback.setSessionId(sessionId);
		rollback.setRollback(isRollback);
		return client.rollbackAsync(rollback);
	}

	public Response<CalculationResponse> calculate(long sessionId, long instId, String status, String operType) {
		CalculationRequest request = new CalculationRequest();
		request.setSessionId(sessionId);
		request.setInstId(instId);
		request.setStatus(status);
		request.setOperType(operType);
		return client.calculateAsync(request);
	}

	public long unload() throws Exception {
		LoadRequest request = new LoadRequest();
		request.setSessionId(sessionId);
		request.setDataType("CALCULATED_FEES");
		AmountResponse response = client.unload(request);
		if (response.getError() != null) {
			throw new Exception("Error in module: " + response.getError() + ". See module log for details.");
		}
		return response.getTotal();
	}

	public Response<LoadResponse> load(String dataType) {
		LoadRequest request = new LoadRequest();
		request.setSessionId(sessionId);
		request.setDataType(dataType);
		return client.loadAsync(request);
	}
}
