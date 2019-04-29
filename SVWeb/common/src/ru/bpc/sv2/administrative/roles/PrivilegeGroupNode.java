package ru.bpc.sv2.administrative.roles;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class PrivilegeGroupNode
	extends PrivilegeNode
	implements ModelIdentifiable, Serializable
{

	/**
	 * 
	 */
	private static final long	serialVersionUID	= -7837023832890663874L;

	private int _id;
	private String _name;
	private boolean _assigned;
	
	private final List<PrivilegeGroupNode>	_members;
	private final List<PrivilegeNode>		_privileges;
	
	private List<PrivilegeNode> _childs;

	public PrivilegeGroupNode()
	{
		_members = new ArrayList<PrivilegeGroupNode>();
		_privileges = new ArrayList<PrivilegeNode>();
	}
	
	@Override
	public int getId()
	{
		return _id;
	}

	public void setId( int id )
	{
		_id = id;
	}

	@Override
	public String getName()
	{
		return _name;
	}

	public void setName( String name )
	{
		_name = name;
	}

	@Override
	public String getDescription()
	{
		return "".intern();
	}

	public void setDescription( String description )
	{
	}

	@Override
	public boolean isAssigned()
	{
		return _assigned;
	}

	@Override
	public void setAssigned( boolean assigned )
	{
		_assigned = assigned;
	}

	public List<PrivilegeGroupNode> getMembers()
	{
		return _members;
	}

	public List<PrivilegeNode> getPrivileges()
	{
		return _privileges;
	}
	
	@Override
	public List<PrivilegeNode> getChilds()
	{
		if ( _childs == null )
		{
			if ( _members == null && _privileges == null )
			{
				_childs = Collections.emptyList();
			}
			else
			{
				_childs = new ArrayList<PrivilegeNode>( _members.size() + _privileges.size() );
				_childs.addAll( _members );
				_childs.addAll( _privileges );
			}
		}
		
		return _childs;
	}

	@Override
	public Object getModelId()
	{
		return _id;
	}

}
