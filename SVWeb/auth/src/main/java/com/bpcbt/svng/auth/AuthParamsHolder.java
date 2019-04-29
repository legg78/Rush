package com.bpcbt.svng.auth;

public final class AuthParamsHolder {
	private static boolean useSso = false;
	private static String ssoServer = null;

	public static boolean isUseSso() {
		return useSso;
	}

	public static void setUseSso(boolean useNewAuth) {
		AuthParamsHolder.useSso = useNewAuth;
	}

	public static String getSsoServer() {
		return ssoServer;
	}

	public static void setSsoServer(String ssoServer) {
		AuthParamsHolder.ssoServer = ssoServer;
	}
}
