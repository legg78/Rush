package ru.bpc.sv2.ps.mastercard;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class McwReject implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer networkId;
	private String networkName;
	private Integer instId;
	private String instName;
	private Integer fileId;
	private Long rejectedFinId;
	private Integer rejectedFileId;
	private String mti;
	private String de024;
	private Integer de071;
	private String de072;
	private String de093;
	private String de094;
	private String de100;
	private String p0005;
	private String p0006;
	private String p0025;
	private String p0026;
	private Integer p0138;
	private String p0165;
	private String p0280;
	
    private Long sessionId;
    private Long sessionFileId;
    private String fileName;
    private Date fileDate;
    private Date dateFrom;
    private Date dateTo;
    
    private Long rejectedSessionId;
    private Long rejectedSessionFileId;
    private String rejectedFileName;
    private Date rejectedFileDate;

	public Long getId(){
		return this.id;
	}
	
	public void setId(Long id){
		this.id = id;
	}
	
	public Integer getNetworkId(){
		return this.networkId;
	}
	
	public void setNetworkId(Integer networkId){
		this.networkId = networkId;
	}
	
	public Integer getInstId(){
		return this.instId;
	}
	
	public void setInstId(Integer instId){
		this.instId = instId;
	}
	
	public Integer getFileId(){
		return this.fileId;
	}
	
	public void setFileId(Integer fileId){
		this.fileId = fileId;
	}
	
	public Long getRejectedFinId(){
		return this.rejectedFinId;
	}
	
	public void setRejectedFinId(Long rejectedFinId){
		this.rejectedFinId = rejectedFinId;
	}
	
	public Integer getRejectedFileId(){
		return this.rejectedFileId;
	}
	
	public void setRejectedFileId(Integer rejectedFileId){
		this.rejectedFileId = rejectedFileId;
	}
	
	public String getMti(){
		return this.mti;
	}
	
	public void setMti(String mti){
		this.mti = mti;
	}
	
	public String getDe024(){
		return this.de024;
	}
	
	public void setDe024(String de024){
		this.de024 = de024;
	}
	
	public Integer getDe071(){
		return this.de071;
	}
	
	public void setDe071(Integer de071){
		this.de071 = de071;
	}
	
	public String getDe072(){
		return this.de072;
	}
	
	public void setDe072(String de072){
		this.de072 = de072;
	}
	
	public String getDe093(){
		return this.de093;
	}
	
	public void setDe093(String de093){
		this.de093 = de093;
	}
	
	public String getDe094(){
		return this.de094;
	}
	
	public void setDe094(String de094){
		this.de094 = de094;
	}
	
	public String getDe100(){
		return this.de100;
	}
	
	public void setDe100(String de100){
		this.de100 = de100;
	}
	
	public String getP0005(){
		return this.p0005;
	}
	
	public void setP0005(String p0005){
		this.p0005 = p0005;
	}
	
	public String getP0006(){
		return this.p0006;
	}
	
	public void setP0006(String p0006){
		this.p0006 = p0006;
	}
	
	public String getP0025(){
		return this.p0025;
	}
	
	public void setP0025(String p0025){
		this.p0025 = p0025;
	}
	
	public String getP0026(){
		return this.p0026;
	}
	
	public void setP0026(String p0026){
		this.p0026 = p0026;
	}
	
	public Integer getP0138(){
		return this.p0138;
	}
	
	public void setP0138(Integer p0138){
		this.p0138 = p0138;
	}
	
	public String getP0165(){
		return this.p0165;
	}
	
	public void setP0165(String p0165){
		this.p0165 = p0165;
	}
	
	public String getP0280(){
		return this.p0280;
	}
	
	public void setP0280(String p0280){
		this.p0280 = p0280;
	}
	
	public String getNetworkName() {
		return networkName;
	}

	public void setNetworkName(String networkName) {
		this.networkName = networkName;
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	public Long getSessionId() {
		return sessionId;
	}

	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
	}

	public String getFileName() {
		return fileName;
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}

	public Date getFileDate() {
		return fileDate;
	}

	public void setFileDate(Date fileDate) {
		this.fileDate = fileDate;
	}

	public Date getDateFrom() {
		return dateFrom;
	}

	public void setDateFrom(Date dateFrom) {
		this.dateFrom = dateFrom;
	}

	public Date getDateTo() {
		return dateTo;
	}

	public void setDateTo(Date dateTo) {
		this.dateTo = dateTo;
	}

	public Long getSessionFileId() {
		return sessionFileId;
	}

	public void setSessionFileId(Long sessionFileId) {
		this.sessionFileId = sessionFileId;
	}

	public Long getRejectedSessionId() {
		return rejectedSessionId;
	}

	public void setRejectedSessionId(Long rejectedSessionId) {
		this.rejectedSessionId = rejectedSessionId;
	}

	public Long getRejectedSessionFileId() {
		return rejectedSessionFileId;
	}

	public void setRejectedSessionFileId(Long rejectedSessionFileId) {
		this.rejectedSessionFileId = rejectedSessionFileId;
	}

	public String getRejectedFileName() {
		return rejectedFileName;
	}

	public void setRejectedFileName(String rejectedFileName) {
		this.rejectedFileName = rejectedFileName;
	}

	public Date getRejectedFileDate() {
		return rejectedFileDate;
	}

	public void setRejectedFileDate(Date rejectedFileDate) {
		this.rejectedFileDate = rejectedFileDate;
	}

	@Override
	public Object getModelId() {
		return getId();
	}
	@Override
	public Object clone(){
		Object result = null;
		try {
			result = super.clone();
		} catch (CloneNotSupportedException e) {
			e.printStackTrace();
		}
		return result;
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("instId", getInstId());
		result.put("sessionId", getSessionId());
		result.put("fileName", getFileName());
		result.put("fileDate", getFileDate());
		return result;
	}
}