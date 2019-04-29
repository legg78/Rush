package ru.bpc.sv2.scheduler.process.svng;

import java.io.OutputStream;

public abstract class AbstractFeUnloadFileSaver extends AbstractFeBaseFileSaver {
	@Override
	protected OutputStream getOutputStream() throws Exception {
		return fileObject.getContent().getOutputStream();
	}
}
