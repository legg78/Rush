package ru.bpc.sv2.administrative.roles;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ExternalRole
	implements Serializable, ModelIdentifiable
{
	/**
	 * 
	 */
	private static final long	serialVersionUID	= 2444179232356696505L;
	
	private Integer _id = null;
	
	private String _name = null;
	
	private final List<ComplexRole> _assignedRoles = new ArrayList<ComplexRole>();
	
	public Integer getId()
	{
		return _id;
	}

	public void setId( Integer id )
	{
		_id = id;
	}

	public void setName( String name )
	{
		_name = name;
	}

	public String getName()
	{
		return _name;
	}
	
	public List<ComplexRole> getAssignedRoles()
	{
		return _assignedRoles;
	}
	
	public Object getModelId()
	{
		return getId();
	}
}
