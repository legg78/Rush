package ru.bpc.sv2.logic.utility.db;

/**
 * Holder class that holds user name and associates it
 * with the current thread. The UserContext will be inherited
 * by any child threads spawned by the current thread
 */
public class UserContextHolder {
	private static final ThreadLocal<String> valueHolder = new InheritableThreadLocal<String>();

	public static String getUserName() {
		return valueHolder.get();
	}

	public static void setUserName(String userName) {
		if (userName == null)
			valueHolder.remove();
		else
			valueHolder.set(userName);
	}
}
