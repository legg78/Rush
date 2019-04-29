package ru.bpc.sv2.ui.administrative.roles;

import java.util.List;

import ru.bpc.sv2.administrative.roles.PrivilegeGroupNode;
import ru.bpc.sv2.administrative.roles.PrivilegeNode;

public class NamePrivilegeSubtreeBuilder
	extends APrivilegeSubtreeBuilder
{
	private String _focusName;

	public NamePrivilegeSubtreeBuilder( Object treeRoot )
	{
		super( treeRoot );
	}
	
	public NamePrivilegeSubtreeBuilder( Object treeRoot, String privilegeName )
	{
		super( treeRoot );
		setFocusName( privilegeName );
	}
	
	public void setFocusName( String privilegeName )
	{
		if ( privilegeName == null )
		{
			_focusName = "";
		}
		else
		{
			_focusName = privilegeName.toLowerCase();
		}
	}
	
	@Override
	protected Object addChild( Object parent, Object child )
	{
		if ( parent instanceof PrivilegeGroupNode )
		{
			if ( child instanceof PrivilegeGroupNode )
			{
				List<PrivilegeGroupNode> members = ( (PrivilegeGroupNode)parent ).getMembers();
				if ( !members.contains( child ) )
				{
					members.add( (PrivilegeGroupNode)child );
				}
			}
			else if ( child instanceof PrivilegeNode )
			{
				List<PrivilegeNode> privileges = ( (PrivilegeGroupNode)parent ).getPrivileges();
				if ( !privileges.contains( child ) )
				{
					privileges.add( (PrivilegeNode)child );
				}
			}
		}
		return null;
	}
	
	@Override
	protected Object createClone( Object node )
	{
		PrivilegeNode newNode = (PrivilegeNode)super.createClone( node );
		if ( newNode instanceof PrivilegeGroupNode )
		{
			if ( shouldInclude( node ) )
			{
				PrivilegeGroupNode newGroupNode = (PrivilegeGroupNode)newNode;
				
				newGroupNode.getMembers().addAll( ( (PrivilegeGroupNode)node ).getMembers() );
				newGroupNode.getPrivileges().addAll( ( (PrivilegeGroupNode)node ).getPrivileges() );
			}
		}
		return newNode;
	}
	
	@Override
	protected boolean shouldInclude( Object node )
	{
		if ( node instanceof PrivilegeNode )
		{
			return ((PrivilegeNode)node).getName().toLowerCase().indexOf( _focusName ) >= 0;
		}
		else
		{
			return false;
		}
	}
	
}
