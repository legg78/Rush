package ru.bpc.sv2.constants.application;

public interface ApplicationConstants {
	int DATA_SEQUENCE_STEP						= 100;
	int DEFAULT_INSTITUTION						= 9999;
	int UNDEFINED_USER							= -1;

	String DEPENDENCE_LOV						= "ASTD0001";
	String DEPENDENCE_REQUIRED					= "ASTD0002";
	String DEPENDENCE_VISIBLE					= "ASTD0003";
	String DEPENDENCE_VALUE						= "ASTD0004";
	String DEPENDENCE_ENTITY_TYPE				= "ASTD0005";

	String ELEMENT_TYPE_SIMPLE					= "SIMPLE";
	String ELEMENT_TYPE_COMPLEX					= "COMPLEX";

	String TYPE_ACQUIRING						= "APTPACQA";
	String TYPE_ISSUING							= "APTPISSA";
	String TYPE_PAYMENT_ORDERS					= "APTPPMNO";
	String TYPE_USER_MNG 						= "APTPUMGT";
	String TYPE_FIN_REQUEST						= "APTPFREQ";
	String TYPE_DISPUTES						= "APTPDSPT";
	String TYPE_PRODUCT							= "APTPPRDT";
	String TYPE_ISS_PRODUCT						= "APTPIPRD";
	String TYPE_ACQ_PRODUCT						= "APTPAPRD";
	String TYPE_INSTITUTION						= "APTPINSA";
	String TYPE_QUESTIONARY						= "APTPQSTN";
	String TYPE_CAMPAIGNS						= "APTPCMPN";

	String DEPENDENCE_AFFECTED_ZONE_SIBLINGS	= "DPAZ0001";
	String DEPENDENCE_AFFECTED_ZONE_CHILDREN	= "DPAZ0002";

	String USER_SCHEME_TYPE 					= "NTFS0020";

	String COMMAND_CREATE_OR_EXCEPT				= "CMMDCREX";
	String COMMAND_CREATE_OR_PROCEED			= "CMMDCRPR";
	String COMMAND_CREATE_OR_UPDATE				= "CMMDCRUP";
	String COMMAND_EXCEPT_OR_REMOVE				= "CMMDEXRE";
	String COMMAND_EXCEPT_OR_UPDATE				= "CMMDEXUP";
	String COMMAND_EXCEPT_OR_PROCEED			= "CMMDEXPR";
	String COMMAND_PROCEED_OR_REMOVE			= "CMMDPRRE";
	String COMMAND_IGNORE						= "CMMDIGNR";

	String PERIODIC_PAYMENT_CYCLE				= "CYTP1401";

	String CARD_CATEGORY_PRIMARY				= "CRCG0800";
	String CARD_CATEGORY_DOUBLE					= "CRCG0600";
	String CARD_CATEGORY_SUPPLEMENTARY			= "CRCG0400";
	String CARD_CATEGORY_UNDEFINED				= "CRCG0200";

	String CUSTOMER_CATEGORY_PRIVILEGED			= "CCTGPRVG";
	String CUSTOMER_CATEGORY_ORDINARY			= "CCTGORDN";
	
	String CUSTOMER_RELATION_AFFILIATE			= "RSCBAFLT";
	String CUSTOMER_RELATION_EMPLOYEE			= "RSCBEMPL";
	String CUSTOMER_RELATION_EXTERNAL			= "RSCBEXTR";
	String CUSTOMER_RELATION_INSD				= "RSCBINSD";

	String APPLICATION_MAIN_NODE				= "application";

	String BACKLINK_ACQ_APPLICATIONS			= "applications|list_acq_apps";
	String BACKLINK_ACQ_PRODUCTS				= "applications|list_acq_prod_apps";
	String BACKLINK_ISS_APPLICATIONS			= "applications|list_iss_apps";
	String BACKLINK_ISS_PRODUCTS				= "applications|list_iss_prod_apps";
	String BACKLINK_INSTITUTIONS				= "applications|list_inst_apps";
	String BACKLINK_PAYMENT_ORDERS				= "applications|list_pmo_apps";
	String BACKLINK_APPLICATIONS				= "applications|list_apps";
	String BACKLINK_USER_MANAGEMENT				= "applications|list_acm_apps";
	String BACKLINK_QUESTIONARY					= "applications|list_qstn_apps";
	String BACKLINK_CAMPAIGNS					= "applications|list_cmpn_apps";
}
