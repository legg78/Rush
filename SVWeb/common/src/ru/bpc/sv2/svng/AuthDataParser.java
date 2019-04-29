package ru.bpc.sv2.svng;

import java.io.StringReader;
import java.util.ArrayList;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamReader;
import org.apache.commons.lang3.StringUtils;

/**
 * BPC Group 2018 (c) All Rights Reserved
 */
public class AuthDataParser {
	private final XMLInputFactory factory;

	public AuthDataParser() {
		super();
		this.factory = XMLInputFactory.newInstance();
	}

	public AuthData parse(final String s, final Long operId) throws Exception {
		if (StringUtils.isNotEmpty(s)) {
			return new AuthData() {
				{
					StringReader sr = new StringReader(s);
					XMLStreamReader reader = factory.createXMLStreamReader(sr);
					try {
						setOperId(operId);
						while (reader.hasNext()) {
							reader.next();
							if (reader.isStartElement()) {
								if ("resp_code".equalsIgnoreCase(reader.getLocalName())) {
									setRespCode(parseString(reader));
								}
								else if ("proc_type".equalsIgnoreCase(reader.getLocalName())) {
									setProcType(parseString(reader));
								}
								else if ("proc_mode".equalsIgnoreCase(reader.getLocalName())) {
									setProcMode(parseString(reader));
								}
								else if ("is_advice".equalsIgnoreCase(reader.getLocalName())) {
									setIsAdvice(parseShort(reader));
								}
								else if ("is_repeat".equalsIgnoreCase(reader.getLocalName())) {
									setIsRepeat(parseShort(reader));
								}
								else if ("bin_amount".equalsIgnoreCase(reader.getLocalName())) {
									setBinAmount(parseLong(reader));
								}
								else if ("bin_currency".equalsIgnoreCase(reader.getLocalName())) {
									setBinCurrency(parseString(reader));
								}
								else if ("bin_cnvt_rate".equalsIgnoreCase(reader.getLocalName())) {
									setBinCnvtRate(parseLong(reader));
								}
								else if ("network_amount".equalsIgnoreCase(reader.getLocalName())) {
									setNetworkAmount(parseLong(reader));
								}
								else if ("network_currency".equalsIgnoreCase(reader.getLocalName())) {
									setNetworkCurrency(parseString(reader));
								}
								else if ("network_cnvt_date".equalsIgnoreCase(reader.getLocalName())) {
									setNetworkCnvtDate(parseString(reader));
								}
								else if ("network_cnvt_rate".equalsIgnoreCase(reader.getLocalName())) {
									setNetworkCnvtRate(parseLong(reader));
								}
								else if ("account_cnvt_rate".equalsIgnoreCase(reader.getLocalName())) {
									setAccountCnvtRate(parseLong(reader));
								}
								else if ("addr_verif_result".equalsIgnoreCase(reader.getLocalName())) {
									setAddrVerifResult(parseString(reader));
								}
								else if ("acq_resp_code".equalsIgnoreCase(reader.getLocalName())) {
									setAcqRespCode(parseString(reader));
								}
								else if ("acq_device_proc_result".equalsIgnoreCase(reader.getLocalName())) {
									setAcqDeviceProcResult(parseString(reader));
								}
								else if ("cat_level".equalsIgnoreCase(reader.getLocalName())) {
									setCatLevel(parseString(reader));
								}
								else if ("card_data_input_cap".equalsIgnoreCase(reader.getLocalName())) {
									setCardDataInputCap(parseString(reader));
								}
								else if ("crdh_auth_cap".equalsIgnoreCase(reader.getLocalName())) {
									setCrdhAuthCap(parseString(reader));
								}
								else if ("card_capture_cap".equalsIgnoreCase(reader.getLocalName())) {
									setCardCaptureCap(parseString(reader));
								}
								else if ("terminal_operating_env".equalsIgnoreCase(reader.getLocalName())) {
									setTerminalOperatingEnv(parseString(reader));
								}
								else if ("crdh_presence".equalsIgnoreCase(reader.getLocalName())) {
									setCrdhPresence(parseString(reader));
								}
								else if ("card_presence".equalsIgnoreCase(reader.getLocalName())) {
									setCardPresence(parseString(reader));
								}
								else if ("card_data_input_mode".equalsIgnoreCase(reader.getLocalName())) {
									setCardDataInputMode(parseString(reader));
								}
								else if ("crdh_auth_method".equalsIgnoreCase(reader.getLocalName())) {
									setCrdhAuthMethod(parseString(reader));
								}
								else if ("crdh_auth_entity".equalsIgnoreCase(reader.getLocalName())) {
									setCrdhAuthEntity(parseString(reader));
								}
								else if ("card_data_output_cap".equalsIgnoreCase(reader.getLocalName())) {
									setCardDataOutputCap(parseString(reader));
								}
								else if ("terminal_output_cap".equalsIgnoreCase(reader.getLocalName())) {
									setTerminalOutputCap(parseString(reader));
								}
								else if ("pin_capture_cap".equalsIgnoreCase(reader.getLocalName())) {
									setPinCaptureCap(parseString(reader));
								}
								else if ("pin_presence".equalsIgnoreCase(reader.getLocalName())) {
									setPinPresence(parseString(reader));
								}
								else if ("cvv2_presence".equalsIgnoreCase(reader.getLocalName())) {
									setCvv2Presence(parseString(reader));
								}
								else if ("cvc_indicator".equalsIgnoreCase(reader.getLocalName())) {
									setCvcIndicator(parseString(reader));
								}
								else if ("pos_entry_mode".equalsIgnoreCase(reader.getLocalName())) {
									setPosEntryMode(parseString(reader));
								}
								else if ("pos_cond_code".equalsIgnoreCase(reader.getLocalName())) {
									setPosCondCode(parseString(reader));
								}
								else if ("emv_data".equalsIgnoreCase(reader.getLocalName())) {
									setEmvData(parseString(reader));
								}
								else if ("atc".equalsIgnoreCase(reader.getLocalName())) {
									setAtc(parseString(reader));
								}
								else if ("tvr".equalsIgnoreCase(reader.getLocalName())) {
									setTvr(parseString(reader));
								}
								else if ("cvr".equalsIgnoreCase(reader.getLocalName())) {
									setCvr(parseString(reader));
								}
								else if ("addl_data".equalsIgnoreCase(reader.getLocalName())) {
									setAddlData(parseString(reader));
								}
								else if ("service_code".equalsIgnoreCase(reader.getLocalName())) {
									setServiceCode(parseString(reader));
								}
								else if ("device_date".equalsIgnoreCase(reader.getLocalName())) {
									setDeviceDate(parseString(reader));
								}
								else if ("cvv2_result".equalsIgnoreCase(reader.getLocalName())) {
									setCvv2Result(parseString(reader));
								}
								else if ("certificate_method".equalsIgnoreCase(reader.getLocalName())) {
									setCertificateMethod(parseString(reader));
								}
								else if ("certificate_type".equalsIgnoreCase(reader.getLocalName())) {
									setCertificateType(parseString(reader));
								}
								else if ("merchant_certif".equalsIgnoreCase(reader.getLocalName())) {
									setMerchantCertif(parseString(reader));
								}
								else if ("cardholder_certif".equalsIgnoreCase(reader.getLocalName())) {
									setCardholderCertif(parseString(reader));
								}
								else if ("ucaf_indicator".equalsIgnoreCase(reader.getLocalName())) {
									setUcafIndicator(parseString(reader));
								}
								else if ("is_early_emv".equalsIgnoreCase(reader.getLocalName())) {
									setIsEarlyEmv(parseShort(reader));
								}
								else if ("is_completed".equalsIgnoreCase(reader.getLocalName())) {
									setIsCompleted(parseString(reader));
								}
								else if ("amounts".equalsIgnoreCase(reader.getLocalName())) {
									setAmounts(parseString(reader));
								}
								else if ("system_trace_audit_number".equalsIgnoreCase(reader.getLocalName())) {
									setSystemTraceAuditNumber(parseString(reader));
								}
								else if ("transaction_id".equalsIgnoreCase(reader.getLocalName())) {
									setTransactionId(parseString(reader));
								}
								else if ("external_auth_id".equalsIgnoreCase(reader.getLocalName())) {
									setExternalAuthId(parseString(reader));
								}
								else if ("external_orig_id".equalsIgnoreCase(reader.getLocalName())) {
									setExternalOrigId(parseString(reader));
								}
								else if ("agent_unique_id".equalsIgnoreCase(reader.getLocalName())) {
									setAgentUniqueId(parseString(reader));
								}
								else if ("native_resp_code".equalsIgnoreCase(reader.getLocalName())) {
									setNativeRespCode(parseString(reader));
								}
								else if ("trace_number".equalsIgnoreCase(reader.getLocalName())) {
									setTraceNumber(parseString(reader));
								}
								else if ("auth_purpose_id".equalsIgnoreCase(reader.getLocalName())) {
									setAuthPurposeId(parseLong(reader));
								}
								else if ("auth_tag".equalsIgnoreCase(reader.getLocalName())) {
									if (getAuthTags() == null) {
										setAuthTags(new ArrayList<AuthTag>(32));
									}
									getAuthTags().add(parseAuthTag(reader, operId));
								}
							}
							else if (reader.isEndElement()) {
								if ("auth_data".equalsIgnoreCase(reader.getLocalName())) {
									break;
								}
							}
						}
					}
					finally {
						if (sr != null) {
							sr.close();
						}
						if (reader != null) {
							reader.close();
						}
					}
				}
			};
		}
		else {
			return (null);
		}
	}

