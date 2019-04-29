package ru.bpc.sv2.ui.administrative.roles;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.administrative.roles.ComplexRole;
import ru.bpc.sv2.administrative.roles.ExternalRole;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ExternalRolesDao;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.SessionWrapper;

@RequestScoped
@KeepAlive
@ManagedBean(name = "externalRoles")
public class ExternalRoles extends AbstractBean
{
	private ExternalRolesDao _extrolesDao = new ExternalRolesDao();

	private RolesDao _rolesDao = new RolesDao();

	private ExternalRole _activeRole;

	private boolean _managingNew;

	private final DaoDataModel<ExternalRole> _rolesSource;

	Long userSessionId = null;
	
	public ExternalRoles()
	{
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		
		_rolesSource = new DaoDataModel<ExternalRole>()
		{
			@Override
			protected ExternalRole[] loadDaoData(SelectionParams params )
			{
				return _extrolesDao.getExternalRoles( userSessionId,  params );
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params )
			{
				return _extrolesDao.getExternalRolesCount( userSessionId,  params );
			}
		};
	}

    @Override
    public void clearFilter() {
        // do nothing
    }

    public DaoDataModel<ExternalRole> getRolesSource()
	{
		return _rolesSource;
	}

	public ExternalRole getActiveRole()
	{
		return _activeRole;
	}

	public void setActiveRole( ExternalRole activeRole )
	{
		_activeRole = activeRole;
	}

	public SelectItem[] getAllAvailableRoles()
	{
		ComplexRole[] croles = _rolesDao.getRoles( userSessionId, null);
		SelectItem[] sitems = new SelectItem[ croles.length ];
		for( int i = 0; i < croles.length; i++ )
		{
			sitems[ i ] = new SelectItem( croles[ i ].getId(), croles[ i ].getName() );
		}

		return sitems;
	}

	public Integer[] getSelectedRoles()
	{
		if ( _activeRole.getAssignedRoles() == null )
		{
			return new Integer[ 0 ];
		}
		Integer[] selRoles = new Integer[ _activeRole.getAssignedRoles().size() ];
		for ( int i = 0; i < _activeRole.getAssignedRoles().size(); i++ )
		{
			selRoles[ i ] = _activeRole.getAssignedRoles().get( i ).getId();
		}

		return selRoles;
	}

	public void setSelectedRoles( Integer[] selectedRoles )
	{
		ComplexRole[] croles = _rolesDao.getRoles( userSessionId, null);
		_activeRole.getAssignedRoles().clear();
		for ( ComplexRole crole : croles )
		{
			boolean contains = false;
			Integer roleId = crole.getId();
			for ( Integer checkRoleId : selectedRoles )
			{
				if ( roleId.equals( checkRoleId ) )
				{
					contains = true;
					break;
				}
			}

			if ( contains )
			{
				_activeRole.getAssignedRoles().add( crole );
			}
		}
	}


	public String createNewRole()
	{
		setActiveRole( new ExternalRole() );

		_managingNew = true;

		return "open_details";
	}

	public String editExistingRole()
	{
		_managingNew = false;

		return "open_details";
	}

	public String commit()
	{
		try
		{
			if ( _managingNew )
			{
				_extrolesDao.createExternalRoleBinding( userSessionId,  _activeRole );
			}
			else
			{
				_extrolesDao.updateExternalRoleBinding( userSessionId,  _activeRole );
			}

			FacesUtils.addMessageInfo( "External role \"" + _activeRole.getName() + "\" saved" );

			_rolesSource.flushCache();

			return "success";
		}
		catch ( DataAccessException ee )
		{
			FacesUtils.addMessageError( ee );
			return "failure";
		}
	}

	public boolean isManagingNew()
	{
		return _managingNew;
	}

	public void setManagingNew( boolean managingNew )
	{
		_managingNew = managingNew;
	}
}
