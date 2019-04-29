package com.bpcbt.svng.auth.utils;

public abstract class AppServerUtils {
	private static Boolean websphere;
	private static Boolean weblogic;

	private AppServerUtils() {
	}

	public static boolean isWebsphere() {
		if (websphere == null) {
			try {
				Class.forName("com.ibm.websphere.runtime.ServerName");
				websphere = true;
			} catch (Exception e) {
				websphere = false;
			}
		}
		return websphere;
	}

	public static boolean isWebogic() {
		if (weblogic == null) {
			try {
				Class.forName("weblogic.utils.Versions");
				weblogic = true;
			} catch (Exception e) {
				weblogic = false;
			}
		}
		return weblogic;
	}
}
