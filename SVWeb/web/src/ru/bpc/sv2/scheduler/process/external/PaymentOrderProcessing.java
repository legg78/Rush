package ru.bpc.sv2.scheduler.process.external;

import org.apache.log4j.Logger;
import ru.bpc.sv.recurauth.RecurAuth;
import ru.bpc.sv.recurauth.RecurAuth_Service;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.pmo.PaymentOrderConstants;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.PaymentOrdersDao;
import ru.bpc.sv2.pmo.PmoOrder;
import ru.bpc.sv2.pmo.PmoPaymentOrder;
import ru.bpc.sv2.scheduler.process.IbatisExternalProcess;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import javax.xml.ws.BindingProvider;
import javax.xml.ws.Holder;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

public class PaymentOrderProcessing extends IbatisExternalProcess{

	private static final Logger logger = Logger.getLogger("PROCESSES");
	private static Logger loggerDB = Logger.getLogger("PROCESSES_DB");
	
	private static final String ORDER_STATUS = "I_ORDER_STATUS";
	private static final String ATTEMPTS_NUMBERS = "I_ATTEMPTS_NUMBER";
	private static final String DECLINE_STATUS = "I_DECLINE_STATUS";
	private static final String GOOD_RESP = "RESP0001";
	
	private Map<String, Object> parameters;
	private String orderStatus;
	private int attemptsNumber;
	private String declineStatus;
	private PaymentOrdersDao paymentOrdersDao;
	private RecurAuth servicePort;
	private ExecutorService executor;
	private int executedOrders  = 0;
	private String fault_code;
	
	public PaymentOrderProcessing() {
		
	}
	
	int current = 0;
	int success = 0;
	int fail = 0;
		
	@Override
	public void execute() throws SystemException, UserException {
		this.executor = Executors.newFixedThreadPool(threadsNumber);
		initServicePort();
		initParams();
		initBean();		
		loggerDB.trace(new TraceLogInfo(processSession.getSessionId(), "Getting orders from DB."));
		PmoPaymentOrder[] orders;
		fault_code=ProcessConstants.PROCESS_FINISHED_WITH_ERRORS;
		try {
			getIbatisSession();
			startSession();
			startLogging();
			con.commit();
			orders = obtainOrders();
		} catch (Exception e) {
			throw new SystemException("Cannot obtain orders", e);
		}
		logEstimated(orders.length);
		loggerDB.trace(new TraceLogInfo(processSession.getSessionId(), "Orders count = " + orders.length));
		int i =0 ;
		if(orders.length == 0){
			return;
		}
		Future<Object>[] futures = new Future[orders.length-1];

		try {
			for (PmoPaymentOrder order : orders){
				futures[i] = executor.submit(new ProcessOrderTask(order));
				i++;
				if (i==3) {
//				break;
				}
			}
			boolean stop = false;
			Exception exc = null;
			int countErr = 0;
			for(int j = 0; j < orders.length-1; j++){
				if(stop && !futures[i].isDone()){
					futures[i].cancel(true);
					if(futures[i].isCancelled()){
						fault_code=ProcessConstants.PROCESS_FAILED;
						logger.debug("--process stoped--");
					}
					continue;
				}
				Object result = futures[j].get();
				if (result instanceof Exception) {
					if (process.isInterruptThreads()){
						stop = true;
					}
					exc = (Exception)result;
					countErr++;
					if(countErr>1){
						fault_code=ProcessConstants.PROCESS_FAILED;
					}	
				}
			}
			if (exc != null) throw (Exception)exc;
			processSession.setResultCode(ProcessConstants.PROCESS_FINISHED);
		} catch (Exception e) {
			try {
				if (con != null) {
					con.rollback();
				}
			} catch (SQLException e1) {
				logger.error("", e1);
			}
			processSession.setResultCode(fault_code);
			throw new UserException(e.getMessage());
		} finally {
			endLogging(success, fail);
			if (con != null) {
				try {
					con.commit();
					con.close();
				} catch (SQLException e) {
					logger.error("", e);
				}
			}

			if (ssn != null) {
				ssn.close();
			}
		}
	}
	
	private void initParams(){
		if (parameters == null) return;
		Object tmp;
		if ((tmp = parameters.get(ORDER_STATUS)) != null){
			orderStatus = (String)tmp;
		}
		if ((tmp = parameters.get(ATTEMPTS_NUMBERS)) != null){
			attemptsNumber = ((BigDecimal)tmp).intValue();
		}
		if ((tmp = parameters.get(DECLINE_STATUS)) != null){
			declineStatus = (String)tmp;
		}
	}

	private void initBean() throws SystemException{
		paymentOrdersDao = new PaymentOrdersDao();
	}
	
	private PmoPaymentOrder[] obtainOrders(){
		Filter[] filters = new Filter[]{new Filter("status", orderStatus)};
		PmoPaymentOrder[] orders = paymentOrdersDao.getPaymentOrdersSys(new SelectionParams(filters));
		return orders;
	}
	
