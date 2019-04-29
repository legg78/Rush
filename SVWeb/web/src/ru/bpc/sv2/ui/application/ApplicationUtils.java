package ru.bpc.sv2.ui.application;

import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.common.Address;


public class ApplicationUtils {
	private static final String ADDRESS_TYPE = "ADDRESS_TYPE";
	private static final String COUNTRY = "COUNTRY";
	private static final String HOUSE = "HOUSE";
	private static final String APARTMENT = "APARTMENT";
	private static final String POSTAL_CODE = "POSTAL_CODE";
	private static final String REGION_CODE = "REGION_CODE";
	private static final String ADDRESS_NAME = "ADDRESS_NAME";
	private static final String REGION = "REGION";
	private static final String CITY = "CITY";
	private static final String STREET = "STREET";

	public static void formatAddressElement(final ApplicationElement addressElement, final Address address) {
		if (addressElement == null || address == null) {
			return;
		}
		ApplicationElement childElement;

		childElement = addressElement.getChildByName(ADDRESS_TYPE, 1);
		if (childElement != null) {
			childElement.setValueV(address.getAddressType());
		}

		childElement = addressElement.getChildByName(COUNTRY, 1);
		if (childElement != null) {
			childElement.setValueV(address.getCountry());
		}

		childElement = addressElement.getChildByName(HOUSE, 1);
		if (childElement != null) {
			childElement.setValueV(address.getHouse());
		}

		childElement = addressElement.getChildByName(APARTMENT, 1);
		if (childElement != null) {
			childElement.setValueV(address.getApartment());
		}

		childElement = addressElement.getChildByName(POSTAL_CODE, 1);
		if (childElement != null) {
			childElement.setValueV(address.getPostalCode());
		}

		childElement = addressElement.getChildByName(REGION_CODE, 1);
		if (childElement != null) {
			childElement.setValueV(address.getRegionCode());
		}

		ApplicationElement addrName = addressElement.getChildByName(ADDRESS_NAME, 1);
		if (addrName != null) {
			childElement = addrName.getChildByName(REGION, 1);
			if (childElement != null) {
				childElement.setValueV(address.getRegion());
			}
			childElement = addrName.getChildByName(CITY, 1);
			if (childElement != null) {
				childElement.setValueV(address.getCity());
			}
			childElement = addrName.getChildByName(STREET, 1);
			if (childElement != null) {
				childElement.setValueV(address.getStreet());
			}
		}
	}
}
