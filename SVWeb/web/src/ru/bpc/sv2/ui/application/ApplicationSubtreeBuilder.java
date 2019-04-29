package ru.bpc.sv2.ui.application;

import java.util.List;

import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.ui.utils.ASubtreeBuilder;

public class ApplicationSubtreeBuilder
	extends ASubtreeBuilder
{
	
	public ApplicationSubtreeBuilder( Object treeRoot )
	{
		super( treeRoot );
	}

	@Override
	protected Object addChild( Object parent, Object child )
	{
		if ( parent instanceof ApplicationElement)
		{
			if (((ApplicationElement)child).getDataType() == null)
				( (ApplicationElement)parent ).getChildren().add( (ApplicationElement)child );						
		}
		return null;
	}
	
	@Override
	protected Object createClone( Object node )
	{
		if ( node instanceof ApplicationElement )
		{
			ApplicationElement groupNode = (ApplicationElement)node;
			
			ApplicationElement newGroupNode = new ApplicationElement();
			newGroupNode.setId( groupNode.getId() );			
			
			return newGroupNode;
		}		
		return null;
	}
	
	@Override
	protected List<?> subnodes( Object node )
	{
		if ( node instanceof ApplicationElement )
		{
			return ( (ApplicationElement)node ).getChildren();
		}
		else
		{
			return null;
		}
	}
	
	@Override
	protected boolean shouldInclude( Object node )
	{
		
		return false;
		
	}
}