	private void initServicePort() throws SystemException{
		RecurAuth_Service service = new RecurAuth_Service();
		servicePort = service.getRecurAuthSOAP();
		BindingProvider bp = (BindingProvider) servicePort;
		
		SettingsCache settingParamsCache = SettingsCache.getInstance();			
		String feLocation = settingParamsCache
				.getParameterStringValue(SettingsConstants.FRONT_END_LOCATION);
		if (feLocation == null || feLocation.trim().length() == 0) {
			throw new SystemException("FE location is not defined");			
		}
		
		BigDecimal port = settingParamsCache.getParameterNumberValue(SettingsConstants.RECURAUTH_WS_PORT);
		if (port == null) {
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "sys_param_empty",
					SettingsConstants.RECURAUTH_WS_PORT);
			throw new SystemException(msg);
		}
		
		feLocation = feLocation + ":" + port.intValue();
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);
		bp.getRequestContext().put("javax.xml.ws.client.connectionTimeout", SystemConstants.FE_TIMEOUT);
		bp.getRequestContext().put("javax.xml.ws.client.receiveTimeout", SystemConstants.FE_TIMEOUT);
	}
	
	private synchronized void logCurrent(boolean isSuccess) throws Exception {
		current++;
		if (isSuccess) {
			success++;
		} else {
			fail++;
		}
		logCurrent(current, fail);
		con.commit();
	}
	
	private class ProcessOrderTask implements Callable {
		private PmoPaymentOrder order;

		public ProcessOrderTask(PmoPaymentOrder order) {
			this.order = order;
		}
		
		@Override
		public Object call() {
			try {
				loggerDB.trace(new TraceLogInfo(processSession.getSessionId(), "Order "+ order.getId()+" - starting execution"));
				String respCode = processOrder(order);
				boolean processed = GOOD_RESP.equals(respCode);
				
				int attemtCount = order.getAttemptCount();
				attemtCount++;
				order.setAttemptCount(attemtCount);
				updateOrderAttemtsCount(order);
				
				if (processed){
					order.setStatus(PaymentOrderConstants.ORDER_STATUS_PROCESSED);
					updateOrderStatus(order);
					loggerDB.trace(new TraceLogInfo(processSession.getSessionId(), "Order "+ order.getId()+" has been processed."));
				} else {
					if (attemtCount >= attemptsNumber){
						order.setStatus(PaymentOrderConstants.ORDER_STATUS_CANCELED);
						updateOrderStatus(order);
						loggerDB.trace(new TraceLogInfo(processSession.getSessionId(), "Order "+ order.getId()+" has not been processed. Resp code = " + respCode + ". Attempts count exceeded. Order has been cancelled."));
						logger.trace(processSession.getSessionId() +": Order "+ order.getId()+" has not been processed. Resp code = " + respCode + ". Attempts count exceeded. Order has been cancelled.");
					} else {
						loggerDB.trace(new TraceLogInfo(processSession.getSessionId(), "Order "+ order.getId()+" has not been processed. Resp code = " + respCode + ". Incrementing attempts count."));
						logger.trace(processSession.getSessionId() +": Order "+ order.getId()+" has not been processed. Resp code = " + respCode + ". Incrementing attempts count.");
					}
				}
				incrementExecutedOrders();
				logCurrent(processed);
				return "OK";
			} catch (Throwable t) {
				loggerDB.error(new TraceLogInfo(processSession.getSessionId(), "Order "+ order.getId()+" - execution failed. " + t.getMessage()), t);
				logger.error(processSession.getSessionId() + ": Order "+ order.getId()+" - execution failed. " + t.getMessage(), t);
				try {
					logCurrent(false);
				} catch (Exception e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				return t;
			}
		}
		
		private String processOrder(PmoPaymentOrder order) throws SystemException{
			Holder<String> respCodeHolder = new Holder<String>();
			Holder<String> newAuthIdHolder = new Holder<String>();
						
			servicePort.createRecurAuthFromPmtOrder(order.getId().toString(), 
					"MSGTCMPL", 
					null, 
					null,
					null,
					respCodeHolder, 
					newAuthIdHolder);
			String respCode = respCodeHolder.value;
			
			return respCode;
		}
		
		private void updateOrderStatus(PmoPaymentOrder order){	
			PmoOrder pmoOrder = new PmoOrder();
			pmoOrder.setId(order.getId());
			pmoOrder.setStatus(order.getStatus());
			paymentOrdersDao.setOrderStatus(null, pmoOrder);
		}
		
		private void updateOrderAttemtsCount(PmoPaymentOrder order){
			PmoOrder pmoOrder = new PmoOrder();
			pmoOrder.setId(order.getId());
			pmoOrder.setAttemptCount(order.getAttemptCount());
			paymentOrdersDao.setOrderAttemptCount(null, pmoOrder);
		}
	}
	
	private synchronized void  incrementExecutedOrders() {
		executedOrders++;
	}

	@Override
	public void setParameters(Map<String, Object> parameters) {
		this.parameters = parameters;
	}	
	
}
