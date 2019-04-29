create or replace force view opr_ui_operation_vw as
select
    o.id
    , o.session_id
    , o.is_reversal
    , o.original_id
    , o.oper_type
    , o.oper_reason
    , o.msg_type
    , o.status
    , case o.status_reason
          when 'AUSR0101' then (
              select a.resp_code
                from aut_auth a
               where a.id = o.id
          )
          else o.status_reason
      end status_reason
    , o.sttl_type
    , o.terminal_type
    , o.acq_inst_bin
    , o.forw_inst_bin
    , o.merchant_number
    , o.terminal_number
    , o.merchant_name
    , o.merchant_street
    , o.merchant_city
    , o.merchant_region
    , o.merchant_country
    , o.merchant_postcode
    , o.mcc
    , o.originator_refnum
    , o.network_refnum
    , o.oper_count
    , o.oper_request_amount
    , o.oper_amount_algorithm
    , o.oper_amount
    , o.oper_currency
    , o.oper_cashback_amount
    , o.oper_replacement_amount
    , o.oper_surcharge_amount
    , o.oper_date
    , o.host_date
    , o.unhold_date
    , o.match_status
    , o.sttl_amount
    , o.sttl_currency
    , o.dispute_id
    , o.payment_order_id
    , o.payment_host_id
    , o.forced_processing
    , o.match_id
    , o.proc_mode
    , o.incom_sess_file_id
    , o.sttl_date
    , o.acq_sttl_date
from 
    opr_operation o
/
