create or replace package body itf_ui_cash_management as

procedure get_institution_list (
    i_lang                in     com_api_type_pkg.t_dict_value    default null
    , o_ref_cursor        out    sys_refcursor 
)is
    l_lang          com_api_type_pkg.t_dict_value;
begin 
    l_lang := nvl(i_lang, get_user_lang);

    open o_ref_cursor for 
         select a.id inst_id
              , get_text ('OST_INSTITUTION', 'NAME', a.id, b.lang) description 
           from ost_institution_vw a, com_language_vw b            
          where lang = l_lang;                  
end;

procedure get_atm_list (
    o_ref_cursor        out    sys_refcursor 
)is
begin
    open o_ref_cursor for 
        select t.id
             , a.region state
             , a.city
             , a.street
             , t.inst_id 
          from acq_terminal_vw t
             , com_address_object o
             , com_address a 
         where t.id in (select id from atm_terminal)
           and terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM
           and o.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
           and o.object_id   = t.id
           and a.id          = o.address_id;
end;

procedure get_atm_transactions (
    i_oper_id           in     com_api_type_pkg.t_long_id
    , i_atm_id_list     in     num_tab_tpt
    , i_max_count       in     com_api_type_pkg.t_tiny_id
    , o_ref_cursor      out    sys_refcursor 
)is
    l_oper_date     date;
begin
    select oper_date 
      into l_oper_date
      from opr_operation 
     where id = i_oper_id;
     
    open o_ref_cursor for     
        select * from (
            select row_number() over(order by o.id) rn
                 , t.id terminal_id
                 , o.id oper_id
                 , o.oper_date
                 -- other oper types??
                 , case when o.oper_type in ('OPTP0028') then 0 --Replenishment
                        when o.oper_type in ('OPTP0001') then 1 --Debit
                        when o.oper_type in ('OPTP0000') then 2 --Credit
                        when o.oper_type in ('OPTP0244') then 3 --Exchange
                        when o.oper_type in ('OPTP0022') then 4 --Cash In Replenishment
                   end oper_type 
                 , o.oper_amount amount
                 , 0 note_retracted
                 , 0 note_rejected
                 , 0 note_cash_in
                 , d1.disp_number disp_number1
                 , d1.face_value face1
                 , d1.currency currency1
                 , d2.disp_number disp_number2
                 , d2.face_value face2
                 , d2.currency currency2
                 , d3.disp_number disp_number3
                 , d3.face_value face3
                 , d3.currency currency3
                 , d4.disp_number disp_number4
                 , d4.face_value face4
                 , d4.currency currency4
                 , d5.disp_number disp_number5
                 , d5.face_value face5
                 , d5.currency currency5
                 , d6.disp_number disp_number6
                 , d6.face_value face6
                 , d6.currency currency6
                 , d7.disp_number disp_number7
                 , d7.face_value face7
                 , d7.currency currency7
                 , d8.disp_number disp_number8
                 , d8.face_value face8
                 , d8.currency currency8
                 , a.note_dispensed
                 , a.note_remained 
              from opr_operation o
                 , opr_participant p
                 , atm_terminal t   
                 , atm_dispenser d1  
                 , atm_dispenser d2  
                 , atm_dispenser d3  
                 , atm_dispenser d4  
                 , atm_dispenser d5  
                 , atm_dispenser d6  
                 , atm_dispenser d7  
                 , atm_dispenser d8 
                 , aup_atm_disp a 
             where o.id = p.oper_id  
               and p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER     
               and p.terminal_id = t.id
               and t.id = d1.terminal_id(+)
               and d1.disp_number(+) = 1
               and t.id = d2.terminal_id(+)
               and d2.disp_number(+) = 2
               and t.id = d3.terminal_id(+)
               and d3.disp_number(+) = 3
               and t.id = d4.terminal_id(+)
               and d4.disp_number(+) = 4
               and t.id = d5.terminal_id(+)
               and d5.disp_number(+) = 5
               and t.id = d6.terminal_id(+)
               and d6.disp_number(+) = 6
               and t.id = d7.terminal_id(+)
               and d7.disp_number(+) = 7
               and t.id = d8.terminal_id(+)
               and d8.disp_number(+) = 8
               and a.auth_id = o.id
               and o.oper_date > to_date(l_oper_date)
               and t.id in (select column_value as t_id from table(cast(i_atm_id_list as num_tab_tpt)))
        ) where rn <= i_max_count;      
end;    

procedure get_atm_downtime (
    i_terminal_id       in     com_api_type_pkg.t_medium_id
    , i_last_date       in     date
    , o_ref_cursor      out    sys_refcursor 
)is
begin
    open o_ref_cursor for
        select t.terminal_id
             , t.datefrom
             , t.dateto 
             , case when t.downtime_type in ('HCDT0033') then 2
                    when t.downtime_type in ('HCDT0004', 'HCDT0017', 'HCDT0025', 'HCDT0028', 'HCDT0005', 'HCDT0029', 'HCDT0030') then 1    
                    when t.downtime_type in ('HCDT0003') then 0         
                    else 0
               end downtime_type
             --, t.downtime_type --dictionary?? Mapping 1. 0 - ATM offline (both Cash In and Dispensers not available) 2. 1 - Dispensers not available 3. 2 - Cash In not available
            from(
            select l.terminal_id
                 , l.status
                 , l.change_date datefrom
                 , lead(l.status) over (partition by l.terminal_id order by l.change_date) next_status
                 , lead(l.change_date) over (partition by l.terminal_id order by l.change_date) dateto
                 , l.atm_part_type downtime_type
              from atm_status_log l 
             where l.terminal_id = i_terminal_id 
               and l.status like 'ASST%'  
               and l.change_date > i_last_date 
        ) t
        where t.status in(atm_api_const_pkg.SERVICE_STATUS_OUT_OF_S, atm_api_const_pkg.SERVICE_STATUS_UNDEFINED)   
          and next_status = atm_api_const_pkg.SERVICE_STATUS_IN_SERVICE;      
end;

procedure get_currency_rates (
    i_inst_id_list      in     num_tab_tpt
    , o_ref_cursor      out    sys_refcursor 
)is

begin
    open o_ref_cursor for 
        select r.inst_id
             , r.eff_date
             , r.src_currency
             , r.dst_currency
             , r.inverted
             , r.src_scale
             , r.src_exponent_scale
             , r.dst_scale
             , r.dst_exponent_scale
             , r.rate_type
             , r.rate
             , r.exp_date
          from com_rate r
         where r.inst_id in (select column_value as inst_id from table(cast(i_inst_id_list as num_tab_tpt)))
           and r.status = com_api_rate_pkg.RATE_STATUS_VALID;
end;

end;
/
