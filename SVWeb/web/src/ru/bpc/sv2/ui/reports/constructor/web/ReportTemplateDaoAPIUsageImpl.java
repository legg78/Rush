package ru.bpc.sv2.ui.reports.constructor.web;

import java.io.StringReader;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import javax.sql.DataSource;

import ru.jtsoft.dynamicreports.db.DbSupport;
import ru.jtsoft.dynamicreports.db.PageRequest;
import ru.jtsoft.dynamicreports.db.Pagination;
import ru.jtsoft.dynamicreports.db.Sequence;
import ru.jtsoft.dynamicreports.report.ReportTemplate;
import ru.jtsoft.dynamicreports.report.ReportTemplateGeneric;
import ru.jtsoft.dynamicreports.report.dao.ReportTemplateDao;
import ru.jtsoft.dynamicreports.report.dao.ReportTemplateDaoImpl;
import ru.jtsoft.dynamicreports.report.xml.XmlReportTemplateUtils;

public class ReportTemplateDaoAPIUsageImpl extends DbSupport implements ReportTemplateDao {

	private ReportTemplateDaoImpl daoImpl;
	private Sequence sequence;
	
	public ReportTemplateDaoAPIUsageImpl(String tableName, Pagination pagination,
			DataSource dataSource, Sequence sequence) {
		super(dataSource);
		daoImpl = new ReportTemplateDaoImpl(tableName, pagination, dataSource, sequence);
		this.sequence = sequence;
	}

	@Override
	public int countAll() {
		return daoImpl.countAll();
	}

	@Override
	public int countByNameLike(String paramString) {
		return daoImpl.countByNameLike(paramString);
	}

	@Override
	public List<ReportTemplateGeneric> find(PageRequest paramPageRequest) {
		return daoImpl.find(paramPageRequest);
	}

	@Override
	public List<ReportTemplateGeneric> findAll() {
		return daoImpl.findAll();
	}

	@Override
	public List<ReportTemplateGeneric> findByNameLike(String paramString,
			PageRequest paramPageRequest) {
		return daoImpl.findByNameLike(paramString, paramPageRequest);
	}

	@Override
	public ReportTemplate getReportTemplateById(Long paramLong) {
		return daoImpl.getReportTemplateById(paramLong);
	}

	@Override
	public void persist(ReportTemplate paramReportTemplate) {
		
		Connection conn = null;
		CallableStatement cs = null;
		
		try {
		
			conn = getDataSource().getConnection();
	
			Long id = sequence.nextVal(conn);
					
			cs = conn.prepareCall("{call rpt_ui_report_constructor_pkg.create_constructor (?, ?, ?, ?) }");
			
			cs.setLong(1, id);
			cs.setString(2, paramReportTemplate.getName());
			cs.setString(3, paramReportTemplate.getDescription());
			cs.setCharacterStream(
					4,
					new StringReader(XmlReportTemplateUtils
							.marshall(paramReportTemplate)));
			
			cs.execute();
		} catch (SQLException e) {
			throw new RuntimeException(e);
		} finally {
			_closeSilently(cs);
			_closeSilently(conn);
		}
	}

	@Override
	public void update(ReportTemplate paramReportTemplate) {
	
		Connection conn = null;
		CallableStatement cs = null;
		
		try {
			
			conn = getDataSource().getConnection();
			
			cs = conn.prepareCall("{call rpt_ui_report_constructor_pkg.update_constructor (?, ?, ?, ?) }");
			
			cs.setLong(1, paramReportTemplate.getId());
			cs.setString(2, paramReportTemplate.getName());
			cs.setString(3, paramReportTemplate.getDescription());
			cs.setCharacterStream(
					4,
					new StringReader(XmlReportTemplateUtils
							.marshall(paramReportTemplate)));
			
			cs.execute();
		} catch (SQLException e) {
			throw new RuntimeException(e);
		} finally {
			_closeSilently(cs);
			_closeSilently(conn);
		}
	}

	@Override
	public void deleteReportTemplateById(Long paramLong) {
		
		Connection conn = null;
		CallableStatement cs = null;
		
		try {
			conn = getDataSource().getConnection();
			
			cs = conn.prepareCall("{call rpt_ui_report_constructor_pkg.delete_constructor (?) }");
			
			cs.setLong(1, paramLong);
			
			cs.execute();
		} catch (SQLException e) {
			throw new RuntimeException(e);
		} finally {
			_closeSilently(cs);
			_closeSilently(conn);
		}
	}
}