	private String parseString(XMLStreamReader reader) throws XMLStreamException {
		String s = reader.getElementText();
		return (s);
	}

	private Long parseLong(XMLStreamReader reader) throws XMLStreamException {
		String s = reader.getElementText();
		if (StringUtils.isNotEmpty(s)) {
			return (Long.valueOf(s.trim()));
		}
		else {
			return (null);
		}
	}

	private Integer parseInteger(XMLStreamReader reader) throws XMLStreamException {
		String s = reader.getElementText();
		if (StringUtils.isNotEmpty(s)) {
			return (Integer.valueOf(s.trim()));
		}
		else {
			return (null);
		}
	}

	private Short parseShort(XMLStreamReader reader) throws XMLStreamException {
		String s = reader.getElementText();
		if (StringUtils.isNotEmpty(s)) {
			return (Short.valueOf(s.trim()));
		}
		else {
			return (null);
		}
	}

	private AuthTag parseAuthTag(XMLStreamReader reader, Long operId) throws XMLStreamException {
		AuthTag at = new AuthTag(operId);
		while (reader.hasNext()) {
			reader.next();
			if (reader.isStartElement()) {
				if ("tag_id".equalsIgnoreCase(reader.getLocalName())) {
					at.setTagId(parseInteger(reader));
				}
				else if ("tag_value".equalsIgnoreCase(reader.getLocalName())) {
					at.setTagValue(parseString(reader));
				}
				else if ("tag_name".equalsIgnoreCase(reader.getLocalName())) {
					at.setTagName(parseString(reader));
				}
			}
			else if (reader.isEndElement()) {
				if ("auth_tag".equalsIgnoreCase(reader.getLocalName())) {
					break;
				}
			}
		}
		return (at);
	}
}
