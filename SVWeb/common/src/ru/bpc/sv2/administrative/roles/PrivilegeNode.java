package ru.bpc.sv2.administrative.roles;

import java.io.Serializable;
import java.util.Collections;
import java.util.List;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class PrivilegeNode
	implements ModelIdentifiable, Serializable
{
	/**
	 * 
	 */
	private static final long	serialVersionUID	= -7586600293475669467L;
	
	private boolean 			_assigned;

	private Privilege _privilege; 
	
	public boolean isAssigned()
	{
		return _assigned;
	}

	public void setAssigned( boolean assigned )
	{
		_assigned = assigned;
	}

	public Privilege getPrivilege()
	{
		return _privilege;
	}

	public void setPrivilege( Privilege privilege )
	{
		_privilege = privilege;
	}
	
	public int getId()
	{
		return _privilege.getId();
	}

	public String getName()
	{
		return _privilege.getName();
	}

	public String getDescription()
	{
		return _privilege.getDescription();
	}

	public List<PrivilegeNode> getChilds()
	{
		return Collections.emptyList();
	}
	
	public Object getModelId()
	{
		return getId();
	}
	
	@Override
	public boolean equals( Object obj )
	{
		if ( obj instanceof PrivilegeNode )
		{
			return getId() == ( (PrivilegeNode)obj ).getId();
		}
		return false;
	}
}
