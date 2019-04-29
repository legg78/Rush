create table mup_fin (
    id                  number(16) not null
    , split_hash        number(4)
    , inst_id           number(4)
    , network_id        number(4)
    , file_id           number(8)
    , status            varchar2(8)
    , impact            number(1)
    , is_incoming       number(1)
    , is_reversal       number(1)
    , is_rejected       number(1)
    , is_fpd_matched    number(1)
    , is_fsum_matched   number(1)
    , dispute_id        number(16)
    , dispute_rn        number(16)
    , fpd_id            number(16)
    , fsum_id           number(16)
    , reject_id         number(16)
    , mti               varchar2(4)
    , de024             varchar2(3)
    , de002             varchar2(19)
    , de003_1           varchar2(2)
    , de003_2           varchar2(2)
    , de003_3           varchar2(2)
    , de004             number(12)
    , de005             number(12)
    , de006             number(12)
    , de009             varchar2(11)
    , de010             varchar2(11)
    , de012             date
    , de014             date
    , de022_1           varchar2(1)
    , de022_2           varchar2(1)
    , de022_3           varchar2(1)
    , de022_4           varchar2(1)
    , de022_5           varchar2(1)
    , de022_6           varchar2(2)
    , de022_8           varchar2(1)
    , de022_9           varchar2(1)
    , de022_10          varchar2(1)
    , de022_11          varchar2(1)
    , de022_12          varchar2(1)
    , de023             number(3)
    , de025             varchar2(4)
    , de026             varchar2(4)
    , de030_1           number(12)
    , de030_2           number(12)
    , de031             varchar2(23)
    , de032             varchar2(11)
    , de033             varchar2(11)
    , de037             varchar2(12)
    , de038             varchar2(6)
    , de040             varchar2(3)
    , de041             varchar2(8)
    , de042             varchar2(15)
    , de043_1           varchar2(99)
    , de043_2           varchar2(99)
    , de043_3           varchar2(99)
    , de043_4           varchar2(99)
    , de043_5           varchar2(3)
    , de043_6           varchar2(3)
    , de049             varchar2(3)
    , de050             varchar2(3)
    , de051             varchar2(3)
    , de054             varchar2(120)
    , de055             raw(255)
    , de063             varchar2(16)
    , de071             number(8)
    , de072             varchar2(999)
    , de073             date
    , de093             varchar2(11)
    , de094             varchar2(11)
    , de095             varchar2(10)
    , de100             varchar2(11)
    , p0025_1           varchar2(1)
    , p0025_2           date
    , p0137             varchar2(20)
    , p0146             varchar2(432)
    , p0146_net         number(12)
    , p0148             varchar2(60)
    , p0149_1           varchar2(3)
    , p0149_2           varchar2(3)
    , p0165             varchar2(30)
    , p0190             varchar2(6)
    , p0198             varchar2(2)
    , p0228             number(1)
    , p0261             varchar2(11)
    , p0262             number(1)
    , p0265             varchar2(110)
    , p0266             varchar2(127)
    , p0267             varchar2(127)
    , p0268_1           number(12)
    , p0268_2           varchar2(3)
    , p0375             varchar2(50)
    , p2002             varchar2(19)
    , p2063             varchar2(16)
    , p2158_1           varchar2(4)
    , p2158_2           date
    , p2158_3           varchar2(2)
    , p2158_4           varchar2(1)
    , p2158_5           varchar2(3)
    , p2158_6           varchar2(2)
    , p2159_1           varchar2(11)
    , p2159_2           varchar2(1)
    , p2159_3           varchar2(10)
    , p2159_4           date
    , p2159_5           varchar2(2)
    , p2159_6           date
    , emv_9f26          varchar2(16)
    , emv_9f27          varchar2(2)
    , emv_9f10          varchar2(64)
    , emv_9f37          varchar2(8)
    , emv_9f36          varchar2(4)
    , emv_95            varchar2(10)   
    , emv_9a            date 
    , emv_9c            number(2)
    , emv_9f02          number(12)
    , emv_5f2a          number(4)
    , emv_82            varchar2(4)
    , emv_9f1a          number(4)
    , emv_9f03          number(12)   
    , emv_9f34          varchar2(6)
    , emv_9f33          varchar2(6)
    , emv_9f35          number(2)
    , emv_9f1e          varchar2(16)    
    , emv_9f53          varchar2(2)
    , emv_84            varchar2(32)
    , emv_9f09          varchar2(4)
    , emv_9f41          number(8)
    , emv_9f4c          varchar2(16)       
    , emv_91            varchar2(32)
    , emv_8A            varchar2(4)
    , emv_71            varchar2(255)
    , emv_72            varchar2(255)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/
comment on table mup_fin is 'MUP financial messages'
/
comment on column mup_fin.id is 'Identifier'
/
comment on column mup_fin.split_hash is 'Hash value to split further processing'
/
comment on column mup_fin.status is 'Clearing message status'
/
comment on column mup_fin.inst_id is 'Institution identifier'
/
comment on column mup_fin.network_id is 'Network identifier'
/
comment on column mup_fin.file_id is 'Logical file identifier'
/
comment on column mup_fin.is_incoming is 'Incoming indicator'
/
comment on column mup_fin.is_reversal is 'Reversal indicator'
/
comment on column mup_fin.is_rejected is 'Rejected indicator'
/
comment on column mup_fin.reject_id is 'Reject message identifier'
/
comment on column mup_fin.is_fpd_matched is 'Financial position detail matched indicator'
/
comment on column mup_fin.fpd_id is 'Financial position detail message identifier'
/
comment on column mup_fin.dispute_id is 'Dispute identifier'
/
comment on column mup_fin.dispute_rn is 'Dispute reference number identifier'
/
comment on column mup_fin.impact is 'Message impact'
/
comment on column mup_fin.mti is 'The Message Type Identifier (MTI) is a four-digit numeric field describing the type of message being interchanged'
/
comment on column mup_fin.de024 is 'DE 24 (Function Code) indicates a messages specific purpose.'
/
comment on column mup_fin.de002 is 'DE 2 (Primary Account Number [PAN]) is a series of digits that identify a customer account or relationship.'
/
comment on column mup_fin.de003_1 is 'Cardholder Transaction Type'
/
comment on column mup_fin.de003_2 is 'Cardholder "From" Account Type Code'
/
comment on column mup_fin.de003_3 is 'Cardholder "To" Account Type Code'
/
comment on column mup_fin.de004 is 'Amount, Transaction'
/
comment on column mup_fin.de005 is 'Amount, Reconciliation'
/
comment on column mup_fin.de006 is 'Amount, Cardholder Billing'
/
comment on column mup_fin.de009 is 'Conversion Rate, Reconciliation'
/
comment on column mup_fin.de010 is 'Conversion Rate, Cardholder Billing'
/
comment on column mup_fin.de012 is 'Date and Time, Local Transaction'
/
comment on column mup_fin.de014 is 'DE 14 (Date, Expiration) specifies the year and month after which a card expires.'
/
comment on column mup_fin.de022_1 is 'Terminal Data: Card Data Input Capability'
/
comment on column mup_fin.de022_2 is 'Terminal Data: Cardholder Authentication Capability'
/
comment on column mup_fin.de022_3 is 'Terminal Data: Card Capture Capability'
/
comment on column mup_fin.de022_4 is 'Terminal Operating Environment'
/
comment on column mup_fin.de022_5 is 'Cardholder Present Data'
/
comment on column mup_fin.de022_6 is 'Card Data: Input Mode'
/
comment on column mup_fin.de022_8 is 'Cardholder Authentication Method'
/
comment on column mup_fin.de022_9 is 'Terminal Type'
/
comment on column mup_fin.de022_10 is 'Cardholder Activated Terminal Level'
/
comment on column mup_fin.de022_11 is 'Electronic Commerce  Indicator'
/
comment on column mup_fin.de022_12 is 'PIN Capture Capability'
/
comment on column mup_fin.de023 is 'Card Sequence Number'
/
comment on column mup_fin.de025 is 'Message Reason Code'
/
comment on column mup_fin.de026 is 'Card Acceptor Business Code (MCC)'
/
comment on column mup_fin.de030_1 is 'Original Amount, Transaction'
/
comment on column mup_fin.de030_2 is 'Original Amount, Reconciliation'
/
comment on column mup_fin.de031 is 'Acquirer Reference Data'
/
comment on column mup_fin.de032 is 'Acquiring Institution ID Code'
/
comment on column mup_fin.de033 is 'Forwarding Institution ID Code'
/
comment on column mup_fin.de037 is 'Retrieval Reference Number'
/
comment on column mup_fin.de038 is 'Approval Code'
/
comment on column mup_fin.de040 is 'Service Code'
/
comment on column mup_fin.de041 is 'Card Acceptor Terminal ID'
/
comment on column mup_fin.de042 is 'Card Acceptor ID Code'
/
comment on column mup_fin.de043_1 is 'Card Acceptor Name'
/
comment on column mup_fin.de043_2 is 'Card Acceptor Street Address'
/
comment on column mup_fin.de043_3 is 'Card Acceptor City'
/
comment on column mup_fin.de043_4 is 'Card Acceptor Postal (ZIP) Code'
/
comment on column mup_fin.de043_5 is 'Card Acceptor State, Province, or Region Code'
/
comment on column mup_fin.de043_6 is 'Card Acceptor Country Code'
/
comment on column mup_fin.de049 is 'Currency Code, Transaction'
/
comment on column mup_fin.de050 is 'Currency Code, Reconciliation'
/
comment on column mup_fin.de051 is 'Currency Code, Cardholder Billing'
/
comment on column mup_fin.de054 is 'DE 54 (Amounts, Additional) are additional amounts and related account data for which specific data elements have not been defined'
/
comment on column mup_fin.de055 is 'Integrated Circuit Card (ICC) System-Related Data'
/
comment on column mup_fin.de063 is 'Transaction Life Cycle ID'
/
comment on column mup_fin.de071 is 'Message Number'
/
comment on column mup_fin.de072 is 'Data Record'
/
comment on column mup_fin.de073 is 'Date, Action'
/
comment on column mup_fin.de093 is 'Transaction Destination Institution ID Code'
/
comment on column mup_fin.de094 is 'Transaction Originator Institution ID Code'
/
comment on column mup_fin.de095 is 'Card Issuer Reference Data'
/
comment on column mup_fin.de100 is 'Receiving Institution ID Code'
/
comment on column mup_fin.p0025_1 is 'Message Reversal Indicator'
/
comment on column mup_fin.p0025_2 is 'Central Site Processing Date of Original Message'
/
comment on column mup_fin.p0137 is 'Fee Collection Control Number'
/
comment on column mup_fin.p0146 is 'Amounts, Transaction Fee'
/
comment on column mup_fin.p0146_net is 'Net value of p0146 Amounts, Transaction Fee'
/
comment on column mup_fin.p0148 is 'Currency Exponents'
/
comment on column mup_fin.p0149_1 is 'Currency Code, Original Transaction Amount'
/
comment on column mup_fin.p0149_2 is 'Currency Code, Original Reconciliation Amount'
/
comment on column mup_fin.p2002 is 'Payment Transaction Primary Account Number'
/
comment on column mup_fin.p2063 is 'Funding Transaction Reference Number'
/
comment on column mup_fin.p2158_1 is 'Network ID'
/
comment on column mup_fin.p2158_2 is 'Reconciliation Date'
/
comment on column mup_fin.p2158_3 is 'Reconciliation Cycle'
/
comment on column mup_fin.p2158_4 is 'Reconciliation Level'
/
comment on column mup_fin.p2158_5 is 'Product ID'
/
comment on column mup_fin.p2158_6 is 'Interchange Fee Descriptor  IFD'
/
comment on column mup_fin.p2159_1 is 'Settlement Service Transfer Agent ID Code'
/
comment on column mup_fin.p2159_2 is 'Settlement Service Level Code'
/
comment on column mup_fin.p2159_3 is 'Settlement Service ID Code'
/
comment on column mup_fin.p2159_4 is 'Reconciliation Date'
/
comment on column mup_fin.p2159_5 is 'Reconciliation Cycle'
/
comment on column mup_fin.p2159_6 is 'Settlement Date'
/
comment on column mup_fin.p0165 is 'Settlement Indicator'
/
comment on column mup_fin.p0190 is 'Partner ID Code'
/
comment on column mup_fin.P0198 is 'Device Type'
/
comment on column mup_fin.p0228 is 'Retrieval Document Code'
/
comment on column mup_fin.p0261 is 'Risk Management Approval Code'
/
comment on column mup_fin.p0262 is 'Documentation Indicator'
/
comment on column mup_fin.p0265 is 'Initial Presentment/Fee Collection Data'
/
comment on column mup_fin.p0266 is 'First Chargeback/Fee Collection Return Data'
/
comment on column mup_fin.p0267 is 'Second Presentment/Fee Collection Resubmission Data'
/
comment on column mup_fin.p0268_1 is 'Amount, Partial Transaction'
/
comment on column mup_fin.p0268_2 is 'Currency Code, Partial Transaction'
/
comment on column mup_fin.p0375 is 'Member Reconciliation Indicator'
/
comment on column mup_fin.is_fsum_matched is 'File summary matched indicator'
/
comment on column mup_fin.fsum_id is 'File summary message identifier'
/
comment on column mup_fin.emv_9f26 is 'Application Cryptogram. Cryptogram returned by the ICC in response of the GENERATE AC command'
/
comment on column mup_fin.emv_9f27 is 'Cryptogram Information Data. Indicates the type of cryptogram and the actions to be performed by the terminal'
/
comment on column mup_fin.emv_9f10 is 'Issuer Application Data. Contains proprietary application data for transmission to the issuer in an online transaction'
/
comment on column mup_fin.emv_9f37 is 'Unpredictable Number. Value to provide variability and uniqueness to the generation of a cryptogram'
/
comment on column mup_fin.emv_9f36 is 'Application Transaction Counter (ATC)'
/
comment on column mup_fin.emv_95 is 'Terminal Verification Results. Status of the different functions as seen from the terminal'
/
comment on column mup_fin.emv_9a is 'Transaction Date. Local date that the transaction was authorised'
/
comment on column mup_fin.emv_9c is 'Transaction Type. Indicates the type of financial transaction, represented by the first two digits of ISO 8583:1987 Processing Code'
/
comment on column mup_fin.emv_9f02 is 'Amount, Authorised. Authorised amount of the transaction (excluding adjustments)'
/
comment on column mup_fin.emv_5f2a is 'Transaction Currency Code. Indicates the currency code of the transaction according to ISO 4217'
/
comment on column mup_fin.emv_82 is 'Application Interchange Profile. Indicates the capabilities of the card to support specific functions in the application'
/
comment on column mup_fin.emv_9f1a is 'Terminal Country Code. Indicates the country of the terminal, represented according to ISO 3166'
/
comment on column mup_fin.emv_9f03 is 'Amount, Other (Numeric). Secondary amount associated with the transaction representing a cashback amount'
/
comment on column mup_fin.emv_9f33 is 'Terminal Capabilities. Indicates the card data input, CVM, and security capabilities of the terminal'
/
comment on column mup_fin.emv_9f34 is 'CVM Results. Indicates the results of the last CVM performed'
/
comment on column mup_fin.emv_9f35 is 'Terminal Type. Indicates the environment of the terminal, its communications capability, and its operational control'
/
comment on column mup_fin.emv_9f53 is 'Transaction Category Code'
/
comment on column mup_fin.emv_9f1e is 'Interface Device (IFD) Serial Number. Unique and permanent serial number assigned to the IFD by the manufacturer'
/
comment on column mup_fin.emv_84 is 'Dedicated File (DF) Name. Identifies the name of the DF as described in ISO/IEC 7816-4'
/
comment on column mup_fin.emv_9f09 is 'Application Version Number. Version number assigned by the payment system for the application'
/
comment on column mup_fin.emv_9f41 is 'Transaction Sequence Counter. Counter maintained by the terminal that is incremented by one for each transaction'
/
comment on column mup_fin.emv_91 is 'Issuer Authentication Data'
/
comment on column mup_fin.emv_9f4c is 'ICC Dynamic Number'
/
comment on column mup_fin.emv_8a is 'Authorisation Response Code'
/
comment on column mup_fin.emv_71 is 'Issuer Script Template 1'
/
comment on column mup_fin.emv_72 is 'Issuer Script Template 2'
/
alter table mup_fin add (p0176 varchar2(6))
/
comment on column mup_fin.p0176 is 'Assigned Merchant ID'
/
alter table mup_fin add (p2072_1 varchar2(3))
/
comment on column mup_fin.p2072_1 is 'Symbol table pointer'
/
alter table mup_fin add (p2072_2 raw(100))
/
comment on column mup_fin.p2072_2 is 'Data record in alternative character set'
/
alter table mup_fin rename column de022_8 to de022_7
/
alter table mup_fin rename column de022_9 to de022_8
/
alter table mup_fin rename column de022_10 to de022_9
/
alter table mup_fin rename column de022_11 to de022_10
/
alter table mup_fin rename column de022_12 to de022_11
/
alter table mup_fin modify (p2072_2 raw(200))
/
alter table mup_fin add p2175_1 varchar(3)
/
comment on column mup_fin.p2175_1 is  'Symbol table pointer for url'
/
alter table mup_fin add p2175_2 raw(255)
/
comment on column mup_fin.p2175_2 is 'Alternate  Card  Acceptor URL'
/
alter table mup_fin add p2097_1 varchar2(3)
/
comment on column mup_fin.p2097_1 is 'Encoding for Text Message to Recipient'
/
alter table mup_fin add p2097_2 varchar2(200)
/
comment on column mup_fin.p2097_2 is 'Text Message to Recipient'
/
alter table mup_fin add is_collection number(1)
/
comment on column mup_fin.is_collection is 'Collection only flag'
/
alter table mup_fin add p2001_1 varchar2(1)
/
comment on column mup_fin.p2001_1 is 'Token Number Indicator'
/
alter table mup_fin add p2001_2 varchar2(19)
/
comment on column mup_fin.p2001_2 is 'Token Number'
/
alter table mup_fin add p2001_3 varchar2(4)
/
comment on column mup_fin.p2001_3 is 'Token Expiration Date'
/
alter table mup_fin add p2001_4 varchar2(2)
/
comment on column mup_fin.p2001_4 is 'Token Assurance Level'
/
alter table mup_fin add p2001_5 number(11)
/
comment on column mup_fin.p2001_5 is 'Token Requestor ID'
/
alter table mup_fin add p2001_6 number(2)
/
comment on column mup_fin.p2001_6 is 'Token Location Type'
/
alter table mup_fin add p2001_7 varchar2(29)
/
comment on column mup_fin.p2001_7 is 'Payment Account Reference (PAR)'
/
