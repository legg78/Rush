package ru.bpc.sv.ws.integration;

import oracle.jdbc.OracleTypes;
import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import ru.bpc.sv2.accounts.Transaction;
import ru.bpc.sv2.constants.DatePatterns;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.WebServiceConstants;
import ru.bpc.sv2.credit.CreditInvoice;
import ru.bpc.sv2.credit.CreditInvoiceAggregation;
import ru.bpc.sv2.credit.CreditInvoiceOperation;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.logic.IntegrationDao;
import ru.bpc.sv2.logic.utility.JndiUtils;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import ru.bpc.sv2.logic.utility.db.UserContextHolder;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.products.Product;
import ru.bpc.sv2.ui.utils.cache.DictCache;
import ru.bpc.sv2.utils.UserException;
import ru.bpc.svxp.*;
import ru.bpc.svxp.integration.*;
import ru.bpc.svxp.integration.ObjectFactory;

import javax.annotation.Resource;
import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebResult;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;
import javax.servlet.ServletContext;
import javax.sql.DataSource;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;
import javax.xml.ws.BindingProvider;
import javax.xml.ws.WebServiceContext;
import javax.xml.ws.handler.MessageContext;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.regex.Pattern;

@SuppressWarnings("unused")
@WebService(name = "InfoWS", portName = "InfoWSSOAP", serviceName = "InfoWS", targetNamespace = "http://bpc.ru/SVXP/integration/")
@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.BARE)
@XmlSeeAlso({ObjectFactory.class})
public class InfoWebService implements InfoWS {
	private static final Logger logger = Logger.getLogger("SVAP");

	IntegrationDao integDao;

	@Resource
	private WebServiceContext wsContext;

