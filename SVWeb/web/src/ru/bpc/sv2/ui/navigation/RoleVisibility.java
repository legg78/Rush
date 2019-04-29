package ru.bpc.sv2.ui.navigation;

import java.io.Serializable;
import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

public class RoleVisibility implements Serializable
{

	protected final Set<String>	_roles;
	private boolean	_visibleToAny	= false;

	public RoleVisibility()
	{
		super();
		_roles = new HashSet<String>();
	}

	public void addRoles( Collection<String> roles )
	{
		_roles.addAll( roles );
	}

	public Set<String> getRoles()
	{
		return _roles;
	}

	public void setVisibleToAny( boolean visibleToAny )
	{
		_visibleToAny = visibleToAny;
	}

	public boolean isVisibleToAny()
	{
		return _visibleToAny;
	}

}
