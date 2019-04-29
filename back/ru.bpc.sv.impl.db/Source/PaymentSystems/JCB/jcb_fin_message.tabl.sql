create table jcb_fin_message (
    id                  number(16) not null
    , split_hash        number(4)
    , status            varchar2(8)
    , inst_id           number(4)
    , network_id        number(4)
    , file_id           number(8)
    , is_incoming       number(1)
    , is_reversal       number(1)
    , is_rejected       number(1)
    , reject_id         number(16)
    , dispute_id        number(16)
    , dispute_rn        number(16)
    , impact            number(1)
    , mti               varchar2(4)    
    , de002             varchar2(19)
    , de003_1           varchar2(2)
    , de003_2           varchar2(2)
    , de003_3           varchar2(2)
    , de004             number(12)
    , de005             number(12)
    , de006             number(12)
    , de009             varchar2(8)
    , de010             varchar2(8)
    , de012             date
    , de014             date
    , de016             date
    , de022_1           varchar2(1)
    , de022_2           varchar2(1)
    , de022_3           varchar2(1)
    , de022_4           varchar2(1)
    , de022_5           varchar2(1)
    , de022_6           varchar2(1)
    , de022_7           varchar2(1)
    , de022_8           varchar2(1)
    , de022_9           varchar2(1)
    , de022_10          varchar2(1)
    , de022_11          varchar2(1)
    , de022_12          varchar2(1)
    , de023             number(3)
    , de024             varchar2(3)
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
    , de043_1           varchar2(25)
    , de043_2           varchar2(45)
    , de043_3           varchar2(13)
    , de043_4           varchar2(10)
    , de043_5           varchar2(3)
    , de043_6           varchar2(3)
    , de049             varchar2(3)
    , de050             varchar2(3)
    , de051             varchar2(3)
    , de054             varchar2(20)
    , de055             raw(255)
    , de071             number(8)
    , de072             varchar2(999)
    , de093             varchar2(11)
    , de094             varchar2(11)
    , de100             varchar2(11)    
    , p3001             varchar2(3)
    , p3002             varchar2(60)
    , p3003             varchar2(25)
    , p3005             varchar2(570)
    , p3007_1           varchar2(1)
    , p3007_2           date
    , p3008             varchar2(287)
    , p3009             number(2)
    , p3011             varchar2(23)
    , p3012             varchar2(15)
    , p3013             varchar2(16)
    , p3014             varchar2(23)
    , p3201             varchar2(11)
    , p3202             varchar2(21)
    , p3203             varchar2(1)
    , p3205             varchar2(12)
    , p3206             varchar2(12)
    , p3207             varchar2(26)
    , p3208             varchar2(12)
    , p3209             number(6)
    , p3210             varchar2(26)
    , p3211             varchar2(12)
    , p3250             number(1)
    , p3251             varchar2(100)
    , p3302             varchar2(111)
    , emv_9f26          varchar2(16)
    , emv_9f02          number(12)
    , emv_9f27          varchar2(2)
    , emv_9f10          varchar2(64)
    , emv_9f36          varchar2(4)
    , emv_95            varchar2(10)
    , emv_82            varchar2(4)
    , emv_9a            date
    , emv_9c            number(2)
    , emv_9f37          varchar2(8)
    , emv_5f2a          number(4)
    , emv_9f33          varchar2(6)
    , emv_9f34          varchar2(6)
    , emv_9f1a          number(4)
    , emv_9f35          number(2)
    , emv_84            varchar2(32)
    , emv_9f09          varchar2(4)
    , emv_9f03          number(12)
    , emv_9f1e          varchar2(16)
    , emv_9f41          number(8)   
    , emv_4f            varchar2(16)  
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/
comment on table jcb_fin_message is 'JCB financial messages'
/
comment on column jcb_fin_message.id is 'Identifier'
/
comment on column jcb_fin_message.split_hash is 'Hash value to split further processing'
/
comment on column jcb_fin_message.status is 'Clearing message status'
/
comment on column jcb_fin_message.inst_id is 'Institution identifier'
/
comment on column jcb_fin_message.network_id is 'Network identifier'
/
comment on column jcb_fin_message.file_id is 'Logical file identifier'
/
comment on column jcb_fin_message.is_incoming is 'Incoming indicator'
/
comment on column jcb_fin_message.is_reversal is 'Reversal indicator'
/
comment on column jcb_fin_message.is_rejected is 'Rejected indicator'
/
comment on column jcb_fin_message.reject_id is 'Reject message identifier'
/
comment on column jcb_fin_message.dispute_id is 'Dispute identifier'
/
comment on column jcb_fin_message.dispute_rn is 'Dispute reference number identifier'
/
comment on column jcb_fin_message.impact is 'Message impact'
/
comment on column jcb_fin_message.mti is 'The Message Type Identifier (MTI) is a four-digit numeric field describing the type of message being interchanged'
/
comment on column jcb_fin_message.de002 is 'DE 2 (Primary Account Number [PAN]) is a series of digits that identify a customer account or relationship.'
/
comment on column jcb_fin_message.de003_1 is 'Cardholder Transaction Type'
/
comment on column jcb_fin_message.de003_2 is 'Cardholder "From" Account Type Code'
/
comment on column jcb_fin_message.de003_3 is 'Cardholder "To" Account Type Code'
/
comment on column jcb_fin_message.de004 is 'Amount, Transaction'
/
comment on column jcb_fin_message.de005 is 'Amount, Reconciliation (Settlement)'
/
comment on column jcb_fin_message.de006 is 'Amount, Cardholder Billing'
/
comment on column jcb_fin_message.de009 is 'Conversion Rate, Reconciliation (Settlement)'
/
comment on column jcb_fin_message.de010 is 'Conversion Rate, Cardholder Billing'
/
comment on column jcb_fin_message.de012 is 'Date and Time, Local Transaction'
/
comment on column jcb_fin_message.de014 is 'Date, Expiration specifies the year and month after which a card expires'
/
comment on column jcb_fin_message.de016 is 'Date, Conversion'
/
comment on column jcb_fin_message.de022_1 is 'Point of Service Data Code: Card Data Input Capability'
/
comment on column jcb_fin_message.de022_2 is 'Point of Service Data Code:  Cardholder Authentication Capability'
/
comment on column jcb_fin_message.de022_3 is 'Point of Service Data Code: Card Capture Capability'
/
comment on column jcb_fin_message.de022_4 is 'Point of Service Data Code: Operating Environment'
/
comment on column jcb_fin_message.de022_5 is 'Point of Service Data Code: Cardholder Present'
/
comment on column jcb_fin_message.de022_6 is 'Point of Service Data Code: Card Present'
/
comment on column jcb_fin_message.de022_7 is 'Point of Service Data Code: Card Data Input Mode'
/
comment on column jcb_fin_message.de022_8 is 'Point of Service Data Code: Cardholder Authentication Method'
/
comment on column jcb_fin_message.de022_9 is 'Point of Service Data Code: Cardholder Authentication Entity'
/
comment on column jcb_fin_message.de022_10 is 'Point of Service Data Code: Card Data Output Capability'
/
comment on column jcb_fin_message.de022_11 is 'Point of Service Data Code: Terminal Output Capability'
/
comment on column jcb_fin_message.de022_12 is 'Point of Service Data Code: PIN Capture Capability'
/
comment on column jcb_fin_message.de023 is 'Card Sequence Number'
/
comment on column jcb_fin_message.de024 is 'DE 24 (Function Code) indicates a messages specific purpose.'
/
comment on column jcb_fin_message.de025 is 'Message Reason Code'
/
comment on column jcb_fin_message.de026 is 'Card Acceptor Business Code (MCC)'
/
comment on column jcb_fin_message.de030_1 is 'Original Transaction Amount (in Transaction Currency)'
/
comment on column jcb_fin_message.de030_2 is 'Original Settlement Amount (in Settlement Currency)'
/
comment on column jcb_fin_message.de031 is 'Acquirer Reference Data'
/
comment on column jcb_fin_message.de032 is 'Acquiring Institution ID Code'
/
comment on column jcb_fin_message.de033 is 'Forwarding Institution ID Code'
/
comment on column jcb_fin_message.de037 is 'Retrieval Reference Number'
/
comment on column jcb_fin_message.de038 is 'Approval Code'
/
comment on column jcb_fin_message.de040 is 'Service Code'
/
comment on column jcb_fin_message.de041 is 'Card Acceptor Terminal ID'
/
comment on column jcb_fin_message.de042 is 'Card Acceptor ID Code'
/
comment on column jcb_fin_message.de043_1 is 'Card Acceptor Name/Location: Card Acceptor Name'
/
comment on column jcb_fin_message.de043_2 is 'Card Acceptor Name/Location: Street Address'
/
comment on column jcb_fin_message.de043_3 is 'Card Acceptor Name/Location: City'
/
comment on column jcb_fin_message.de043_4 is 'Card Acceptor Name/Location: ZIP Code'
/
comment on column jcb_fin_message.de043_5 is 'Card Acceptor Name/Location: State Code'
/
comment on column jcb_fin_message.de043_6 is 'Card Acceptor Name/Location: Country Code'
/
comment on column jcb_fin_message.de049 is 'Currency Code, Transaction'
/
comment on column jcb_fin_message.de050 is 'Currency Code, Reconciliation (Settlement)'
/
comment on column jcb_fin_message.de051 is 'Currency Code, Cardholder Billing'
/
comment on column jcb_fin_message.de054 is 'Amounts, Additional are additional amounts and related account data for which specific data elements have not been defined'
/
comment on column jcb_fin_message.de055 is 'Integrated Circuit Card (ICC) System-Related Data'
/
comment on column jcb_fin_message.de071 is 'Message Number'
/
comment on column jcb_fin_message.de072 is 'Data Record'
/
comment on column jcb_fin_message.de093 is 'Transaction Destination Institution ID Code'
/
comment on column jcb_fin_message.de094 is 'Transaction Originator Institution ID Code'
/
comment on column jcb_fin_message.de100 is 'Receiving Institution ID Code'
/
comment on column jcb_fin_message.p3001 is 'JCB Int`l Product / Grade Identifier'
/
comment on column jcb_fin_message.p3002 is 'Currency Exponents'
/
comment on column jcb_fin_message.p3003 is 'Clearing Data'
/
comment on column jcb_fin_message.p3005 is 'Amounts, Transaction Fees'
/
comment on column jcb_fin_message.p3007_1 is 'Reversal Indicator'
/
comment on column jcb_fin_message.p3007_2 is 'Central Processing Date of Original Transaction'
/
comment on column jcb_fin_message.p3008 is 'Card Acceptor Additional Information'
/
comment on column jcb_fin_message.p3009 is 'EC Security Level Indicator'
/
comment on column jcb_fin_message.p3011 is 'Original Acquirer Reference Data'
/
comment on column jcb_fin_message.p3012 is 'Original Card Acceptor Terminal ID'
/
comment on column jcb_fin_message.p3013 is 'Original Card Acceptor ID Code'
/
comment on column jcb_fin_message.p3014 is 'Modified Acquirer Reference Data'
/
comment on column jcb_fin_message.p3201 is 'Dispute Control Number'
/
comment on column jcb_fin_message.p3202 is 'Retrieval Request Data'
/
comment on column jcb_fin_message.p3203 is 'Retrieval Document'
/
comment on column jcb_fin_message.p3205 is 'First Chargeback Reference Number'
/
comment on column jcb_fin_message.p3206 is 'Chargeback Support Documentation Dates'
/
comment on column jcb_fin_message.p3207 is 'First Chargeback Return Data'
/
comment on column jcb_fin_message.p3208 is 'Representment Reference Number'
/
comment on column jcb_fin_message.p3209 is 'Second Chargeback Support Documentation Date'
/
comment on column jcb_fin_message.p3210 is 'Representment Resubmission Data'
/
comment on column jcb_fin_message.p3211 is 'Second Chargeback Reference Number'
/
comment on column jcb_fin_message.p3250 is 'Documentation Indicator'
/
comment on column jcb_fin_message.p3251 is 'Sender Memo'
/
comment on column jcb_fin_message.p3302 is 'Amount, Other'
/
comment on column jcb_fin_message.emv_9f26 is 'Application Cryptogram. Cryptogram returned by the ICC in response of the GENERATE AC command'
/
comment on column jcb_fin_message.emv_9f02 is 'Amount, Authorised. Authorised amount of the transaction (excluding adjustments)'
/
comment on column jcb_fin_message.emv_9f27 is 'Cryptogram Information Data. Indicates the type of cryptogram and the actions to be performed by the terminal'
/
comment on column jcb_fin_message.emv_9f10 is 'Issuer Application Data. Contains proprietary application data for transmission to the issuer in an online transaction'
/
comment on column jcb_fin_message.emv_9f36 is 'Application Transaction Counter (ATC)'
/
comment on column jcb_fin_message.emv_95 is 'Terminal Verification Results. Status of the different functions as seen from the terminal'
/
comment on column jcb_fin_message.emv_82 is 'Application Interchange Profile. Indicates the capabilities of the card to support specific functions in the application'
/
comment on column jcb_fin_message.emv_9a is 'Transaction Date. Local date that the transaction was authorised'
/
comment on column jcb_fin_message.emv_9c is 'Transaction Type. Indicates the type of financial transaction, represented by the first two digits of ISO 8583:1987 Processing Code'
/
comment on column jcb_fin_message.emv_9f37 is 'Unpredictable Number. Value to provide variability and uniqueness to the generation of a cryptogram'
/
comment on column jcb_fin_message.emv_5f2a is 'Transaction Currency Code. Indicates the currency code of the transaction according to ISO 4217'
/
comment on column jcb_fin_message.emv_9f33 is 'Terminal Capabilities. Indicates the card data input, CVM, and security capabilities of the terminal'
/
comment on column jcb_fin_message.emv_9f34 is 'CVM Results. Indicates the results of the last CVM performed'
/
comment on column jcb_fin_message.emv_9f1a is 'Terminal Country Code. Indicates the country of the terminal, represented according to ISO 3166'
/
comment on column jcb_fin_message.emv_9f35 is 'Terminal Type. Indicates the environment of the terminal, its communications capability, and its operational control'
/
comment on column jcb_fin_message.emv_84 is 'Dedicated File (DF) Name. Identifies the name of the DF as described in ISO/IEC 7816-4'
/
comment on column jcb_fin_message.emv_9f09 is 'Application Version Number. Version number assigned by the payment system for the application'
/
comment on column jcb_fin_message.emv_9f03 is 'Amount, Other (Numeric). Secondary amount associated with the transaction representing a cashback amount'
/
comment on column jcb_fin_message.emv_9f1e is 'Interface Device (IFD) Serial Number. Unique and permanent serial number assigned to the IFD by the manufacturer'
/
comment on column jcb_fin_message.emv_9f41 is 'Transaction Sequence Counter. Counter maintained by the terminal that is incremented by one for each transaction'
/
comment on column jcb_fin_message.emv_4f is 'ICC Application ID'
/

alter table jcb_fin_message add(de097 varchar2(17))
/
comment on column jcb_fin_message.de097 is 'Amount, Net Reconciliation'
/
alter table jcb_fin_message add(p3021 varchar2(16))
/
comment on column jcb_fin_message.p3021 is 'ATM Access Fee Amount, Reconciliation'
/
alter table jcb_fin_message add p3006 varchar2(47)
/
comment on column jcb_fin_message.p3006 is 'Additional Info (QR code)'
/
alter table jcb_fin_message modify p3006 varchar2(60)
/
