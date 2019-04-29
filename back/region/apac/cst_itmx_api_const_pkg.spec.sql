create or replace package cst_itmx_api_const_pkg as
/*********************************************************
*  ITMX API constants <br />
*  Created by Zakharov M.(m.zakharov@bpcbt.com)  at 17.12.2018 <br />
*  Module: CST_ITMX_API_CONST_PKG <br />
*  @headcom
**********************************************************/

MODULE_CODE_ITMX                constant com_api_type_pkg.t_module_code := 'ITM';

TC_RETURNED_CREDIT              constant varchar2(2) := '01';
TC_RETURNED_DEBIT               constant varchar2(2) := '02';
TC_RETURNED_NONFINANCIAL        constant varchar2(2) := '03';
TC_SALES                        constant varchar2(2) := '05';
TC_VOUCHER                      constant varchar2(2) := '06';
TC_CASH                         constant varchar2(2) := '07';
TC_SALES_CHARGEBACK             constant varchar2(2) := '15';
TC_VOUCHER_CHARGEBACK           constant varchar2(2) := '16';
TC_CASH_CHARGEBACK              constant varchar2(2) := '17';
TC_SALES_REVERSAL               constant varchar2(2) := '25';
TC_VOUCHER_REVERSAL             constant varchar2(2) := '26';
TC_CASH_REVERSAL                constant varchar2(2) := '27';
TC_MULTIPURPOSE_MESSAGE         constant varchar2(2) := '33';
TC_SALES_CHARGEBACK_REV         constant varchar2(2) := '35';
TC_VOUCHER_CHARGEBACK_REV       constant varchar2(2) := '36';
TC_CASH_CHARGEBACK_REV          constant varchar2(2) := '37';
TC_MONEY_TRANSFER               constant varchar2(2) := '09';
TC_MONEY_TRANSFER2              constant varchar2(2) := '19';
TC_FEE_COLLECTION               constant varchar2(2) := '10';
TC_FUNDS_DISBURSEMENT           constant varchar2(2) := '20';
TC_GENERAL_DELIVERY_REPORT      constant varchar2(2) := '45';
TC_REJECTED                     constant varchar2(2) := '44';
TC_MEMBER_SETTLEMENT_DATA       constant varchar2(2) := '46';
TC_REQUEST_ORIGINAL_PAPER       constant varchar2(2) := '51';
TC_REQUEST_FOR_PHOTOCOPY        constant varchar2(2) := '52';
TC_MAILING_CONFIRMATION         constant varchar2(2) := '53';
TC_CURRENCY_RATE_UPDATE         constant varchar2(2) := '56';
TC_FRAUD_ADVICE                 constant varchar2(2) := '40';
TC_FILE_HEADER                  constant varchar2(2) := '90';
TC_BATCH_TRAILER                constant varchar2(2) := '91';
TC_FILE_TRAILER                 constant varchar2(2) := '92';

TCQ_AFT                         constant varchar2(2) := '1';
TCQ_OCT                         constant varchar2(2) := '2';

FILE_TYPE_CLEARING              constant com_api_type_pkg.t_dict_value := 'FLTPCLRG';

CMID                            constant com_api_type_pkg.t_name := 'CST_ITMX_ACQ_PROC_BIN';
ACQ_BUSINESS_ID                 constant com_api_type_pkg.t_name := 'CST_ITMX_ACQ_BUSINESS_ID';

ITMX_SECURITY_CODE              constant com_api_type_pkg.t_name := 'CST_ITMX_SECURITY_CODE';

ITMX_PARENT_NETWORK             constant com_api_type_pkg.t_name := 'CST_ITMX_PARENT_NETWORK';

ITMX_ACQ_PROC_BIN_HEADER        constant com_api_type_pkg.t_name := 'CST_ITMX_ACQ_PROC_BIN_HEADER';
ITMX_BATCH_NUMBER_SHIFT         constant com_api_type_pkg.t_name := 'CST_ITMX_BATCH_NUMBER_SHIFT';

