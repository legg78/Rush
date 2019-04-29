package ru.bpc.sv2.fraud;

import ru.bpc.sv2.invocation.IAuditableObject;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class McwFraud implements Serializable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer instId;
	private Long fileId;
	private Boolean incoming;
	private Boolean rejected;
	private Long disputeId;
	private String status;
	private String format;
	private String c01;
	private String c02;
	private Long c03;
	private String c04;
	private String c05;
	private Date c06;
	private String c07;
	private Date c08_10;
	private Long c09;
	private Long c11;
	private String c12;
	private Integer c13;
	private Long c14;
	private String c15;
	private Boolean c16;
	private String c17;
	private String c18;
	private String c19;
	private String c20;
	private String c21;
	private String c22;
	private String c23;
	private String c24;
	private String c25;
	private String c26;
	private String c27;
	private String c28;
	private String c29;
	private String c30;
	private String c31;
	private Date c32;
	private String c33;
	private String c34;
	private String c35;
	private String c36;
	private String c37;
	private String c39;
	private String c44;
	private String c45;
	private String c46;
	private String c47;
	private String c48;
	private String error1_1;
	private String error1_2;
	private String error2_1;
	private String error2_2;
	private String error3_1;
	private String error3_2;
	private String error4_1;
	private String error4_2;
	private String error5_1;
	private String error5_2;


	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Long getFileId() {
		return fileId;
	}

	public void setFileId(Long fileId) {
		this.fileId = fileId;
	}

	public Boolean getIncoming() {
		return incoming;
	}

	public void setIncoming(Boolean incoming) {
		this.incoming = incoming;
	}

	public Boolean getRejected() {
		return rejected;
	}

	public void setRejected(Boolean rejected) {
		this.rejected = rejected;
	}

	public Long getDisputeId() {
		return disputeId;
	}

	public void setDisputeId(Long disputeId) {
		this.disputeId = disputeId;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getFormat() {
		return format;
	}

	public void setFormat(String format) {
		this.format = format;
	}

	public String getC01() {
		return c01;
	}

	public void setC01(String c01) {
		this.c01 = c01;
	}

	public String getC02() {
		return c02;
	}

	public void setC02(String c02) {
		this.c02 = c02;
	}

	public Long getC03() {
		return c03;
	}

	public void setC03(Long c03) {
		this.c03 = c03;
	}

	public String getC04() {
		return c04;
	}

	public void setC04(String c04) {
		this.c04 = c04;
	}

	public String getC05() {
		return c05;
	}

	public void setC05(String c05) {
		this.c05 = c05;
	}

	public Date getC06() {
		return c06;
	}

	public void setC06(Date c06) {
		this.c06 = c06;
	}

	public String getC07() {
		return c07;
	}

	public void setC07(String c07) {
		this.c07 = c07;
	}

	public Date getC08_10() {
		return c08_10;
	}

	public void setC08_10(Date c08_10) {
		this.c08_10 = c08_10;
	}

	public Long getC09() {
		return c09;
	}

	public void setC09(Long c09) {
		this.c09 = c09;
	}

	public Long getC11() {
		return c11;
	}

	public void setC11(Long c11) {
		this.c11 = c11;
	}

	public String getC12() {
		return c12;
	}

	public void setC12(String c12) {
		this.c12 = c12;
	}

	public Integer getC13() {
		return c13;
	}

	public void setC13(Integer c13) {
		this.c13 = c13;
	}

	public Long getC14() {
		return c14;
	}

	public void setC14(Long c14) {
		this.c14 = c14;
	}

	public String getC15() {
		return c15;
	}

	public void setC15(String c15) {
		this.c15 = c15;
	}

	public Boolean getC16() {
		return c16;
	}

	public void setC16(Boolean c16) {
		this.c16 = c16;
	}

	public String getC17() {
		return c17;
	}

	public void setC17(String c17) {
		this.c17 = c17;
	}

	public String getC18() {
		return c18;
	}

	public void setC18(String c18) {
		this.c18 = c18;
	}

	public String getC19() {
		return c19;
	}

	public void setC19(String c19) {
		this.c19 = c19;
	}

	public String getC20() {
		return c20;
	}

	public void setC20(String c20) {
		this.c20 = c20;
	}

	public String getC21() {
		return c21;
	}

	public void setC21(String c21) {
		this.c21 = c21;
	}

	public String getC22() {
		return c22;
	}

	public void setC22(String c22) {
		this.c22 = c22;
	}

	public String getC23() {
		return c23;
	}

	public void setC23(String c23) {
		this.c23 = c23;
	}

	public String getC24() {
		return c24;
	}

	public void setC24(String c24) {
		this.c24 = c24;
	}

	public String getC25() {
		return c25;
	}

	public void setC25(String c25) {
		this.c25 = c25;
	}

	public String getC26() {
		return c26;
	}

	public void setC26(String c26) {
		this.c26 = c26;
	}

	public String getC27() {
		return c27;
	}

	public void setC27(String c27) {
		this.c27 = c27;
	}

	public String getC28() {
		return c28;
	}

	public void setC28(String c28) {
		this.c28 = c28;
	}

	public String getC29() {
		return c29;
	}

	public void setC29(String c29) {
		this.c29 = c29;
	}

	public String getC30() {
		return c30;
	}

	public void setC30(String c30) {
		this.c30 = c30;
	}

	public String getC31() {
		return c31;
	}

	public void setC31(String c31) {
		this.c31 = c31;
	}

	public Date getC32() {
		return c32;
	}

	public void setC32(Date c32) {
		this.c32 = c32;
	}

	public String getC33() {
		return c33;
	}

	public void setC33(String c33) {
		this.c33 = c33;
	}

	public String getC34() {
		return c34;
	}

	public void setC34(String c34) {
		this.c34 = c34;
	}

	public String getC35() {
		return c35;
	}

	public void setC35(String c35) {
		this.c35 = c35;
	}

	public String getC36() {
		return c36;
	}

	public void setC36(String c36) {
		this.c36 = c36;
	}

	public String getC37() {
		return c37;
	}

	public void setC37(String c37) {
		this.c37 = c37;
	}

	public String getC39() {
		return c39;
	}

	public void setC39(String c39) {
		this.c39 = c39;
	}

	public String getC44() {
		return c44;
	}

	public void setC44(String c44) {
		this.c44 = c44;
	}

	public String getC45() {
		return c45;
	}

	public void setC45(String c45) {
		this.c45 = c45;
	}

	public String getC46() {
		return c46;
	}

	public void setC46(String c46) {
		this.c46 = c46;
	}

	public String getC47() {
		return c47;
	}

	public void setC47(String c47) {
		this.c47 = c47;
	}

	public String getC48() {
		return c48;
	}

	public void setC48(String c48) {
		this.c48 = c48;
	}

	public String getError1_1() {
		return error1_1;
	}

	public void setError1_1(String error1_1) {
		this.error1_1 = error1_1;
	}

	public String getError1_2() {
		return error1_2;
	}

	public void setError1_2(String error1_2) {
		this.error1_2 = error1_2;
	}

	public String getError2_1() {
		return error2_1;
	}

	public void setError2_1(String error2_1) {
		this.error2_1 = error2_1;
	}

	public String getError2_2() {
		return error2_2;
	}

	public void setError2_2(String error2_2) {
		this.error2_2 = error2_2;
	}

	public String getError3_1() {
		return error3_1;
	}

	public void setError3_1(String error3_1) {
		this.error3_1 = error3_1;
	}

	public String getError3_2() {
		return error3_2;
	}

	public void setError3_2(String error3_2) {
		this.error3_2 = error3_2;
	}

	public String getError4_1() {
		return error4_1;
	}

	public void setError4_1(String error4_1) {
		this.error4_1 = error4_1;
	}

	public String getError4_2() {
		return error4_2;
	}

	public void setError4_2(String error4_2) {
		this.error4_2 = error4_2;
	}

	public String getError5_1() {
		return error5_1;
	}

	public void setError5_1(String error5_1) {
		this.error5_1 = error5_1;
	}

	public String getError5_2() {
		return error5_2;
	}

	public void setError5_2(String error5_2) {
		this.error5_2 = error5_2;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("instId", getInstId());
		result.put("status", getStatus());

		return result;
	}
}
