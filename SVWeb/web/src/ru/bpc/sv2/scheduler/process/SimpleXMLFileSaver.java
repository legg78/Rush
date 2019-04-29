package ru.bpc.sv2.scheduler.process;

import java.io.StringReader;
import java.io.StringWriter;
import java.sql.CallableStatement;

import org.apache.commons.io.IOUtils;
import ru.bpc.sv2.utils.DBUtils;

public class SimpleXMLFileSaver extends AbstractFileSaver {

	@Override
	public void save() throws Exception {
		setupTracelevel();
		StringWriter writer = new StringWriter();
		IOUtils.copy(inputStream, writer, "UTF-8");
		String result = writer.toString();
		CallableStatement cstmt = null;
		try {
			cstmt = con.prepareCall("{call prc_api_file_pkg.put_file(i_sess_file_id => ?, i_clob_content => ?)}");
			cstmt.setLong(1, fileAttributes.getSessionId());
			cstmt.setCharacterStream(2, new StringReader(result), result.length());
			cstmt.execute();
		}finally {
			DBUtils.close(cstmt);
		}
	}

}
