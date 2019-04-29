package ru.bpc.sv2.utils;

import com.ibatis.sqlmap.client.extensions.ParameterSetter;
import com.ibatis.sqlmap.client.extensions.ResultGetter;
import com.ibatis.sqlmap.client.extensions.TypeHandlerCallback;
import org.apache.commons.io.IOUtils;
import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.SystemConstants;

import javax.naming.OperationNotSupportedException;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.Clob;
import java.sql.SQLException;

public class ReportXmlTypeHandler implements TypeHandlerCallback {
	@Override
	public Object getResult(ResultGetter getter) throws SQLException {
		Clob clob = getter.getClob();
		if (clob == null)
			return null;
		File result = SystemUtils.getTempFile("report");
		FileOutputStream fos = null;
		try {
			fos = new FileOutputStream(result);
			IOUtils.copy(clob.getCharacterStream(), fos, SystemConstants.DEFAULT_CHARSET);
		} catch (Exception e) {
			throw new RuntimeException(e.getMessage(), e);
		} finally {
			IOUtils.closeQuietly(fos);
		}
		return result;
	}

	@Override
	public void setParameter(ParameterSetter setter, Object parameter) throws SQLException {
		throw new SQLException(new OperationNotSupportedException("ReportXmlTypeHandler.setParameter is not supported"));
	}

	@Override
	public Object valueOf(String s) {
		return s;
	}
}
