package ru.bpc.sv2.atm;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class CapturedCard implements Serializable, ModelIdentifiable, Cloneable{

	private static final long serialVersionUID = 1L;

	private Long authId;
	private Integer terminalId;
	private Long collId;
	private Date operDate;
	private String cardMask;
	private Long cardId;
	private String cardNumber;
	private String respCode;
	
	public Object getModelId() {
		return getAuthId();
	}
	
	public Long getAuthId(){
		return this.authId;
	}
	
	public void setAuthId(Long authId){
		this.authId = authId;
	}
	
	public Integer getTerminalId(){
		return this.terminalId;
	}
	
	public void setTerminalId(Integer terminalId){
		this.terminalId = terminalId;
	}
	
	public Long getCollId(){
		return this.collId;
	}
	
	public void setCollId(Long collId){
		this.collId = collId;
	}
	
	public Date getOperDate(){
		return this.operDate;
	}
	
	public void setOperDate(Date operDate){
		this.operDate = operDate;
	}
	
	public String getCardMask(){
		return this.cardMask;
	}
	
	public void setCardMask(String cardMask){
		this.cardMask = cardMask;
	}
	
	public Long getCardId(){
		return this.cardId;
	}
	
	public void setCardId(Long cardId){
		this.cardId = cardId;
	}
	
	public String getCardNumber(){
		return this.cardNumber;
	}
	
	public void setCardNumber(String cardNumber){
		this.cardNumber = cardNumber;
	}
	
	public Object clone(){
		Object result = null;
		try {
			result = super.clone();
		} catch (CloneNotSupportedException e) {
			e.printStackTrace();
		}
		return result;
	}

	public String getRespCode() {
		return respCode;
	}

	public void setRespCode(String respCode) {
		this.respCode = respCode;
	}
}