package ru.bpc.sv2.notifications;

@Deprecated
public class UserCustomEvent extends CustomEvent {
	private static final long serialVersionUID = 1L;

	private Integer roleId;
	private Integer userId;

	@Override
	public Object getModelId() {
		return getSchemeEventId() + "_" + getUserId() + "_" + getRoleId();
	}

	public Integer getRoleId() {
		return roleId;
	}

	public void setRoleId(Integer roleId) {
		this.roleId = roleId;
	}

	public Integer getUserId() {
		return userId;
	}

	public void setUserId(Integer userId) {
		this.userId = userId;
	}
}
