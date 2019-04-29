create or replace package body aut_prc_unhold_pkg is
/********************************************************* 
 *  process for unhold authorizations  <br /> 
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 23.12.2011 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: aut_prc_unhold_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 

procedure process is
    l_processed_count  com_api_type_pkg.t_long_id := 0;
    l_excepted_count   com_api_type_pkg.t_long_id := 0;
    l_date             date;
    l_record_count     com_api_type_pkg.t_long_id := 0;
    l_inst_id          com_api_type_pkg.t_inst_id;
    l_split_hash       com_api_type_pkg.t_tiny_id;
begin
    l_date  := get_sysdate;
    
    trc_log_pkg.debug (
        i_text          => 'Unhold authorizations started, date[#1]'
        , i_env_param1  => to_char(l_date, 'dd.mm.yyyy')
    );
    
    for auth in (
        select --+ index( a opr_oper_unhold_status_ndx)
               row_number() over(order by id) rn
             , row_number() over(order by id desc ) rn_desc
             , count(*) over(order by id) cnt
             , id
             , status
          from opr_operation a
         where decode(status,'OPST0800',unhold_date,'OPST0850',unhold_date,NULL) <= l_date
    ) loop
        -- set current object
        trc_log_pkg.set_object (
            i_entity_type  => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
            , i_object_id  => auth.id
        );
                    
        l_record_count := l_record_count + 1;
        if auth.rn = 1 then
            prc_api_stat_pkg.log_estimation ( 
                i_estimated_count => auth.cnt
              , i_measure         => opr_api_const_pkg.ENTITY_TYPE_OPERATION
            );
        end if;

        if auth.status = opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD then
                aut_api_process_pkg.unhold(
                    i_id        => auth.id
                    , i_reason  => aut_api_const_pkg.AUTH_REASON_UNHOLD_AUTO
                );
            else
                aut_api_process_pkg.unhold_partial(
                    i_id        => auth.id
                    , i_reason  => aut_api_const_pkg.AUTH_REASON_UNHOLD_AUTO
                );
        end if;
        
        begin
            select inst_id
                 , split_hash
              into l_inst_id
                 , l_split_hash   
              from (select inst_id
                         , split_hash
                     from opr_participant
                    where oper_id = auth.id
                    order by decode(participant_type
                                      , com_api_const_pkg.PARTICIPANT_ISSUER, 0
                                      , com_api_const_pkg.PARTICIPANT_ACQUIRER, 1
                                      , 2
                                   )     
                   ) 
             where rownum = 1; 
             
             evt_api_event_pkg.register_event(
                i_event_type        => aut_api_const_pkg.EVENT_UNHOLD_AUTO
              , i_eff_date          => l_date
              , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id         => auth.id
              , i_inst_id           => l_inst_id
              , i_split_hash        => l_split_hash
            );
             
        exception
            when no_data_found then
                null;     
        end; 
        
        l_processed_count := l_processed_count + 1;
        
        prc_api_stat_pkg.log_current (
            i_current_count  => l_processed_count
          , i_excepted_count => l_excepted_count
        );
        
        if auth.rn_desc = 1 then
            prc_api_stat_pkg.log_end (
                i_excepted_total  => l_excepted_count
              , i_processed_total => l_processed_count
              , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
            );
        end if;
        
        -- clear current object
        trc_log_pkg.clear_object;
    end loop;

    if l_record_count = 0 then
        prc_api_stat_pkg.log_estimation(
            i_estimated_count => 0
          , i_measure         => opr_api_const_pkg.ENTITY_TYPE_OPERATION
        );

        prc_api_stat_pkg.log_end (
            i_excepted_total  => l_excepted_count
          , i_processed_total => l_processed_count
          , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
    end if;
exception
    when others then
        trc_log_pkg.debug(sqlerrm);
        trc_log_pkg.clear_object;
        
        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        raise;
end; 
 

end;
/
