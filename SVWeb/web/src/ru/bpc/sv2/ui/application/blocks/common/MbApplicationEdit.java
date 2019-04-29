package ru.bpc.sv2.ui.application.blocks.common;

import java.math.BigDecimal;
import java.util.HashMap;

import java.util.List;
import java.util.Map;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;

import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.ui.utils.SimpleAppBlock;

@ViewScoped
@ManagedBean (name = "mbApplicationEdit")
public class MbApplicationEdit extends SimpleAppBlock {
	private static final Logger logger = Logger.getLogger("APPLICATIONS");

	private Long applicationId;
	private Integer instId;
	private Integer agentId;
	private Integer productId;
	private Integer flowId;
	private Integer fileRecNum;
	private String appType;
	private String appStatus;
	private String operatorId;
	private String rejectCode;
	private String customerType;
	private String contractType;
	
	private static final String APPLICATION_ID 			= "APPLICATION_ID";
	private static final String INSTITUTION_ID 			= "INSTITUTION_ID";
	private static final String AGENT_ID				= "AGENT_ID";
	private static final String PRODUCT_ID 				= "PRODUCT_ID";
	private static final String APPLICATION_FLOW_ID 	= "APPLICATION_FLOW_ID";
	private static final String FILE_REC_NUM 			= "FILE_REC_NUM";
	private static final String APPLICATION_REJECT_CODE = "APPLICATION_REJECT_CODE";
	private static final String OPERATOR_ID 			= "OPERATOR_ID";
	private static final String CUSTOMER_TYPE 			= "CUSTOMER_TYPE";
	private static final String CONTRACT_TYPE 			= "CONTRACT_TYPE";
	private static final String APPLICATION_TYPE 		= "APPLICATION_TYPE";
	private static final String APPLICATION_STATUS 		= "APPLICATION_STATUS";
	
	private Map<String, ApplicationElement> objectAttrs;
	
	public MbApplicationEdit() {				
	}

	@Override
	public void parseAppBlock() {
		//implement hardcode here
		objectAttrs = new HashMap<String, ApplicationElement>();
		try {
			for (ApplicationElement el : getLocalRootEl().getChildren()) {
				if (el.isComplex()) {
					continue;
				}
				
				if (el.getContent()) {
					//implement some logic if needed
				}
				String name = el.getName();
				if (name.equals(APPLICATION_ID)) {
					if (el.getValueN() == null) {
						applicationId = null;
					} else {
						applicationId = el.getValueN().longValue();
					}
					getObjectAttrs().put(APPLICATION_ID, el);					
				
				} else if (name.equals(APPLICATION_FLOW_ID)) {
					if (el.getValueN() == null) {
						flowId = null;
					} else {
						flowId = el.getValueN().intValue();
					}
					getObjectAttrs().put(APPLICATION_FLOW_ID, el);					
				
				} else if (name.equals(INSTITUTION_ID)) {
					if (el.getValueN() == null) {
						instId = null;
					} else {
						instId = el.getValueN().intValue();
					}
					getObjectAttrs().put(INSTITUTION_ID, el);					
				
				} else if (name.equals(AGENT_ID)) {
					if (el.getValueN() == null) {
						agentId = null;
					} else {
						agentId = el.getValueN().intValue();
					}
					getObjectAttrs().put(AGENT_ID, el);					
				
				} else if (name.equals(PRODUCT_ID)) {
					if (el.getValueN() == null) {
						productId = null;
					} else {
						productId = el.getValueN().intValue();
					}
					getObjectAttrs().put(PRODUCT_ID, el);					
				
				} else if (name.equals(FILE_REC_NUM)) {
					if (el.getValueN() == null) {
						fileRecNum = null;
					} else {
						fileRecNum = el.getValueN().intValue();
					}
					getObjectAttrs().put(FILE_REC_NUM, el);					
				
				} else if (name.equals(OPERATOR_ID)) {
					operatorId = el.getValueV();					
					getObjectAttrs().put(OPERATOR_ID, el);
					
				} else if (name.equals(APPLICATION_REJECT_CODE)) {
					rejectCode = el.getValueV();					
					getObjectAttrs().put(APPLICATION_REJECT_CODE, el);
					
				} else if (name.equals(CUSTOMER_TYPE)) {
					customerType = el.getValueV();					
					getObjectAttrs().put(CUSTOMER_TYPE, el);
					
				} else if (name.equals(CONTRACT_TYPE)) {
					contractType = el.getValueV();					
					getObjectAttrs().put(CONTRACT_TYPE, el);
					
				} else if (name.equals(APPLICATION_TYPE)) {
					appType = el.getValueV();					
					getObjectAttrs().put(APPLICATION_TYPE, el);
					
				} else if (name.equals(APPLICATION_STATUS)) {
					appStatus = el.getValueV();					
					getObjectAttrs().put(APPLICATION_STATUS, el);
					
				}
			}
		} catch (Exception e) {
			logger.error("", e);
		}
	}
	
