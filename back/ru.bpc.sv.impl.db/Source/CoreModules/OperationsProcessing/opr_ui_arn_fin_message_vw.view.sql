create or replace force view opr_ui_arn_fin_message_vw as
select id oper_id
     , arn
     , 'VISA' as mps
  from vis_fin_message
union all
select id oper_id
     , de031 as arn
     , 'MASTERCARD' as mps
  from mcw_fin
/
