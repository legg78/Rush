package ru.bpc.sv2.logic.utility.db;

import java.sql.SQLException;

import com.ibatis.sqlmap.client.extensions.ParameterSetter;
import com.ibatis.sqlmap.client.extensions.ResultGetter;
import com.ibatis.sqlmap.client.extensions.TypeHandlerCallback;

public class IsNotNullTypeHandlerCallback
	implements TypeHandlerCallback
{

	@Override
	public Object getResult( ResultGetter getter )
		throws SQLException
	{
		getter.getString();
		return !getter.wasNull();
	}

	@Override
	public void setParameter( ParameterSetter setter, Object obj )
		throws SQLException
	{
		if ( obj instanceof Boolean )
		{
			if ( Boolean.TRUE.equals( obj ) )
			{
				setter.setInt( 1 );
			}
			else
			{
				setter.setInt( 0 );
			}
		}
		else
		{
			throw new SQLException( "Argument is not java.lang.Boolean" );
		}
	}

	@Override
	public Object valueOf( String str )
	{
		if ( str != null )
		{
			return true;
		}
		else
		{
			return false;
		}
	}


}
