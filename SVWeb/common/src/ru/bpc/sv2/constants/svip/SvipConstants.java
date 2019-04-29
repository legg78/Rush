package ru.bpc.sv2.constants.svip;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public class SvipConstants {
	
	public static final String PARAM_RATE_TYPE = "DEFAULT_RATE_TYPE";
	public static final String PARAM_CURRENCY = "DEFAULT_CURRENCY";
	
	public final static String ifxAcctBalanceTypeAvail = "Avail";
	public final static String ifxAcctBalanceTypeTotalHeld = "TotalHeld";	
	public final static String ifxAcctBalanceTypeWarningLowThreshold = "WarningLowThreshold";
	public final static String ifxAcctBalanceTypeDisableLowThreshold = "DisableLowThreshold";
	public final static String ifxAcctBalanceTypeCreditLimit = "CreditLimit";
	public final static String ifxAcctBalanceTypeYotaTelecomHeld = "YotaTelecomHeld";
	public final static String ifxAcctBalanceTypeTopUpLimit = "TopUpLimit";
	
	public final static String ifxAcctBalanceTypeCycleLimit = "CycleLimit";
	
	public final static String ifxAcctBalanceTypeCycleLimitThreshold = "CycleLimitThreshold";
	public final static String ifxAcctBalanceTypeCycleLimitRest = "CycleLimitRest";
	public final static String ifxAcctBalanceTypeHighThreshold = "HighThreshold";
	public final static String ifxAcctBalanceTypeHighRest = "HighRest";
	
	public final static String ifxPartyStatusNotAvail = "NotAvail";
	public final static String ifxPartyStatusDeleted = "Deleted";
	public final static String ifxPartyStatusValid = "Valid";
	
	public final static String ifxTrnStatusCodeCancelled = "Cancelled";
	public final static String ifxTrnStatusCodePosted = "Posted";
	public final static String ifxTrnStatusCodeRejected = "Rejected";
	public final static String ifxTrnStatusCodeScheduled = "Scheduled";
	public final static String ifxTrnStatusCodeOnHold = "OnHold";
	
	public final static String ifxAcctStatusCodeUndefined = "";
	public final static String ifxAcctStatusCodeOpen = "Open";
	public final static String ifxAcctStatusCodeClosed = "Closed";
	public final static String ifxAcctStatusCodeClosing = "Closing";
	public final static String ifxAcctStatusCodeInactive = "Inactive";
	public final static String ifxAcctStatusCodeNotAvail = "NotAvail";
	public final static String ifxAcctStatusCodeNotFunded = "NotFunded";
	public final static String ifxAcctStatusCodeFunded = "Funded";
	public final static String ifxAcctStatusCodeDormant = "Dormant";
	public final static String ifxAcctStatusCodeFrozen = "Frozen";
	public final static String ifxAcctStatusCodeActive = "Active";
	public final static String ifxAcctStatusCodePaidOff = "PaidOff";
	public final static String ifxAcctStatusCodeTerminated = "Terminated";
	public final static String ifxAcctStatusCodeEscheat = "Escheat";
	public final static String ifxAcctStatusCodeChargeOffInProcess = "ChargeOffInProcess";
	public final static String ifxAcctStatusCodeChargedOff = "ChargedOff";
	public final static String ifxAcctStatusCodeUnreedemed = "Unreedemed";
	public final static String ifxAcctStatusCodeAbandoned = "Abandoned";
	public final static String ifxAcctStatusCodeDelinquent = "Delinquent";
	
	public static Map<String, String> accStatusMap = createAccStatusMapMap();
	public static final String bpcAcctStatusActive = "ACSTACTV";
	public static final String bpcAcctStatusClosed = "ACSTCLSD";
	private static Map<String, String> createAccStatusMapMap() {
        Map<String, String> result = new HashMap<String, String>();
        result.put(bpcAcctStatusActive, ifxAcctStatusCodeActive);             
        result.put(bpcAcctStatusClosed, ifxAcctStatusCodeInactive);
        return Collections.unmodifiableMap(result);
    }

	public final static String ifxNetworkOwnerATM = "ATM";
    public final static String ifxNetworkOwnerBranch = "Branch";
    public final static String ifxNetworkOwnerPOS = "POS";
    public final static String ifxNetworkOwnerCallCenter = "CallCenter";
    public final static String ifxNetworkOwnerACH = "ACH";
    public final static String ifxNetworkOwnerOther = "Other";

	public final static String ifxTerminalTypeAdminTerm = "AdminTerm";
    public final static String ifxTerminalTypeATM = "ATM";
    public final static String ifxTerminalTypePOS = "POS";
    public final static String ifxTerminalTypeCustomerDevice = "CustomerDevice";
    public final static String ifxTerminalTypeECR = "ECR";
    public final static String ifxTerminalTypeDialCash = "DialCash";
    public final static String ifxTerminalTypeTravelerCheckDispenser = "TravelerCheckDispenser";
    public final static String ifxTerminalTypeFuelPump = "FuelPump";
    public final static String ifxTerminalTypeScripTerm = "ScripTerm";
    public final static String ifxTerminalTypeCouponTerm = "CouponTerm";
    public final static String ifxTerminalTypeTicketTerm = "TicketTerm";
    public final static String ifxTerminalTypePOBTerm = "POBTerm";
    public final static String ifxTerminalTypeTeller = "Teller";
    public final static String ifxTerminalTypeUtility = "Utility";
    public final static String ifxTerminalTypeVending = "Vending";
    public final static String ifxTerminalTypePayment = "Payment";
    public final static String ifxTerminalTypeVRU = "VRU";
    
    public final static String ifxCompositeCurAmtTypeImmediate = "Immediate" ;
    public final static String ifxCompositeCurAmtType1DayFloat = "1DayFloat" ;
    public final static String ifxCompositeCurAmtType2DayFloat = "2DayFloat" ;
    public final static String ifxCompositeCurAmtType3DayFloat = "3DayFloat" ;
    public final static String ifxCompositeCurAmtType4DayFloat = "4DayFloat" ;
    public final static String ifxCompositeCurAmtType5DayFloat = "5DayFloat" ;
    public final static String ifxCompositeCurAmtType6DayFloat = "6DayFloat" ;
    public final static String ifxCompositeCurAmtTypeOnePlusDay = "OnePlusDay" ;
    public final static String ifxCompositeCurAmtTypeTwoPlusDay = "TwoPlusDay" ;
    public final static String ifxCompositeCurAmtTypeThreePlusDay = "ThreePlusDay" ;
    public final static String ifxCompositeCurAmtTypeDebit = "Debit" ;
    public final static String ifxCompositeCurAmtTypeCredit = "Credit" ;
    public final static String ifxCompositeCurAmtTypeCheckFee = "CheckFee" ;
    public final static String ifxCompositeCurAmtTypeForExFee = "ForExFee" ;
    public final static String ifxCompositeCurAmtTypeStopChkFee = "StopChkFee" ;
    public final static String ifxCompositeCurAmtTypeLateFee = "LateFee" ;
    public final static String ifxCompositeCurAmtTypeTransactionFee = "TransactionFee" ;
    public final static String ifxCompositeCurAmtTypeInterchangeFee = "InterchangeFee" ;
    public final static String ifxCompositeCurAmtTypeSurcharge = "Surcharge" ;
    public final static String ifxCompositeCurAmtTypeStatementFee = "StatementFee" ;
    public final static String ifxCompositeCurAmtTypeTax = "Tax" ;
    public final static String ifxCompositeCurAmtTypeMerchandisePurchase = "MerchandisePurchase" ;
    public final static String ifxCompositeCurAmtTypePmtEnclosed = "PmtEnclosed" ;
    public final static String ifxCompositeCurAmtTypeCashBack = "CashBack" ;
    public final static String ifxCompositeCurAmtTypeCreditHeld = "CreditHeld" ;
    public final static String ifxCompositeCurAmtTypeBonus = "Bonus" ;
    public final static String ifxCompositeCurAmtTypeFreight = "Freight" ;
    public final static String ifxCompositeCurAmtTypePurchaseItemTotal = "PurchaseItemTotal" ;
    
    public final static String ifxAcctIdentTypeUndefined = "";
    public final static String ifxAcctIdentTypeConvertedAcctNum = "ConvertedAcctNum";
    public final static String ifxAcctIdentTypeAcctNum = "AcctNum";
    public final static String ifxAcctIdentTypeMobilePhoneNumber = "MobilePhoneNumber";
    public final static String ifxAcctIdentTypeEMail = "EMail";
    
    public final static String identTypeUndefined = "CITPUNKN";
    public final static String identTypeNone = "CITPNONE";
    public final static String identTypeCard = "CITPCARD";
    public final static String identTypeAcctNum = "CITPACCT";
    public final static String identTypeMobilePhoneNumber = "CITPMBPH";
    public final static String identTypeEMail = "CITPEMAI";
    public final static String identTypeCustomer = "CITPCUST";
    public final static String identTypeContract = "CITPCNTR";
    
    public static Map<String, String> clientIdTypesMap = createClientIdTypesMap();	
	private static Map<String, String> createClientIdTypesMap() {
        Map<String, String> result = new HashMap<String, String>();
        result.put(ifxAcctIdentTypeUndefined, identTypeUndefined);
        result.put(ifxAcctIdentTypeAcctNum, identTypeAcctNum);
        result.put(ifxAcctIdentTypeEMail, identTypeEMail);
        result.put(ifxAcctIdentTypeMobilePhoneNumber, identTypeMobilePhoneNumber);        
        return Collections.unmodifiableMap(result);
    }
	
	public static Map<String, String> clientIdTypesReverseMap = createClientIdTypesReverseMap();	
	private static Map<String, String> createClientIdTypesReverseMap() {
        Map<String, String> result = new HashMap<String, String>();
        result.put(identTypeUndefined, ifxAcctIdentTypeUndefined);
        result.put(identTypeAcctNum, ifxAcctIdentTypeAcctNum);
        result.put(identTypeEMail, ifxAcctIdentTypeEMail);
        result.put(identTypeMobilePhoneNumber, ifxAcctIdentTypeMobilePhoneNumber);        
        return Collections.unmodifiableMap(result);
    }

	public final static String ifxEmailType = "Person";
	public final static String ifxMobilePhoneType = "Mobile";
	
    public final static String ifxXferStatusCodeUndefined = "" ;
	public final static String ifxXferStatusCodeScheduled = "Scheduled" ;
	public final static String ifxXferStatusCodeCancelled = "Cancelled" ;
	public final static String ifxXferStatusCodeFIHeld = "FIHeld" ;
	public final static String ifxXferStatusCodeRejNoFund = "RejNoFund" ;
	public final static String ifxXferStatusCodeRejInactive = "RejInactive" ;
	public final static String ifxXferStatusCodeRejClosed = "RejClosed" ;
	public final static String ifxXferStatusCodeReturned = "Returned" ;
	public final static String ifxXferStatusCodeFailed = "Failed" ;
	public final static String ifxXferStatusCodeProcessed = "Processed" ;
	public final static String ifxXferStatusCodePosted = "Posted" ;
	public final static String ifxXferStatusCodeCleared = "Cleared" ;
	public final static String ifxXferStatusCodeSkipped = "Skipped" ;
	public final static String ifxXferStatusCodeRejected = "Rejected" ;
	public final static String ifxXferStatusCodeHeld = "Held" ;
	public final static String ifxXferStatusCodeValid = "Valid" ;
	public final static String ifxXferStatusCodeDeleted = "Deleted" ;

	
	public final static int ifxStatusCode0000Info =  0;   
	public final static int ifxStatusCode0005Warn =  5;   
	public final static int ifxStatusCode0100Error = 100; 
	public final static int ifxStatusCode0200Error = 200; 
	public final static int ifxStatusCode0300Error = 300; 
	public final static int ifxStatusCode0400Error = 400; 
	public final static int ifxStatusCode0500Error = 500; 
	public final static int ifxStatusCode0600Error = 600; 
	public final static int ifxStatusCode0700Error = 700; 
	public final static int ifxStatusCode0750Error = 750; 
	public final static int ifxStatusCode0900Warn =  900; 
	public final static int ifxStatusCode1000Error = 1000;
	public final static int ifxStatusCode1030Error = 1030;
	public final static int ifxStatusCode1040Warn =  1040;
	public final static int ifxStatusCode1045Error = 1045;
	public final static int ifxStatusCode1070Error = 1070;
	public final static int ifxStatusCode1090Error = 1090;
	public final static int ifxStatusCode2365Error = 2365;
	public final static int ifxStatusCode2395Error = 2395;
	public final static int ifxStatusCode2550Error = 2550;
	public final static int ifxStatusCode2800Warn =  2800;
	public final static int ifxStatusCode2810Error = 2810;
	public final static int ifxStatusCode2820Error = 2820;
	public final static int ifxStatusCode2830Error = 2830;
	public final static int ifxStatusCode3060Error = 3060;
	public final static int ifxStatusCode3800Error = 3800;
	public final static int ifxStatusCode3920Error = 3920;
	public final static int ifxStatusCode3930Error = 3930;
	public final static int ifxStatusCode4000Warn =  4000;
	public final static int ifxStatusCode4090Error = 4090;
	public final static int ifxStatusCode5100Error = 5100;
	public final static int ifxStatusCode6000Error = 6000;
	public final static int ifxStatusCode6010Error = 6010;
	public final static int ifxStatusCode6020Error = 6020;
	public final static int ifxStatusCode6030Error = 6030;
	public final static int ifxStatusCode6040Error = 6040;
	public final static int ifxStatusCode6050Error = 6050;
	public final static int ifxStatusCode6060Error = 6060;
	public final static int ifxStatusCode6090Error = 6090;
	public final static int ifxStatusCode6100Error = 6100;
	public final static int ifxStatusCode6110Error = 6110;
	public final static int ifxStatusCode6120Error = 6120;
	public final static int ifxStatusCode6154Warn =  6154;
	public final static int ifxStatusCode6155Error = 6155;
	public final static int ifxStatusCode6160Error = 6160;
	public final static int ifxStatusCode6170Error = 6170;
	public final static int ifxStatusCode6180Error = 6180;
	public final static int ifxStatusCode6190Error = 6190;
	public final static int ifxStatusCode6310Error = 6310;
	public final static int ifxStatusCode6410Error = 6410;
	public final static int ifxStatusCode0800Error = 800; 
	public final static int ifxStatusCode0810Error = 810; 
	public final static int ifxStatusCode1050Error = 1050;
	public final static int ifxStatusCode1060Error = 1060;
	public final static int ifxStatusCode1080Warn =  1080;
	public final static int ifxStatusCode1100Warn =  1100;
	public final static int ifxStatusCode1120Info =  1120;
	public final static int ifxStatusCode1140Warn =  1140;
	public final static int ifxStatusCode1160Error = 1160;
	public final static int ifxStatusCode1220Error = 1220;
	public final static int ifxStatusCode1240Warn =  1240;
	public final static int ifxStatusCode1260Error = 1260;
	public final static int ifxStatusCode1280Warn =  1280;
	public final static int ifxStatusCode1500Error = 1500;
	public final static int ifxStatusCode1700Error = 1700;
	public final static int ifxStatusCode1740Error = 1740;
	public final static int ifxStatusCode1760Error = 1760;
	public final static int ifxStatusCode1880Error = 1880;
	public final static int ifxStatusCode1881Error = 1881;
	public final static int ifxStatusCode1900Warn =  1900;
	public final static int ifxStatusCode2020Error = 2020;
	public final static int ifxStatusCode2030Error = 2030;
	public final static int ifxStatusCode2050Error = 2050;
	public final static int ifxStatusCode2080Error = 2080;
	public final static int ifxStatusCode2120Error = 2120;
	public final static int ifxStatusCode2130Error = 2130;
	public final static int ifxStatusCode2140Error = 2140;
	public final static int ifxStatusCode2150Error = 2150;
	public final static int ifxStatusCode2160Error = 2160;
	public final static int ifxStatusCode2170Warn =  2170;
	public final static int ifxStatusCode2180Error = 2180;
	public final static int ifxStatusCode2190Error = 2190;
	public final static int ifxStatusCode2200Warn =  2200;
	public final static int ifxStatusCode2210Warn =  2210;
	public final static int ifxStatusCode2320Error = 2320;
	public final static int ifxStatusCode2350Error = 2350;
	public final static int ifxStatusCode2370Error = 2370;
	public final static int ifxStatusCode2380Error = 2380;
	public final static int ifxStatusCode2381Error = 2381;
	public final static int ifxStatusCode2400Error = 2400;
	public final static int ifxStatusCode2401Error = 2401;
	public final static int ifxStatusCode2420Error = 2420;
	public final static int ifxStatusCode2500Error = 2500;
	public final static int ifxStatusCode2510Error = 2510;
	public final static int ifxStatusCode2520Error = 2520;
	public final static int ifxStatusCode2530Error = 2530;
	public final static int ifxStatusCode2540Error = 2540;
	public final static int ifxStatusCode2720Error = 2720;
	public final static int ifxStatusCode2740Error = 2740;
	public final static int ifxStatusCode2900Error = 2900;
	public final static int ifxStatusCode2910Error = 2910;
	public final static int ifxStatusCode2920Error = 2920;
	public final static int ifxStatusCode2940Error = 2940;
	public final static int ifxStatusCode3000Error = 3000;
	public final static int ifxStatusCode3020Error = 3020;
	public final static int ifxStatusCode3040Error = 3040;
	public final static int ifxStatusCode3080Error = 3080;
	public final static int ifxStatusCode3320Error = 3320;
	public final static int ifxStatusCode3380Error = 3380;
	public final static int ifxStatusCode3520Error = 3520;
	public final static int ifxStatusCode3560Error = 3560;
	public final static int ifxStatusCode3580Error = 3580;
	public final static int ifxStatusCode3600Info =  3600;
	public final static int ifxStatusCode3610Error = 3610;
	public final static int ifxStatusCode3620Error = 3620;
	public final static int ifxStatusCode3630Error = 3630;
	public final static int ifxStatusCode3640Error = 3640;
	public final static int ifxStatusCode3650Error = 3650;
	public final static int ifxStatusCode3700Error = 3700;
	public final static int ifxStatusCode3730Error = 3730;
	public final static int ifxStatusCode3740Error = 3740;
	public final static int ifxStatusCode3750Error = 3750;
	public final static int ifxStatusCode3760Error = 3760;
	public final static int ifxStatusCode3880Info =  3880;
	public final static int ifxStatusCode3890Error = 3890;
	public final static int ifxStatusCode3950Error = 3950;
	public final static int ifxStatusCode4040Error = 4040;
	public final static int ifxStatusCode4050Error = 4050;
	public final static int ifxStatusCode4070Info =  4070;
	public final static int ifxStatusCode4080Warn =  4080;
	public final static int ifxStatusCode5000Warn =  5000;
	public final static int ifxStatusCode5010Warn =  5010;
	public final static int ifxStatusCode5020Error = 5020;
	public final static int ifxStatusCode5030Warn =  5030;
	public final static int ifxStatusCode5110Error = 5110;
	public final static int ifxStatusCode5130Error = 5130;
	public final static int ifxStatusCode6130Error = 6130;
	public final static int ifxStatusCode6140Error = 6140;
	public final static int ifxStatusCode6145Error = 6145;
	public final static int ifxStatusCode6150Error = 6150;
	public final static int ifxStatusCode6510Error = 6510;

	
	public final static String ifxStatusSeveriryInfo = "Info";
	public final static String ifxStatusSeveriryWarn = "Warn";
	public final static String ifxStatusSeveriryError = "Error";
	
	public static Map<Integer, String> statusCodeSeverityMap = createStatusCodeSeverityMap();
	
	private static Map<Integer, String> createStatusCodeSeverityMap() {
        Map<Integer, String> result = new HashMap<Integer, String>();
        result.put(ifxStatusCode0000Info, ifxStatusSeveriryInfo);
    	result.put(ifxStatusCode0005Warn, ifxStatusSeveriryWarn);
    	result.put(ifxStatusCode0100Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode0200Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode0300Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode0400Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode0500Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode0600Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode0700Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode0750Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode0900Warn,  ifxStatusSeveriryWarn);
    	result.put(ifxStatusCode1000Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode1030Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode1040Warn,  ifxStatusSeveriryWarn);
    	result.put(ifxStatusCode1045Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode1070Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode1090Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2365Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2395Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2550Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2800Warn,  ifxStatusSeveriryWarn);
    	result.put(ifxStatusCode2810Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2820Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2830Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3060Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3800Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3920Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3930Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode4000Warn,  ifxStatusSeveriryWarn);
    	result.put(ifxStatusCode4090Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode5100Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode6000Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode6010Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode6020Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode6030Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode6040Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode6050Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode6060Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode6090Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode6100Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode6110Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode6120Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode6154Warn,  ifxStatusSeveriryWarn);
    	result.put(ifxStatusCode6155Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode6160Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode6170Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode6180Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode6190Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode6310Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode6410Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode0800Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode0810Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode1050Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode1060Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode1080Warn,  ifxStatusSeveriryWarn);
    	result.put(ifxStatusCode1100Warn,  ifxStatusSeveriryWarn);
    	result.put(ifxStatusCode1120Info,  ifxStatusSeveriryInfo);
    	result.put(ifxStatusCode1140Warn,  ifxStatusSeveriryWarn);
    	result.put(ifxStatusCode1160Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode1220Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode1240Warn,  ifxStatusSeveriryWarn);
    	result.put(ifxStatusCode1260Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode1280Warn,  ifxStatusSeveriryWarn);
    	result.put(ifxStatusCode1500Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode1700Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode1740Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode1760Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode1880Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode1881Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode1900Warn,  ifxStatusSeveriryWarn);
    	result.put(ifxStatusCode2020Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2030Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2050Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2080Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2120Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2130Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2140Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2150Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2160Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2170Warn,  ifxStatusSeveriryWarn);
    	result.put(ifxStatusCode2180Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2190Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2200Warn,  ifxStatusSeveriryWarn);
    	result.put(ifxStatusCode2210Warn,  ifxStatusSeveriryWarn);
    	result.put(ifxStatusCode2320Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2350Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2370Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2380Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2381Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2400Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2401Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2420Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2500Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2510Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2520Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2530Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2540Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2720Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2740Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2900Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2910Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2920Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode2940Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3000Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3020Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3040Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3080Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3320Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3380Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3520Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3560Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3580Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3600Info,  ifxStatusSeveriryInfo);
    	result.put(ifxStatusCode3610Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3620Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3630Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3640Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3650Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3700Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3730Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3740Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3750Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3760Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3880Info,  ifxStatusSeveriryInfo);
    	result.put(ifxStatusCode3890Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode3950Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode4040Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode4050Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode4070Info,  ifxStatusSeveriryInfo);
    	result.put(ifxStatusCode4080Warn,  ifxStatusSeveriryWarn);
    	result.put(ifxStatusCode5000Warn,  ifxStatusSeveriryWarn);
    	result.put(ifxStatusCode5010Warn,  ifxStatusSeveriryWarn);
    	result.put(ifxStatusCode5020Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode5030Warn,  ifxStatusSeveriryWarn);
    	result.put(ifxStatusCode5110Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode5130Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode6130Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode6140Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode6145Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode6150Error, ifxStatusSeveriryError);
    	result.put(ifxStatusCode6510Error, ifxStatusSeveriryError);
        return Collections.unmodifiableMap(result);
    }
	
	public static Map<String, String> serviceLevelsMap = createServiceLevelsMap();
	
	private static Map<String, String> createServiceLevelsMap() {
        Map<String, String> result = new HashMap<String, String>();
        result.put("CCTGPRVG", "Priviledged");
        result.put("CCTGORDN", "Ordinary");
        result.put("CCTG5001", "Level1");
        result.put("CCTG5002", "Level2");
        result.put("CCTG5003", "Level3");
        result.put("CCTG5004", "Level4");
        result.put("CCTG5005", "Level5");
        return Collections.unmodifiableMap(result);
    }
	
	
	public static final String yotaPEWAccount = "PEW";
	public static final String yotaNEWAccount = "NEW";
	public static final String yotaDDAAccount = "DDA";
	public static final String yotaAIAAccount = "AIA";
	
	public static final String bpcPEWAccount = "ACTPPEW";
	public static final String bpcNEWAccount = "ACTPNEW";
	public static final String bpcDDAAccount = "ACTP0120";
	
	public static Map<String, String> accTypeMap = createAccTypeMapMap();
	
	private static Map<String, String> createAccTypeMapMap() {
        Map<String, String> result = new HashMap<String, String>();
        result.put(bpcPEWAccount, yotaPEWAccount);             
        result.put(bpcNEWAccount, yotaNEWAccount);
        result.put(bpcDDAAccount, yotaDDAAccount);        
        return Collections.unmodifiableMap(result);
    }
	
	public static Map<String, String> xferStatusMap = createXferStatusMap();
	
	public static final String bpcRespCodeOk = "RESP0001";
	public static final String bpcRespCodeError = "RESP0002";
	public static final String bpcRespCodeNotFound = "RESP0008";
	public static final String bpcRespCodeCannotBeReversed = "RESP0009";
	public static final String bpcRespCodeCancelNotAllowed = "RESP0041";
	
	private static Map<String, String> createXferStatusMap() {
        Map<String, String> result = new HashMap<String, String>();
        result.put(bpcRespCodeOk, ifxXferStatusCodeCancelled);             
        result.put(bpcRespCodeError, ifxXferStatusCodeRejected);
        result.put(bpcRespCodeNotFound, ifxXferStatusCodeRejected);
        result.put(bpcRespCodeCannotBeReversed, ifxXferStatusCodeRejected);
        result.put(bpcRespCodeCancelNotAllowed, ifxXferStatusCodeRejected);
        return Collections.unmodifiableMap(result);
    }
	
	public static Map<String, String> customerStatusMap = createCustomerStatusMap();
	private static Map<String, String> createCustomerStatusMap() {
        Map<String, String> result = new HashMap<String, String>();
        result.put("CUST5001", ifxPartyStatusValid);             
        result.put("CUST5002", ifxPartyStatusDeleted);
        result.put("CUST5003", ifxPartyStatusNotAvail);
        return Collections.unmodifiableMap(result);
    }
	
	public static final String ifxPmoBic = "BIC";
	public static final String ifxPmoBankName = "BankName";
	public static final String ifxPmoBankBranchName = "BankBranchName";
	public static final String ifxPmoBkPtyId = "BkPtyId";
	public static final String ifxPmoTaxIdNb = "TaxIdNb";
	public static final String ifxPmoBankCorrAcct = "BankCorrAcct";
	
	public static final String bpcPmoBic = "CBS_TRANSFER_BIC";
	public static final String bpcPmoBankName = "CBS_TRANSFER_BANK_NAME";
	public static final String bpcPmoBankBranchName = "CBS_TRANSFER_BANK_BRANCH_NAME";
	public static final String bpcPmoBkPtyId = "CBS_TRANSFER_RECIPIENT_ACCOUNT";
	public static final String bpcPmoTaxIdNb = "CBS_TRANSFER_RECIPIENT_TAX_ID";
	public static final String bpcPmoPayerName = "CBS_TRANSFER_PAYER_NAME";
	public static final String bpcPmoBankCorrAcct = "CBS_TRANSFER_BANK_CORR_ACC";
	
	public static final String bpcPmoMemo = "CBS_TRANSFER_PAYMENT_PURPOSE";
	public static final String bpcPmoRecipientName = "CBS_TRANSFER_RECIPIENT_NAME";
	public static final String bpcPmoRecipientIdentType = "TRANSFER_RECIPIENT_IDENTIF_TYPE";
	public static final String bpcPmoRecipientIdentValue = "TRANSFER_RECIPIENT_IDENTIFIER";
	
	public static Map<String, String> pmoParamsMap = createPmoParamsMap();
	private static Map<String, String> createPmoParamsMap() {
        Map<String, String> result = new HashMap<String, String>();
        result.put(bpcPmoBic, ifxPmoBic);             
        result.put(bpcPmoBankName, ifxPmoBankName);
        result.put(bpcPmoBankBranchName, ifxPmoBankBranchName);
        result.put(bpcPmoBkPtyId, ifxPmoBkPtyId);
        result.put(bpcPmoTaxIdNb, ifxPmoTaxIdNb);
        result.put(bpcPmoBankCorrAcct, ifxPmoBankCorrAcct);
        return Collections.unmodifiableMap(result);
    }
	
	public static Map<String, String> operTypesMap = createOperTypesMap();
	private static Map<String, String> createOperTypesMap() {
        Map<String, String> result = new HashMap<String, String>();
        result.put("Transfer", "OPTP0011");             
        result.put("Payment", "OPTP0060");
        return Collections.unmodifiableMap(result);
    }
	public static Map<String, String> operTypesReverseMap = createOperTypesReverseMap();
	private static Map<String, String> createOperTypesReverseMap() {
        Map<String, String> result = new HashMap<String, String>();
        result.put("OPTP0011", "Transfer");             
        result.put("OPTP0060", "Payment");
        return Collections.unmodifiableMap(result);
    }
	
	public static Map<String, String> operStatusesMap = createOperStatusesMap();
	private static Map<String, String> createOperStatusesMap() {
        Map<String, String> result = new HashMap<String, String>();
        result.put("Transfer", "OPTP0011");             
        result.put("Payment", "OPTP0060");
        return Collections.unmodifiableMap(result);
    }
	public static Map<String, String> operStatusesReverseMap = createOperStatusesReverseMap();
	private static Map<String, String> createOperStatusesReverseMap() {
        Map<String, String> result = new HashMap<String, String>();
        result.put("AUST0401", ifxTrnStatusCodeCancelled);             
        result.put("AUST0402", ifxTrnStatusCodeCancelled);
        result.put("AUST0101", ifxTrnStatusCodePosted);
        result.put("AUST0107", ifxTrnStatusCodePosted);
        result.put("AUST0400", ifxTrnStatusCodePosted);
        result.put("AUST0800", ifxTrnStatusCodeOnHold);
        return Collections.unmodifiableMap(result);
    }
}
