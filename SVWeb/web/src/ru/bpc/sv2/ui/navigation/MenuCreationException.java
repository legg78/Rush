package ru.bpc.sv2.ui.navigation;

public class MenuCreationException
	extends Exception
{
	/**
	 *
	 */
	private static final long	serialVersionUID	= 4580004197393989476L;

	public MenuCreationException()
	{
		super();
	}

	public MenuCreationException( String message )
	{
		super( message );
	}

	public MenuCreationException( Throwable cause )
	{
		super( cause );
	}

	public MenuCreationException( String message, Throwable cause )
	{
		super( message, cause );
	}
}
