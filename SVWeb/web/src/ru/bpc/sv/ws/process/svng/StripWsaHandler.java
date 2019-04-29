package ru.bpc.sv.ws.process.svng;

import org.apache.cxf.binding.soap.SoapMessage;
import org.apache.cxf.binding.soap.interceptor.AbstractSoapInterceptor;
import org.apache.cxf.interceptor.Fault;
import org.apache.cxf.ws.addressing.soap.VersionTransformer;

import javax.xml.namespace.QName;
import java.util.Set;

public class StripWsaHandler extends AbstractSoapInterceptor {
	public StripWsaHandler() {
		super("pre-protocol");
	}

	@Override
	public Set<QName> getUnderstoodHeaders() {
		return VersionTransformer.HEADERS;
	}

	@Override
	public void handleMessage(SoapMessage message) throws Fault {

	}
}
