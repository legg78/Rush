/*
 * Created on 17.04.2008
 */
package ru.bpc.sv2.utils;

import java.sql.Date;
import java.sql.SQLException;
import java.sql.SQLInput;
import java.sql.SQLOutput;

/**
 * @author Dmitriev Vadim
 */
public final class SQLDataObjects
{
    public static void writeInt( SQLOutput sqlo, Integer i )
		throws SQLException
	{
	    if( i == null )
	    {
	        sqlo.writeObject( null );
	    }
	    else
	    {
	        sqlo.writeInt( i.intValue() );
	    }
	}
    
    public static Integer readInt( SQLInput sqli )
		throws SQLException
	{
        int i = sqli.readInt();
        if( sqli.wasNull() )
        {
        	return null;
        }
        else
        {
        	return new Integer( i );
        }
	}
	
    public static  void writeByte( SQLOutput sqlo, Byte i )
		throws SQLException
	{
	    if( i == null )
	    {
	        sqlo.writeObject( null );
	    }
	    else
	    {
	        sqlo.writeByte( i.byteValue() );
	    }
	}
	
    public static  Byte readByte( SQLInput sqli )
		throws SQLException
	{
	    byte i = sqli.readByte();
	    if( sqli.wasNull() )
	    {
	    	return null;
	    }
	    else
	    {
	    	return new Byte( i );
	    }
	}
	
    public static void writeBoolean( SQLOutput sqlo, Boolean i )
		throws SQLException
	{
	    if( i == null )
	    {
	        sqlo.writeObject( null );
	    }
	    else
	    {
	        sqlo.writeBoolean( i.booleanValue() );
	    }
	}
	
    public static  Boolean readBoolean( SQLInput sqli )
		throws SQLException
	{
    	boolean i = sqli.readBoolean();
	    if( sqli.wasNull() )
	    {
	    	return null;
	    }
	    else
	    {
	    	return new Boolean( i );
	    }
	}
	
    public static  void writeFloat( SQLOutput sqlo, Float i )
		throws SQLException
	{
	    if( i == null )
	    {
	        sqlo.writeObject( null );
	    }
	    else
	    {
	        sqlo.writeFloat( i.floatValue() );
	    }
	}
	
    public static  Float readFloat( SQLInput sqli )
		throws SQLException
	{
    	float i = sqli.readFloat();
	    if( sqli.wasNull() )
	    {
	    	return null;
	    }
	    else
	    {
	    	return new Float( i );
	    }
	}
	
    public static  void writeLong( SQLOutput sqlo, Long i )
		throws SQLException
	{
	    if( i == null )
	    {
	        sqlo.writeObject( null );
	    }
	    else
	    {
	        sqlo.writeLong( i.longValue() );
	    }
	}
	
    public static  Long readLong( SQLInput sqli )
		throws SQLException
	{
    	long i = sqli.readLong();
	    if( sqli.wasNull() )
	    {
	    	return null;
	    }
	    else
	    {
	    	return new Long( i );
	    }
	}
	
    public static  void writeDate( SQLOutput sqlo, java.util.Date i )
		throws SQLException
	{
	    if( i == null )
	    {
	        sqlo.writeObject( null );
	    }
	    else
	    {
	        sqlo.writeDate( new Date( i.getTime() ) );
	    }
	}
	
    public static  Date readDate( SQLInput sqli )
		throws SQLException
	{
		return sqli.readDate();
	}
    
    public static void writeBooleanAsInt( SQLOutput sqlo, Boolean i )
		throws SQLException
	{
		writeInt( sqlo, new Integer( i.booleanValue() == true ? Integer.valueOf( 1 ) : Integer.valueOf( 0 ) ) );
	}
    
    public static Boolean readBooleanAsChar( SQLInput sqli )
		throws SQLException
	{
		String val = sqli.readString();
		if( val == null )
		{
			return null;
		}
		else
		{
			if( "Y".equals( val ) )
			{
				return new Boolean( true );
			}
			else if( "N".equals( val ) )
			{
				return new Boolean( false );
			}
			else
			{
				return null;
			}
		}
	}
    
    public static void writeBooleanAsChar( SQLOutput sqlo, Boolean i )
		throws SQLException
	{	
		if( i == null )
		{
			sqlo.writeObject( null );
		}
		else
		{
			if( i.booleanValue() == true )
			{
				sqlo.writeString( "Y" );
			}
			else
			{
				sqlo.writeString( "N" );
			}
		}
	}
}