	@Override
	public void formatObject(ApplicationElement root) {
		//implement hardcode here
		if (getSourceRootEl() == null) {
			return;
		}
		ApplicationElement el = null;
		el = root.getChildByName(APPLICATION_ID, 1);
		if (applicationId == null) {
			el.setValueN((BigDecimal)null);
		} else {
			el.setValueN(BigDecimal.valueOf(applicationId));
		}
		
		el = root.getChildByName(INSTITUTION_ID, 1);
		if (instId == null) {
			el.setValueN((BigDecimal)null);
		} else {
			el.setValueN(BigDecimal.valueOf(instId));
		}
		
		el = root.getChildByName(AGENT_ID, 1);
		if (agentId == null) {
			el.setValueN((BigDecimal)null);
		} else {
			el.setValueN(BigDecimal.valueOf(agentId));
		}
		
		el = root.getChildByName(PRODUCT_ID, 1);
		if (productId == null) {
			el.setValueN((BigDecimal)null);
		} else {
			el.setValueN(BigDecimal.valueOf(productId));
		}
		
		el = root.getChildByName(APPLICATION_FLOW_ID, 1);
		if (flowId == null) {
			el.setValueN((BigDecimal)null);
		} else {
			el.setValueN(BigDecimal.valueOf(flowId));
		}
		
		el = root.getChildByName(FILE_REC_NUM, 1);
		if (fileRecNum == null) {
			el.setValueN((BigDecimal)null);
		} else {
			el.setValueN(BigDecimal.valueOf(fileRecNum));
		}
		
		el = root.getChildByName(APPLICATION_REJECT_CODE, 1);
		el.setValueV(rejectCode);
		
		el = root.getChildByName(OPERATOR_ID, 1);
		el.setValueV(operatorId);
		
		el = root.getChildByName(CUSTOMER_TYPE, 1);
		el.setValueV(customerType);
		
		el = root.getChildByName(CONTRACT_TYPE, 1);
		el.setValueV(contractType);
		
		el = root.getChildByName(APPLICATION_TYPE, 1);
		el.setValueV(appType);
		
		el = root.getChildByName(APPLICATION_STATUS, 1);
		el.setValueV(appStatus);
		
	}
	
	@Override
	public Map<String, ApplicationElement> getObjectAttrs() {
		return objectAttrs;
	}
	
	@Override
	public void clear() {
		super.clear();		
	}
	
	@Override
	protected Logger getLogger() {
		return logger;
	}
	
	public List<SelectItem> getProducts() {
		return getLov(getObjectAttrs().get("PRODUCT_ID"));
	}
	
	public List<SelectItem> getInstitutions() {
		return getLov(getObjectAttrs().get("INSTITUTION_ID"));
	}
	
	public List<SelectItem> getAgents() {
		return getLov(getObjectAttrs().get("AGENT_ID"));
	}
	
	public List<SelectItem> getRejectCodes() {
		return getLov(getObjectAttrs().get("APPLICATION_REJECT_CODE"));
	}
	
	public List<SelectItem> getApplicationStatuses() {
		return getLov(getObjectAttrs().get("APPLICATION_STATUS"));
	}
		
	public List<SelectItem> getApplicationTypes() {
		return getLov(getObjectAttrs().get("APPLICATION_TYPE"));
	}
	
	public List<SelectItem> getCustomerTypes() {
		return getLov(getObjectAttrs().get("CUSTOMER_TYPE"));
	}
	
	public List<SelectItem> getContractTypes() {
		return getLov(getObjectAttrs().get("CONTRACT_TYPE"));
	}
	
	public List<SelectItem> getApplicationFlows() {
		return getLov(getObjectAttrs().get("APPLICATION_FLOW_ID"));
	}

	public Long getApplicationId() {
		return applicationId;
	}

	public void setApplicationId(Long applicationId) {
		this.applicationId = applicationId;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Integer getAgentId() {
		return agentId;
	}

	public void setAgentId(Integer agentId) {
		this.agentId = agentId;
	}

	public Integer getProductId() {
		return productId;
	}

	public void setProductId(Integer productId) {
		this.productId = productId;
	}

	public Integer getFlowId() {
		return flowId;
	}

	public void setFlowId(Integer flowId) {
		this.flowId = flowId;
	}

	public Integer getFileRecNum() {
		return fileRecNum;
	}

	public void setFileRecNum(Integer fileRecNum) {
		this.fileRecNum = fileRecNum;
	}

	public String getAppType() {
		return appType;
	}

	public void setAppType(String appType) {
		this.appType = appType;
	}

	public String getAppStatus() {
		return appStatus;
	}

	public void setAppStatus(String appStatus) {
		this.appStatus = appStatus;
	}

	public String getOperatorId() {
		return operatorId;
	}

	public void setOperatorId(String operatorId) {
		this.operatorId = operatorId;
	}

	public String getRejectCode() {
		return rejectCode;
	}

	public void setRejectCode(String rejectCode) {
		this.rejectCode = rejectCode;
	}

	public String getCustomerType() {
		return customerType;
	}

	public void setCustomerType(String customerType) {
		this.customerType = customerType;
	}

	public String getContractType() {
		return contractType;
	}

	public void setContractType(String contractType) {
		this.contractType = contractType;
	}
	
	
}
