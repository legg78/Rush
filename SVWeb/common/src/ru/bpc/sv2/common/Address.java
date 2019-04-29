package ru.bpc.sv2.common;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Address implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 763148958078760771L;

	private Long addressId;
	private String lang;
	private String country;
	private String region;
	private String city;
	private String street;
	private String house;
	private String apartment;
	private String postalCode;
	private String regionCode;
	private Integer seqNum;
	private String addressType;
	private String countryName;

	private Long addressObjectId;
	private Long objectId;
	private String entityType;
	private String addressString;

	private String coordLabel;
	private String coordLink;
	private Double latitude;
	private Double longitude;
	private String placeCode;

	private String statusReason;

	public Long getAddressId() {
		return addressId;
	}

	public void setAddressId(Long addressId) {
		this.addressId = addressId;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getCountry() {
		return country;
	}

	public void setCountry(String country) {
		this.country = country;
	}

	public String getRegion() {
		return region;
	}

	public void setRegion(String region) {
		this.region = region;
	}

	public String getCity() {
		return city;
	}

	public void setCity(String city) {
		this.city = city;
	}

	public String getStreet() {
		return street;
	}

	public void setStreet(String street) {
		this.street = street;
	}

	public String getHouse() {
		return house;
	}

	public void setHouse(String house) {
		this.house = house;
	}

	public String getApartment() {
		return apartment;
	}

	public void setApartment(String apartment) {
		this.apartment = apartment;
	}

	public String getPostalCode() {
		return postalCode;
	}

	public void setPostalCode(String postalCode) {
		this.postalCode = postalCode;
	}

	public String getRegionCode() {
		return regionCode;
	}

	public void setRegionCode(String regionCode) {
		this.regionCode = regionCode;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public String getAddressType() {
		return addressType;
	}

	public void setAddressType(String addressType) {
		this.addressType = addressType;
	}
	
	public String getCountryName() {
		return countryName;
	}

	public void setCountryName(String countryName) {
		this.countryName = countryName;
	}

	/**
	 * <p>
	 * Composes full address from different address strings. May differ
	 * from <code>addressString</code> which is formed in data base.
	 * </p>
	 */
	public String getFullAddress() {
		StringBuilder fullAddress = new StringBuilder();
		
		if (countryName != null && countryName.length() > 0) {
			fullAddress.append(countryName);
		}

		if (postalCode != null && postalCode.length() > 0) {
			if (fullAddress.length() > 0) {
				fullAddress.append(", ");
			}
			fullAddress.append(postalCode); 
		}

		if (regionCode != null && regionCode.length() > 0) {
			if (fullAddress.length() > 0) {
				fullAddress.append(", ");
			}
			fullAddress.append(regionCode); 
		}

		if (region != null && region.length() > 0) {
			if (fullAddress.length() > 0) {
				fullAddress.append(", ");
			}
			fullAddress.append(region); 
		}
		if (city != null && city.length() > 0) {
			if (fullAddress.length() > 0) {
				fullAddress.append(", ");
			}
			fullAddress.append(city); 
		}
		if (street != null && street.length() > 0) {
			if (fullAddress.length() > 0) {
				fullAddress.append(", ");
			}
			fullAddress.append(street); 
		}
		if (house != null && house.length() > 0) {
			if (fullAddress.length() > 0) {
				fullAddress.append(", ");
			}
			fullAddress.append(house); 
		}
		if (apartment != null && apartment.length() > 0) {
			if (fullAddress.length() > 0) {
				fullAddress.append(", ");
			}
			fullAddress.append(apartment); 
		}
		
		return fullAddress.toString();
	}

	public Object getModelId() {
		return getAddressId();
	}

	public Long getAddressObjectId() {
		return addressObjectId;
	}

	public void setAddressObjectId(Long addressObjectId) {
		this.addressObjectId = addressObjectId;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public String getAddressString() {
		return addressString;
	}

	public void setAddressString(String addressString) {
		this.addressString = addressString;
	}

	public String getCoordLabel() {
		return coordLabel;
	}

	public void setCoordLabel(String coordLabel) {
		this.coordLabel = coordLabel;
	}

	public String getCoordLink() {
		return coordLink;
	}

	public void setCoordLink(String coordLink) {
		this.coordLink = coordLink;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	public Double getLatitude() {
		return latitude;
	}

	public void setLatitude(Double latitude) {
		this.latitude = latitude;
	}

	public Double getLongitude() {
		return longitude;
	}

	public void setLongitude(Double longitude) {
		this.longitude = longitude;
	}

	public String getPlaceCode() {
		return placeCode;
	}

	public void setPlaceCode(String placeCode) {
		this.placeCode = placeCode;
	}

	public String getStatusReason() {
		return statusReason;
	}

	public void setStatusReason(String statusReason) {
		this.statusReason = statusReason;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("addressType", this.getAddressType());
		result.put("lang", this.getLang());
		result.put("country", this.getCountry());
		result.put("postalCode", this.getPostalCode());
		result.put("regionCode", this.getRegionCode());
		result.put("region", this.getRegion());
		result.put("city", this.getCity());
		result.put("street", this.getStreet());
		result.put("house", this.getHouse());
		result.put("apartment", this.getApartment());
		result.put("latitude", this.getLatitude());
		result.put("longitude", this.getLongitude());
		
		return result;
	}
}
