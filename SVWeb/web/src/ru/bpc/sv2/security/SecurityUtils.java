package ru.bpc.sv2.security;

import com.bpcbt.svng.auth.utils.PasswordHashUtility;
import org.apache.log4j.Logger;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetails;
import ru.bpc.sv2.WebApplication;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.RequestContextHolder;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public abstract class SecurityUtils {
	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

	private SecurityUtils() {
	}

	public static boolean isUserLogged() {
		return SecurityContextHolder.getContext() != null
				&& SecurityContextHolder.getContext().getAuthentication() != null
				&& !(SecurityContextHolder.getContext().getAuthentication() instanceof AnonymousAuthenticationToken);
	}

	public static boolean tryAuthenticate(String login, String password) {
		AuthenticationManager authenticationManager = WebApplication.getApplicationContext().getBean(AuthenticationManager.class);
		try {
			UsernamePasswordAuthenticationToken token = new UsernamePasswordAuthenticationToken(login, password);

			WebAuthenticationDetails wad = new WebAuthenticationDetails(RequestContextHolder.getRequest());
			token.setDetails(wad);

			Authentication auth = authenticationManager.authenticate(token);
			return auth.isAuthenticated();
		} catch (AuthenticationException e) {
			logger.warn("Could not authenticate user " + login, e);
			return false;
		}
	}

	public static String encodePassword(String password) {
		return new PasswordHashUtility(PasswordHashUtility.DEFAULT_ALGORITHM).hashPassword(password, false, false);
	}

	public static List<String> validatePassword(String password) {
		List<String> result = new ArrayList<>();
		SettingsCache settings = SettingsCache.getInstance();
		if (password == null) {
			password = "";
		}
		int countAlpha = 0;
		int countNum = 0;
		int countLower = 0;
		int countUpper = 0;
		int countNonAlphanum = 0;
		int countNonAlphabet = 0;
		for (int i = 0; i < password.length(); i++) {
			char ch = password.charAt(i);
			if (Character.isAlphabetic(ch)) {
				countAlpha++;
				if (Character.isLowerCase(ch)) {
					countLower++;
				}
				if (Character.isUpperCase(ch)) {
					countUpper++;
				}
			} else {
				countNonAlphabet++;
				if (Character.isDigit(ch)) {
					countNum++;
				} else {
					countNonAlphanum++;
				}
			}
		}
		BigDecimal val = settings.getParameterNumberValue(SettingsConstants.PASSWORD_MIN_LENGTH);
		if (val != null && val.intValue() > 0 && password.length() < val.intValue()) {
			result.add(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acm", "password_min_length_invalid", val.intValue()));
		}
		val = settings.getParameterNumberValue(SettingsConstants.PASSWORD_MAX_LENGTH);
		if (val != null && val.intValue() > 0 && password.length() > val.intValue()) {
			result.add(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acm", "password_max_length_invalid", val.intValue()));
		}
		val = settings.getParameterNumberValue(SettingsConstants.PASSWORD_MIN_ALPHA_CHARS);
		if (val != null && val.intValue() > 0 && countAlpha < val.intValue()) {
			result.add(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acm", "password_min_alpha_chars_invalid", val.intValue()));
		}
		val = settings.getParameterNumberValue(SettingsConstants.PASSWORD_MIN_NUM_CHARS);
		if (val != null && val.intValue() > 0 && countNum < val.intValue()) {
			result.add(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acm", "password_min_num_chars_invalid", val.intValue()));
		}
		val = settings.getParameterNumberValue(SettingsConstants.PASSWORD_MIN_LOWERCASE_CHARS);
		if (val != null && val.intValue() > 0 && countLower < val.intValue()) {
			result.add(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acm", "password_min_lowercase_chars_invalid", val.intValue()));
		}
		val = settings.getParameterNumberValue(SettingsConstants.PASSWORD_MIN_UPPERCASE_CHARS);
		if (val != null && val.intValue() > 0 && countUpper < val.intValue()) {
			result.add(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acm", "password_min_uppercase_chars_invalid", val.intValue()));
		}
		val = settings.getParameterNumberValue(SettingsConstants.PASSWORD_MIN_NON_ALPHANUM_CHARS);
		if (val != null && val.intValue() > 0 && countNonAlphanum < val.intValue()) {
			result.add(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acm", "password_min_non_alphanum_chars_invalid", val.intValue()));
		}
		val = settings.getParameterNumberValue(SettingsConstants.PASSWORD_MIN_NON_ALPHABET_CHARS);
		if (val != null && val.intValue() > 0 && countNonAlphabet < val.intValue()) {
			result.add(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acm", "password_min_non_alphabet_chars_invalid", val.intValue()));
		}
		return result;
	}
}