	private Fault_Exception handleException(Exception e) {
		logger.error(e.getMessage(), e);
		String message = e.getMessage();
		Fault fault = new Fault();
		if (message != null && message.startsWith("ORA-")) {
			message = message.replaceFirst("ORA-\\d+: ", "");
			message = message.split("ORA-\\d+:")[0];
		}
		fault.setDescription(message);
		if (e instanceof UserException) {
			fault.setCode(((UserException) e).getErrorCodeText());
		} else {
			fault.setCode("UNKNOWN");
		}
		UserContextHolder.setUserName(null);
		return new Fault_Exception("ERROR", fault);
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/auth")
	@WebResult(name = "authResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public Auth auth(@WebParam(name = "authRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") AuthRequest request)
			throws Fault_Exception {
		try {
			Map<String, Object> map = new HashMap<String, Object>();
			checkLength(request.getCardNumber(), 12, 24, "cardNum");
			map.put("cardNum", request.getCardNumber());
			map.put("keyword", request.getKeyword());
			if (request.getInstId() != null) {
				map.put("instId", request.getInstId());
			}

			initDao();
			map = integDao.auth(map);

			Auth response = new Auth();
			if (map.get("customerId") != null) {
				response.setCustomerId((Long) map.get("customerId"));
			}
			if (map.get("instId") != null) {
				response.setInstId((Integer) map.get("instId"));
			}

			return response;
		} catch (Exception e) {
			throw handleException(e);
		}
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getCustomerInfo")
	@WebResult(name = "getCustomerInfoResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public CustomerInfo getCustomerInfo(@WebParam(name = "getCustomerInfoRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetCustomerInfoRequest request)
			throws Fault_Exception {
		try {
			Map<String, Object> map = new HashMap<String, Object>();
			checkLength(String.valueOf(request.getCustomerId()), 12, "customerId");
			map.put("customerId", request.getCustomerId());
			checkLength(String.valueOf(request.getInstId()), 4, 4, "instId");
			map.put("instId", request.getInstId());

			long userSessionId = initDao();
			map = integDao.getCustomerInfo(userSessionId, map);

			CustomerInfo response = new CustomerInfo();
			response.setName((String) map.get("name"));
			response.setMsisdn((String) map.get("msisdn"));

			return response;
		} catch (Exception e) {
			throw handleException(e);
		}
	}

    @Override
    @WebMethod(action = "http://bpc.ru/SVXP/integration/getCards")
    @WebResult(name = "getCardsResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
    public Cards getCards(
            @WebParam(name = "getCardsRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetCardsRequest request)
            throws Fault_Exception {
        Cards out = new Cards();
        try {
            Map<String, Object> map = new HashMap<String, Object>();
	        if (request.getCustomerId() != null) {
		        checkLength(request.getCustomerId().toString(), 12, "customer_id");
		        map.put("customer_id", request.getCustomerId());
	        } else {
		        checkLength(request.getInstId().toString(), 4, "inst_id");
		        map.put("inst_id", request.getInstId());
	        }
            if (StringUtils.isNotBlank(request.getCustomerNumber())) {
		        checkLength(request.getCustomerNumber(), 200, "customer_number");
		        map.put("customer_number", request.getCustomerNumber());
	        }
			if (StringUtils.isNotBlank(request.getAccountNumber())) {
		        checkLength(request.getAccountNumber(), 32, "account_number");
		        map.put("account_number", request.getAccountNumber());
	        }
	        if (request.getAccountId() != null) {
		        checkLength(request.getAccountId().toString(), 12, "account_id");
		        map.put("account_id", request.getAccountId());
	        }
	        if (request.getState() != null) {
		        checkLength(request.getState(), 8, "state");
		        map.put("state", request.getState());
	        }
	        if (StringUtils.isNotBlank(request.getCardMask())) {
		        checkLength(request.getCardMask().trim(), 24, "card_mask");
		        map.put("card_mask", Filter.mask(request.getCardMask()));
	        }
	        if (request.getCardTypeId() != null) {
		        checkLength(request.getCardTypeId().toString(), 4, "card_type_id");
	        	map.put("card_type_id", request.getCardTypeId());
	        }
	        if (request.getProductId() != null) {
		        checkLength(request.getProductId().toString(), 8, "product_id");
	        	map.put("product_id", request.getProductId());
	        }
	        if (request.getCreationDate() != null) {
		        map.put("creation_date", request.getCreationDate().toGregorianCalendar().getTime());
	        } else if (request.getRegistrationDate() != null) {
		        if (request.getRegistrationTime() != null) {
			        long creationDateTime = request.getRegistrationDate().toGregorianCalendar().getTime().getTime() +
					        request.getRegistrationTime().toGregorianCalendar().getTime().getTime();
			        map.put("creation_date", new Date(creationDateTime));
		        } else {
			        map.put("creation_date", request.getRegistrationDate().toGregorianCalendar().getTime());
		        }
	        }
	        if (request.getExpirDate() != null) {
		        Date expDate = null;
		        checkLength(request.getExpirDate(), 7, "expir_date");
		        try {
			        expDate = new SimpleDateFormat(DatePatterns.EXP_DATE_PATTERN).parse(request.getExpirDate());
		        } catch (ParseException e) {
			        expDate = new SimpleDateFormat(DatePatterns.FULL_EXP_DATE_PATTERN).parse(request.getExpirDate());
		        }
		        if (expDate != null) {
			        Calendar c = Calendar.getInstance();
			        c.setTime(expDate);
			        c.set(Calendar.DAY_OF_MONTH, c.getActualMaximum(Calendar.DAY_OF_MONTH));
			        map.put("expir_date", c.getTime());
		        }
	        }
	        if (request.getEmbossedName() != null) {
		        checkLength(request.getEmbossedName(), 200, "embossed_name");
	        	map.put("embossed_name", request.getEmbossedName().trim());
	        }
	        if (request.getCardholderName() != null) {
		        if (StringUtils.isNotBlank(request.getCardholderName().getFirstName())) {
			        checkLength(request.getCardholderName().getFirstName(), 200, "cardholder_first_name");
		        	map.put("cardholder_first_name", request.getCardholderName().getFirstName().trim());
		        }
		        if (StringUtils.isNotBlank(request.getCardholderName().getLastName())) {
			        checkLength(request.getCardholderName().getLastName(), 200, "cardholder_last_name");
		        	map.put("cardholder_last_name", request.getCardholderName().getLastName().trim());
		        }
	        }
	        if (StringUtils.isNotBlank(request.getCardholderNumber())) {
		        checkLength(request.getCardholderNumber(), 200, "cardholder_number");
		        map.put("cardholder_number", request.getCardholderNumber());
	        }
	        if (StringUtils.isNotBlank(request.getLang())) {
		        checkLang(request.getLang());
		        map.put("lang", request.getLang());
	        } else {
		        map.put("lang", SystemConstants.ENGLISH_LANGUAGE);
	        }
	        if (request.getImpersonalCards() != null) {
		        map.put("impersonal_cards", request.getImpersonalCards());
	        }

            long userSessionId = initDao();
            if (map.containsKey("customer_id")) {
                out.getCard().addAll(integDao.getCards(userSessionId, map));
            } else if (map.containsKey("customer_number") && map.containsKey("inst_id")) {
	            out.getCard().addAll(integDao.getCards(userSessionId, map));
            } else if (map.containsKey("cardholder_number") && map.containsKey("inst_id")) {
                out.getCard().addAll(integDao.getCards(userSessionId, map));
            } else if (map.containsKey("card_mask") && map.containsKey("inst_id")) {
	            out.getCard().addAll(integDao.getCards(userSessionId, map));
            } else {
                throw new UserException("Customer ID, cardholder/customer number/card mask and institution ID is required",
                                        "PARAMETER_IS_REQUIRED", null);
            }
	        return out;
        } catch (Exception e) {
            throw handleException(e);
        }
    }

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getOperations")
	@WebResult(name = "getOperationsResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public Operations getOperations(
			@WebParam(name = "getOperationsRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetOperationsRequest request)
			throws Fault_Exception {
		try {
			Operations operationsSpx = new Operations();
			ru.bpc.svxp.Operation[] operations;
			Map<String, Object> filters = new HashMap<String, Object>();
			if (request.getEndDate() != null) {
				filters.put("end_date", request.getEndDate().toGregorianCalendar().getTime());
			}
			if (request.getStartDate() != null) {
				filters.put("start_date", request.getStartDate().toGregorianCalendar().getTime());
			}
			if (request.getAccountId() != null) {
				checkLength(request.getAccountId().toString(), 12, "account_id");
				filters.put("account_id", request.getAccountId());
			}
			if (request.getAccountNumber() != null) {
				checkLength(request.getAccountNumber(), 32, "account_number");
				filters.put("account_number", request.getAccountNumber());
			}
			if (request.getCardId() != null) {
				checkLength(request.getCardId(), 200, "card_id");
				filters.put("card_id", request.getCardId());
			}
			if (request.getCardNumber() != null) {
				checkLength(request.getCardNumber(), 24, "card_number");
				filters.put("card_number", request.getCardNumber());
			}
			if (request.getCustomerId() != null) {
				checkLength(request.getCustomerId().toString(), 12, "customer_id");
				filters.put("customer_id", request.getCustomerId());
			}
			if (request.getCustomerNumber() != null) {
				checkLength(request.getCustomerNumber(), 200, "customer_number");
				filters.put("customer_number", request.getCustomerNumber());
			}
			checkLength(String.valueOf(request.getInstId()), 4, "inst_id");
			filters.put("inst_id", request.getInstId());
			if (request.getStatuses() != null) {
				for (Object st : request.getStatuses().getStatus()) {
					checkLength(st.toString(), 8, "status");
				}
				filters.put("i_status_tab", request.getStatuses().getStatus().toArray());
			} else {
				filters.put("i_status_tab", (new ArrayList<Object>()).toArray());
			}
			if (request.getOperType() != null) {
				checkLength(request.getOperType(), 8, "oper_type");
				filters.put("oper_type", request.getOperType());
			}
			if (request.getMsgType() != null) {
				checkLength(request.getMsgType(), 8, "msg_type");
				filters.put("msg_type", request.getMsgType());
			}
			if (request.getMatchStatus() != null) {
				checkLength(request.getMatchStatus(), 8, "match_status");
				filters.put("match_status", request.getMatchStatus());
			}
			if (request.getMerchantNumber() != null) {
				checkLength(request.getMerchantNumber(), 15, "merchant_number");
				filters.put("merchant_number", request.getMerchantNumber());
			}
			if (request.getMerchantName() != null) {
				checkLength(request.getMerchantName(), 200, "merchant_name");
				filters.put("merchant_name", request.getMerchantName());
			}
			if (StringUtils.isNotBlank(request.getLang())) {
				checkLang(request.getLang());
				filters.put("lang", request.getLang());
			} else {
				filters.put("lang", "LANGENG");
			}

			long userSessionId = initDao();
			operations = integDao.getOperations(userSessionId, filters);
			for (ru.bpc.svxp.Operation op : operations) {
				operationsSpx.getOperation().add(op);
			}
			return operationsSpx;
		} catch (Exception e) {
			throw handleException(e);
		}
	}

	@WebMethod(action = "http://bpc.ru/SVXP/integration/generatePinBlock")
	@WebResult(name = "generatePinBlockResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public GeneratePinBlockResponse generatePinBlock(
			@WebParam(name = "generatePinBlockRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input")
			GeneratePinBlockRequest request)
			throws Fault_Exception {
		GeneratePinBlockResponse resp = new GeneratePinBlockResponse();
		try {
			long userSessionId = initDao();
			String pinBlock = integDao.getPINblock(userSessionId, request);
			Base64 encoder = new Base64();
			byte[] encodedBytes = encoder.encode(pinBlock.getBytes());
			String base64 = new String(encodedBytes);
			resp.setPinBlock(base64);
			return resp;
		} catch (Exception e) {
			throw handleException(e);
		}
	}

	private long initDao() throws Fault_Exception {
		try {
			ServletContext servletContext = (ServletContext) wsContext.getMessageContext().get(MessageContext.SERVLET_CONTEXT);
			MessageContext mc = wsContext.getMessageContext();
			mc.get(BindingProvider.USERNAME_PROPERTY);
			mc.get(BindingProvider.PASSWORD_PROPERTY);
			String userFile = servletContext.getInitParameter(SystemConstants.EXTERNAL_PROPERTIES_FILE);
			Properties prop = new Properties();
			String wsUserName;
			try {
				prop.load(new FileInputStream(userFile));
				wsUserName = prop.getProperty(WebServiceConstants.WS_USERNAME_PROPERTY);
				wsUserName = (wsUserName == null) ? WebServiceConstants.WS_DEFAULT_CREDENTIALS : wsUserName;
			} catch (FileNotFoundException e) {
				logger.error(e.getMessage());
				logger.trace("Using default credentials...");
				wsUserName = WebServiceConstants.WS_DEFAULT_CREDENTIALS;
			}

			long userSessionId = registerSession(wsUserName);
			integDao = new IntegrationDao();
			return userSessionId;
		} catch (Exception e) {
			logger.error("", e);
			throw new Fault_Exception("ERROR", new Fault());
		}
	}

	private Long registerSession(String userName) throws Exception {
		Long sessionId;
		Connection con = JndiUtils.getConnection();
		CallableStatement cstmt = null;
		try {
			cstmt = con.prepareCall("{ call com_ui_user_env_pkg.set_user_context( " +
							"  i_user_name  	=> ?" +
							", io_session_id	=> ?" +
							", i_ip_address		=> ?)}"
			);

			cstmt.setString(1, userName);
			cstmt.setObject(2, null, OracleTypes.BIGINT);
			cstmt.setObject(3, null, OracleTypes.VARCHAR);
			cstmt.registerOutParameter(2, OracleTypes.BIGINT);
			cstmt.executeUpdate();

			sessionId = cstmt.getLong(2);
			if (sessionId == 0) {
				throw new Exception("Couldn't set user context.");
			}

			con.commit();
			UserContextHolder.setUserName(userName);
		} catch (Exception e) {
			try {
				con.rollback();
			} catch (SQLException ignored) {
			}
			throw e;
		} finally {
			if (cstmt != null) {
				try {
					cstmt.close();
				} catch (SQLException ignored) {
				}
			}
			if (con != null) {
				try {
					con.close();
				} catch (SQLException ignored) {
				}
			}
		}

		return sessionId;
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getInvoice")
	@WebResult(name = "getInvoiceResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public Invoice getInvoice(@WebParam(name = "getInvoiceRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetInvoiceRequest request)
		throws Fault_Exception {
		Invoice resp = new Invoice();
		try {
			long userSessionId = initDao();
			Map<String, Object> params = new HashMap<String, Object>();

			checkLength(request.getAccountNumber(), 32, "Account number");
			checkLength(String.valueOf(request.getInstId()), 4, "Inst id");

			params.put("account_number", request.getAccountNumber());
			params.put("inst_id", request.getInstId());
			if (request.getInvoiceAge() != null) {
				params.put("invoice_age", request.getInvoiceAge());
			}

			CreditInvoice invoice = integDao.getSpecifiedInvoice(userSessionId, params);
			if (invoice == null) {
				return null;
			}

			resp.setAccountNumber(invoice.getAccountNumber());
			resp.setCurrency(invoice.getCurrency());
			resp.setSerialNumber(invoice.getSerialNumber());
			resp.setExceedLimit(invoice.getExceedLimit());
			resp.setMinAmountDue(invoice.getMinAmountDue());
			resp.setTotalAmountDue(invoice.getTotalAmountDue());
			resp.setOwnFunds(invoice.getOwnFunds());
			resp.setInvoiceType(invoice.getType());
			resp.setCustomerName(invoice.getCustomerName());
			resp.setCustomerAddress(invoice.getCustomerAddress());
			resp.setTotalIncome(invoice.getTotalIncome());
			resp.setTotalExpenses(invoice.getTotalExpenses());
			resp.setInterestAmount(invoice.getInterestAmount());
			resp.setFeeAmount(invoice.getFeeAmount());
			resp.setOverdueAmount(invoice.getOverdueAmount());
			resp.setOverdueInterestAmount(invoice.getOverdueInterestAmount());
			resp.setPenaltyFeeAmount(invoice.getPenaltyFeeAmount());
			resp.setIncomingDebt(invoice.getIncomingDebt());
			resp.setOutgoingDebt(invoice.getOutgoingDebt());

			GregorianCalendar cal = new GregorianCalendar();
			if (invoice.getStartDate() != null) {
				cal.setTime(invoice.getStartDate());
				resp.setStartDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
			} else {
				resp.setStartDate(null);
			}
			if (invoice.getDueDate() != null) {
				cal.setTime(invoice.getDueDate());
				resp.setDueDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
			} else {
				resp.setDueDate(null);
			}
			if (invoice.getGraceDate() != null) {
				cal.setTime(invoice.getGraceDate());
				resp.setGraceDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
			} else {
				resp.setGraceDate(null);
			}
			if (invoice.getInvoiceDate() != null) {
				cal.setTime(invoice.getInvoiceDate());
				resp.setInvoiceDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
			} else {
				resp.setInvoiceDate(null);
			}
			if (invoice.getStatementDate() != null) {
				cal.setTime(invoice.getStatementDate());
				resp.setStatementDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
			} else {
				resp.setStatementDate(null);
			}
			if (invoice.getBeginDate() != null) {
				cal.setTime(invoice.getBeginDate());
				resp.setInvoiceBeginDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
			} else {
				resp.setInvoiceBeginDate(null);
			}
			if (invoice.getEndDate() != null) {
				cal.setTime(invoice.getEndDate());
				resp.setInvoiceEndDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
			} else {
				resp.setInvoiceEndDate(null);
			}

			resp.setAgingPeriod(invoice.getAging());
			resp.setIsMadPaid(invoice.getMadPaid() ? 1 : 0);
			resp.setIsTadPaid(invoice.getTadPaid() ? 1 : 0);
			resp.setOperationsDetails(null);
			resp.setOperationsTotal(null);

			if (invoice.getId() != null) {
				params.clear();
				params.put("invoice_id", invoice.getId());

				List<CreditInvoiceAggregation> aggregations = integDao.getInvoiceAggregation(userSessionId, params);
				if (aggregations != null && aggregations.size() > 0) {
					OperationsTotal operTotals = new OperationsTotal();
					for (CreditInvoiceAggregation aggregation : aggregations) {
						OperationTotal item = new OperationTotal();
						item.setOperationType(aggregation.getType() + " - " + aggregation.getTypeName());
						item.setOperationCurrency(aggregation.getCurrency());
						item.setTotalOperationCount(aggregation.getCount());
						item.setTotalOperationAmount(aggregation.getAmount());
						operTotals.getOperationTotal().add(item);
					}
					resp.setOperationsTotal(operTotals);
				}

				if (Boolean.TRUE.equals(request.isIncludeOperDetails())) {
					List<CreditInvoiceOperation> operations = integDao.getInvoiceOperations(userSessionId, params);
					if (operations != null && operations.size() > 0) {
						OperationsDetails operDetails = new OperationsDetails();
						for (CreditInvoiceOperation operation : operations) {
							OperationDetails item = new OperationDetails();
							item.setCredit(operation.getCredit());
							item.setExpenses(operation.getExpenses());
							item.setIncome(operation.getIncome());
							item.setOperationDescription(operation.getDescription());
							item.setOperType(operation.getType());
							item.setPercent(operation.getPercent());
							item.setRepayment(operation.getRepayment());
							if (operation.getDate() != null) {
								cal.setTime(operation.getDate());
								item.setOperDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
							} else {
								item.setOperDate(null);
							}
							operDetails.getOperationDetails().add(item);
						}
						resp.setOperationsDetails(operDetails);
					}
				}
			}
			return resp;
		} catch (Exception e) {
			throw handleException(e);
		}
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getCustomerByCard")
	@WebResult(name = "getCustomerByCardResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public CustomerByCard getCustomerByCard(
			@WebParam(name = "getCustomerByCardRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetCustomerByCardRequest request)
			throws Fault_Exception {
		CustomerByCard response = null;
		try {
			Map<String, Object> filters = new HashMap<String, Object>();
			if (StringUtils.isNotBlank(request.getCardNumber())) {
				checkLength(request.getCardNumber(), 24, "card_number");
				filters.put("card_number", Filter.mask(request.getCardNumber()));
			}
			if (request.getInstId() != null) {
				checkLength(request.getInstId().toString(), 4, 4, "inst_id");
				filters.put("inst_id", request.getInstId());
			}
			if (StringUtils.isNotBlank(request.getLang())) {
				checkLang(request.getLang());
				filters.put("lang", request.getLang());
			}

			Long userSessionId = initDao();
			response = integDao.getCustomerByCard(userSessionId, filters);
		} catch(DataAccessException dao) {
			if (dao.getMessage().toUpperCase().contains("CARD")) {
				throw handleException(new UserException(dao.getCause().getMessage(), "CARD_NOT_FOUND", dao));
			} else if (dao.getMessage().toUpperCase().contains("CUSTOMER")) {
				throw handleException(new UserException(dao.getCause().getMessage(), "CUSTOMER_NOT_FOUND", dao));
			} else {
				throw handleException((Exception)dao);
			}
		} catch (Exception e) {
			throw handleException(e);
		}
		return response;
	}

	@WebMethod(action = "http://bpc.ru/SVXP/integration/getAccounts")
	@WebResult(name = "getAccountsResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public Accounts getAccounts(
			@WebParam(name = "getAccountsRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetAccountsRequest request)
			throws Fault_Exception {
		try {
			Map<String, Object> filters = new HashMap<String, Object>();

			if (request.getAccountType() != null) {
				checkLength(request.getAccountType(), 8,
						"account_type");
				filters.put("account_type", request.getAccountType());
			}
			if (request.getCardId() != null) {
				checkLength(request.getCardId(), 200, "card_id");
				filters.put("card_id", request.getCardId());
			}
			if (request.getCardNumber() != null) {
				checkLength(request.getCardNumber(), 24, "card_number");
				filters.put("card_number", request.getCardNumber());
			}
			if ((request.getCustomerId() != null)) {
				checkLength(request.getCustomerId().toString(), 12, "customer_id");
				filters.put("customer_id", request.getCustomerId());
			} else if (request.getCustomerNumber() != null) {
				checkLength(request.getCustomerNumber(), 200, "customer_number");
				filters.put("customer_number", request.getCustomerNumber());
			}

			checkLength(String.valueOf(request.getInstId()), 4, "inst_id");
			filters.put("inst_id", request.getInstId());

			if (request.getStatus() != null) {
				checkLength(request.getStatus(), 8, "state");
				filters.put("status", request.getStatus());
			}
			if (request.getBalanceType() != null) {
				checkLength(request.getBalanceType(), 8, "balance_type");
				filters.put("balance_type", request.getBalanceType());
			}
			if (StringUtils.isNotBlank(request.getLang())) {
				checkLang(request.getLang());
				filters.put("lang", request.getLang());
			} else {
				filters.put("lang", "LANGENG");
			}

			long userSessionId = initDao();
			ru.bpc.svxp.Account[] accounts = integDao.getAccounts(userSessionId, filters);
			Accounts acc = new Accounts();
			for (ru.bpc.svxp.Account account : accounts) {
				acc.getAccount().add(account);
			}
			return acc;
		} catch (Exception e) {
			throw handleException(e);
		}

	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getPostedTransactions")
	@WebResult(name = "getPostedTransactionsResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public Transactions getPostedTransactions(
			@WebParam(name = "getPostedTransactionsRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetPostedTransactionsRequest request)
			throws Fault_Exception {
		try {
			String accountNumber = request.getAccountNumber();
			String objectId = request.getObjectId();
			if ((accountNumber == null || accountNumber.isEmpty()) && (objectId == null || objectId.isEmpty())) {
				Fault fault = new Fault();
				fault.setCode("MANDATORY_PARAMETER_ABSENT");
				fault.setDescription("Mandatory parameter Account number is absent");
				throw new Fault_Exception("ERROR", fault);
			}
			Transactions resp = new Transactions();
			long userSessionId = initDao();
			List<Filter> filters = new ArrayList<Filter>();
			if (accountNumber != null && !accountNumber.isEmpty()) {
				filters.add(new Filter("accountNumber", accountNumber));
			}
			if (objectId != null && !objectId.isEmpty()) {
				filters.add(new Filter("objectId", objectId));
			}
			filters.add(new Filter("status", "ENTRPOST"));
			if (request.getDateFrom() != null) {
				filters.add(new Filter("postingDateFrom", request.getDateFrom().toGregorianCalendar().getTime()));
			}
			if (request.getDateTo() != null) {
				filters.add(new Filter("postingDateTo", request.getDateTo().toGregorianCalendar().getTime()));
			}
			SelectionParams params = new SelectionParams(filters);
			Transaction[] transactions = integDao.getTransactions(userSessionId, params);
			GregorianCalendar cal;
			for (Transaction tran : transactions) {
				ru.bpc.svxp.Transaction transactionSVXP = new ru.bpc.svxp.Transaction();
				transactionSVXP.setTransactionId(tran.getTransactionId());
				transactionSVXP.setAmount(tran.getAmount());
				transactionSVXP.setAmountPurpose(tran.getAmountPurpose());
				transactionSVXP.setAmountPurposeDescription(DictCache.getInstance().getAllArticlesDescByLang().get("LANGENG").get(tran.getAmountPurpose()));
				transactionSVXP.setAvalBal(tran.getAvalBal());
				transactionSVXP.setCurrency(tran.getCurrency());
				transactionSVXP.setOperType(tran.getOperationType());
				transactionSVXP.setOperTypeDescription(DictCache.getInstance().getAllArticlesDescByLang().get("LANGENG").get(tran.getOperationType()));
				transactionSVXP.setTransactionType(tran.getTransactionType());
				transactionSVXP.setTransactionTypeDescription(DictCache.getInstance().getAllArticlesDescByLang().get("LANGENG").get(tran.getTransactionType()));
				cal = new GregorianCalendar();
				cal.setTime(tran.getOperationDate());
				transactionSVXP.setOperDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
				cal = new GregorianCalendar();
				cal.setTime(tran.getPostingDate());
				transactionSVXP.setPostingDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
				transactionSVXP.setMerchantCity(tran.getMerchantCity());
				transactionSVXP.setMerchantCountry(tran.getMerchantCountry());
				transactionSVXP.setMerchantName(tran.getMerchantName());
				transactionSVXP.setMerchantStreet(tran.getMerchantStreet());
				transactionSVXP.setMerchantNumber(tran.getMerchantNumber());
				transactionSVXP.setObjectId(tran.getObjectId());
				transactionSVXP.setOriginalId(tran.getOriginalId());
				resp.getTransaction().add(transactionSVXP);
			}
			return resp;
		} catch (Exception e) {
			Fault fault = new Fault();
			String message = e.getMessage();
			if (message != null && message.startsWith("ORA-")) {
				message = message.replaceFirst("ORA-\\d+: ", "");
				message = message.split("ORA-\\d+:")[0];
			}
			fault.setCode("UNKNOWN");
			fault.setDescription(message);
			throw new Fault_Exception("ERROR", fault);
		}
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getCreditStatement")
	@WebResult(name = "getCreditStatementResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public GetCreditStatementResponse getCreditStatement(
			@WebParam(name = "getCreditStatementRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetCreditStatementRequest request)
			throws Fault_Exception {
		try {
			long userSessionId = initDao();
			Map<String, Object> params = new HashMap<String, Object>();
			checkLength(request.getAccountNumber(), 32, "account number");
			checkLength(String.valueOf(request.getInstId()), 4, "Inst id");
			params.put("account_number", request.getAccountNumber());
			params.put("inst_id", request.getInstId());
			if (StringUtils.isNotBlank(request.getLang())) {
				checkLang(request.getLang());
				params.put("lang", request.getLang());
			} else {
				params.put("lang", "LANGENG");
			}
			Statement st = integDao.getStatement(userSessionId, params);
			GetCreditStatementResponse resp = new GetCreditStatementResponse();
			resp.setReport(st);
			return resp;
		} catch (Exception e) {
			throw handleException(e);
		}
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getCardholderExt")
	@WebResult(name = "getCardholderExtResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public CardholderExt getCardholderExt(@WebParam(name = "getCardholderExtRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") CardholderExtRequest request) throws Fault_Exception {
		try {
			Map<String, Object> map = new HashMap<String, Object>();

			if (request.getCardholderId() != null) {
				checkLength(request.getCardholderId().toString(), 200, "cardholder_id");
				map.put("cardholder_id", request.getCardholderId());
			}
			if (request.getCardholderNumber() != null) {
				checkLength(request.getCardholderNumber(), 200, "cardholder_number");
				map.put("cardholder_number", request.getCardholderNumber());
			}
			if (request.getInstId() != null) {
				checkLength(request.getInstId().toString(), 4, "inst_id");
				map.put("inst_id", request.getInstId());
			}

			if (request.getLang() != null) {
				checkLang(request.getLang());
				map.put("lang", request.getLang());
			} else {
				map.put("lang", "LANGENG");
			}

			Long userSessionId = initDao();
			CardholderExt result = integDao.getCardholderExt(userSessionId, map);
			return result;
		} catch(Exception e) {
			throw handleException(e);
		}
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getAddresses")
	@WebResult(name = "getAddressesResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public Addresses getAddresses(
			@WebParam(name = "getAddressesRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetAddressesRequest request)
			throws Fault_Exception {
		Map<String, Object> filters = new HashMap<String, Object>();
		Addresses result = new Addresses();
		try {
			if (request.getCustomerId() != null) {
				checkLength(request.getCustomerId().toString(), 12,
						"customer_id");
				filters.put("customer_id", request.getCustomerId());
			}
			if (request.getCustomerNumber() != null) {
				checkLength(request.getCustomerNumber(), 200,
						"customer_number");
				filters.put("customer_number",
						request.getCustomerNumber());
			}

			checkLength(String.valueOf(request.getInstId()), 4, "inst_id");
			filters.put("inst_id", request.getInstId());

			if (StringUtils.isNotBlank(request.getLang())) {
				checkLang(request.getLang());
				filters.put("lang", request.getLang());
			} else {
				filters.put("lang", "LANGENG");
			}
			long userSessionId = initDao();

			Address[] addresses = integDao.getAddresses(userSessionId, filters);
			for (Address address : addresses) {
				result.getAddress().add(address);
			}
		} catch (Exception e) {
			throw handleException(e);
		}
		return result;
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getDocuments")
	@WebResult(name = "getDocumentsResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public CustomerDocuments getDocuments(
			@WebParam(name = "getDocumentsRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetDocumentsRequest request)
			throws Fault_Exception {
		CustomerDocuments result = new CustomerDocuments();
		Map<String, Object> filters = new HashMap<String, Object>();
		try {
			if (request.getCustomerId() != null) {
				checkLength(request.getCustomerId().toString(),
						12, "customer_id");
				filters.put("customer_id", request.getCustomerId());
			}
			if (request.getCustomerNumber() != null) {
				checkLength(request.getCustomerNumber(), 200,
						"customer_number");
				filters.put("customer_number", request.getCustomerNumber());
			}

			checkLength(String.valueOf(request.getInstId()), 4, "inst_id");
			filters.put("inst_id", request.getInstId());

			if (StringUtils.isNotBlank(request.getLang())) {
				checkLang(request.getLang());
				filters.put("lang", request.getLang());
			} else {
				filters.put("lang", "LANGENG");
			}
			filters.put("get_only_actual", request.isGetOnlyActual());
			long userSessionId = initDao();

			CustomerDocument[] documents = integDao.getCustomerDocuments(userSessionId, filters);
			for (CustomerDocument doc : documents) {
				result.getCustomerDocument().add(doc);
			}
		} catch (Exception e) {
			throw handleException(e);
		}
		return result;
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getContacts")
	@WebResult(name = "getContactsResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public Contacts getContacts(
			@WebParam(name = "getContactsRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetContactsRequest request)
			throws Fault_Exception {
		Contacts result = new Contacts();
		try {
			Map<String, Object> filters = new HashMap<String, Object>();
			if (request.getCustomerId() != null) {
				checkLength(request.getCustomerId().toString(),
						12, "customer_id");
				filters.put("customer_id", request.getCustomerId());
			}
			if (request.getCustomerNumber() != null) {
				checkLength(request.getCustomerNumber(), 200,
						"customer_number");
				filters.put("customer_number", request.getCustomerNumber());
			}

			checkLength(String.valueOf(request.getInstId()), 4, "inst_id");
			filters.put("inst_id", request.getInstId());

			if (StringUtils.isNotBlank(request.getLang())) {
				checkLang(request.getLang());
				filters.put("lang", request.getLang());
			} else {
				filters.put("lang", "LANGENG");
			}

			filters.put("get_only_actual", request.isGetOnlyActual());
			long userSessionId = initDao();

			Contact[] contacts = integDao.getContacts(userSessionId, filters);
			for (Contact contact : contacts) {
				result.getContact().add(contact);
			}
		} catch (Exception e) {
			throw handleException(e);
		}
		return result;
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getFlexFields")
	@WebResult(name = "getFlexFieldsResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public FlexFields getFlexFields(
			@WebParam(name = "getFlexFieldsRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetFlexFieldsRequest request)
			throws Fault_Exception {
		FlexFields result = new FlexFields();
		try {
			Map<String, Object> params = new HashMap<String, Object>();
			params.put("entity_type", request.getEntityType());
			params.put("object_id", request.getObjectId());
			if (StringUtils.isNotBlank(request.getLang())) {
				checkLang(request.getLang());
				params.put("lang", request.getLang());
			}
			long userSessionId = initDao();
			FlexField[] flexFields = integDao.getFlexField(userSessionId, params);
			for (FlexField flexField : flexFields) {
				result.getFlexFiled().add(flexField);
			}
		} catch (Exception e) {
			throw handleException(e);
		}
		return result;
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getAccountPaymentDetails")
	@WebResult(name = "getAccountPaymentDetailsResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public AccountPaymentDetails getAccountPaymentDetails(
			@WebParam(name = "getAccountPaymentDetailsRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetAccountPaymentDetailsRequest request)
			throws Fault_Exception {
		AccountPaymentDetails result;
		Map<String, Object> filters = new HashMap<String, Object>();
		try {
			if (request.getId() != null) {
				checkLength(request.getId().toString(), 12, "id");
				filters.put("id", request.getId());
			} else {
				if ((request.getAccountNumber() != null)) {
					checkLength(request.getAccountNumber(), 32,
							"account_number");
					filters.put("accountNumber", request.getAccountNumber());
				}
			}

			checkLength(String.valueOf(request.getInstId()), 4, "inst_id");
			filters.put("inst_id", request.getInstId());

			if (StringUtils.isNotBlank(request.getLang())) {
				checkLang(request.getLang());
				filters.put("lang", request.getLang());
			} else {
				filters.put("lang", "LANGENG");
			}


			long userSessionId = initDao();

			result = integDao.getAccountPaymentDetails(userSessionId, filters);
		} catch (Exception e) {
			throw handleException(e);
		}
		return result;
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getRateForInst")
	@WebResult(name = "getRateForInstResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public Rate getRateForInst(
			@WebParam(name = "getRateForInstRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetRateForInstRequest request)
			throws Fault_Exception {
		BigDecimal result;
		Rate res;
		try {

			Map<String, Object> filters = new HashMap<String, Object>();
			if (request.getDstCurrency() != null) {
				checkLength(request.getDstCurrency(), 3, "dst_currency");
				filters.put("dst_currency", request.getDstCurrency());
			}
			if (request.getEffDate() != null) {
				try {
					filters.put("eff_date", request.getEffDate()
							.toGregorianCalendar().getTime());
				} catch (Exception e) {
					Fault fault = new Fault();
					fault.setCode("UNKNOWN");
					fault.setDescription(e.getMessage());
					throw new Fault_Exception("ERROR", fault);
				}
			}

			checkLength(String.valueOf(request.getInstId()), 4, "inst_id");
			filters.put("inst_id", request.getInstId());

			if (request.getRateType() != null) {
				checkLength(request.getRateType(), 8, "rate_type");
				filters.put("rate_type", request.getRateType());
			}
			if (request.getSrcCurrency() != null) {
				checkLength(request.getSrcCurrency(), 3, "src_currency");
				filters.put("src_currency", request.getSrcCurrency());
			}
			Long userSessionId = initDao();
			res = new Rate();
			result = integDao.getRateForInst(userSessionId, filters);
			res.setRate(result);
		} catch (Exception e) {
			throw handleException(e);
		}
		return res;
	}


	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getCardDetails")
	@WebResult(name = "getCardDetailsResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public CardDetails getCardDetails(
			@WebParam(name = "getCardDetailsRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetCardDetailsRequest request)
			throws Fault_Exception {
		Map<String, Object> filters = new HashMap<String, Object>();
		CardDetails cd;
		try {
			if (request.getCardId() != null) {
				checkLength(request.getCardId(), 200, "card_id");
				filters.put("card_id", request.getCardId());
			}
			if (request.getCardNumber() != null) {
				checkLength(request.getCardNumber(), 12, 24, "card_number");
				filters.put("card_number", Filter.mask(request.getCardNumber()));
			}
			if (request.getExpirDate() != null) {
				filters.put("expir_date", request.getExpirDate().toGregorianCalendar().getTime());
			}
			if (request.getInstanceId() != null) {
				checkLength(request.getInstanceId().toString(), 12, "instance_id");
				filters.put("instance_id", request.getInstanceId());
			}
			if (request.getSeqNumber() != null) {
				checkLength(request.getSeqNumber(), 4, "seq_number");
				filters.put("seq_number", request.getSeqNumber());
			}
			if (request.getCardTypeId() != null) {
				checkLength(request.getCardTypeId().toString(), 4, "card_type_id");
				filters.put("card_type_id", request.getCardTypeId());
			}
			if (request.getInstId() != null) {
				checkLength(request.getInstId().toString(), 4, 4, "inst_id");
				filters.put("inst_id", request.getInstId());
			}
			if (StringUtils.isNotBlank(request.getLang())) {
				checkLang(request.getLang());
				filters.put("lang", request.getLang());
			} else {
				filters.put("lang", "LANGENG");
			}

			Long userSessionId = initDao();
			cd = integDao.getCardDetails(userSessionId, filters);
		} catch (Exception e) {
			throw handleException(e);
		}
		return cd;
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getCustomerDetails")
	@WebResult(name = "getCustomerDetailsResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public CustomerDetails getCustomerDetails(
			@WebParam(name = "getCustomerDetailsRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetCustomerDetailsRequest request)
			throws Fault_Exception {
		CustomerDetails customerDetails;
		Map<String, Object> filters = new HashMap<String, Object>();
		try {
			if (request.getCustomerId() != null) {
				checkLength(request.getCustomerId().toString(), 12,
						"customer_id");
				filters.put("customer_id", request.getCustomerId());
			}
			if (request.getCustomerNumber() != null) {
				checkLength(request.getCustomerNumber(), 200,
						"customer_number");
				filters.put("customer_number", request.getCustomerNumber());
			}

			checkLength(String.valueOf(request.getInstId()), 4, "inst_id");
			filters.put("inst_id", request.getInstId());

			if (StringUtils.isNotBlank(request.getLang())) {
				checkLang(request.getLang());
				filters.put("lang", request.getLang());
			} else {
				filters.put("lang", "LANGENG");
			}
			Long userSessionId = initDao();
			customerDetails = integDao.getCustomerDetails(userSessionId, filters);
		} catch (Exception e) {
			throw handleException(e);
		}
		return customerDetails;
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getCustomerNtfSettings")
	@WebResult(name = "getCustomerNtfSettingsResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public CustomerNtfsSettings getCustomerNtfSettings(
			@WebParam(name = "getCustomerNtfSettingsRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetCustomerNtfSettingsRequest request)
			throws Fault_Exception {
		CustomerNtfsSettings ntfs = new CustomerNtfsSettings();
		Map<String, Object> filters = new HashMap<String, Object>();
		try {
			if (request.getAccountId() != null) {
				checkLength(request.getAccountId().toString(), 12, "account_id");
				filters.put("account_id", request.getAccountId());
			}
			if (request.getAccountNumber() != null) {
				checkLength(request.getAccountNumber(), 32, "account_number");
				filters.put("account_number", request.getAccountNumber());
			}
			if (request.getCardId() != null) {
				checkLength(request.getCardId(), 200, "card_id");
				filters.put("card_id", request.getCardId());
			}
			if (request.getCardNumber() != null) {
				checkLength(request.getCardNumber(), 24, "card_number");
				filters.put("card_number", request.getCardNumber());
			}
			if (request.getCustomerId() != null) {
				checkLength(request.getCustomerId().toString(), 12, "customer_id");
				filters.put("customer_id", request.getCustomerId());
			}
			if (request.getCustomerNumber() != null) {
				checkLength(request.getCustomerNumber(), 200, "customer_number");
				filters.put("customer_number", request.getCustomerNumber());
			}
			if (StringUtils.isNotBlank(request.getLang())) {
				checkLang(request.getLang());
				filters.put("lang", request.getLang());
			} else {
				filters.put("lang", "LANGENG");
			}

			checkLength(String.valueOf(request.getInstId()), 4, "inst_id");
			filters.put("inst_id", request.getInstId());
			Long userSessionId = initDao();
			CustomerNtfSettings[] ntf = integDao.getCustomerNtfSettings(userSessionId, filters);
			for (CustomerNtfSettings e : ntf) {
				ntfs.getCustomerNtfSettings().add(e);
			}
		} catch (Exception e) {
			throw handleException(e);
		}
		return ntfs;
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getObjectLimits")
	@WebResult(name = "getObjectLimitsResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public ObjectsLimits getObjectLimits(
			@WebParam(name = "getObjectLimitsRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetObjectLimitsRequest request)
			throws Fault_Exception {
		ObjectsLimits result;
		Map<String, Object> filters = new HashMap<String, Object>();
		try {
			if (request.getAccountId() != null) {
				checkLength(request.getAccountId().toString(), 12, "account_id");
				filters.put("account_id", request.getAccountId());
			}
			if (request.getAccountNumber() != null) {
				checkLength(request.getAccountNumber(), 32, "account_number");
				filters.put("account_number", request.getAccountNumber());
			}
			if (request.getCustomerId() != null) {
				checkLength(request.getCustomerId().toString(), 12, "customer_id");
				filters.put("customer_id", request.getCustomerId());
			}
			if (request.getCustomerNumber() != null) {
				checkLength(request.getCustomerNumber(), 200, "customer_number");
				filters.put("customer_number", request.getCustomerNumber());
			}
			if (request.getCardId() != null) {
				checkLength(request.getCardId(), 200, "card_id");
				filters.put("card_id", request.getCardId());
			}
			if (request.getCardNumber() != null) {
				checkLength(request.getCardNumber(), 24, "card_number");
				filters.put("card_number", request.getCardNumber());
			}
			if (StringUtils.isNotBlank(request.getLang())) {
				checkLang(request.getLang());
				filters.put("lang", request.getLang());
			} else {
				filters.put("lang", "LANGENG");
			}
			if (request.getInstId() != null) {
				checkLength(request.getInstId().toString(), 4, "inst_id");
				filters.put("inst_id", request.getInstId());
			}

			initDao();
			result = integDao.getObjectLimits(filters);
		} catch (Exception e) {
			throw handleException(e);
		}
		return result;
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/setAuthScheme")
	public void setAuthScheme(
			@WebParam(name = "setAuthSchemeRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") SetAuthSchemeRequest request)
			throws Fault_Exception {
		Map<String, Object> filters = new HashMap<String, Object>();
		try {
			if (request.getAuthSchemeCode() != null) {
				checkLength(request.getAuthSchemeCode(), 200, "authSchemeCode");
				filters.put("authSchemeCode", request.getAuthSchemeCode());
			}
			if (request.getCardNumber() != null) {
				checkLength(request.getCardNumber(), 24, "cardNumber");
				filters.put("cardNumber", request.getCardNumber());
			}
			if (request.getCardId() != null) {
				checkLength(request.getCardId(), 200, "cardUid");
				filters.put("cardUid", request.getCardId());
			}
			if (request.getStartDate() != null) {
				filters.put("startDate", request.getStartDate().toGregorianCalendar().getTime());
			}
			if (request.getEndDate() != null) {
				filters.put("endDate", request.getEndDate().toGregorianCalendar().getTime());
			}
			initDao();
			integDao.setAuthScheme(filters);
		} catch (Exception e) {
			throw handleException(e);
		}

	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getCardAuthSchemes")
	@WebResult(name = "getCardAuthSchemesResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public CardAuthSchemes getCardAuthSchemes(
			@WebParam(name = "getCardAuthSchemesRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetCardAuthSchemesRequest request)
			throws Fault_Exception {
		Map<String, Object> filters = new HashMap<String, Object>();
		try {
			if (request.getCardNumber() != null) {
				checkLength(request.getCardNumber(), 12, 24, "card_number");
				filters.put("card_number", request.getCardNumber());
			}
			if (request.getCardId() != null) {
				checkLength(request.getCardId(), 200, "card_id");
				filters.put("card_id", request.getCardId());
			}
			if (request.isOnlyActive() != null) {
				filters.put("only_active", request.isOnlyActive());
			}
			if (StringUtils.isNotBlank(request.getLang())) {
				checkLang(request.getLang());
				filters.put("lang", request.getLang());
			} else {
				filters.put("lang", "LANGENG");
			}
			if (request.getInstId() != null) {
				checkLength(request.getInstId().toString(), 4, 4, "inst_id");
				filters.put("inst_id", request.getInstId());
			}

			initDao();
			return integDao.getCardAuthSchemes(filters);
		} catch (Exception e) {
			throw handleException(e);
		}

	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getCardholder")
	@WebResult(name = "getCardholderResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public Cardholder getCardholder(
			@WebParam(name = "getCardholderRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetCardholderRequest request)
			throws Fault_Exception {
		Cardholder cardholder;
		Map<String, Object> filters = new HashMap<String, Object>();
		try {
			if (request.getCardId() != null) {
				checkLength(request.getCardId(), 200, "card_id");
				filters.put("card_id", request.getCardId());
			}
			if (request.getCardNumber() != null) {
				checkLength(request.getCardNumber(), 12, 24, "card_number");
				filters.put("card_number", request.getCardNumber());
			}
			if (request.getInstId() != null) {
				checkLength(request.getInstId().toString(), 4, 4, "inst_id");
				filters.put("inst_id", request.getInstId());
			}
			if (StringUtils.isNotBlank(request.getLang())) {
				checkLang(request.getLang());
				filters.put("lang", request.getLang());
			} else {
				filters.put("lang", "LANGENG");
			}
			Long userSessionId = initDao();

			cardholder = integDao.getCardholder(userSessionId, filters);
		} catch (Exception e) {
			throw handleException(e);
		}
		return cardholder;
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getServiceProviders")
	@WebResult(name = "getServiceProvidersResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public ServiceProviders getServiceProviders(
			@WebParam(name = "getServiceProvidersRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetServiceProvidersRequest request)
			throws Fault_Exception {

		Map<String, Object> filters = new HashMap<String, Object>();
		try {
			if (StringUtils.isNotBlank(request.getLang())) {
				checkLang(request.getLang());
				filters.put("lang", request.getLang());
			}
			initDao();
			ServiceProviders result;

			result = integDao.getServiceProviders(filters);
			return result;
		} catch (Exception e) {
			throw handleException(e);
		}
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getUnbilledDebts")
	@WebResult(name = "getUnbilledDebtsResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public UnbilledDebtsResponse getUnbilledDebts(
			@WebParam(name = "getUnbilledDebtsRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") UnbilledDebtsRequest request)
			throws Fault_Exception {
		UnbilledDebtsResponse response = new UnbilledDebtsResponse();
		try {
			Map<String, Object> filters = new HashMap<String, Object>();

			if (request.getAccountId() != null) {
				filters.put("account_id", request.getAccountId());
			}
			if (StringUtils.isNotBlank(request.getAccountNumber())) {
				filters.put("account_number", request.getAccountNumber().trim());
			}
			if (request.getInstId() != null) {
				checkLength(request.getInstId().toString(), 4, 4, "inst_id");
				filters.put("inst_id", request.getInstId());
			}

			Long userSessionId = initDao();
			List<UnbilledDebt> debts = integDao.getUnbilledDebts(userSessionId, filters);
			if (debts != null && debts.size() > 0) {
				response.getDebt().addAll(debts);
			}
		} catch (Exception e) {
			throw handleException(e);
		}
		return response;
	}

	private void checkLang(String lang) throws UserException {
		if (StringUtils.isEmpty(lang) || StringUtils.isEmpty(lang.trim())) {
			throw new UserException("'lang' parameter is empty", "EMPTY_PARAMETER", null);
		}
		if (!Pattern.matches("LANG[A-Z0-9]{2,4}", lang)) {
			throw new UserException("'lang' parameter is invalid", "INVALID_PARAMETER", null);
		}
	}

	private void checkLength(String value, int minLength, int maxLength, String name) throws UserException {
		if (minLength > 0 || maxLength > 0) {
			checkNull(value, name);
		}
		if (minLength > 0) {
			if(value.trim().length() < minLength) {
				throw new UserException(name + " length is too small", "PARAMETER_TOO_SMALL", null);
			}
		}
		if (maxLength > 0) {
			if (value.length() > maxLength) {
				throw new UserException(name + " length is too large", "PARAMETER_TOO_LARGE", null);
			}
		}
	}

	private void checkLength(String value, int maxLength, String name) throws UserException {
		checkLength(value, -1, maxLength, name);
	}

	private void checkNull(Object object, String name) throws UserException {
		if (object == null) {
			throw new UserException(name + " parameter is required", "PARAMETER_IS_REQUIRED", null);
		}
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getObjectCycles")
	@WebResult(name = "getObjectCyclesResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public ObjectCycles getObjectCycles(
			@WebParam(name = "getObjectCyclesRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetObjectCyclesRequest request)
			throws Fault_Exception {

		Map<String, Object> filters = new HashMap<String, Object>();
		try {
			checkNull(request.getEntityType(), "entity_type");
			checkLength(request.getEntityType(), 8, "entity_type");
			filters.put("entity_type", request.getEntityType());

			checkNull(request.getObjectId(), "object_id");
			checkLength(request.getObjectId().toString(), 16, "object_id");
			filters.put("object_id", request.getObjectId());

			initDao();

			ObjectCycles result;

			result = integDao.getObjectCycles(filters);
			return result;
		} catch (Exception e) {
			throw handleException(e);
		}
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getAccountDetails")
	@WebResult(name = "getAccountDetailsResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public AccountDetails getAccountDetails(
			@WebParam(name = "getAccountDetailsRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetAccountDetailsRequest request)
			throws Fault_Exception {
		Map<String, Object> filters = new HashMap<String, Object>();
		try {
			if (request.getAccountNumber() != null) {
				checkLength(request.getAccountNumber(), 32, "account_number");
				filters.put("account_number", request.getAccountNumber());
			}

			if (request.getAccountId() != null) {
				checkLength(request.getAccountId().toString(), 12, "account_id");
				filters.put("account_id", request.getAccountId());
			}

			if (request.getInstId() != null) {
				checkLength(request.getInstId().toString(), 4, "inst_id");
				filters.put("inst_id", request.getInstId());
			}

			initDao();

			AccountDetails result;

			result = integDao.getAccountDetails(filters);
			return result;
		} catch (Exception e) {
			throw handleException(e);
		}
	}


	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getAccountBalances")
	@WebResult(name = "getAccountBalancesResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public AccountBalances getAccountBalances(
			@WebParam(name = "getAccountBalancesRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetAccountBalancesRequest request)
			throws Fault_Exception {
		Map<String, Object> filters = new HashMap<String, Object>();
		try {
			if (request.getAccountNumber() != null) {
				if (request.getAccountId() == null)
					checkNull(request.getInstId(), "inst_id");
				checkLength(request.getAccountNumber(), 32, "account_number");
				filters.put("account_number", request.getAccountNumber());
			}

			if (request.getAccountId() != null) {
				checkLength(request.getAccountId().toString(), 12, "account_id");
				filters.put("account_id", request.getAccountId());
			}

			if (request.getInstId() != null) {
				checkLength(request.getInstId().toString(), 4, "inst_id");
				filters.put("inst_id", request.getInstId());
			}

			initDao();

			AccountBalances result;

			result = integDao.getAccountBalances(filters);
			return result;
		} catch (Exception e) {
			throw handleException(e);
		}
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getCardFeatures")
	@WebResult(name = "getCardFeaturesResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public CardFeatures getCardFeatures(
			@WebParam(name = "getCardFeaturesRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetCardFeaturesRequest request)
			throws Fault_Exception {
		Map<String, Object> filters = new HashMap<String, Object>();
		try {
			if (request.getCardNumber() != null) {
				checkLength(request.getCardNumber(), 12, 24, "card_number");
				filters.put("card_number", request.getCardNumber());
			}
			if (request.getCardId() != null) {
				checkLength(request.getCardId(), 200, "card_id");
				filters.put("card_id", request.getCardId());
			}
			if (request.getInstId() != null) {
				checkLength(request.getInstId().toString(), 4, 4, "inst_id");
				filters.put("inst_id", request.getInstId());
			}

			initDao();
			CardFeatures result;
			result = integDao.getCardFeatures(filters);
			return result;
		} catch (Exception e) {
			throw handleException(e);
		}
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getCardFeatures")
	@WebResult(name = "getCreditAccountResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public CreditAccount getCreditAccount(
			@WebParam(name = "getCreditAccountRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetCreditAccountRequest request)
			throws Fault_Exception {
		Map<String, Object> filters = new HashMap<String, Object>();
		try {
			if (request.getAccountId() != null) {
				filters.put("accountId", request.getAccountId());
			}
			if (request.getAccountNumber() != null) {
				filters.put("accountNumber", request.getAccountNumber());
			}
			if (request.getInstId() != null) {
				filters.put("instId", request.getInstId());
			}
			if (request.getEffDate() != null) {
				filters.put("effDate", request.getEffDate().toGregorianCalendar().getTime());
			}
			if (StringUtils.isNotBlank(request.getLang())) {
				checkLang(request.getLang());
				filters.put("lang", request.getLang());
			}
			initDao();
			return integDao.getCreditAccount(filters);
		} catch (Exception e) {
			throw handleException(e);
		}
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getCustomerByPersonData")
	@WebResult(name = "getCustomerByPersonDataResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "parameters")
	public CustomerByPersonData getCustomerByPersonData(
			@WebParam(name = "getCustomerByPersonDataRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "parameters") GetCustomerByPersonDataRequest request)
			throws Fault_Exception {
		Map<String, Object> filter = new HashMap<String, Object>();
		CustomerByPersonData result = new CustomerByPersonData();
		try {
			if (request.getCommunAddress() != null) {
				filter.put("commun_address", request.getCommunAddress());
			}
			if (request.getCommunMethod() != null) {
				filter.put("commun_method", request.getCommunMethod());
			}
			if (request.getIdNumber() != null) {
				filter.put("id_number", request.getIdNumber());
			}
			if (request.getIdSeries() != null) {
				filter.put("id_series", request.getIdSeries());
			}
			if (request.getIdType() != null) {
				filter.put("id_type", request.getIdType());
			}
			if ("UNLIMITED".equals(request.getMaxCount())) {
				filter.put("max_count", null);
			} else if (request.getMaxCount() != null && !StringUtils.isNumeric(request.getMaxCount())){
				throw new UserException("Incorrect value for max_count");
			} else {
				filter.put("max_count", request.getMaxCount() != null ? Long.valueOf(request.getMaxCount()) : 1);
			}
			filter.put("inst_id", request.getInstId());
			initDao();
			result.getId().addAll(integDao.getCustomerByPersonData(filter));
		} catch (Exception e) {
			throw handleException(e);
		}
		return result;
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getCardByPhone")
	@WebResult(name = "getCardByPhoneResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "parameters")
	public CardNumberByPhone getCardByPhone(
			@WebParam(name = "getCardByPhoneRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "parameters") GetCardByPhoneRequest request)
			throws Fault_Exception {
		CardNumberByPhone result = new CardNumberByPhone();
		Map<String, Object> filter = new HashMap<String, Object>();
		try {
			if (StringUtils.isNotBlank(request.getCardMask())) {
				checkLength(request.getCardMask(), 28, "card_mask");
				filter.put("card_mask", Filter.mask(request.getCardMask()));
			}
			if (request.getCommunAddress() != null) {
				filter.put("commun_address", request.getCommunAddress());
			}
			if (request.getInstId() != null) {
				checkLength(request.getInstId().toString(), 4, 4, "inst_id");
				filter.put("inst_id", request.getInstId());
			}

			initDao();
			String value = integDao.getCardNumberByPhone(filter);
			if (filter.containsKey("mask") && filter.get("mask") != null) {
				result.setCardMask(value);
			} else {
				result.setCardNumber(value);
			}
		} catch (Exception e) {
			throw handleException(e);
		}
		return result;
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getContractList")
	@WebResult(name = "getContractListResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "parameters")
	public ContractListResponse getContractList(
			@WebParam(name = "getContractListRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "parameters") ContractListRequest request)
			throws Fault_Exception {
		ContractListResponse result = new ContractListResponse();
		try {
			Map<String, Object> filter = new HashMap<String, Object>();
			if (request.getCustomerNumber() != null) {
				filter.put("customer_number", request.getCustomerNumber());
			} else {
				throw new UserException("Customer number is not defined in the request");
			}
			if (request.getInstId() != 0) {
				filter.put("inst_id", request.getInstId());
			} else {
				throw new UserException("Institution is not defined in the request");
			}
			if (request.getCustomerId() != null) {
				filter.put("customer_id", request.getCustomerId());
			}
			if (request.getCardId() != null) {
				checkLength(request.getCardId(), 200, "card_id");
				filter.put("card_id", request.getCardId());
			}
			if (request.getCardNumber() != null) {
				filter.put("card_number", request.getCardNumber());
			}
			if (request.getAccountId() != null) {
				filter.put("account_id", request.getAccountId());
			}
			if (request.getAccountNumber() != null) {
				filter.put("account_number", request.getAccountNumber());
			}
			if (request.getSeqNumber() != null) {
				filter.put("seq_number", request.getSeqNumber());
			}
			if (request.getExpiryDate() != null) {
				filter.put("expir_date", request.getExpiryDate().toGregorianCalendar().getTime());
			}
			if (request.getInstanceId() != null) {
				filter.put("instance_id", request.getInstanceId());
			}
			initDao();
			result.getContract().addAll(integDao.getContractList(filter));
		} catch (Exception e) {
			throw handleException(e);
		}
		return result;
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getRemoteBankingActivity")
	@WebResult(name = "getRemoteBankingActivityResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "parameters")
	public boolean getRemoteBankingActivity(RemoteBankingActivityRequest request) throws Fault_Exception {

		Map<String, Object> filters = new HashMap<String, Object>();
		try {
			if (request.getCustomerNumber() != null) {
				filters.put("customerNumber", request.getCustomerNumber());
			}

			filters.put("instId", request.getInstId());
			initDao();
			return integDao.getRemoteBankingActivity(filters);
		}catch (Exception e) {
			throw handleException(e);
		}
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getMerchantStat")
	@WebResult(name = "getMerchantStatResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "parameters")
	public MerchantStatResponse getMerchantStat(
		@WebParam(name = "getMerchantStatRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetMerchantStatRequest request
    ) throws Fault_Exception {
        MerchantStatResponse result = new MerchantStatResponse();
		Map<String, Object> filter = new HashMap<String, Object>();

		try {
			checkNull(request.getCustomerNumber(), "customerNumber");
			filter.put("customerNumber", request.getCustomerNumber());

            if (request.getStartDate() != null) {
				filter.put("startDate", request.getStartDate().toGregorianCalendar().getTime());
			}

			if (request.getEndDate() != null) {
				filter.put("endDate", request.getEndDate().toGregorianCalendar().getTime());
			}

			checkNull(request.getInstId(),"inst_id");
			if (request.getInstId() == 0) {
				throw new UserException("Institution ID cannot be 0 !");
			}

			filter.put("instId", request.getInstId());

			long userSessionId = initDao();

			return integDao.getMerchantStat(userSessionId, filter);
		}catch (Exception e) {
			throw handleException(e);
		}
	}

	@Override
	public RepaymentDebtOperationResponse repaymentDebtOperation(RepaymentDebtOperationRequest repaymentDebtOperationRequest) throws Fault_Exception {
		RepaymentDebtOperationResponse response = new RepaymentDebtOperationResponse();
		try {
			Map<String, Object> params = new HashMap<String, Object>();
			params.put("new_count", repaymentDebtOperationRequest.getNewCount());
			if (StringUtils.isNotBlank(repaymentDebtOperationRequest.getExternalAuthId())) {
				params.put("external_auth_id", repaymentDebtOperationRequest.getExternalAuthId());
			}
			if (StringUtils.isNotBlank(repaymentDebtOperationRequest.getPaymentAmount())) {
				params.put("payment_amount", new BigDecimal(repaymentDebtOperationRequest.getPaymentAmount()));
			}
			if (StringUtils.isNotBlank(repaymentDebtOperationRequest.getAccelerationType())) {
				params.put("acceleration_type", repaymentDebtOperationRequest.getAccelerationType());
			}
			if (repaymentDebtOperationRequest.getCheckMadAgingUnpaid() != null) {
				params.put("check_mad_aging_unpaid", repaymentDebtOperationRequest.getCheckMadAgingUnpaid());
			} else {
				params.put("check_mad_aging_unpaid", new Integer(1));
			}

			Long userSessionId = initDao();
			integDao.repaymentDebtOperation(userSessionId, params);
			response.setResponseCode(ResponseCode.OK);
			return response;
		} catch (Exception e) {
			logger.error("", e);
			response.setResponseCode(ResponseCode.ERROR);
			response.setError(e.getCause().getMessage());
			return response;
		}

	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getProducts")
	@WebResult(name = "getProductsResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public ProductsByInstAndCustomer getProducts(@WebParam(name = "getProductsRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetProductsRequest request)
			throws Fault_Exception {
		ProductsByInstAndCustomer response = new ProductsByInstAndCustomer();
		try {
			Map<String, Object> filter = new HashMap<String, Object>();
			filter.put("customerId", request.getCustomerId());
			filter.put("instId", request.getInstId());
			if (StringUtils.isNotBlank(request.getLang())) {
				checkLang(request.getLang());
				filter.put("lang", request.getLang());
			} else {
				filter.put("lang", "LANGENG");
			}

			response.setCustomerId(request.getCustomerId());
			response.setInstId((int) request.getInstId());

			Long userSessionId = initDao();
			List<Product> products = integDao.getProducts(userSessionId, filter);
			fillProductHierarchy(null, products, response.getProduct());
		} catch (Exception e) {
			throw handleException(e);
		}
		return response;
	}

	@Override
	public PaymentInformationResponse paymentInformation(PaymentInformationRequest paymentInformationRequest) throws Fault_Exception {
		Map<String, Object> params = new HashMap<String, Object>();
		try {
			if (StringUtils.isNotBlank(paymentInformationRequest.getShortCardMask()) && StringUtils.isNotBlank((paymentInformationRequest.getNumberId()))) {
				params.put("short_card_mask", paymentInformationRequest.getShortCardMask());
				params.put("id_type", paymentInformationRequest.getTypeId().value());
				params.put("id_series", paymentInformationRequest.getSeriesId());
				params.put("id_number", paymentInformationRequest.getNumberId());
				long userSessionId = initDao();
				return (integDao.getPaymentInformation(userSessionId, params));
			} else if (StringUtils.isNotBlank(paymentInformationRequest.getAccountNumber()) && paymentInformationRequest.getInstId() != null) {
				params.put("account_number", paymentInformationRequest.getAccountNumber());
				params.put("inst_id", paymentInformationRequest.getInstId());
				long userSessionId = initDao();
				return (integDao.getPaymentInformationAccount(userSessionId, params));
			}
			else {
				throw new Fault_Exception("Incorrect request parameters. Parameters must include short_card_mask, type_id, series_id, number_id or account_number, inst_id");
			}
		}
		catch (UserException e) {
			throw handleException(e);
		}
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getTransactions")
	@WebResult(name = "getTransactionsResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public TransactionsByInstAndCustomer getTransactions(@WebParam(name = "getTransactionsRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetTransactionsRequest request)
			throws Fault_Exception {
		TransactionsByInstAndCustomer response = new TransactionsByInstAndCustomer();
		try {
			Map<String, Object> filter = new HashMap<String, Object>();
			filter.put("customerId", request.getCustomerId());
			filter.put("instId", request.getInstId());
			if (StringUtils.isNotBlank(request.getLang())) {
				checkLang(request.getLang());
				filter.put("lang", request.getLang());
			} else {
				filter.put("lang", "LANGENG");
			}
			if (request.getCardTypeId() != null) {
				filter.put("cardTypeId", request.getCardTypeId());
			}
			if (StringUtils.isNotBlank(request.getAccountNumber())) {
				filter.put("accountNumber", request.getAccountNumber());
			}
			if (request.getTransactionDateFrom() != null) {
				SimpleDateFormat df = new SimpleDateFormat(DatePatterns.FULL_DATE_PATTERN);
				filter.put("transactionDateFrom", df.format(request.getTransactionDateFrom().toGregorianCalendar().getTime()));
			}
			if (request.getTransactionDateTo() != null) {
				SimpleDateFormat df = new SimpleDateFormat(DatePatterns.FULL_DATE_PATTERN);
				filter.put("transactionDateTo", df.format(request.getTransactionDateTo().toGregorianCalendar().getTime()));
			}
			if (StringUtils.isNotBlank(request.getMaskedPan())) {
				checkLength(request.getMaskedPan().trim(), 12, 28, "mask");
				filter.put("cardMask", Filter.mask(request.getMaskedPan()));
			}
			if (StringUtils.isNotBlank(request.getResponseCode())) {
				filter.put("respCode", request.getResponseCode());
			}
			if (StringUtils.isNotBlank(request.getTransactionType())) {
				filter.put("transType", request.getTransactionType());
			}
			if (request.getTransactionsSorting() != null && request.getTransactionsSorting().size() > 0) {
				List<SortElement> sorting = new ArrayList<SortElement>();
				for (Sorting sort : request.getTransactionsSorting()) {
					if (sort.getField() != null && StringUtils.isNotBlank(sort.getField().value())) {
						if (sort.getDirection() != null) {
							sorting.add(new SortElement(mapSortFields(sort.getField().value()), sort.getDirection().value()));
						} else {
							sorting.add(new SortElement(mapSortFields(sort.getField().value()), "ASC"));
						}
					}
				}
				filter.put("transactionsSorting", sorting);
			} else if (request.getTransactionDirectionSorting() != null) {
				filter.put("transactionDirectionSort", request.getTransactionDirectionSorting().value());
			}

			response.setCustomerId(request.getCustomerId());
			response.setInstId((int) request.getInstId());
			Long userSessionId = initDao();
			List<Operation> operations = integDao.getTransactions(userSessionId, filter);
			for (Operation operation : operations) {
				TransactionItem transaction = new TransactionItem();

				transaction.setAmount(operation.getOperAmount());
				transaction.setCurrency(operation.getOperCurrency());
				transaction.setTransactionType(operation.getOperationType());
				transaction.setIsReversal(operation.getIsReversal());
				transaction.setCardType(operation.getCardType());
				transaction.setMaskedPan(operation.getCardMask());
				transaction.setResponseCode(operation.getStatusReason());
				transaction.setTerminal(operation.getTerminalNumber());
				transaction.setAccountNumber(operation.getAccountNumber());
				transaction.setDebitCreditSign(operation.getDebitCreditSign());

				GregorianCalendar calendar = new GregorianCalendar();
				calendar.setTime(operation.getOperDate());
				transaction.setDateTime(DatatypeFactory.newInstance().newXMLGregorianCalendar(calendar));

				response.getTransaction().add(transaction);
			}
		} catch (Exception e) {
			throw handleException(e);
		}
		return response;
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getDppInstallments")
	@WebResult(name = "getDppInstallmentsResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public DppInstallmentsResponse getDppInstallments(@WebParam(name = "getDppInstallmentsRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") DppInstallmentsRequest request)
			throws Fault_Exception {
		DppInstallmentsResponse response = null;
		try {
			Map<String, Object> filter = new HashMap<String, Object>();
			if (request.getDppAmount() != null) {
				filter.put("dppAmount", request.getDppAmount());
			}
			if (request.getAccount() != null) {
				if (request.getAccount().getAccountId() != null) {
					filter.put("accountId", request.getAccount().getAccountId());
				}
				if (StringUtils.isNotBlank(request.getAccount().getAccountNumber())) {
					filter.put("accountNumber", request.getAccount().getAccountNumber());
				}
			}
			if (request.getFeeId() != null) {
				filter.put("feeId", request.getFeeId());
			}
			if (request.getInstallmentCount() != null) {
				filter.put("installmentCount", request.getInstallmentCount());
			}
			if (request.getInstallmentAmount() != null) {
				filter.put("installmentAmount", request.getInstallmentAmount());
			}
			if (request.getFirstInstallmentDate() != null) {
				filter.put("firstInstallmentDate", request.getFirstInstallmentDate().toGregorianCalendar().getTime());
			}
			if (StringUtils.isNotBlank(request.getCalcAlgorithm())) {
				filter.put("calcAlgorithm", request.getCalcAlgorithm());
			}
			if (request.getInstId() != null) {
				filter.put("instId", request.getInstId());
			}
			Long userSessionId = initDao();
			response = integDao.getDppInstallments(userSessionId, filter);
		} catch (Exception e) {
			throw handleException(e);
		}
		return response;
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getFinancialOverview")
	@WebResult(name = "getFinancialOverviewResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public FinOverview getFinancialOverview(@WebParam(name = "getFinancialOverviewRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetFinancialOverviewRequest request)
			throws Fault_Exception {
		FinOverview response = new FinOverview();
		try {
			Map<String, Object> filter = new HashMap<String, Object>();
			if (StringUtils.isNotBlank(request.getCardNumber())) {
				checkLength(request.getCardNumber(), 12, 24, "cardNumber");
				filter.put("cardNumber", Filter.mask(request.getCardNumber()));
			}
			if (StringUtils.isNotBlank(request.getAccountNumber())) {
				checkLength(request.getAccountNumber(), 200, "accountNumber");
				filter.put("accountNumber", request.getAccountNumber());
			}
			if (request.getInstId() != null) {
				checkLength(request.getInstId().toString(), 4, 4, "instId");
				filter.put("instId", request.getInstId());
			}

			Long userSessionId = initDao();
			response = integDao.getFinancialOverview(userSessionId, filter);
		} catch (Exception e) {
			throw handleException(e);
		}
		return response;
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getCreditCardPayments")
	@WebResult(name = "getCreditCardPaymentsResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public CreditCardPayments getCreditCardPayments(@WebParam(name = "getCreditCardPaymentsRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetCreditCardPaymentsRequest request)
			throws Fault_Exception {
		CreditCardPayments response = new CreditCardPayments();
		try {
			Map<String, Object> filter = new HashMap<String, Object>();
			if (StringUtils.isNotBlank(request.getCardNumber())) {
				checkLength(request.getCardNumber(), 12, 24, "cardNumber");
				filter.put("cardNumber", Filter.mask(request.getCardNumber()));
			} else {
				throw new UserException("cardNumber parameter is required", "PARAMETER_IS_REQUIRED", null);
			}
			if (StringUtils.isNotBlank(request.getAccountNumber())) {
				checkLength(request.getAccountNumber(), 200, "accountNumber");
				filter.put("accountNumber", request.getAccountNumber());
			}
			if (request.getInstId() != null) {
				checkLength(request.getInstId().toString(), 4, 4, "instId");
				filter.put("instId", request.getInstId());
			}
			Long userSessionId = initDao();
			response = integDao.getCreditCardPayments(userSessionId, filter);
		} catch (Exception e) {
			throw handleException(e);
		}
		return response;
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/integration/getCustomerInfoByCard")
	@WebResult(name = "getCustomerInfoByCardResponse", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "output")
	public CustomerInfoByCard getCustomerInfoByCard(@WebParam(name = "getCustomerInfoByCardRequest", targetNamespace = "http://bpc.ru/SVXP/integration", partName = "input") GetCustomerInfoByCardRequest request)
			throws Fault_Exception {
		CustomerInfoByCard response = new CustomerInfoByCard();
		try {
			Map<String, Object> filter = new HashMap<String, Object>();
			if (StringUtils.isNotBlank(request.getCardNumber())) {
				checkLength(request.getCardNumber(), 12, 24, "card_number");
				filter.put("card_number", Filter.mask(request.getCardNumber()));
			}
			if (StringUtils.isNotBlank(request.getLang())) {
				checkLang(request.getLang());
				filter.put("lang", request.getLang());
			}
			if (request.getInstId() != null) {
				checkLength(request.getInstId().toString(), 4, 4, "inst_id");
				filter.put("inst_id", request.getInstId());
			}

			Long userSessionId = initDao();
			response = integDao.getCustomerInfoByCard(userSessionId, filter);
		} catch (Exception e) {
			throw handleException(e);
		}
		return response;
	}

	private boolean isSuitableProduct(Long example, Long current) {
		if (current == null && example == null) {
			return true;
		} else if (current != null && current.equals(example)) {
			return true;
		}
		return false;
	}

	private void fillProductHierarchy(Long parentId, List<Product> source, List<ProductItem> dest) throws Exception {
		for (Product product : source) {
			if (isSuitableProduct(parentId, product.getParentId())) {
				ProductItem item = new ProductItem();
				item.setId(product.getId());
				item.setName(product.getName());
				item.setDescription(product.getDescription());
				fillProductHierarchy(product.getId(), source, item.getProduct());
				dest.add(item);
			}
		}
	}

	private String mapSortFields(String in) {
		if (in != null) {
			if ("ID".equalsIgnoreCase(in.trim())) {
				return "id";
			} else if ("OPERATION_TYPE".equalsIgnoreCase(in.trim())) {
				return "operationType";
			} else if ("OPERATION_DATE".equalsIgnoreCase(in.trim())) {
				return "operDate";
			} else if ("STATUS".equalsIgnoreCase(in.trim())) {
				return "status";
			} else if ("TERMINAL_NUMBER".equalsIgnoreCase(in.trim())) {
				return "terminalNumber";
			}
		}
		return in;
	}
}

