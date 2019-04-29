package ru.bpc.sv2.ui.reports.constructor.web;

import java.util.ResourceBundle;
import java.util.concurrent.TimeUnit;

import javax.faces.bean.ApplicationScoped;
import javax.faces.bean.ManagedBean;

import net.sf.dynamicreports.jasper.builder.JasperReportBuilder;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.jtsoft.dynamicreports.ReportingDataModel;
import ru.jtsoft.dynamicreports.db.OraclePagination;
import ru.jtsoft.dynamicreports.db.OracleSequence;
import ru.jtsoft.dynamicreports.db.Pagination;
import ru.jtsoft.dynamicreports.exceptions.DataSourceException;
import ru.jtsoft.dynamicreports.exceptions.ReportingModelLoadException;
import ru.jtsoft.dynamicreports.provider.DataSourceProvider;
import ru.jtsoft.dynamicreports.report.DefaultReportBuilderFactory;
import ru.jtsoft.dynamicreports.report.ReportBuilderFactory;
import ru.jtsoft.dynamicreports.report.ReportingEnvironment;
import ru.jtsoft.dynamicreports.report.dao.ReportTemplateDao;
import ru.jtsoft.dynamicreports.report.dao.ReportTemplateDaoFactory;
import ru.jtsoft.dynamicreports.xml.XmlReportingDataModelLoader;

import com.google.common.base.Supplier;
import com.google.common.base.Suppliers;

@ApplicationScoped
@ManagedBean(name="MbReportingEnvironment")
public class MbReportingEnvironment implements ReportingEnvironment {

	private static final Pagination PAGINATION = new OraclePagination();
	private static final DefaultReportBuilderFactory BUILDER_FACTORY = new DefaultReportBuilderFactory();

	private static final String MODEL_PATH = "sv2-reporting-data-model.xml";
	
	private static final Supplier<ReportingDataModel> CACHE2 = Suppliers.memoizeWithExpiration(new Supplier<ReportingDataModel>() {
			@Override
			public ReportingDataModel get() {
				try {
					return XmlReportingDataModelLoader.loadModel(Thread.currentThread().getContextClassLoader().getResource(MODEL_PATH));
				} catch (ReportingModelLoadException e) {
					throw new RuntimeException("Exception has occurred while loading the report model from " + MODEL_PATH, e);
				}
			}
		}, 5, TimeUnit.MINUTES);
	
	private static volatile ReportTemplateDao DAO = null; 
	
	@Override
	public ReportingDataModel getReportingDataModel() {
		return CACHE2.get();
	}

	@Override
	public ReportTemplateDao getReportTemplateDao() {
		return getDAO();
	}

	@Override
	public ResourceBundle getResourceBundle() {
		return ResourceBundle.getBundle("ru.bpc.sv2.ui.bundles.Rptc");
	}

	@Override
	public int getMaxReportRecords() {
		return SettingsCache.getInstance().getParameterNumberValue(SettingsConstants.CONSTRUCTOR_MAX_ROW_COUNT).intValue();
	}

	@Override
	public Pagination getPagination() {
		return PAGINATION;
	}
	
	@Override
	public ReportBuilderFactory<JasperReportBuilder> getReportBuilderFactory() {
		return BUILDER_FACTORY;
	}

	@Override
	public DataSourceProvider getDataSourceProvider() {
		return getReportingDataModel().getReportDataSourceProvider();
	}

	
	public static ReportTemplateDao getDAO() {
		
		if (DAO == null) {
			synchronized (ReportTemplateDaoFactory.class) {
				if (DAO == null) {
					 try {
						 DAO = new ReportTemplateDaoAPIUsageImpl("RPT_REPORT_CONSTRUCTOR"
								 , PAGINATION
								 , CACHE2.get().getReportDataSourceProvider().getDataSource()
								 , new OracleSequence("RPT_REPORT_CONSTRUCTOR_SEQ"));
					 } catch (DataSourceException e) {
						 throw new RuntimeException(e);
					 }
				}
			}
		}
	
		return DAO;
	}
}
