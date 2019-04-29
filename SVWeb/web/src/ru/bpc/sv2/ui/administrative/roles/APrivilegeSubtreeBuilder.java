package ru.bpc.sv2.ui.administrative.roles;

import java.util.List;

import ru.bpc.sv2.administrative.roles.PrivilegeGroupNode;
import ru.bpc.sv2.administrative.roles.PrivilegeNode;
import ru.bpc.sv2.ui.utils.ASubtreeBuilder;

public abstract class APrivilegeSubtreeBuilder
	extends ASubtreeBuilder
{
	
	public APrivilegeSubtreeBuilder( Object treeRoot )
	{
		super( treeRoot );
	}

	@Override
	protected Object addChild( Object parent, Object child )
	{
		if ( parent instanceof PrivilegeGroupNode )
		{
			if ( child instanceof PrivilegeGroupNode )
			{
				( (PrivilegeGroupNode)parent ).getMembers().add( (PrivilegeGroupNode)child );
			}
			else if ( child instanceof PrivilegeNode )
			{
				( (PrivilegeGroupNode)parent ).getPrivileges().add( (PrivilegeNode)child );
			}
		}
		return null;
	}
	
	@Override
	protected Object createClone( Object node )
	{
		if ( node instanceof PrivilegeGroupNode )
		{
			PrivilegeGroupNode groupNode = (PrivilegeGroupNode)node;
			
			PrivilegeGroupNode newGroupNode = new PrivilegeGroupNode();
			newGroupNode.setAssigned( groupNode.isAssigned() );
			newGroupNode.setDescription( groupNode.getDescription() );
			newGroupNode.setId( groupNode.getId() );
			newGroupNode.setName( groupNode.getName() );
			
			return newGroupNode;
		}
		else if ( node instanceof PrivilegeNode )
		{
			PrivilegeNode privNode = (PrivilegeNode)node;
			
			PrivilegeNode newPrivNode = new PrivilegeNode();
			newPrivNode.setAssigned( privNode.isAssigned() );
			newPrivNode.setPrivilege( privNode.getPrivilege() );
			
			return newPrivNode;
		}
		return null;
	}
	
	@Override
	protected List<?> subnodes( Object node )
	{
		if ( node instanceof PrivilegeGroupNode )
		{
			return ( (PrivilegeGroupNode)node ).getChilds();
		}
		else
		{
			return null;
		}
	}
	
}
