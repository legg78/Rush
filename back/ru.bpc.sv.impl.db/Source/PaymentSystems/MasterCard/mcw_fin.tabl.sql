create table mcw_fin (
    id                  number(16) not null
    , part_key          as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual  -- [@skip patch]
    , split_hash        number(4)
    , status            varchar2(8)
    , inst_id           number(4)
    , network_id        number(4)
    , file_id           number(8)
    , is_incoming       number(1)
    , is_reversal       number(1)
    , is_rejected       number(1)
    , reject_id         number(16)
    , is_fpd_matched    number(1)
    , fpd_id            number(16)
    , dispute_id        number(16)
    , impact            number(1)
    , mti               varchar2(4)
    , de024             varchar2(3)
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
    , de054             varchar2(20)
    , de055             raw(255)
    , de063             varchar2(16)
    , de071             number(7)
    , de072             varchar2(999)
    , de073             date
    , de093             varchar2(11)
    , de094             varchar2(11)
    , de095             varchar2(10)
    , de100             varchar2(11)
    , de111             number(12)
    , p0002             varchar2(3)
    , p0023             varchar2(3)
    , p0025_1           varchar2(1)
    , p0025_2           date
    , p0043             varchar2(3)
    , p0052             varchar2(3)
    , p0137             varchar2(20)
    , p0148             varchar2(60)
    , p0146             varchar2(432)
    , p0146_net         number(12)
    , p0149_1           varchar2(3)
    , p0149_2           varchar2(3)
    , p0158_1           varchar2(3)
    , p0158_2           varchar2(1)
    , p0158_3           varchar2(6)
    , p0158_4           varchar2(2)
    , p0158_5           date
    , p0158_6           number(2)
    , p0158_7           varchar2(1)
    , p0158_8           varchar2(3)
    , p0158_9           varchar2(1)
    , p0158_10          varchar2(1)
    , p0159_1           varchar2(11)
    , p0159_2           varchar2(28)
    , p0159_3           number(1)
    , p0159_4           varchar2(10)
    , p0159_5           varchar2(1)
    , p0159_6           date
    , p0159_7           number(2)
    , p0159_8           date
    , p0159_9           number(2)
    , p0165             varchar2(30)
    , p0176             varchar2(6)
    , p0228             number(1)
    , p0230             number(1)
    , p0241             varchar2(7)
    , p0243             varchar2(38)
    , p0244             varchar2(12)
    , p0260             varchar2(4)
    , p0261             number(11)
    , p0262             number(1)
    , p0264             number(4)
    , p0265             varchar2(110)
    , p0266             varchar2(127)
    , p0267             varchar2(127)
    , p0268_1           number(12)
    , p0268_2           varchar2(3)
    , p0375             varchar2(50)
    , is_fsum_matched   number(1)
    , fsum_id           number(16)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                     -- [@skip patch]
subpartition by list (split_hash)                                                       -- [@skip patch]
subpartition template                                                                   -- [@skip patch]
(                                                                                       -- [@skip patch]
    <subpartition_list>                                                                 -- [@skip patch]
)                                                                                       -- [@skip patch]
(                                                                                       -- [@skip patch]
    partition mcw_fin_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))           -- [@skip patch]
)                                                                                       -- [@skip patch]
******************** partition end ********************/
/
comment on table mcw_fin is 'MasterCard financial messages'
/
comment on column mcw_fin.id is 'Identifier'
/
comment on column mcw_fin.status is 'Clearing message status'
/
comment on column mcw_fin.inst_id is 'Institution identifier'
/
comment on column mcw_fin.network_id is 'Network identifier'
/
comment on column mcw_fin.file_id is 'Logical file identifier'
/
comment on column mcw_fin.is_incoming is 'Incoming indicator'
/
comment on column mcw_fin.is_reversal is 'Reversal indicator'
/
comment on column mcw_fin.is_rejected is 'Rejected indicator'
/
comment on column mcw_fin.reject_id is 'Reject message identifier'
/
comment on column mcw_fin.is_fpd_matched is 'Financial position detail matched indicator'
/
comment on column mcw_fin.fpd_id is 'Financial position detail message identifier'
/
comment on column mcw_fin.dispute_id is 'Dispute identifier'
/
comment on column mcw_fin.impact is 'Message impact'
/
comment on column mcw_fin.mti is 'The Message Type Identifier (MTI) is a four-digit numeric field describing the type of message being interchanged'
/
comment on column mcw_fin.de024 is 'DE 24 (Function Code) indicates a messages specific purpose.'
/
comment on column mcw_fin.de002 is 'DE 2 (Primary Account Number [PAN]) is a series of digits that identify a customer account or relationship.'
/
comment on column mcw_fin.de003_1 is 'Cardholder Transaction Type'
/
comment on column mcw_fin.de003_2 is 'Cardholder "From" Account Type Code'
/
comment on column mcw_fin.de003_3 is 'Cardholder "To" Account Type Code'
/
comment on column mcw_fin.de004 is 'Amount, Transaction'
/
comment on column mcw_fin.de005 is 'Amount, Reconciliation'
/
comment on column mcw_fin.de006 is 'Amount, Cardholder Billing'
/
comment on column mcw_fin.de009 is 'Conversion Rate, Reconciliation'
/
comment on column mcw_fin.de010 is 'Conversion Rate, Cardholder Billing'
/
comment on column mcw_fin.de012 is 'Date and Time, Local Transaction'
/
comment on column mcw_fin.de014 is 'DE 14 (Date, Expiration) specifies the year and month after which a card expires.'
/
comment on column mcw_fin.de022_1 is 'Terminal Data: Card Data Input Capability'
/
comment on column mcw_fin.de022_2 is 'Terminal Data: Cardholder Authentication Capability'
/
comment on column mcw_fin.de022_3 is 'Terminal Data: Card Capture Capability'
/
comment on column mcw_fin.de022_4 is 'Terminal Operating Environment'
/
comment on column mcw_fin.de022_5 is 'Cardholder Present Data'
/
comment on column mcw_fin.de022_6 is 'Card Present Data'
/
comment on column mcw_fin.de022_7 is 'Card Data: Input Mode'
/
comment on column mcw_fin.de022_8 is 'Cardholder Authentication Method'
/
comment on column mcw_fin.de022_9 is 'Cardholder Authentication Entity'
/
comment on column mcw_fin.de022_10 is 'Card Data Output Capability'
/
comment on column mcw_fin.de022_11 is 'Terminal Data Output Capability'
/
comment on column mcw_fin.de022_12 is 'PIN Capture Capability'
/
comment on column mcw_fin.de023 is 'Card Sequence Number'
/
comment on column mcw_fin.de025 is 'Message Reason Code'
/
comment on column mcw_fin.de026 is 'Card Acceptor Business Code (MCC)'
/
comment on column mcw_fin.de030_1 is 'Original Amount, Transaction'
/
comment on column mcw_fin.de030_2 is 'Original Amount, Reconciliation'
/
comment on column mcw_fin.de031 is 'Acquirer Reference Data'
/
comment on column mcw_fin.de032 is 'Acquiring Institution ID Code'
/
comment on column mcw_fin.de033 is 'Forwarding Institution ID Code'
/
comment on column mcw_fin.de037 is 'Retrieval Reference Number'
/
comment on column mcw_fin.de038 is 'Approval Code'
/
comment on column mcw_fin.de040 is 'Service Code'
/
comment on column mcw_fin.de041 is 'Card Acceptor Terminal ID'
/
comment on column mcw_fin.de042 is 'Card Acceptor ID Code'
/
comment on column mcw_fin.de043_1 is 'Card Acceptor Name'
/
comment on column mcw_fin.de043_2 is 'Card Acceptor Street Address'
/
comment on column mcw_fin.de043_3 is 'Card Acceptor City'
/
comment on column mcw_fin.de043_4 is 'Card Acceptor Postal (ZIP) Code'
/
comment on column mcw_fin.de043_5 is 'Card Acceptor State, Province, or Region Code'
/
comment on column mcw_fin.de043_6 is 'Card Acceptor Country Code'
/
comment on column mcw_fin.de049 is 'Currency Code, Transaction'
/
comment on column mcw_fin.de050 is 'Currency Code, Reconciliation'
/
comment on column mcw_fin.de051 is 'Currency Code, Cardholder Billing'
/
comment on column mcw_fin.de054 is 'DE 54 (Amounts, Additional) are additional amounts and related account data for which specific data elements have not been defined'
/
comment on column mcw_fin.de055 is 'Integrated Circuit Card (ICC) System-Related Data'
/
comment on column mcw_fin.de063 is 'Transaction Life Cycle ID'
/
comment on column mcw_fin.de071 is 'Message Number'
/
comment on column mcw_fin.de072 is 'Data Record'
/
comment on column mcw_fin.de073 is 'Date, Action'
/
comment on column mcw_fin.de093 is 'Transaction Destination Institution ID Code'
/
comment on column mcw_fin.de094 is 'Transaction Originator Institution ID Code'
/
comment on column mcw_fin.de095 is 'Card Issuer Reference Data'
/
comment on column mcw_fin.de100 is 'Receiving Institution ID Code'
/
comment on column mcw_fin.de111 is 'Amount, Currency Conversion Assessment'
/
comment on column mcw_fin.p0002 is 'PDS 0002 (GCMS Product Identifier) identifies the product recognized by GCMS.'
/
comment on column mcw_fin.p0023 is 'PDS 0023 (Terminal Type) identifies the type of terminal used at the point of interaction.'
/
comment on column mcw_fin.p0025_1 is 'Message Reversal Indicator'
/
comment on column mcw_fin.p0025_2 is 'Central Site Processing Date of Original Message'
/
comment on column mcw_fin.p0043 is 'Program Registration ID'
/
comment on column mcw_fin.p0052 is 'Electronic Commerce Security Level Indicator'
/
comment on column mcw_fin.p0137 is 'Fee Collection Control Number'
/
comment on column mcw_fin.p0146 is 'Amounts, Transaction Fee'
/
comment on column mcw_fin.p0146_net is 'Net value of p0146 Amounts, Transaction Fee'
/
comment on column mcw_fin.p0148 is 'Currency Exponents'
/
comment on column mcw_fin.p0149_1 is 'Currency Code, Original Transaction Amount'
/
comment on column mcw_fin.p0149_2 is 'Currency Code, Original Reconciliation Amount'
/
comment on column mcw_fin.p0158_1 is 'Card Program Identifier'
/
comment on column mcw_fin.p0158_2 is 'Business Service Arrangement Type Code'
/
comment on column mcw_fin.p0158_3 is 'Business Service ID Code'
/
comment on column mcw_fin.p0158_4 is 'Interchange Rate Designator'
/
comment on column mcw_fin.p0158_5 is 'Business Date'
/
comment on column mcw_fin.p0158_6 is 'Business Cycle'
/
comment on column mcw_fin.p0158_7 is 'Card Acceptor Classification Override Indicator'
/
comment on column mcw_fin.p0158_8 is 'Product Class Override Indicator'
/
comment on column mcw_fin.p0158_9 is 'Corporate Incentive Rates Apply Indicator'
/
comment on column mcw_fin.p0158_10 is 'ATM Special Conditions Indicator'
/
comment on column mcw_fin.p0159_1 is 'Settlement Service Transfer Agent ID Code'
/
comment on column mcw_fin.p0159_2 is 'Settlement Service Transfer Agent Account'
/
comment on column mcw_fin.p0159_3 is 'Settlement Service Level Code'
/
comment on column mcw_fin.p0159_4 is 'Settlement Service ID Code'
/
comment on column mcw_fin.p0159_5 is 'Settlement Foreign Exchange Rate Class Code'
/
comment on column mcw_fin.p0159_6 is 'Reconciliation Date'
/
comment on column mcw_fin.p0159_7 is 'Reconciliation Cycle'
/
comment on column mcw_fin.p0159_8 is 'Settlement Date'
/
comment on column mcw_fin.p0159_9 is 'Settlement Cycle'
/
comment on column mcw_fin.p0165 is 'Settlement Indicator'
/
comment on column mcw_fin.p0176 is 'MasterCard Assigned ID'
/
comment on column mcw_fin.p0228 is 'Retrieval Document Code'
/
comment on column mcw_fin.p0230 is 'Fulfillment Document Code'
/
comment on column mcw_fin.p0241 is 'MasterCom Control Number'
/
comment on column mcw_fin.p0243 is 'MasterCom Retrieval Response Data'
/
comment on column mcw_fin.p0244 is 'MasterCom Chargeback Support Documentation Dates'
/
comment on column mcw_fin.p0260 is 'Edit Exclusion Indicator'
/
comment on column mcw_fin.p0261 is 'Risk Management Approval Code'
/
comment on column mcw_fin.p0262 is 'Documentation Indicator'
/
comment on column mcw_fin.p0264 is 'Original Retrieval Reason for Request'
/
comment on column mcw_fin.p0265 is 'Initial Presentment/Fee Collection Data'
/
comment on column mcw_fin.p0266 is 'First Chargeback/Fee Collection Return Data'
/
comment on column mcw_fin.p0267 is 'Second Presentment/Fee Collection Resubmission Data'
/
comment on column mcw_fin.p0268_1 is 'Amount, Partial Transaction'
/
comment on column mcw_fin.p0268_2 is 'Currency Code, Partial Transaction'
/
comment on column mcw_fin.p0375 is 'Member Reconciliation Indicator'
/
comment on column mcw_fin.is_fsum_matched is 'File summary matched indicator'
/
comment on column mcw_fin.fsum_id is 'File summary message identifier'
/

