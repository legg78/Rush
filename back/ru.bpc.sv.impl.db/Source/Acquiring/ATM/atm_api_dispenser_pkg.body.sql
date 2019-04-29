create or replace package body atm_api_dispenser_pkg as
/*********************************************************
 *  Api for dispensers of ATM terminals <br>
 *  Created by Filimonov A.(filimonov@bpc.ru)  at 27.10.2010  <br>
 *  Last changed by $Author$ <br>
 *  $LastChangedDate::                           $  <br>
 *  Revision: $LastChangedRevision$ <br>
 *  Module: atm_api_dispenser_pkg <br>
 *  @headcom
 **********************************************************/
procedure add_dispenser_history(
    i_dispenser_id     in       com_api_type_pkg.t_medium_id
  , i_terminal_id      in       com_api_type_pkg.t_short_id
  , i_disp_number      in       com_api_type_pkg.t_tiny_id
  , i_face_value       in       com_api_type_pkg.t_money
  , i_currency         in       com_api_type_pkg.t_curr_code
  , i_denomination_id  in       com_api_type_pkg.t_curr_code  
  , i_dispenser_type   in       com_api_type_pkg.t_dict_value
) is
    l_change_date               date;
begin
    select max(start_date)
    into l_change_date
    from atm_collection
    where terminal_id = i_terminal_id;
         
    insert into atm_dispenser_history(
        dispenser_id
      , terminal_id
      , disp_number
      , face_value
      , currency
      , denomination_id
      , dispenser_type
      , change_date
    ) values(
        i_dispenser_id
      , i_terminal_id
      , i_disp_number
      , i_face_value 
      , i_currency
      , i_denomination_id
      , i_dispenser_type
      , nvl(l_change_date, get_sysdate)
    );    
end;

procedure register_dispenser_event (
    i_terminal_id       in  com_api_type_pkg.t_short_id
  , i_old_note_remained in  com_api_type_pkg.t_tiny_id
  , i_old_note_rejected in  com_api_type_pkg.t_tiny_id
) is
    l_split_hash        com_api_type_pkg.t_tiny_id;
    l_note_remained     com_api_type_pkg.t_tiny_id;
    l_note_rejected     com_api_type_pkg.t_tiny_id;
    l_reject_limit      com_api_type_pkg.t_tiny_id;
    l_remain_limit      com_api_type_pkg.t_tiny_id;
begin

    select nvl(min(dd.note_remained),0)
         , nvl(sum(dd.note_rejected),0)
    into   l_note_remained
         , l_note_rejected         
    from   atm_dispenser_dynamic dd
      join atm_dispenser ad on dd.id = ad.id
    where  ad.terminal_id = i_terminal_id;
    
    select disp_rest_warn
         , reject_disp_min_warn
    into   l_remain_limit
         , l_reject_limit     
    from   atm_terminal
    where  id = i_terminal_id;         

    if l_note_remained <= l_remain_limit and i_old_note_remained > l_remain_limit or l_note_rejected >= l_reject_limit and i_old_note_rejected < l_reject_limit then
        select split_hash
        into   l_split_hash
        from   acq_terminal
        where  id = i_terminal_id;
        
        if l_note_remained <= l_remain_limit and i_old_note_remained > l_remain_limit then
             evt_api_event_pkg.register_event (
                i_event_type    =>  acq_api_const_pkg.event_terminal_disp_limit
              , i_eff_date      =>  com_api_sttl_day_pkg.get_sysdate
              , i_entity_type   =>  acq_api_const_pkg.entity_type_terminal
              , i_object_id     =>  i_terminal_id
              , i_inst_id       =>  ost_api_const_pkg.default_inst
              , i_split_hash    =>  l_split_hash
            );
        end if;
        
        if l_note_rejected >= l_reject_limit and i_old_note_rejected < l_reject_limit then
             evt_api_event_pkg.register_event (
                i_event_type    =>  acq_api_const_pkg.event_terminal_reject_limit
              , i_eff_date      =>  com_api_sttl_day_pkg.get_sysdate
              , i_entity_type   =>  acq_api_const_pkg.entity_type_terminal
              , i_object_id     =>  i_terminal_id
              , i_inst_id       =>  ost_api_const_pkg.default_inst
              , i_split_hash    =>  l_split_hash
            );
        end if;
        
        evt_api_event_pkg.register_event (
              i_event_type    =>  acq_api_const_pkg.event_terminal_common
            , i_eff_date      =>  com_api_sttl_day_pkg.get_sysdate
            , i_entity_type   =>  acq_api_const_pkg.entity_type_terminal
            , i_object_id     =>  i_terminal_id
            , i_inst_id       =>  ost_api_const_pkg.default_inst
            , i_split_hash    =>  l_split_hash
        );
        
    end if; 
    