MCC_CASH                        constant com_api_type_pkg.t_mcc        := '6010';
MCC_ATM                         constant com_api_type_pkg.t_mcc        := '6011';
MCC_WIRE_TRANSFER_MONEY         constant com_api_type_pkg.t_mcc        := '4829';
MCC_FIN_INSTITUTIONS            constant com_api_type_pkg.t_mcc        := '6012';
MCC_BETTING_CASINO_GAMBLING     constant com_api_type_pkg.t_mcc        := '7995';

TAG_REF_SENDER_ACCOUNT          constant com_api_type_pkg.t_name := 'DF8608';
TAG_REF_SENDER_STREET           constant com_api_type_pkg.t_name := 'SENDER_STREET';
TAG_REF_SENDER_CITY             constant com_api_type_pkg.t_name := 'SENDER_CITY';
TAG_REF_SENDER_COUNTRY          constant com_api_type_pkg.t_name := 'SENDER_COUNTRY';

ITMX_REGION_ASIA_PACIFIC        constant com_api_type_pkg.t_name := 'AP';

TAG_BUSINESS_APPLICATION_ID     constant com_api_type_pkg.t_short_id := 55; -- DF8A24 Business Application Identifier

-- TCR3
INDUSTRY_SPEC_DATA_CREDIT_FUND  constant com_api_type_pkg.t_byte_char := 'CR';
INDUSTRY_SPEC_DATA_PASS_ITINER  constant com_api_type_pkg.t_byte_char := 'AI';