alter table mcw_fin add (emv_9f26 varchar2(16), emv_9f02 number(2), emv_9f27 varchar2(2), emv_9f10 varchar2(64), emv_9f36 varchar2(4), emv_95 varchar2(10), emv_82 varchar2(4), emv_9a date, emv_9c number(2), emv_9f37 varchar2(8), emv_5f2a number(3), emv_9f33 varchar2(6))
/
alter table mcw_fin add (emv_9f34 varchar2(6), emv_9f1a number(3), emv_9f35 number(2), emv_9f53 varchar2(2), emv_84 varchar2(32), emv_9f09 varchar2(4), emv_9f03 number(4), emv_9f1e varchar2(16), emv_9f41 number(8))
/
comment on column mcw_fin.emv_9f26 is 'Application Cryptogram. Cryptogram returned by the ICC in response of the GENERATE AC command'
/
comment on column mcw_fin.emv_9f02 is 'Amount, Authorised. Authorised amount of the transaction (excluding adjustments)'
/
comment on column mcw_fin.emv_9f27 is 'Cryptogram Information Data. Indicates the type of cryptogram and the actions to be performed by the terminal'
/
comment on column mcw_fin.emv_9f10 is 'Issuer Application Data. Contains proprietary application data for transmission to the issuer in an online transaction'
/
comment on column mcw_fin.emv_9f36 is 'Application Transaction Counter (ATC)'
/
comment on column mcw_fin.emv_95 is 'Terminal Verification Results. Status of the different functions as seen from the terminal'
/
comment on column mcw_fin.emv_82 is 'Application Interchange Profile. Indicates the capabilities of the card to support specific functions in the application'
/
comment on column mcw_fin.emv_9a is 'Transaction Date. Local date that the transaction was authorised'
/
comment on column mcw_fin.emv_9c is 'Transaction Type. Indicates the type of financial transaction, represented by the first two digits of ISO 8583:1987 Processing Code'
/
comment on column mcw_fin.emv_9f37 is 'Unpredictable Number. Value to provide variability and uniqueness to the generation of a cryptogram'
/
comment on column mcw_fin.emv_5f2a is 'Transaction Currency Code. Indicates the currency code of the transaction according to ISO 4217'
/
comment on column mcw_fin.emv_9f33 is 'Terminal Capabilities. Indicates the card data input, CVM, and security capabilities of the terminal'
/
comment on column mcw_fin.emv_9f34 is 'CVM Results. Indicates the results of the last CVM performed'
/
comment on column mcw_fin.emv_9f1a is 'Terminal Country Code. Indicates the country of the terminal, represented according to ISO 3166'
/
comment on column mcw_fin.emv_9f35 is 'Terminal Type. Indicates the environment of the terminal, its communications capability, and its operational control'
/
comment on column mcw_fin.emv_9f53 is 'Transaction Category Code'
/
comment on column mcw_fin.emv_84 is 'Dedicated File (DF) Name. Identifies the name of the DF as described in ISO/IEC 7816-4'
/
comment on column mcw_fin.emv_9f09 is 'Application Version Number. Version number assigned by the payment system for the application'
/
comment on column mcw_fin.emv_9f03 is 'Amount, Other (Numeric). Secondary amount associated with the transaction representing a cashback amount'
/
comment on column mcw_fin.emv_9f1e is 'Interface Device (IFD) Serial Number. Unique and permanent serial number assigned to the IFD by the manufacturer'
/
comment on column mcw_fin.emv_9f41 is 'Transaction Sequence Counter. Counter maintained by the terminal that is incremented by one for each transaction'
/

