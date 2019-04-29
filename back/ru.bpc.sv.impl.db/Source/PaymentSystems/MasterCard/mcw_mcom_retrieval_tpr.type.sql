create or replace type mcw_mcom_retrieval_tpr as object(
    acquirer_ref_num         varchar2(23)
  , acq_response_cd          varchar2(1)
  , acq_memo                 varchar2(200)
  , acq_respond_date         date
  , amount                   number(22,4)
  , currency                 varchar2(3)
  , claim_id                 varchar2(20)
  , create_date              date
  , doc_needed               number(1)
  , iss_response_cd          varchar2(8)
  , iss_reject_rsn_cd        varchar2(1)
  , iss_memo                 varchar2(200)
  , iss_respond_date         date
  , image_review_decision    varchar2(1)
  , image_review_date        date
  , card_number              varchar2(19)
  , request_id               varchar2(12)
  , retrieval_reason         varchar2(4)
)
/
alter type mcw_mcom_retrieval_tpr modify attribute iss_response_cd varchar2(100) cascade
/
alter type mcw_mcom_retrieval_tpr modify attribute iss_reject_rsn_cd varchar2(2) cascade
/
alter type mcw_mcom_retrieval_tpr add attribute ext_msg_status varchar2(12) invalidate
/
