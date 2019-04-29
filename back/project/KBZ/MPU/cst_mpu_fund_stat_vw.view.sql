create or replace force view cst_mpu_fund_stat_vw as
select s.id
     , s.inst_id
     , s.network_id
     , s.status
     , s.file_id
     , s.record_type
     , s.member_inst_code
     , s.out_amount_sign
     , s.out_amount
     , s.out_fee_sign
     , s.out_fee_amount
     , s.in_amount_sign
     , s.in_amount
     , s.in_fee_sign
     , s.in_fee_amount
     , s.stf_amount_sign
     , s.stf_amount
     , s.stf_fee_sign
     , s.stf_fee_amount
     , s.out_summary
     , s.in_summary
     , s.sttl_currency
  from cst_mpu_fund_stat s
/