alter table mcw_fin add dispute_rn number(16)
/
comment on column mcw_fin.emv_9f41 is 'Dispute reference number identifier'
/
comment on column mcw_fin.emv_9f41 is 'Transaction Sequence Counter. Counter maintained by the terminal that is incremented by one for each transaction'
/
comment on column mcw_fin.dispute_rn is 'Dispute reference number identifier'
/
alter table mcw_fin modify emv_9f02 number(12)
/

alter table mcw_fin add P0042 varchar2(1)
/
alter table mcw_fin add p0158_11 varchar2(1)
/
alter table mcw_fin add p0158_12 varchar2(1)
/
alter table mcw_fin add p0158_13 varchar2(1)
/
alter table mcw_fin add p0158_14 varchar2(1)
/
alter table mcw_fin add P0198 varchar2(2)
/
alter table mcw_fin add P0200_1 date
/
alter table mcw_fin add P0200_2 number
/
alter table mcw_fin add P0210_1 varchar2(2)
/
alter table mcw_fin add P0210_2 varchar2(2)
/

comment on column mcw_fin.P0042 is 'Merchant Capability'
/
comment on column mcw_fin.p0158_11 is 'MasterCard Assigned ID Override Indicator'
/
comment on column mcw_fin.p0158_12 is 'Account Level Management Account Category Code'
/
comment on column mcw_fin.p0158_13 is 'Rate Indicator'
/
comment on column mcw_fin.p0158_14 is 'Merchant Capability'
/
comment on column mcw_fin.P0198 is 'Device Type'
/
comment on column mcw_fin.P0210_1 is 'Fraud Notification Service Date'
/
comment on column mcw_fin.P0210_2 is 'Fraud Notification Service Chargeback Counter'
/
comment on column mcw_fin.P0210_1 is 'Transit Transaction Type Indicator'
/
comment on column mcw_fin.P0210_2 is 'Transportation Mode Indicator'
/

