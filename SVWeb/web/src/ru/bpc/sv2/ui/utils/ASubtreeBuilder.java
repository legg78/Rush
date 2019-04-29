package ru.bpc.sv2.ui.utils;

import java.util.ArrayList;
import java.util.List;

public abstract class ASubtreeBuilder
{
	private final Object _origRoot;
	
	public ASubtreeBuilder( Object treeRoot )
	{
		_origRoot = treeRoot;
	}
	
	public Object createSubtree()
	{
		return createSubtree( _origRoot );
	}
	
	private Object createSubtree( Object root )
	{
		List<?> childs = subnodes( root );
		
		if ( childs == null || childs.size() == 0 )
		{
			if ( shouldInclude( root ) )
			{
				return createClone( root );
			}
			else
			{
				return null;
			}
		}
		else
		{
			List<Object> neededChilds = new ArrayList<Object>();
			
			for ( Object child : childs )
			{
				Object subtree = createSubtree( child );
				
				if ( subtree != null )
				{
					neededChilds.add( subtree );
				}
			}
			
			if ( neededChilds.size() > 0 || shouldInclude( root ) )
			{
				Object clonedRoot = createClone( root );
				for ( Object child : neededChilds )
				{
					addChild( clonedRoot, child );
				}
				return clonedRoot;
			}
			else
			{
				return null;
			}
		}
	}
	
	protected abstract Object createClone( Object node );
	
	protected abstract List<?> subnodes( Object node );
	
	protected abstract Object addChild( Object parent, Object child );
	
	protected abstract boolean shouldInclude( Object node );
}
