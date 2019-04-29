create or replace force view opr_operation_unpivot_vw as
select 
   o.id
   , x.column_id
   , x.column_name
   , x.data_type
   , (case x.column_name
        when 'session_id' then to_char(o.session_id,'FM000000000000000000.0000')
        when 'is_reversal' then to_char(o.is_reversal,'FM000000000000000000.0000')
        when 'original_id' then to_char(o.original_id,'FM000000000000000000.0000')
        when 'oper_type' then o.oper_type
        when 'oper_reason' then o.oper_reason
        when 'msg_type' then o.msg_type
        when 'status' then o.status
        when 'status_reason' then o.status_reason
        when 'sttl_type' then o.sttl_type
        when 'terminal_type' then o.terminal_type
        when 'acq_inst_bin' then o.acq_inst_bin
        when 'forw_inst_bin' then o.forw_inst_bin
        when 'merchant_number' then o.merchant_number
        when 'terminal_number' then o.terminal_number
        when 'merchant_name' then o.merchant_name
        when 'merchant_street' then o.merchant_street
        when 'merchant_city' then o.merchant_city
        when 'merchant_region' then o.merchant_region
        when 'merchant_country' then o.merchant_country
        when 'merchant_postcode' then o.merchant_postcode
        when 'mcc' then o.mcc
        when 'originator_refnum' then o.originator_refnum
        when 'network_refnum' then o.network_refnum
        when 'oper_count' then to_char(o.oper_count,'FM000000000000000000.0000')
        when 'oper_request_amount' then to_char(o.oper_request_amount,'FM000000000000000000.0000')
        when 'oper_amount_algorithm' then o.oper_amount_algorithm
        when 'oper_amount' then to_char(o.oper_amount,'FM000000000000000000.0000')
        when 'oper_currency' then o.oper_currency
        when 'oper_cashback_amount' then to_char(o.oper_cashback_amount,'FM000000000000000000.0000')
        when 'oper_replacement_amount' then to_char(o.oper_replacement_amount,'FM000000000000000000.0000')
        when 'oper_surcharge_amount' then to_char(o.oper_surcharge_amount,'FM000000000000000000.0000')
        when 'oper_date' then to_char(o.oper_date,'yyyymmddhh24miss')
        when 'host_date' then to_char(o.host_date,'yyyymmddhh24miss')
        when 'unhold_date' then to_char(o.unhold_date,'yyyymmddhh24miss')
        when 'match_status' then o.match_status
        when 'sttl_amount' then to_char(o.sttl_amount,'FM000000000000000000.0000')
        when 'sttl_currency' then o.sttl_currency
        when 'dispute_id' then to_char(o.dispute_id,'FM000000000000000000.0000')
        when 'payment_order_id' then to_char(o.payment_order_id,'FM000000000000000000.0000')
        when 'payment_host_id' then to_char(o.payment_host_id,'FM000000000000000000.0000')
        when 'forced_processing' then to_char(o.forced_processing,'FM000000000000000000.0000')
        when 'match_id' then to_char(o.match_id,'FM000000000000000000.0000')
        when 'proc_mode' then o.proc_mode
        when 'clearing_sequence_num' then to_char(o.clearing_sequence_num,'FM000000000000000000.0000')
        when 'clearing_sequence_count' then to_char(o.clearing_sequence_count,'FM000000000000000000.0000')
        when 'incom_sess_file_id' then to_char(o.incom_sess_file_id,'FM000000000000000000.0000')
        when 'fee_amount' then to_char(o.fee_amount,'FM000000000000000000.0000')
        when 'fee_currency' then o.fee_currency
        when 'sttl_date' then to_char(o.sttl_date,'yyyymmddhh24miss')
        when 'acq_sttl_date' then to_char(o.acq_sttl_date,'yyyymmddhh24miss')
      else 'n/a'
      end) as value
 from opr_operation o
 join (select z.column_id
            , lower(z.column_name) as column_name
            , lower(z.data_type) as data_type 
         from user_tab_columns z 
        where lower(z.table_name) = 'opr_operation' 
          and lower(z.column_name) != 'id') x on (1=1)
/
