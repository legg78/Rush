create or replace type mcw_mcom_claim_tpr as object(
    acquirer_id         varchar2(11)
  , acquirer_ref_num    varchar2(23)
  , card_number         varchar2(19)
  , claim_id            varchar2(20)
  , claim_type          varchar2(20)
  , claim_value         number(22, 4)
  , claim_currency      varchar2(3)
  , clearing_due_date   date
  , clearing_network    varchar2(8)
  , create_date         date
  , due_date            date
  , transaction_id      varchar2(20)
  , is_accurate         number(1)
  , is_acquirer         number(1)
  , is_issuer           number(1)
  , is_open             number(1)
  , issuer_id           varchar2(11)
  , last_modified_by    varchar2(8)
  , last_modified_date  date
  , merchant_id         varchar2(15)
  , progress_state      varchar2(20)
  , queue_name          varchar2(15)
)
/
