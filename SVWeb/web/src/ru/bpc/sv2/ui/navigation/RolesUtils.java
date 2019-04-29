package ru.bpc.sv2.ui.navigation;

import java.util.Set;

public class RolesUtils
{
	public static boolean intersectionNotNull( Set<String> a, Set<String> b )
	{
		for( String aElem : a )
		{
			if( b.contains( aElem ) )
			{
				return true;
			}
		}
		return false;
	}
}