TAG_PASS_ITINER_PASSENGER_NAME  constant com_api_type_pkg.t_short_id := 35401; -- DF8A49  Passenger Itinerary. Passenger Name
TAG_PASS_ITINER_DEPARTURE_DATE  constant com_api_type_pkg.t_short_id := 35402; -- DF8A4A  Passenger Itinerary. Departure Date (MMDDYY)
TAG_PASS_ITINER_ORIG_CITY_AIR   constant com_api_type_pkg.t_short_id := 35403; -- DF8A4B  Passenger Itinerary. Origination City/Airport Code
TAG_PASS_ITINER_CARRIER_CODE1   constant com_api_type_pkg.t_short_id := 35404; -- DF8A4C  Passenger Itinerary. Trip Leg 1. Carrier Code
TAG_PASS_ITINER_SERVICE_CLASS1  constant com_api_type_pkg.t_short_id := 35405; -- DF8A4D  Passenger Itinerary. Trip Leg 1. Service Class
TAG_PASS_ITINER_STOP_OVR_CODE1  constant com_api_type_pkg.t_short_id := 35406; -- DF8A4E  Passenger Itinerary. Trip Leg 1. Stop-Over Code
TAG_PASS_ITINER_DEST_CITY_AIR1  constant com_api_type_pkg.t_short_id := 35407; -- DF8A4F  Passenger Itinerary. Trip Leg 1. Destination City/Airport Code
TAG_PASS_ITINER_CARRIER_CODE2   constant com_api_type_pkg.t_short_id := 35408; -- DF8A50  Passenger Itinerary. Trip Leg 2. Carrier Code
TAG_PASS_ITINER_SERVICE_CLASS2  constant com_api_type_pkg.t_short_id := 35409; -- DF8A51  Passenger Itinerary. Trip Leg 2. Service Class
TAG_PASS_ITINER_STOP_OVR_CODE2  constant com_api_type_pkg.t_short_id := 35410; -- DF8A52  Passenger Itinerary. Trip Leg 2. Stop-Over Code
TAG_PASS_ITINER_DEST_CITY_AIR2  constant com_api_type_pkg.t_short_id := 35411; -- DF8A53  Passenger Itinerary. Trip Leg 2. Destination City/Airport Code
TAG_PASS_ITINER_CARRIER_CODE3   constant com_api_type_pkg.t_short_id := 35412; -- DF8A54  Passenger Itinerary. Trip Leg 3. Carrier Code
TAG_PASS_ITINER_SERVICE_CLASS3  constant com_api_type_pkg.t_short_id := 35413; -- DF8A55  Passenger Itinerary. Trip Leg 3. Service Class
TAG_PASS_ITINER_STOP_OVR_CODE3  constant com_api_type_pkg.t_short_id := 35414; -- DF8A56  Passenger Itinerary. Trip Leg 3. Stop-Over Code
TAG_PASS_ITINER_DEST_CITY_AIR3  constant com_api_type_pkg.t_short_id := 35415; -- DF8A57  Passenger Itinerary. Trip Leg 3. Destination City/Airport Code
TAG_PASS_ITINER_CARRIER_CODE4   constant com_api_type_pkg.t_short_id := 35416; -- DF8A58  Passenger Itinerary. Trip Leg 4. Carrier Code
TAG_PASS_ITINER_SERVICE_CLASS4  constant com_api_type_pkg.t_short_id := 35417; -- DF8A59  Passenger Itinerary. Trip Leg 4. Service Class
TAG_PASS_ITINER_STOP_OVR_CODE4  constant com_api_type_pkg.t_short_id := 35418; -- DF8A5A  Passenger Itinerary. Trip Leg 4. Stop-Over Code
TAG_PASS_ITINER_DEST_CITY_AIR4  constant com_api_type_pkg.t_short_id := 35419; -- DF8A5B  Passenger Itinerary. Trip Leg 4. Destination City/Airport Code
TAG_PASS_ITINER_TRAV_AGEN_CODE  constant com_api_type_pkg.t_short_id := 35420; -- DF8A5C  Passenger Itinerary. Travel Agency Code   
TAG_PASS_ITINER_TRAV_AGEN_NAME  constant com_api_type_pkg.t_short_id := 35421; -- DF8A5D  Passenger Itinerary. Travel Agency Name
TAG_PASS_ITINER_R_TICKET_INDIC  constant com_api_type_pkg.t_short_id := 35422; -- DF8A5E  Passenger Itinerary. Restricted Ticket Indicator
TAG_PASS_ITINER_FARE_BAS_CODE1  constant com_api_type_pkg.t_short_id := 35389; -- DF8A3D  Passenger Itinerary. Fare Basis Code - Leg 1
TAG_PASS_ITINER_FARE_BAS_CODE2  constant com_api_type_pkg.t_short_id := 35390; -- DF8A3E  Passenger Itinerary. Fare Basis Code - Leg 2
TAG_PASS_ITINER_FARE_BAS_CODE3  constant com_api_type_pkg.t_short_id := 35391; -- DF8A3F  Passenger Itinerary. Fare Basis Code - Leg 3
TAG_PASS_ITINER_FARE_BAS_CODE4  constant com_api_type_pkg.t_short_id := 35392; -- DF8A40  Passenger Itinerary. Fare Basis Code - Leg 4    
TAG_PASS_ITINER_COMP_RESRV_SYS  constant com_api_type_pkg.t_short_id := 35393; -- DF8A41  Passenger Itinerary. Computerized Reservation System    
TAG_PASS_ITINER_FLIGHT_NUMBER1  constant com_api_type_pkg.t_short_id := 35394; -- DF8A42  Passenger Itinerary. Flight Number - Leg 1  
TAG_PASS_ITINER_FLIGHT_NUMBER2  constant com_api_type_pkg.t_short_id := 35395; -- DF8A43  Passenger Itinerary. Flight Number - Leg 2
TAG_PASS_ITINER_FLIGHT_NUMBER3  constant com_api_type_pkg.t_short_id := 35396; -- DF8A44  Passenger Itinerary. Flight Number - Leg 3  
TAG_PASS_ITINER_FLIGHT_NUMBER4  constant com_api_type_pkg.t_short_id := 35397; -- DF8A45  Passenger Itinerary. Flight Number - Leg 4  
TAG_PASS_ITINER_CRD_RSN_INDIC   constant com_api_type_pkg.t_short_id := 35398; -- DF8A46  Passenger Itinerary. Credit Reason Indicator 
TAG_PASS_ITINER_TIC_CHN_INDIC   constant com_api_type_pkg.t_short_id := 35399; -- DF8A47  Passenger Itinerary. Ticket Change Indicator

g_default_charset               com_api_type_pkg.t_oracle_name;
function init_default_charset return com_api_type_pkg.t_oracle_name;

end;
/