alter table mcw_fin add local_message number(1)
/
comment on column mcw_fin.local_message is 'Sign of domestic transaction'
/
comment on column mcw_fin.split_hash is 'Hash value to split further processing'
/
alter table mcw_fin modify emv_5f2a number(4)
/
alter table mcw_fin modify emv_9f1a number(4)
/
alter table mcw_fin modify emv_9f03 number(12)
/
alter table mcw_fin add (p0181 varchar2(33))
/
comment on column mcw_fin.p0181 is 'Installment Payment Data'
/
alter table mcw_fin modify de054 varchar2(120)
/
alter table mcw_fin add p0147 varchar2(576)
/
comment on column mcw_fin.p0147 is 'Extended Precision Fee Amounts'
/
alter table mcw_fin modify (p0181 varchar2(50))
/
alter table mcw_fin add p0208_1 varchar2(11)
/
comment on column mcw_fin.p0208_1 is 'Payment Facilitator ID'
/
alter table mcw_fin add p0208_2 varchar2(15)
/
comment on column mcw_fin.p0208_2 is 'Sub-Merchant ID'
/
alter table mcw_fin add p0209 varchar2(11)
/
comment on column mcw_fin.p0209 is 'Independent Sales Organization ID'
/
alter table mcw_fin add p0045 varchar2(1)
/
comment on column mcw_fin.p0045 is 'Mastercard Generated Installment Identifier'
/
alter table mcw_fin add p0047 varchar2(15)
/
comment on column mcw_fin.p0047 is 'Trade Payment Information'
/
alter table mcw_fin add p0207 varchar2(3)
/
comment on column mcw_fin.p0207 is 'Wallet Identifier'
/
alter table mcw_fin add p0001_1 varchar2(2)
/
comment on column mcw_fin.p0001_1 is 'Mapping Service Account Number Type'
/
alter table mcw_fin add p0001_2 varchar2(19)
/
comment on column mcw_fin.p0001_2 is 'Mapping Service Account Number'
/
alter table mcw_fin add p0058 varchar2(2)
/
comment on column mcw_fin.p0058 is 'Token Assurance Level'
/
alter table mcw_fin add p0059 varchar2(11)
/
comment on column mcw_fin.p0059 is 'Token Requestor ID'
/
alter table mcw_fin add p1001 number(12)
/
comment on column mcw_fin.p1001 is 'ATM Service Fee'
/
alter table mcw_fin add ird_trace varchar2(2000)
/
comment on column mcw_fin.ird_trace is 'Trace of IRD calculating'
/
alter table mcw_fin add p0004_1 varchar2(2)
/
comment on column mcw_fin.p0004_1 is 'Funding Account Information - Funding Source'
/
alter table mcw_fin add p0004_2 varchar2(34)
/
comment on column mcw_fin.p0004_2 is 'Funding Account Information - Sender Account Number'
/
alter table mcw_fin add p0072 number(1)
/
comment on column mcw_fin.p0072 is 'Authentication Indicator'
/
alter table mcw_fin modify (p0181 varchar2(68))
/
comment on column mcw_fin.p0200_1 is 'Fraud NTF date'
/
comment on column mcw_fin.p0200_2 is 'Fraud Notification Service Chargeback Counter'
/

