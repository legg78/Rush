create or replace force view vch_ui_batch_vw as
select b.id
     , b.seqnum
     , b.status
     , b.total_amount
     , b.currency
     , b.total_count
     , b.reg_date
     , b.proc_date
     , b.merchant_id
     , b.terminal_id
     , b.status_reason
     , b.user_id
     , b.inst_id
     , b.card_network_id
     , u.second_name || ' ' || u.first_name || ' ' || u.surname as user_name
     , ost_ui_institution_pkg.get_inst_name(b.inst_id) as inst_name
     , (select min(merchant_name) from acq_merchant  m where m.id = b.merchant_id) as merchant_name 
     , (select min(terminal_number) from acq_terminal t where t.id = b.terminal_id) as terminal_number
     , get_text(
           i_table_name   => 'net_network'
         , i_column_name  => 'name'
         , i_object_id    => b.card_network_id
       ) as network_name
  from vch_batch b
     , acm_ui_user_vw u
 where b.user_id = u.user_id
/
