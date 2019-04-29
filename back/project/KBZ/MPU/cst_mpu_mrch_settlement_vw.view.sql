create or replace force view cst_mpu_mrch_settlement_vw as
select s.id
     , s.inst_id
     , s.network_id
     , s.status
     , s.file_id
     , s.record_type
     , s.member_inst_code
     , s.merchant_number
     , s.in_amount_sign
     , s.in_amount
     , s.in_fee_sign
     , s.in_fee_amount
     , s.total_sttl_amount_sign
     , s.total_sttl_amount
     , s.in_summary
     , s.sttl_currency
     , s.mrch_sttl_account
  from cst_mpu_mrch_settlement s
/
