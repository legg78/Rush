create table mcw_fraud (
    id          number(16)
 ,  file_id     number(16)
 ,  is_incoming number(1)
 ,  is_rejected number(1)
 ,  dispute_id  number(16)
 ,  status      varchar2(8)
 ,  c01         varchar2(8)
 ,  c02         varchar2(7)
 ,  c03         number(16)
 ,  c04         varchar2(7)
 ,  c05         varchar2(23)
 ,  c06         date
 ,  c07         varchar2(19)
 ,  c08_10      date
 ,  c09         number(12)
 ,  c11         number(12)
 ,  c12         varchar2(3)
 ,  c13         number(1)
 ,  c14         number(12)
 ,  c15         varchar2(3)
 ,  c16         number(1)
 ,  c17         varchar2(3)
 ,  c18         varchar2(99)
 ,  c19         varchar2(15)
 ,  c20         varchar2(99)
 ,  c21         varchar2(3)
 ,  c22         varchar2(3)
 ,  c23         varchar2(10)
 ,  c24         varchar2(4)
 ,  c25         varchar2(6)
 ,  c26         varchar2(2)
 ,  c27         varchar2(8)
 ,  c28         varchar2(8)
 ,  c29         varchar2(8)
 ,  c30         varchar2(8)
 ,  c31         varchar2(8)
 ,  c32         date
 ,  c33         varchar2(2)
 ,  c34         varchar2(8)
 ,  c35         varchar2(3)
 ,  c36         varchar2(8)
 ,  c37         varchar2(8)
 ,  c39         varchar2(3)
 ,  c44         varchar2(8)
 ,  c45         varchar2(3)
 ,  c46         varchar2(1)
 ,  c47         varchar2(1)
 ,  c48         varchar2(1)
 ,  format      varchar2(8)
 ,  inst_id     number(4)
 ,  error1_1    varchar2(8)
 ,  error1_2    varchar2(8)
 ,  error2_1    varchar2(8)
 ,  error2_2    varchar2(8)
 ,  error3_1    varchar2(8)
 ,  error3_2    varchar2(8)
 ,  error4_1    varchar2(8)
 ,  error4_2    varchar2(8)
 ,  error5_1    varchar2(8)
 ,  error5_2    varchar2(8)
)
/

comment on table mcw_fraud is 'MasterCard Fraud messages table. (SAFE Messages)'
/
comment on column mcw_fraud.id         is 'Identifier'
/
comment on column mcw_fraud.file_id    is 'Reference to clearing file.'
/
comment on column mcw_fraud.is_incoming is 'Incoming indicator'
/
comment on column mcw_fraud.is_rejected is 'Rejected indicator'
/
comment on column mcw_fraud.dispute_id  is 'Dispute identifier'
/
comment on column mcw_fraud.status      is 'current message state '
/
comment on column mcw_fraud.c01         is 'record type '
/
comment on column mcw_fraud.c02         is 'issuer customer number'
/
comment on column mcw_fraud.c03         is 'audit control number '
/
comment on column mcw_fraud.c04         is 'acquirer'
/
comment on column mcw_fraud.c05         is 'ARN'
/
comment on column mcw_fraud.c06         is '(dd/mm/yyyy) fraud posted date'
/
comment on column mcw_fraud.c07         is 'cardholder number'
/
comment on column mcw_fraud.c08_10      is '(date - time) transaction date/time'
/
comment on column mcw_fraud.c09         is 'transaction amount u.s. dollar'
/
comment on column mcw_fraud.c11         is 'transaction amount in currency of transaction'
/
comment on column mcw_fraud.c12         is 'transaction currency code'
/
comment on column mcw_fraud.c13         is 'transaction currency exponent'
/ 
comment on column mcw_fraud.c14         is 'transaction amount cardholder billing'
/
comment on column mcw_fraud.c15         is 'cardholder billing currency code'
/
comment on column mcw_fraud.c16         is 'cardholder billing currency exponent'
/
comment on column mcw_fraud.c17         is 'card type '
/
comment on column mcw_fraud.c18         is 'merchant name'
/
comment on column mcw_fraud.c19         is 'merchant number'
/
comment on column mcw_fraud.c20         is 'merchant city'
/
comment on column mcw_fraud.c21         is 'merchant state/province'
/
comment on column mcw_fraud.c22         is 'merchant country'
/
comment on column mcw_fraud.c23         is 'merchant postal code'
/
comment on column mcw_fraud.c24         is 'mcc'
/
comment on column mcw_fraud.c25         is 'field 25'
/
comment on column mcw_fraud.c26         is 'pos entry mode'
/
comment on column mcw_fraud.c27         is 'terminal number'
/
comment on column mcw_fraud.c28         is 'fraud type code'
/
comment on column mcw_fraud.c29         is 'sub fraud type'
/
comment on column mcw_fraud.c30         is 'chargeback indicator'
/
comment on column mcw_fraud.c31         is 'counterfeit insurance eligibility '
/
comment on column mcw_fraud.c32        is '(dd/mm/yyyy) settlement date'
/
comment on column mcw_fraud.c33        is 'authorization response code'
/
comment on column mcw_fraud.c34        is 'delete duplicates flag '
/
comment on column mcw_fraud.c35        is '(dd/mm/yyyy) date the cardholder first reported the fraud to the issuer'
/
comment on column mcw_fraud.c36        is 'addendum indicator'
/
comment on column mcw_fraud.c37        is 'date cardholder reported fraud '
/
comment on column mcw_fraud.c39        is 'cvc indicator.'
/
comment on column mcw_fraud.c44        is 'account device type'
/
comment on column mcw_fraud.c45        is 'electronic commerce indicator'
/
comment on column mcw_fraud.c46        is 'AVS response code'
/
comment on column mcw_fraud.c47        is 'card present'
/
comment on column mcw_fraud.c48        is 'terminal operating environment'
/
comment on column mcw_fraud.format     is 'enhancements indicator '
/
comment on column mcw_fraud.inst_id    is 'id of the financial institution the record belongs to. 0000 - smartvista bo system institution, 9999 - all institutions.'
/
comment on column mcw_fraud.error1_1   is 'error code 1 '
/
comment on column mcw_fraud.error1_2   is 'field containing error 1'
/
comment on column mcw_fraud.error2_1   is 'error code 2 '
/
comment on column mcw_fraud.error2_2   is 'field containing error 2 '
/
comment on column mcw_fraud.error3_1   is 'error code 3 '
/
comment on column mcw_fraud.error3_2   is 'field containing error 3 '
/
comment on column mcw_fraud.error4_1   is 'error code 4 '
/
comment on column mcw_fraud.error4_2   is 'field containing error 4 '
/
comment on column mcw_fraud.error5_1   is 'error code 5 '
/
comment on column mcw_fraud.error5_2   is 'field containing error 5 '
/
alter table mcw_fraud add ext_claim_id varchar2(20)
/
comment on column mcw_fraud.ext_claim_id is 'Identifier assigned to the Claim in MasterCom'
/
alter table mcw_fraud add ext_message_id varchar2(12)
/
comment on column mcw_fraud.ext_message_id is 'MasterCom Message Id'
/