alter table mcw_fin add p0028 varchar2(34)
/
comment on column mcw_fin.p0028 is 'Masterpass QR Receiving Account Number'
/

alter table mcw_fin add p0029 varchar2(250)
/
comment on column mcw_fin.p0029 is 'QR Dynamic Code Data'
/

alter table mcw_fin add p0674 varchar2(19)
/
comment on column mcw_fin.p0674 is 'Additional Trace/Reference Number Used by Card Acceptor'
/

alter table mcw_fin modify (de054 varchar2(240))
/

alter table mcw_fin add p0018 number(1)
/
comment on column mcw_fin.p0018 is 'Subfield 1 (mPOS Acceptance Device Type) of PDS 0018 (Acceptance Data)'
/
alter table mcw_fin modify (p1001 varchar2(1000))
/

alter table mcw_fin add p0021 varchar2(1)
/
comment on column mcw_fin.p0021 is 'PDS 0021—Transaction Type Indicator (form factor of the terminal device that initiated the transaction)'
/
alter table mcw_fin add p0022 varchar2(1)
/
comment on column mcw_fin.p0022 is 'PDS 0022 Additional Terminal Operating Environments'
/
alter table mcw_fin add ext_claim_id varchar2(20)
/
comment on column mcw_fin.ext_claim_id is 'Identifier assigned to the Claim in MasterCom'
/
alter table mcw_fin add ext_message_id varchar2(12)
/
comment on column mcw_fin.ext_message_id is 'MasterCom Message Id'
/

comment on column mcw_fin.p0021 is 'PDS 0021 Transaction Type Indicator (form factor of the terminal device that initiated the transaction)'
/
alter table mcw_fin add p0184 varchar2(36)
/
comment on column mcw_fin.p0184 is 'PDS 0184 Directory Server Transaction ID (generated by EMV 3DS Mastercard Directory Server)'
/
alter table mcw_fin add p0185 varchar2(32)
/
comment on column mcw_fin.p0185 is 'PDS 0185 Accountholder Authentication Value'
/
alter table mcw_fin add p0186 varchar2(1)
/
comment on column mcw_fin.p0186 is 'PDS 0186 Program Protocol'
/
alter table mcw_fin add ext_msg_status varchar2(12)
/
comment on column mcw_fin.ext_msg_status is 'MasterCom Message status'
/