end;

procedure add_dispenser(
    o_id                   out  com_api_type_pkg.t_medium_id
  , i_terminal_id      in       com_api_type_pkg.t_short_id
  , i_disp_number      in       com_api_type_pkg.t_tiny_id
  , i_face_value       in       com_api_type_pkg.t_money
  , i_currency         in       com_api_type_pkg.t_curr_code
  , i_denomination_id  in       com_api_type_pkg.t_curr_code  
  , i_dispenser_type   in       com_api_type_pkg.t_dict_value
) is
begin
    o_id  := atm_dispenser_seq.nextval;
    
    insert into atm_dispenser(
        id
      , terminal_id
      , disp_number
      , face_value
      , currency
      , denomination_id
      , dispenser_type
    ) values(
        o_id
      , i_terminal_id
      , i_disp_number
      , i_face_value
      , i_currency
      , i_denomination_id
      , i_dispenser_type
    );
end;

procedure modify_dispenser(
    i_id               in       com_api_type_pkg.t_medium_id
  , i_terminal_id      in       com_api_type_pkg.t_short_id
  , i_disp_number      in       com_api_type_pkg.t_tiny_id
  , i_face_value       in       com_api_type_pkg.t_money
  , i_currency         in       com_api_type_pkg.t_curr_code
  , i_denomination_id  in       com_api_type_pkg.t_curr_code  
  , i_dispenser_type   in       com_api_type_pkg.t_dict_value
) is
    l_terminal_id      com_api_type_pkg.t_short_id;
    l_disp_number      com_api_type_pkg.t_tiny_id;
    l_face_value       com_api_type_pkg.t_money;
    l_currency         com_api_type_pkg.t_curr_code;
    l_denomination_id  com_api_type_pkg.t_curr_code; 
    l_dispenser_type   com_api_type_pkg.t_dict_value;

begin
    begin
        select terminal_id
             , disp_number
             , face_value
             , currency
             , denomination_id
             , dispenser_type
          into l_terminal_id
             , l_disp_number 
             , l_face_value  
             , l_currency    
             , l_denomination_id 
             , l_dispenser_type   
          from atm_dispenser
         where id = i_id;
    
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'DISPENSER_NOT_FOUND'
                , i_env_param1  => i_id
            );    
    end;

    update atm_dispenser
    set terminal_id     = nvl(i_terminal_id,     terminal_id )
      , disp_number     = nvl(i_disp_number,     disp_number)
      , face_value      = nvl(i_face_value, face_value)
      , currency        = nvl(i_currency,        currency)
      , denomination_id = nvl(i_denomination_id, denomination_id)
      , dispenser_type  = nvl(i_dispenser_type,  dispenser_type)
    where id            = i_id;

    add_dispenser_history(
        i_dispenser_id     => i_id
      , i_terminal_id      => l_terminal_id
      , i_disp_number      => l_disp_number
      , i_face_value       => l_face_value 
      , i_currency         => l_currency
      , i_denomination_id  => l_denomination_id 
      , i_dispenser_type   => l_dispenser_type
    );       
        
end;

procedure remove_dispenser(
    i_id  in      com_api_type_pkg.t_medium_id
) is
begin
    delete atm_dispenser where id = i_id;
end;

procedure modify_disp_stat(
    i_dispenser_id          in      com_api_type_pkg.t_medium_id
  , i_note_dispensed        in      com_api_type_pkg.t_tiny_id
  , i_note_remained         in      com_api_type_pkg.t_tiny_id
  , i_note_rejected         in      com_api_type_pkg.t_tiny_id
  , i_note_loaded           in      com_api_type_pkg.t_tiny_id      default null
  , i_cassette_status       in      com_api_type_pkg.t_dict_value
) is
    l_terminal_id                   com_api_type_pkg.t_short_id;
    l_old_note_remained             com_api_type_pkg.t_tiny_id;
    l_old_note_rejected             com_api_type_pkg.t_tiny_id;
