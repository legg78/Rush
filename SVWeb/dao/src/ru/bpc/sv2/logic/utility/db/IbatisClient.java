package ru.bpc.sv2.logic.utility.db;

import com.ibatis.common.resources.Resources;
import com.ibatis.sqlmap.client.SqlMapClient;
import com.ibatis.sqlmap.client.SqlMapClientBuilder;
import org.apache.log4j.Logger;

import java.io.Reader;

/**
 * Created by Dmitrenko on 25.08.2014.
 */
public class IbatisClient {
	private static Logger systemLogger = Logger.getLogger("SYSTEM");
	private SqlMapClient _sqlClient;
	private static volatile IbatisClient instance;

	private IbatisClient() {
		try {
			Reader ibatisConf = Resources.getResourceAsReader("SqlMapConfig.xml");
			_sqlClient = SqlMapClientBuilder.buildSqlMapClient(ibatisConf);
		} catch (Exception e) {
			systemLogger.error("Cannot init ibatis", e);
		}
	}


	public SqlMapClient getSqlClient() {
		return _sqlClient;
	}

	public static IbatisClient getInstance() {
		if (instance != null) {
			return instance;
		}
		synchronized (IbatisClient.class) {
			if (instance == null) {
				instance = new IbatisClient();
			}
		}
		return instance;
	}
}
