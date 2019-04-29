package ru.bpc.sv2.ui.acm;

import org.apache.log4j.Logger;
import org.springframework.util.StringUtils;
import ru.bpc.sv2.logic.UsersDao;
import ru.bpc.sv2.security.AuthScheme;
import ru.bpc.sv2.security.CertificateAuthException;
import ru.bpc.sv2.security.SecurityUtils;
import ru.bpc.sv2.security.X509Utils;
import ru.bpc.sv2.ui.error.MbErrorUtils;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.RequestContextHolder;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.List;

@ViewScoped
@ManagedBean(name = "MbLogin")
public class MbLogin {
	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

	private UsersDao usersDao = new UsersDao();

	private String userName;
	private String password;
	private String oldPassword;
	private String newPassword;
	private String newPasswordConfirm;
	private boolean passwordExpired;

	private boolean passwordChanged;

	public void login() {

	}

	public void init() {
		if (userName == null) {
			passwordChanged = false;
			userName = RequestContextHolder.getRequest().getRemoteUser();
			passwordExpired = StringUtils.hasText(userName) && ManagedBeanWrapper.getManagedBean(MbErrorUtils.class).isPasswordExpiredErrorHappened();
			if (!passwordExpired) {
				password = null;
			} else {
				password = (String) RequestContextHolder.getRequest().getSession().getAttribute("j_password");
			}
		}
	}

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		RequestContextHolder.getRequest().getSession().setAttribute("j_password", password);
	}

	public String getOldPassword() {
		return oldPassword;
	}

	public void setOldPassword(String oldPassword) {
		this.oldPassword = oldPassword;
	}

	public String getNewPassword() {
		return newPassword;
	}

	public void setNewPassword(String newPassword) {
		this.newPassword = newPassword;
	}

	public String getNewPasswordConfirm() {
		return newPasswordConfirm;
	}

	public void setNewPasswordConfirm(String newPasswordConfirm) {
		this.newPasswordConfirm = newPasswordConfirm;
	}

	public boolean isPasswordExpired() {
		return passwordExpired;
	}

	@SuppressWarnings("unused")
	public boolean isPasswordChanged() {
		return passwordChanged;
	}

	public void changePassword() {
		if (userName == null) {
			return;
		}
		boolean error = false;
		String valueRequestMessage = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "field_required");
		if (!StringUtils.hasText(oldPassword)) {
			FacesUtils.addMessageError("newPasswordForm:oldPassword", valueRequestMessage);
			error = true;
		} else if (!password.equals(oldPassword)) {
			FacesUtils.addMessageError("newPasswordForm:oldPassword", FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acm", "invalid_old_password"));
			error = true;
		}
		if (!StringUtils.hasText(newPassword)) {
			FacesUtils.addMessageError("newPasswordForm:newPassword", valueRequestMessage);
			error = true;
		} else {
			if (password.equals(newPassword)) {
				FacesUtils.addMessageError("newPasswordForm:newPassword", FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acm", "password_should_no_be_the_same"));
				error = true;
			}
		}
		if (!StringUtils.hasText(newPasswordConfirm)) {
			FacesUtils.addMessageError("newPasswordForm:newPasswordConfirm", valueRequestMessage);
			error = true;
		}
		if (!error) {
			passwordChanged = changePassword(userName, oldPassword, newPassword, newPasswordConfirm, true);
		}
		if (passwordChanged) {
			RequestContextHolder.getRequest().getSession().setAttribute("j_password", null);
		}
	}

	public boolean changePassword(String userName, String oldPassword, String newPassword, String newPasswordConfirm) {
		return changePassword(userName, oldPassword, newPassword, newPasswordConfirm, false);
	}

	public boolean changePassword(String userName, String oldPassword, String newPassword, String newPasswordConfirm, boolean forceReset) {
		String idStr = SessionWrapper.getUserSessionIdStr();
		Long userSessionId = idStr != null ? Long.parseLong(idStr) : null;

		UserSession usession = ManagedBeanWrapper.getManagedBean("usession");
		try {
			if (!newPassword.equals(newPasswordConfirm)) {
				FacesUtils.addMessageError(new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acm", "passwords_dont_match")));
				return false;
			} else {
				List<String> errors = SecurityUtils.validatePassword(newPassword);
				if (!errors.isEmpty()) {
					for (String error : errors) {
						FacesUtils.addMessageError(error);
					}
					return false;
				}
				if (forceReset || (usession.getInRole().containsKey("CHANGE_PASSWORD") && !userName.equals(usession.getUserName()))) {
					usersDao.setPassword(userSessionId, userName, null, SecurityUtils.encodePassword(newPassword), forceReset);
				} else {
					if (!SecurityUtils.tryAuthenticate(userName, oldPassword)) {
						FacesUtils.addMessageError(new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acm", "wrong_old_password")));
						return false;
					}
					usersDao.setPassword(userSessionId, userName, null, SecurityUtils.encodePassword(newPassword));
				}
			}
			return true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return false;
		}
	}

	public boolean getCanLogin() {
		if (X509Utils.getEffectiveAuthScheme(null) != AuthScheme.ATHSPASS) {
			try {
				X509Utils.checkCertificateIfNecessary(RequestContextHolder.getRequest(), null);
			} catch (CertificateAuthException e) {
				return false;
			}
		}
		return true;
	}
}
