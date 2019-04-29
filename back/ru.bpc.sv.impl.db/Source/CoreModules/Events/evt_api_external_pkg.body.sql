create or replace package body evt_api_external_pkg as

procedure get_events(
    i_procedure_name    in      com_api_type_pkg.t_oracle_name
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null  
  , i_start_date        in      date                                default null
  , i_end_date          in      date                                default null
  , i_status            in      com_api_type_pkg.t_dict_value       default EVT_API_CONST_PKG.EVENT_STATUS_READY
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , o_row_count            out  com_api_type_pkg.t_long_id
  , o_ref_cursor           out  com_api_type_pkg.t_ref_cur
) is
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_split_hash        com_api_type_pkg.t_tiny_id;
    l_id_from           com_api_type_pkg.t_long_id;
    l_id_to             com_api_type_pkg.t_long_id;
    l_start_date        date;
    l_end_date          date;
    l_query             com_api_type_pkg.t_text := q'!
        select o.id
             , e.event_type
             , o.procedure_name
             , o.entity_type
             , o.object_id
             , o.eff_date
             , o.inst_id
             , o.split_hash
             , o.status
          from evt_event_object o
          join evt_event e      on e.id             = o.event_id
          join evt_subscriber s on e.event_type     = s.event_type
                               and o.procedure_name = s.procedure_name
         where :STATUS_CONDITION: = :i_procedure_name
           and o.eff_date       between :l_start_date and :l_end_date
           and (o.split_hash    = :l_split_hash  or :l_split_hash  is null)
           and (o.entity_type   = :l_entity_type or :l_entity_type is null)
           and (o.object_id     = :l_object_id   or :l_object_id   is null)
           and (o.inst_id       = :l_inst_id     or :l_inst_id = 9999)
           and o.split_hash in (select split_hash from com_api_split_map_vw)
           and o.id between :l_id_from and :l_id_to
    !';
    l_cnt_query             com_api_type_pkg.t_text := 'select count(*) from (' || l_query || ')';
    
    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_events: ';
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'START i_procedure_name [' || i_procedure_name || '] i_inst_id [' || i_inst_id ||
              '] i_entity_type [' || i_entity_type || '] i_object_id [' || i_object_id || '] i_start_date [' || i_start_date ||
              '] i_end_date [' || i_end_date || '] i_status [' || i_status || '] i_split_hash [' || i_split_hash || ']'
    );
    
    -- determine missed parameters
    if i_start_date is null then
        l_start_date := com_api_sttl_day_pkg.get_sysdate;
    else
        l_start_date := i_start_date;
    end if;

    if i_end_date is null then
        l_end_date := com_api_sttl_day_pkg.get_sysdate + 1 - com_api_const_pkg.ONE_SECOND;
    else
        l_end_date := i_end_date;
    end if;

    if i_split_hash is null and i_object_id is not null and i_entity_type is not null then
        l_split_hash := com_api_hash_pkg.get_split_hash(
            i_entity_type   =>  i_entity_type
          , i_object_id     =>  i_object_id
        );
    else 
        l_split_hash := i_split_hash;   
    end if;        
    
    if i_inst_id is null then
        l_inst_id := com_ui_user_env_pkg.get_user_inst;
    else
        l_inst_id := i_inst_id; 
    end if;

    l_id_from := com_api_id_pkg.get_from_id(l_start_date);
    l_id_to   := com_api_id_pkg.get_till_id(l_end_date);
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'l_split_hash=' || l_split_hash || ' l_inst_id=' || l_inst_id
    );
           
    if i_status = EVT_API_CONST_PKG.EVENT_STATUS_READY then
        l_query := replace(l_query, ':STATUS_CONDITION:', 'decode(o.status, ''EVST0001'', o.procedure_name, null) ');
    else
        l_query := replace(l_query, ':STATUS_CONDITION:', 'o.status = ''' || i_status || ''' and o.procedure_name');
    end if;        
    
    l_cnt_query := 'select count(*) from (' || l_query || ')';
    
    trc_log_pkg.debug(
        i_text => l_query
    );    
    
    execute immediate l_cnt_query 
                 into o_row_count
                using i_procedure_name
                    , l_start_date
                    , l_end_date
                    , l_split_hash
                    , l_split_hash
                    , i_entity_type
                    , i_entity_type
                    , i_object_id
                    , i_object_id
                    , l_inst_id
                    , l_inst_id
                    , l_id_from
                    , l_id_to;
    
    open o_ref_cursor for l_query
                using i_procedure_name
                    , l_start_date
                    , l_end_date
                    , l_split_hash
                    , l_split_hash
                    , i_entity_type
                    , i_entity_type
                    , i_object_id
                    , i_object_id
                    , l_inst_id
                    , l_inst_id
                    , l_id_from
                    , l_id_to;
    
    trc_log_pkg.debug(LOG_PREFIX || 'END with ' || o_row_count);
end;

end evt_api_external_pkg;
/
