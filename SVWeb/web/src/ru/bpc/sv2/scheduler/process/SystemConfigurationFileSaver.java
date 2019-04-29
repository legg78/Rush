package ru.bpc.sv2.scheduler.process;

import java.io.Reader;
import java.io.StringReader;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class SystemConfigurationFileSaver extends AbstractFileSaver {

	@Override
	public void save() throws Exception {
		setupTracelevel();
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
		DocumentBuilder db = dbf.newDocumentBuilder();
		Document doc = db.parse(inputStream);
		doc.getDocumentElement().normalize();

		PreparedStatement pst1 = null;
		ResultSet rs1 = null;
		//initialization
		Element fstElmnt = null;
		String sqlQuery = null;
		//process for xml_query tags
		NodeList nodeLst = doc.getElementsByTagName("xml-query");
		try {
			for (int s = 0; s < nodeLst.getLength(); s++) {
			    Node fstNode = nodeLst.item(s);
			    if (fstNode.getNodeType() == Node.ELEMENT_NODE) {
		           fstElmnt = (Element) fstNode;
		           sqlQuery = fstElmnt.getFirstChild().getNodeValue();
		           pst1 = con.prepareStatement(sqlQuery);
		           rs1 = pst1.executeQuery();
		           rs1.close();
		           pst1.close();
			    }
			}
		} catch (SQLException e) {
			e.printStackTrace();
			throw e;
		} finally {
			rs1.close();
			pst1.close();
		}

		// process for clob tags
		nodeLst = doc.getElementsByTagName("clob");
        PreparedStatement pst2 = null;
        ResultSet rs2 = null;
        //initialization
        Reader reader = null;
        String tableName = null;
        String columnName = null;
        String idValue = null;
        String clobValue = null;
        try {
			for (int s = 0; s < nodeLst.getLength(); s++) {
			    Node fstNode = nodeLst.item(s);
			    if (fstNode.getNodeType() == Node.ELEMENT_NODE) {
		           fstElmnt = (Element) fstNode;
		           tableName = fstElmnt.getAttribute("table_name");
		           columnName = fstElmnt.getAttribute("column_name");
		           idValue = fstElmnt.getAttribute("ID");
		           clobValue = fstElmnt.getFirstChild().getNodeValue();
		           sqlQuery = buildSQLQuery(tableName, columnName);
		           pst2 = con.prepareStatement(sqlQuery);
		           // set parameter for query
		           reader = new StringReader(clobValue);
		           pst2.setClob(1, reader);
		           pst2.setLong(2, Long.valueOf(idValue));

		           rs2 = pst2.executeQuery();
		           reader.close();
		           rs2.close();
		           pst2.close();
			    }
			}

        } catch (SQLException e) {
        	e.printStackTrace();
        	throw e;
        } finally {
        	rs2.close();
        	pst2.close();
		}
	}

	private String buildSQLQuery(String tableName, String columnName) {
		StringBuffer result = new StringBuffer("update ");
		result.append(tableName).append(" set ").append(columnName).append(" = ? where ID = ?");
		return result.toString();
	}
}
