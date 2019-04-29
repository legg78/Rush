package ru.bpc.sv2.ui.administrative.roles;

import ru.bpc.sv2.administrative.roles.PrivilegeNode;

public class AssignedPrivilegeSubtreeBuilder
	extends APrivilegeSubtreeBuilder
{
	
	public AssignedPrivilegeSubtreeBuilder( Object treeRoot )
	{
		super( treeRoot );
	}

	@Override
	protected boolean shouldInclude( Object node )
	{
		if ( node instanceof PrivilegeNode )
		{
			return ((PrivilegeNode)node).isAssigned();
		}
		return false;
	}
}
