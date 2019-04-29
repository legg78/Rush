create table vis_retrieval (
   id                       number(16)
 , file_id                  number(16)
 , req_id                   number(16)
 , purchase_date            date
 , source_amount            number(12)
 , source_currency          varchar2(3)
 , country_code             varchar2(3)
 , state_province           varchar2(3)
 , reason_code              varchar2(2)
 , national_reimb_fee       number(12)
 , atm_account_sel          varchar2(8)
 , reimb_flag               varchar2(1)
 , fax_number               varchar2(16)
 , req_fulfill_method       varchar2(1)
 , used_fulfill_method      varchar2(1)
 , iss_rfc_bin              varchar2(6)
 , iss_rfc_subaddr          varchar2(7)
 , iss_billing_currency     varchar2(3)
 , iss_billing_amount       number(12)
 , trans_id                 varchar2(15)
 , excluded_trans_id_reason varchar2(1)
 , crs_code                 varchar2(1)
 , multiple_clearing_seqn   varchar2(2)
 , product_code             varchar2(4)
 , contact_info             varchar2(25)
 , iss_inst_id              number(4)
 , acq_inst_id              number(4)
)
/

comment on table vis_retrieval is 'VISA Financial Messages Table. This contains VISA retrieval request records TC 51, 52, 53.'
/

comment on column vis_retrieval.id is 'Primary Key.'
/

comment on column vis_retrieval.file_id is 'Reference to clearing file.'
/

comment on column vis_retrieval.req_id is 'Retrieval Request ID'
/

comment on column vis_retrieval.purchase_date is 'Purchase Date (MMDD). May be relict date for incoming messages.'
/

comment on column vis_retrieval.source_amount is 'Amount Transaction (Source Amount) Matched to posting file field 3'
/

comment on column vis_retrieval.source_currency is 'Source Currency Code'
/

comment on column vis_retrieval.country_code is 'Country (3 - digit ISO alpha country code) - converted from 2 - digit VISA code.'
/

comment on column vis_retrieval.state_province is 'Merchant State/Province Code. Otherwise spaces.'
/

comment on column vis_retrieval.reason_code is 'Reason code'
/

comment on column vis_retrieval.national_reimb_fee is 'National Reimbursement Fee'
/

comment on column vis_retrieval.atm_account_sel is 'ATM Account Selection.'
/

comment on column vis_retrieval.reimb_flag is 'Reimbursement Attribute The field must contain A through Z, or 0 through 9.'
/

comment on column vis_retrieval.fax_number is 'Fax number'
/

comment on column vis_retrieval.req_fulfill_method is 'Requested Fulfilment Method'
/

comment on column vis_retrieval.used_fulfill_method is 'Established Fulfilment Method'
/

comment on column vis_retrieval.iss_rfc_bin is 'Issuer RFC BIN'
/

comment on column vis_retrieval.iss_rfc_subaddr is 'Issuer RFC Sub - Address'
/

comment on column vis_retrieval.iss_billing_currency is 'Issuer Billing Currency Code'
/

comment on column vis_retrieval.iss_billing_amount is 'Issuer Billing Transaction Amount'
/

comment on column vis_retrieval.trans_id is 'Transaction Identifier'
/

comment on column vis_retrieval.excluded_trans_id_reason is 'Excluded Transaction Identifier Reason'
/

comment on column vis_retrieval.crs_code is 'CRS Processing Code'
/

comment on column vis_retrieval.multiple_clearing_seqn is 'Multiple Clearing Sequence Number'
/

comment on column vis_retrieval.product_code is 'Debit Product Code'
/

comment on column vis_retrieval.contact_info is 'Contact for information'
/

comment on column vis_retrieval.iss_inst_id is 'ID of the issuing financial institution the record belongs to. '
/

comment on column vis_retrieval.acq_inst_id is 'ID of the acquiring financial institution the record belongs to.'
/
 