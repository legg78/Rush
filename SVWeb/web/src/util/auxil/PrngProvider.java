package util.auxil;

import java.security.Provider;
import java.security.Security;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/**
 * A PRNG provider that automatically choses between IBM and Sun SecureRandom implemenration
 */
public class PrngProvider extends Provider {
	private static Map<String, String> supportedPrngs = new HashMap<String, String>() {{
		put("SUN", "SHA1PRNG");
		put("IBMJCE", "IBMSecureRandom");
	}};
	private Service prngService;

	public PrngProvider() {
		super("SVPRNG", 1.0, "PrngProvider");
	}

	@Override
	public synchronized Service getService(String type, String algorithm) {
		if (!type.equals("SecureRandom"))
			return null;
		if (prngService == null) {
			for (Map.Entry<String, String> entry : supportedPrngs.entrySet()) {
				try {
					Provider provider = Security.getProvider(entry.getKey());
					prngService = provider.getService(type, entry.getValue());
					if (prngService != null) {
						break;
					}
				} catch (Exception ignored) {
				}
			}
			if (prngService == null)
				throw new IllegalArgumentException("Could not find supported PRNG algorithm");
		}
		return prngService;
	}

	@Override
	public synchronized Set<Service> getServices() {
		return Collections.singleton(getService("SecureRandom", "SecureRandom"));
	}
}
