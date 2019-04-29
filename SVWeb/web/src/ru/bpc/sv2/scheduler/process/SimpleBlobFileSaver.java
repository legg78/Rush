package ru.bpc.sv2.scheduler.process;

import org.apache.commons.io.IOUtils;
import ru.bpc.sv2.utils.DBUtils;

import java.io.OutputStream;
import java.sql.Blob;
import java.sql.CallableStatement;

public class SimpleBlobFileSaver extends AbstractFileSaver {

	@Override
	public void save() throws Exception {
		setupTracelevel();
		CallableStatement cstmt = null;
		try {
			cstmt = con.prepareCall("{call prc_api_file_pkg.put_file(  " +
					"i_sess_file_id   => ?" +
					", i_blob_content => ?)}");
			Blob blob = con.createBlob();
			OutputStream os = blob.setBinaryStream(1);
			IOUtils.copy(inputStream, os);
			os.flush();
			os.close();
			cstmt.setLong(1, fileAttributes.getSessionId());
			cstmt.setBlob(2, blob);
			cstmt.execute();
		} finally {
			DBUtils.close(cstmt);
		}
	}
}
