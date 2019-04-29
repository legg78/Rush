package ru.bpc.sv2.logic.utility.db;

public class QueryRange
{
	private long _start;
	private long _end;
	
	public QueryRange()
	{
		setRange( -1, -1 );
	}
	
	public QueryRange( long end )
	{
		setEnd( end );
		setStart( 0 );
	}

	public QueryRange( long start, long end )
	{
		setRange( start, end );
	}
	
	public void setRange ( long start, long end )
	{
		if ( start < 0 )
		{
			start = 0;
		}
		
		if ( end < 0 )
		{
			end = Long.MAX_VALUE;
		}
		
		if ( end < start )
		{
			throw new IllegalArgumentException( "Selection range end cannot be less then start" );
		}
		
		_end = end;
		_start = start;
	}
	
	public long getStart()
	{
		return _start;
	}

	public void setStart( long start )
	{
		if ( start < 0 )
		{
			start = 0;
		}
		
		if ( start > _end )
		{
			throw new IllegalArgumentException( "Range start should be less or equal to range end" );
		}
		
		
		_start = start;
	}

	public long getEnd()
	{
		return _end;
	}

	public void setEnd( long end )
	{
		if ( end < 0 )
		{
			end = Long.MAX_VALUE;
		}
		
		if ( end < _start )
		{
			throw new IllegalArgumentException( "Range end should be greater or equal to range start" );
		}
		
		_end = end;
	}
	
	public long getStartPlusOne() {
		return _start + 1;
	}
	
	public long getEndPlusOne() {
		return _end == Long.MAX_VALUE ? _end : _end + 1;
	}
}
