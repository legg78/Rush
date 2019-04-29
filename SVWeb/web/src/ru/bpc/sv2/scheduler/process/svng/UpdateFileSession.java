package ru.bpc.sv2.scheduler.process.svng;

import java.sql.PreparedStatement;
import java.sql.ResultSet;

import ru.bpc.sv2.scheduler.process.AbstractFileSaver;

public class UpdateFileSession extends AbstractFileSaver {

	@Override
	public void save() throws Exception {
		setupTracelevel();
		ResultSet rs = null;
		PreparedStatement ps = null;
		try{
			ps = con.prepareStatement("update prc_session_file set session_id = ? where session_id is null and file_type = ?");
			String fileType = fileAttributes.getFileType();
			ps.setLong(1, sessionId);
			ps.setString(2, fileType);
			rs = ps.executeQuery();
		}finally{
			if(rs != null){
				rs.close();
			}
			if(ps != null){
				ps.close();
			}
		}
	}
	
	@Override
	public boolean isRequiredInFiles() {
		return false;
	}
}

