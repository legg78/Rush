package ru.bpc.sv.ws.settlement;

import com.bpcbt.sv.merge.message.v1.MergeRequest;
import com.bpcbt.sv.merge.message.v1.ResultResponse;
import com.bpcbt.sv.merge.service.v1.MergePortType;
import ru.bpc.sv.ws.svng.JmsWsClient;

import javax.xml.ws.Response;


public class MergeClient extends JmsWsClient<MergePortType> {
	private long sessionId;

	public MergeClient(String mqUrl, String queue, long sessionId) throws Exception {
		super(mqUrl, queue, MergePortType.class);
		this.sessionId = sessionId;
	}


	public Response<ResultResponse> sendMerge(String queue, String inputFile, String outputFile) {
		MergeRequest request = new MergeRequest();
		request.setSessionId(sessionId);
		request.setInFile(inputFile);
		request.setQueue(queue);
		request.setOutFile(outputFile);
		return client.mergeAsync(request);
	}
}
