create or replace package body com_ui_reject_pkg is
/*********************************************************
*  UI for Reject Management module <br />
*  Created by Mashonkin V.(mashonkin@bpcbt.com)  at 02.07.2015 <br />
*  Last changed by $Author: mashonkin $ <br />
*  $LastChangedDate:: 2015-07-02 12:28:48 +0300#$ <br />
*  Revision: $LastChangedRevision: 52735 $ <br />
*  Module: com_ui_reject_pkg <br />
*  @headcom
**********************************************************/
    function i_get_network(i_reject_id in com_api_type_pkg.t_long_id)
      return com_api_type_pkg.t_dict_value
    is 
        l_vis_cnt com_api_type_pkg.t_long_id;
        l_mcw_cnt com_api_type_pkg.t_long_id;
    begin

        select count(id)
          into l_vis_cnt
          from vis_reject_data
         where original_id = i_reject_id;
        --
        select count(id)
          into l_mcw_cnt
          from mcw_reject_data
         where original_id = i_reject_id;
      
      return case when l_vis_cnt>0 then vis_api_const_pkg.MODULE_CODE_VISA 
                  when l_mcw_cnt>0 then mcw_api_const_pkg.MODULE_CODE_MASTERCARD 
                  else null
             end; 
       
    end;
    -- use case "Edit operation field"
    procedure update_field_value(
        i_table_name        in com_api_type_pkg.t_name
        , i_pk_field_name   in com_api_type_pkg.t_name
        , i_pk_value        in com_api_type_pkg.t_text
        , i_upd_field_name  in com_api_type_pkg.t_name
        , i_upd_value       in com_api_type_pkg.t_text
        , i_pk2_field_name  in com_api_type_pkg.t_name default null
        , i_pk2_value       in com_api_type_pkg.t_text default null        
    )
    is
        l_pk_value  com_api_type_pkg.t_long_id := i_pk_value;
        l_query     com_api_type_pkg.t_text;
        l_data_type com_api_type_pkg.t_text;
        l_cnt       com_api_type_pkg.t_long_id;
            l_fnc       com_api_type_pkg.t_text := 'update_field_value';
        --
        l_table_name      com_api_type_pkg.t_name := upper(trim(i_table_name));
        l_pk_field_name   com_api_type_pkg.t_name := upper(trim(i_pk_field_name));   
        l_upd_field_name  com_api_type_pkg.t_name := upper(trim(i_upd_field_name));
        --
        l_number_value    com_api_type_pkg.t_long_id;
        l_date_value      date;
        l_check_passed    com_api_type_pkg.t_boolean := com_api_type_pkg.false;
        --
        l_id              com_api_type_pkg.t_long_id;
        l_updated_oper_id com_api_type_pkg.t_long_id;

        l_network         com_api_type_pkg.t_dict_value;
    begin
        trc_log_pkg.debug(i_text =>
            'i_table_name ['||i_table_name||']' ||        
            ' i_pk_field_name [' || i_pk_field_name ||']'||
            ' i_pk_value_pk_value [' || i_pk_value ||']'||
            ' i_upd_field_name [' || i_upd_field_name ||']'||
            ' i_upd_value [' || i_upd_value ||']'
        );
        
        -- check if dulicate need to be made
        --    if comes i_pk_value = updated_oper_id it will not create duplicate again
        --    because there will be no *rejected_data with original_id = updated_oper_id
        if upper(i_table_name) in (
            C_TABL_OPR_OPERATION
            , C_TABL_OPR_PARTICIPANT
            , C_TABL_VIS_FIN_MESSAGE
            , C_TABL_MCW_FIN
        )
        then
            
            l_network := i_get_network (i_pk_value); 

            -- visa
            if l_network = vis_api_const_pkg.MODULE_CODE_VISA  then
                select id
                     , updated_oper_id
                  into l_id
                     , l_updated_oper_id
                  from vis_reject_data
                 where original_id = i_pk_value;
                --
                if l_updated_oper_id is null then
                    --
                    l_updated_oper_id := 
                        vis_api_reject_pkg.create_duplicate_operation(
                            i_oper_id        => i_pk_value
                        );
                    --
                    update vis_reject_data
                       set updated_oper_id = l_updated_oper_id
                     where id = l_id;
                    --
                    l_pk_value := l_updated_oper_id;
                end if;
            -- mastercard
            elsif l_network = mcw_api_const_pkg.MODULE_CODE_MASTERCARD  then
                select id
                     , updated_oper_id
                  into l_id
                     , l_updated_oper_id
                  from mcw_reject_data
                 where original_id = i_pk_value;
                --
                if l_updated_oper_id is null then
                    --
                    l_updated_oper_id := 
                        mcw_api_reject_pkg.create_duplicate_operation(
                            i_oper_id        => i_pk_value
                            , i_fin_msg_type => com_api_reject_pkg.C_NETW_MASTERCARD
                        );
                    --
                    update mcw_reject_data
                       set updated_oper_id = l_updated_oper_id
                     where id = l_id;
                    --
                    l_pk_value := l_updated_oper_id;
                end if;
            --
            else
                trc_log_pkg.error(
                    i_text       => l_fnc ||': Operation [#1] not found in rejected data.'
                  , i_env_param1 => l_pk_value
                );
            end if;
        end if;
        
        -- update must executes on view, not on table, because 
        -- there should be an "instead of update" trigger with saving data into historical tables (ADT_TRAIL è ADT_DETAIL)
        -- table name must present in ADT_ENTITY table with flag is_active=1
        if upper(trim(i_upd_field_name)) = 'ID' then
            trc_log_pkg.error(
                i_text       => l_fnc ||': pk_field [#1] of table [#2] can not be updated.'
              , i_env_param1 => l_pk_field_name
              , i_env_param2 => upper(trim(i_table_name))
            );
        else
            --
            select count(1)
              into l_cnt
              from user_tab_columns
             where table_name  = l_table_name
               and column_name in (l_pk_field_name, 
                                   l_upd_field_name);
            --
            if nvl(l_cnt, 0) != 2 then
                trc_log_pkg.error(
                    i_text       => l_fnc ||': pk_field [#1] or upd_field [#2] or table [#3] not found.'
                  , i_env_param1 => l_pk_field_name
                  , i_env_param2 => l_upd_field_name
                  , i_env_param3 => l_table_name
                );
            else
                select upper(data_type)
                  into l_data_type
                  from user_tab_columns
                 where table_name  = l_table_name
                   and column_name = l_upd_field_name;
                --
                begin
                    if l_data_type    = 'NUMBER' then
                        l_number_value := to_number(i_upd_value, com_api_const_pkg.number_format); -- 'FM000000000000000000.0000'
                    elsif l_data_type = 'DATE' then
                        l_date_value   := to_date(i_upd_value, com_api_const_pkg.date_format); -- YYYYMMDDHH24MISS
                    end if;
                    l_check_passed := com_api_type_pkg.true;
                exception
                    when others then
                    trc_log_pkg.error(
                        i_text       => l_fnc ||': Wrong value [#1] of upd_field [#2] of table [#3], field data_type [#4]'
                      , i_env_param1 => i_upd_value
                      , i_env_param2 => l_upd_field_name
                      , i_env_param3 => l_table_name
                      , i_env_param4 => l_data_type
                    );
                    l_check_passed := com_api_type_pkg.false;
                end;
                --
                if l_check_passed = com_api_type_pkg.true 
                then
                    l_query := 'select count(' || i_pk_field_name || ')' || 
                                ' from ' || i_table_name || 
                               ' where ' || i_pk_field_name || ' = :l_pk_value';
                    
                    if i_pk2_field_name is not null then
                        l_query := l_query||' and '||i_pk2_field_name||' = :l_pk2_value ';
                        execute immediate l_query into l_cnt using l_pk_value, i_pk2_value;
                      else
                        execute immediate l_query into l_cnt using l_pk_value;   
                    end if;                                          
                               
                    --
                    if l_cnt = 0 then
                        trc_log_pkg.warn(
                            i_text       => l_fnc ||': Nothing to update. column [#1] or table [#2].'
                          , i_env_param1  => l_table_name
                          , i_env_param2  => l_upd_field_name
                        );
                    elsif l_cnt > 1 then
                          trc_log_pkg.error(
                              i_text       => l_fnc ||': Too many rows to update. column [#1] or table [#2].'
                            , i_env_param1  => l_table_name
                            , i_env_param2  => l_upd_field_name
                          );
                    elsif l_cnt = 1 then
                        l_query := 'update ' || i_table_name || ' set ' || i_upd_field_name ||' = ';
                        if l_data_type = 'NUMBER' then
                            l_query := l_query || 'to_char(:i_upd_value, ''' || com_api_const_pkg.number_format || ''')'; -- 'FM000000000000000000.0000'
                        elsif l_data_type = 'DATE' then
                            l_query := l_query || 'to_date(:i_upd_value, ''' || com_api_const_pkg.date_format || ''')'; -- 'FM000000000000000000.0000'
                        else
                            l_query := l_query || ':i_upd_value';
                        end if;
                        
                        l_query := l_query || ' where ' || i_pk_field_name  || ' = :l_pk_value';

                        if i_pk2_field_name is not null then
                            
                            l_query := l_query||' and '|| i_pk2_field_name ||' = :l_pk2_value ';
                            
                            trc_log_pkg.debug(i_text => l_query || '; i_upd_value ['||i_upd_value||'] l_pk_value ['||l_pk_value||'] l_pk2_value ['||i_pk2_value||']');
                            --
                            
                            execute immediate l_query using i_upd_value, l_pk_value, i_pk2_value;
                          else
                            --
                            trc_log_pkg.debug(i_text => l_query || '; i_upd_value ['||i_upd_value||'] l_pk_value ['||l_pk_value||']');
                            --
                            execute immediate l_query using i_upd_value, l_pk_value;   
                        end if;  

                    end if;
                end if;
            end if;
        end if;    
    exception
        when com_api_error_pkg.e_application_error then
            raise;
        when com_api_error_pkg.e_fatal_error then
            raise;
        when others then
            trc_log_pkg.error(
                i_text       => l_fnc ||': column [#1], table [#2]. ' || substr(sqlerrm, 1, 200)
              , i_env_param1  => l_table_name
              , i_env_param2  => l_upd_field_name
            );
    end update_field_value;

    -- use case "Assign reject to user"
    procedure assign_reject (
        i_reject_id        in com_api_type_pkg.t_long_id
        , i_user_id        in com_api_type_pkg.t_long_id
    )
    is
        l_network         com_api_type_pkg.t_dict_value;

    begin
        l_network := i_get_network (i_reject_id);
            
        -- visa
        if l_network = vis_api_const_pkg.MODULE_CODE_VISA then
            update vis_reject_data_vw
               set assigned  = i_user_id
             where reject_id = i_reject_id;
        -- mastercard
        elsif l_network = mcw_api_const_pkg.MODULE_CODE_MASTERCARD then
            update mcw_reject_data_vw
               set assigned  = i_user_id
             where reject_id = i_reject_id;
        else
            trc_log_pkg.error(
                i_text       => 'Reject not found [#1].'
              , i_env_param1  => i_reject_id
            );
        end if;
    exception
        when com_api_error_pkg.e_application_error then
            raise;
        when com_api_error_pkg.e_fatal_error then
            raise;
        when others then
            com_api_error_pkg.raise_fatal_error(
                i_error => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => SQLERRM
            );
    end assign_reject;
    
    -- use case "Action on reject"
    procedure change_oper_status (
        i_action    in com_api_type_pkg.t_dict_value
      , i_oper_id   in com_api_type_pkg.t_long_id
    )
    is
        l_vis_reject_id   com_api_type_pkg.t_long_id;
        l_mcw_reject_id   COM_API_TYPE_PKG.t_long_id;
        l_is_incoming     com_api_type_pkg.t_boolean;
        l_is_rej_op_stage com_api_type_pkg.t_boolean;
        
        l_status          com_api_type_pkg.t_dict_value;
        l_fin_rec         mcw_api_type_pkg.t_fin_rec;
        l_host_id         com_api_type_pkg.t_tiny_id;
        l_standard_id     com_api_type_pkg.t_tiny_id;
    begin
        begin
            select r.id
                 , f.is_incoming
              into l_vis_reject_id
                 , l_is_incoming
              from vis_reject_data r
              join vis_fin_message f on (f.id = r.original_id) 
             where r.original_id = i_oper_id;
        exception 
            when no_data_found then
                begin 
                    select r.id
                         , m.is_incoming
                      into l_mcw_reject_id
                         , l_is_incoming
                      from mcw_reject_data r
                      join mcw_fin         m on (m.id = r.original_id) 
                     where r.original_id = i_oper_id;
                exception 
                    when no_data_found then
                        trc_log_pkg.error(
                            i_text       => 'Reject not found for operation [#1].'
                          , i_env_param1 => i_oper_id
                        );
                end;
        end;                     
        --
        select 
            case when exists 
            (select 1 
                from opr_oper_stage 
               where oper_id    = i_oper_id
                 and proc_stage = opr_api_const_pkg.PROCESSING_STAGE_REJECTED
                 and status     = com_api_reject_pkg.OPER_STATUS_REJECTED
            ) then 1
            else 0 
            end 
         into l_is_rej_op_stage
         from dual;
        --
        case i_action -- RJMD 'Reject resolution mode'
            when com_api_reject_pkg.REJECT_RESOLUT_MODE_FORWARD    then --'RJMD0001'
                -- 1
                if l_is_incoming = com_api_type_pkg.true then
                    --
                    
                    if l_vis_reject_id is not null then
                        opr_ui_operation_pkg.modify_status (
                            i_oper_id         => i_oper_id
                            , i_oper_status   => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                        );
                    elsif l_mcw_reject_id is not null then
                        mcw_api_fin_pkg.get_fin(
                           i_id     => i_oper_id
                           , o_fin_rec   => l_fin_rec
                        );
                        
                        l_host_id := net_api_network_pkg.get_default_host(l_fin_rec.network_id);
                        l_standard_id := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);                        
                        
                        l_status := mcw_api_fin_pkg.get_status(
                              i_network_id  => l_fin_rec.network_id
                            , i_host_id     => l_host_id
                            , i_standard_id => l_standard_id
                            , i_inst_id     => l_fin_rec.inst_id);
                            
                        opr_ui_operation_pkg.modify_status (
                            i_oper_id         => i_oper_id
                            , i_oper_status   => nvl(l_status, opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY)
                        );
                    end if;
                else
                    if l_vis_reject_id is not null then
                        --
                        update vis_fin_message 
                           set status = NET_API_CONST_PKG.CLEARING_MSG_STATUS_READY -- 'CLMS0010'
                         where id = i_oper_id;
                    --
                    elsif l_mcw_reject_id is not null then
                        --
                        update mcw_fin 
                           set status = NET_API_CONST_PKG.CLEARING_MSG_STATUS_READY -- 'CLMS0010'
                         where id = i_oper_id;
                    end if;
                end if;
                -- 2
                if l_is_rej_op_stage = com_api_type_pkg.false then
                    insert into opr_oper_stage (
                        oper_id
                        , proc_stage
                        , exec_order
                        , status
                        , split_hash
                    ) values (
                        i_oper_id
                        , opr_api_const_pkg.PROCESSING_STAGE_REJECTED
                        , 1
                        , com_api_reject_pkg.OPER_STATUS_REJECTED
                        , com_api_hash_pkg.get_split_hash(opr_api_const_pkg.ENTITY_TYPE_OPERATION, i_oper_id)
                    );
                end if;
                -- 3
                if l_vis_reject_id is not null then
                    --
                    update vis_reject_data_vw
                       set status = com_api_reject_pkg.REJECT_STATUS_RESOLVED -- RJST0003
                           ,RESOLUTION_DATE = sysdate
                           ,RESOLUTION_MODE = i_action
                     where id = l_vis_reject_id;
                --
                elsif l_mcw_reject_id is not null then
                    --
                    update mcw_reject_data_vw
                       set status = com_api_reject_pkg.REJECT_STATUS_RESOLVED -- RJST0003
                           ,RESOLUTION_DATE = sysdate
                           ,RESOLUTION_MODE = i_action
                     where id = l_mcw_reject_id;
                end if;
            when com_api_reject_pkg.REJECT_RESOLUT_MODE_CANCELED   then --'RJMD0002'
                --
                if l_vis_reject_id is not null then
                    --
                    update vis_reject_data_vw
                       set status = com_api_reject_pkg.REJECT_STATUS_CLOSED -- RJST0002
                           ,RESOLUTION_DATE = sysdate
                           ,RESOLUTION_MODE = i_action                       
                     where id = l_vis_reject_id;
                --
                elsif l_mcw_reject_id is not null then
                    --
                    update mcw_reject_data_vw
                       set status = com_api_reject_pkg.REJECT_STATUS_CLOSED -- RJST0002
                           ,RESOLUTION_DATE = sysdate
                           ,RESOLUTION_MODE = i_action                       
                     where id = l_mcw_reject_id;
                end if;
            when com_api_reject_pkg.REJECT_RESOLUT_MODE_NO_ACTIONS then --'RJMD0003'
                trc_log_pkg.warn(
                    i_text       => 'No activities should be done for Action [#1].'
                  , i_env_param1 => i_action
                );
            else
                trc_log_pkg.error(
                    i_text       => 'Action not allwed [#1].'
                  , i_env_param1 => i_action
                );
        end case;
    exception
        when com_api_error_pkg.e_application_error then
            raise;
        when com_api_error_pkg.e_fatal_error then
            raise;
        when others then
            com_api_error_pkg.raise_fatal_error(
                i_error => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => SQLERRM
            );
    end change_oper_status;

    procedure get_list_of_group (
       i_id                      in com_api_type_pkg.t_long_id
       , i_lang                  in com_api_type_pkg.t_dict_value
       , o_group_list          out com_api_type_pkg.t_ref_cur
    )
    is

       l_network         com_api_type_pkg.t_dict_value;
    begin
        l_network := i_get_network (i_id);
            
        -- visa
        if l_network = vis_api_const_pkg.MODULE_CODE_VISA then
          
           open o_group_list for 
            select ELEMENT_VALUE, LABEL
            from com_ui_array_element_vw
            where array_id = 10000039 
            and lang = i_lang;
            
        -- mastercard
        elsif l_network = mcw_api_const_pkg.MODULE_CODE_MASTERCARD then
        
           open o_group_list for 
            select ELEMENT_VALUE, LABEL
            from com_ui_array_element_vw
            where array_id = 10000038 
            and lang = i_lang;
            
        end if;
   
    end;
    
    procedure get_list_of_user (
       i_group                      in com_api_type_pkg.t_long_id
       , i_lang                  in com_api_type_pkg.t_dict_value
       , o_user_list          out com_api_type_pkg.t_ref_cur
    )
    is
    begin
      open o_user_list for
      select u.user_id, 
             u.user_name
       from acm_ui_user_vw u, acm_user_role ur 
       where lang = i_lang
       and ur.role_id = i_group
       and ur.user_id = u.user_id;
    end;
        
   
    
begin
  null;
end com_ui_reject_pkg;
/

