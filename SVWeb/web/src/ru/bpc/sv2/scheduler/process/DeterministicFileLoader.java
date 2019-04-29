package ru.bpc.sv2.scheduler.process;

import ru.bpc.sv2.constants.SystemConstants;

import java.io.*;

public class DeterministicFileLoader extends AbstractFileSaver {

	@Override
	public void save() throws Exception {
		setupTracelevel();
		BufferedWriter bw = null;
		BufferedReader br = null;
		try {
			OutputStream out = fileObject.getContent().getOutputStream();
			bw = new BufferedWriter(new OutputStreamWriter(out));
			br = new BufferedReader(new InputStreamReader(inputStream, fileAttributes.getCharacterSet() != null ?
					fileAttributes.getCharacterSet() : SystemConstants.DEFAULT_CHARSET));

			char[] buf = new char[1024];
			int read;
			while ((read = br.read(buf)) > 0) {
				bw.write(buf, 0, read);
			}
			bw.flush();
		} finally {
			try {bw.close();} catch (Exception ignored) {}
			try {br.close();} catch (Exception ignored) {}
		}
	}

}
