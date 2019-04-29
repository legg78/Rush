create or replace force view atm_ui_operation_vw as
select o.id
     , o.oper_date
     , o.host_date
     , o.oper_type
     , p_iss.client_id_type
     , aup_api_atm_pkg.get_atm_disp_condition(
        i_auth_id    => o.id
      ) condition
     , o.oper_currency
     , o.oper_amount
     , o.status
     , case o.status_reason
           when 'AUSR0101' then a.resp_code
           else o.status_reason
       end resp_code
     , p_acq.terminal_id  
     , l.lang
  from opr_operation o
     , opr_participant p_iss
     , opr_participant p_acq
     , aut_auth a     
     , com_language_vw l 
 where o.id = a.id(+)
   and o.id = p_iss.oper_id(+)
   and p_iss.participant_type(+) = 'PRTYISS'
   and o.id = p_acq.oper_id(+)    
   and p_acq.participant_type(+) = 'PRTYACQ'
/
