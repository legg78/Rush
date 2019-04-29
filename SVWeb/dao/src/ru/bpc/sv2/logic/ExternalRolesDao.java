package ru.bpc.sv2.logic;

import java.sql.SQLException;
import java.util.List;

import ru.bpc.sv2.logic.utility.db.DataAccessException;


import com.ibatis.sqlmap.client.SqlMapSession;

import ru.bpc.sv2.administrative.roles.ComplexRole;
import ru.bpc.sv2.administrative.roles.ExternalRole;
import ru.bpc.sv2.administrative.roles.ExtroleIdRoleIdBind;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.utility.db.IbatisAware;

/**
 * Session Bean implementation class ExternalRoles
 */
public class ExternalRolesDao extends IbatisAware {

    /**
     * Default constructor. 
     */
    public ExternalRolesDao() {
        // TODO Auto-generated constructor stub
    }

	@SuppressWarnings( "unchecked" )
	public ExternalRole[] getExternalRoles( Long userSessionId,  SelectionParams params )
	{
		SqlMapSession ssn = null;
		
		try
		{
			ssn = getIbatisSessionFE(userSessionId);

			List<ExternalRole> extroles = ssn.queryForList( "extroles.select-extroles", convertQueryParams( params ) );
			
			for ( ExternalRole extrole : extroles )
			{
				extrole.getAssignedRoles().addAll( ssn.queryForList( "extroles.select-extrole-roles", extrole ) );
			}

			return extroles.toArray( new ExternalRole[ extroles.size() ] );
		}
		catch( SQLException e )
		{
			throw new DataAccessException( e );
		}
		finally
		{
			close( ssn );
		}
	}
	
	public int getExternalRolesCount( Long userSessionId,  SelectionParams params )
	{
		SqlMapSession ssn = null;
		
		try
		{
			ssn = getIbatisSessionFE(userSessionId);

			return (Integer)ssn.queryForObject( "extroles.select-extroles-count", convertQueryParams( params ) );
			
		}
		catch( SQLException e )
		{
			throw new DataAccessException( e );
		}
		finally
		{
			close( ssn );
		}
	}
	
	public void createExternalRoleBinding( Long userSessionId,  ExternalRole extRole )
	{
		SqlMapSession ssn = null;
		
		try
		{
			ssn = getIbatisSessionFE(userSessionId);

			Integer extRoleId = (Integer)ssn.insert( "extroles.add-new-extrole", extRole );
			extRole.setId( extRoleId );
			
			bindRoles( ssn, extRole );
		}
		catch( SQLException e )
		{
			throw new DataAccessException( e );
		}
		finally
		{
			close( ssn );
		}
	}
	
	private void bindRoles( SqlMapSession ssn, ExternalRole extrole )
		throws SQLException
	{
		ssn.delete( "extroles.drop-role-bindings", extrole );
		
		ExtroleIdRoleIdBind binding = new ExtroleIdRoleIdBind();
		binding.extRoleId = extrole.getId();
		for ( ComplexRole role : extrole.getAssignedRoles() )
		{
			binding.roleId = role.getId();
			ssn.insert( "extroles.add-role-binding", binding );
		}
	}
	
	public void updateExternalRoleBinding( Long userSessionId,  ExternalRole extRole )
	{
		SqlMapSession ssn = null;
		
		try
		{
			ssn = getIbatisSessionFE(userSessionId);
			ssn.update( "extroles.update-extrole", extRole );
			bindRoles( ssn, extRole );
		}
		catch( SQLException e )
		{
			throw new DataAccessException( e );
		}
		finally
		{
			close( ssn );
		}
	}
	
	public void removeExternalRoleBinding( Long userSessionId,  ExternalRole extRole )
	{
		
	}
    
}