begin

    select terminal_id
    into   l_terminal_id
    from   atm_dispenser 
    where  id = i_dispenser_id;

    select nvl(min(dd.note_remained),0)
         , nvl(sum(dd.note_rejected),0)
    into   l_old_note_remained
         , l_old_note_rejected         
    from   atm_dispenser_dynamic dd
      join atm_dispenser ad on dd.id = ad.id
    where  ad.terminal_id = l_terminal_id;

    merge into atm_dispenser_dynamic a
    using (
           select i_dispenser_id    id
                , i_note_dispensed  note_dispensed
                , i_note_remained   note_remained
                , i_note_rejected   note_rejected
                , i_note_loaded     note_loaded
                , i_cassette_status cassete_status
             from dual
          ) b
       on (a.id = b.id)
    when matched then
        update
           set a.note_dispensed  = b.note_dispensed
             , a.note_remained   = b.note_remained
             , a.note_rejected   = b.note_rejected
             , a.note_loaded     = nvl(b.note_loaded, a.note_loaded)
             , a.cassette_status = cassete_status
    when not matched then
        insert (
            id
          , note_dispensed
          , note_remained
          , note_rejected
          , note_loaded
          , cassette_status
        ) values (
            b.id
          , b.note_dispensed
          , b.note_remained
          , b.note_rejected
          , b.note_loaded
          , b.cassete_status
        );
    
    register_dispenser_event (
        i_terminal_id       =>  l_terminal_id
      , i_old_note_remained =>  l_old_note_remained
      , i_old_note_rejected =>  l_old_note_rejected
    );
    
end;

procedure modify_disp_stat(
    i_dispenser_id_tab      in      com_api_type_pkg.t_number_tab
  , i_note_dispensed_tab    in      com_api_type_pkg.t_number_tab
  , i_note_remained_tab     in      com_api_type_pkg.t_number_tab
  , i_note_rejected_tab     in      com_api_type_pkg.t_number_tab
  , i_note_loaded_tab       in      com_api_type_pkg.t_number_tab
  , i_cassette_status_tab   in      com_api_type_pkg.t_dict_tab
) is
    l_terminal_id                   com_api_type_pkg.t_short_id;
    l_old_note_remained             com_api_type_pkg.t_tiny_id;
    l_old_note_rejected             com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug (
        i_text        => 'Request to update dispensers status [#1][#2][#3][#4][#5][#6]'
      , i_env_param1  => i_dispenser_id_tab.count
      , i_env_param2  => i_note_dispensed_tab.count
      , i_env_param3  => i_note_remained_tab.count
      , i_env_param4  => i_note_rejected_tab.count
      , i_env_param5  => i_note_loaded_tab.count
      , i_env_param6  => i_cassette_status_tab.count
    );

    for i in 1 .. i_dispenser_id_tab.count loop
        trc_log_pkg.debug (
            i_text        => 'Status data [#6]: id=[#1] dispenced=[#2] remained=[#3] rejected=[#4] loaded=[#5]'
          , i_env_param1  => i_dispenser_id_tab(i)
          , i_env_param2  => i_note_dispensed_tab(i)
          , i_env_param3  => i_note_remained_tab(i)
          , i_env_param4  => i_note_rejected_tab(i)
          , i_env_param5  => i_note_loaded_tab(i)
          , i_env_param6  => i
        );
    
        select terminal_id
        into   l_terminal_id
        from   atm_dispenser 
        where  id = i_dispenser_id_tab(i);

        select nvl(min(dd.note_remained),0)
             , nvl(sum(dd.note_rejected),0)
        into   l_old_note_remained
             , l_old_note_rejected         
        from   atm_dispenser_dynamic dd
          join atm_dispenser ad on dd.id = ad.id
        where  ad.terminal_id = l_terminal_id;
    
        merge into atm_dispenser_dynamic a
        using (
            select i_dispenser_id_tab(i)    id
                 , i_note_dispensed_tab(i)  note_dispensed
                 , i_note_remained_tab(i)   note_remained
                 , i_note_rejected_tab(i)   note_rejected
                 , i_note_loaded_tab(i)     note_loaded
                 , i_cassette_status_tab(i) cassette_status
              from dual
        ) b
        on ( a.id = b.id )
        when matched then
            update
            set a.note_dispensed  = b.note_dispensed
              , a.note_remained   = b.note_remained
              , a.note_rejected   = b.note_rejected
              , a.note_loaded     = nvl(b.note_loaded, a.note_loaded)
              , a.cassette_status = b.cassette_status
        when not matched then
            insert(
                id
              , note_dispensed
              , note_remained
              , note_rejected
              , note_loaded
              , cassette_status
            ) values (
                b.id
              , b.note_dispensed
              , b.note_remained
              , b.note_rejected
              , b.note_loaded
              , b.cassette_status
        );
        
        register_dispenser_event (
            i_terminal_id       =>  l_terminal_id
          , i_old_note_remained =>  l_old_note_remained
          , i_old_note_rejected =>  l_old_note_rejected
        );
        
    end loop;    

    trc_log_pkg.debug (
        i_text          => 'Update dispensers status done'
    );
end;

end;
/
