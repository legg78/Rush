package ru.bpc.sv2.scheduler.process;

import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import java.util.Map;

public class GenReqCertificate extends IbatisExternalProcess{
	private Map<String, Object> parameters;
	
	@Override
	public void execute() throws SystemException, UserException {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void setParameters(Map<String, Object> parameters) {
		this.parameters = parameters;
	}
}
