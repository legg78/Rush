package ru.bpc.sv2.logic.utility.db;

import java.util.Map;

import javax.sql.DataSource;

import com.ibatis.sqlmap.engine.datasource.DataSourceFactory;

public class NoneDataSourceFactory
	implements DataSourceFactory
{
	
	@Override
	public DataSource getDataSource()
	{
		return null;
	}
	
	@SuppressWarnings( "unchecked" )
	@Override
	public void initialize( Map paramMap )
	{
	}
	
}
