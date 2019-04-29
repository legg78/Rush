package ru.bpc.sv.ws.integration.ibatis;

import ru.bpc.sv.svxp.pmo.ImportOrderResponse;
import ru.bpc.sv2.common.SQLDataRec;
import ru.bpc.sv2.utils.AuthOracleTypeNames;

import java.sql.SQLException;
import java.sql.SQLOutput;

public class ImportPmoResponseRec extends SQLDataRec {
	private Long orderId;
	private Long amount;
	private String currency;
	private String respCode;

	@Override
	public String getSQLTypeName() throws SQLException {
		return AuthOracleTypeNames.PMO_RESPONSE_REC;
	}

	@Override
	public void writeSQL(SQLOutput stream) throws SQLException {
		stream.writeLong(orderId);
		stream.writeLong(amount);
		stream.writeString(currency);
		stream.writeString(respCode);
	}

	public static ImportPmoResponseRec createByOrderResponse(ImportOrderResponse order) {
		ImportPmoResponseRec rec = new ImportPmoResponseRec();
		rec.setOrderId(order.getOrderId());
		rec.setAmount(order.getAmount());
		rec.setCurrency(order.getCurrency());
		rec.setRespCode(order.getRespCode());
		return rec;
	}

	public Long getOrderId() {
		return orderId;
	}

	public void setOrderId(Long orderId) {
		this.orderId = orderId;
	}

	public Long getAmount() {
		return amount;
	}

	public void setAmount(Long amount) {
		this.amount = amount;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public String getRespCode() {
		return respCode;
	}

	public void setRespCode(String respCode) {
		this.respCode = respCode;
	}
}
