package ru.bpc.sv2.ui.administrative.roles;

import ru.bpc.sv2.administrative.roles.PrivilegeNode;

public class NameAssignedPrivilegeSubtreeBuilder
	extends NamePrivilegeSubtreeBuilder
{

	public NameAssignedPrivilegeSubtreeBuilder( Object treeRoot, String privilegeName )
	{
		super( treeRoot, privilegeName );
	}

	public NameAssignedPrivilegeSubtreeBuilder( Object treeRoot )
	{
		super( treeRoot );
	}

	@Override
	protected boolean shouldInclude( Object node )
	{
		if ( node instanceof PrivilegeNode )
		{
			return super.shouldInclude( node ) && ((PrivilegeNode)node).isAssigned();
		}
		else
		{
			return false;
		}
	}
}
