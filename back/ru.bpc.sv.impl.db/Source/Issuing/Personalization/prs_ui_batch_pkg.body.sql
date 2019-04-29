create or replace package body prs_ui_batch_pkg is
/************************************************************
 * User interface for perso batches <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 03.08.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_ui_batch_pkg <br />
 * @headcom
 ************************************************************/
    
    procedure add_batch (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_agent_id                in com_api_type_pkg.t_agent_id
        , i_product_id              in com_api_type_pkg.t_short_id
        , i_card_type_id            in com_api_type_pkg.t_tiny_id
        , i_blank_type_id           in com_api_type_pkg.t_tiny_id
        , i_card_count              in com_api_type_pkg.t_short_id
        , i_hsm_device_id           in com_api_type_pkg.t_tiny_id
        , i_status                  in com_api_type_pkg.t_dict_value
        , i_sort_id                 in com_api_type_pkg.t_tiny_id
        , i_perso_priority          in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_batch_name              in com_api_type_pkg.t_name
        , i_reissue_reason          in com_api_type_pkg.t_dict_value
        , i_force                   in com_api_type_pkg.t_boolean
    ) is
        l_check_cnt                 com_api_type_pkg.t_count := 0;
        l_batch_id                  com_api_type_pkg.t_short_id := null;
        LOG_PREFIX                  constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.add_batch: ';          
    begin
        trc_log_pkg.debug (
            i_text          => LOG_PREFIX || 'Start adding batch: i_batch_name = ' || i_batch_name 
                                          || ' i_inst_id = ' || i_inst_id 
                                          || ' i_agent_id = ' || i_agent_id 
                                          || ' i_product_id = ' || i_product_id
                                          || ' i_card_type_id = ' || i_card_type_id
                                          || ' i_blank_type_id = ' || i_blank_type_id
                                          || ' i_card_count = ' || i_card_count
                                          || ' i_hsm_device_id = ' || i_hsm_device_id
                                          || ' i_status = ' || i_status
                                          || ' i_sort_id = ' || i_sort_id
                                          || ' i_perso_priority = ' || i_perso_priority  
                                          || ' i_lang = ' || i_lang
                                          || ' i_reissue_reason = ' || i_reissue_reason
                                          || ' i_force = ' || i_force
        );
     
        if i_force = com_api_type_pkg.TRUE then 
            -- delete prev data if not processed 
            for tab in (
                select id 
                  from prs_batch
                 where batch_name = i_batch_name
            )
            loop
                l_batch_id :=  tab.id;   
            end loop;
            
            delete
              from prs_batch_vw
             where batch_name = i_batch_name
               and status != prs_api_const_pkg.BATCH_STATUS_PROCESSED;      -- only not processed items
        
            -- delete associated cards if any
            delete 
              from prs_batch_card_vw
             where batch_id = l_batch_id;
        else 
            select count(1)
              into l_check_cnt
              from prs_batch
             where batch_name = i_batch_name
               and inst_id = i_inst_id;
               
            if l_check_cnt > 0 then
                com_api_error_pkg.raise_error (
                    i_error           => 'BATCH_NAME_ALREADY_EXISTS'
                    , i_env_param1    => i_batch_name
                    , i_env_param2    => i_inst_id
                );
            end if;      
        end if;
             
        o_id := prs_batch_seq.nextval;
        o_seqnum := 1;
        
        insert into prs_batch_vw (
            id
            , seqnum
            , inst_id
            , agent_id
            , product_id
            , card_type_id
            , blank_type_id
            , card_count
            , hsm_device_id
            , status
            , sort_id
            , perso_priority
            , batch_name
            , reissue_reason
        ) values (
            o_id
            , o_seqnum
            , i_inst_id
            , i_agent_id
            , i_product_id
            , i_card_type_id
            , i_blank_type_id
            , i_card_count
            , i_hsm_device_id
            , i_status
            , nvl(i_sort_id, prs_api_const_pkg.DEFAULT_SORTING)
            , i_perso_priority
            , i_batch_name
            , i_reissue_reason
        );
    end;

    procedure modify_batch (
        i_id                        in com_api_type_pkg.t_short_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_product_id              in com_api_type_pkg.t_short_id
        , i_card_type_id            in com_api_type_pkg.t_tiny_id
        , i_blank_type_id           in com_api_type_pkg.t_tiny_id
        , i_card_count              in com_api_type_pkg.t_short_id
        , i_hsm_device_id           in com_api_type_pkg.t_tiny_id
        , i_sort_id                 in com_api_type_pkg.t_tiny_id
        , i_perso_priority          in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_batch_name              in com_api_type_pkg.t_name
        , i_status                  in com_api_type_pkg.t_dict_value
        , i_reissue_reason          in com_api_type_pkg.t_dict_value
    ) is
        l_check_cnt                 com_api_type_pkg.t_count := 0;
        l_inst_id                   com_api_type_pkg.t_tiny_id;
    begin
        select inst_id
          into l_inst_id
          from prs_batch
         where id = i_id;
             
        select
            count(*)
        into
            l_check_cnt
        from
            prs_batch_card_vw
        where
            batch_id = i_id;
        
        for r in (
            select
                product_id
                , card_type_id
                , blank_type_id
                , card_count
                , hsm_device_id
                , sort_id
                , perso_priority
            from
                prs_batch b
            where
                id = i_id
        ) loop
            if (r.product_id != i_product_id
               or r.card_type_id != i_card_type_id
               or r.blank_type_id != i_blank_type_id
               or r.card_count != i_card_count
               or r.hsm_device_id != i_hsm_device_id
               or r.sort_id != nvl(i_sort_id, prs_api_const_pkg.DEFAULT_SORTING)
               or r.perso_priority != i_perso_priority)
               and l_check_cnt > 0 then
                com_api_error_pkg.raise_error (
                    i_error        => 'BATCH_CANNOT_MODIFED'
                );
            end if;
        end loop;

        --check batch_name unique
        select count(1)
          into l_check_cnt
          from prs_batch
         where batch_name = i_batch_name
           and inst_id = l_inst_id
           and id != i_id;
           
        if l_check_cnt > 0 then
            com_api_error_pkg.raise_error (
                i_error           => 'BATCH_NAME_ALREADY_EXISTS'
                , i_env_param1    => i_batch_name
                , i_env_param2    => l_inst_id
            );
        end if;       

        update
            prs_batch_vw
        set
            seqnum = io_seqnum
            , product_id = i_product_id
            , card_type_id = i_card_type_id
            , blank_type_id = i_blank_type_id
            , card_count = i_card_count
            , hsm_device_id = i_hsm_device_id
            , sort_id = nvl(i_sort_id, prs_api_const_pkg.DEFAULT_SORTING)
            , perso_priority = i_perso_priority
            , status = nvl(i_status, status)
            , batch_name = nvl(i_batch_name, batch_name)
            , reissue_reason = nvl(i_reissue_reason, reissue_reason)
        where
            id = i_id;
            
        io_seqnum := io_seqnum + 1;
    end;

    procedure remove_batch (
        i_id                        in com_api_type_pkg.t_short_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
        l_check_cnt                 com_api_type_pkg.t_count := 0;
    begin
        select
            count(*)
        into
            l_check_cnt
        from
            prs_batch_vw
        where
            id = i_id
            and status = prs_api_const_pkg.BATCH_STATUS_PROCESSED;
        
        if l_check_cnt > 0 then
            com_api_error_pkg.raise_error (
                i_error        => 'BATCH_CANNOT_REMOVED'
            );
        end if;
        
        delete from
            prs_batch_card_vw
        where
            batch_id = i_id;
            
        com_api_i18n_pkg.remove_text (
            i_table_name   => 'prs_batch'
            , i_object_id  => i_id
        );
          
        update
            prs_batch_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;
            
        delete from
            prs_batch_vw
        where
            id = i_id;
    end;

    procedure clone_batch (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_batch_id                in com_api_type_pkg.t_short_id
        , i_batch_name              in com_api_type_pkg.t_name
        , i_pin_request             in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request      in com_api_type_pkg.t_dict_value
        , i_embossing_request       in com_api_type_pkg.t_dict_value
    ) is
    begin
        -- update instances 
        update iss_card_instance
           set pin_request        = i_pin_request
             , pin_mailer_request = i_pin_mailer_request
             , embossing_request  = i_embossing_request
         where id in ( 
            select card_instance_id 
              from prs_batch_card
             where batch_id = i_batch_id
        );    
    
        o_id := prs_batch_seq.nextval;
        o_seqnum := 1;

        insert into prs_batch (
            id
            , seqnum
            , inst_id
            , agent_id
            , product_id
            , card_type_id
            , blank_type_id
            , card_count
            , hsm_device_id
            , status
            , status_date
            , sort_id
            , perso_priority
            , batch_name
            , reissue_reason
        )
        select 
            o_id
             , o_seqnum
             , inst_id
             , agent_id
             , product_id
             , card_type_id
             , blank_type_id
             , card_count
             , hsm_device_id
             , prs_api_const_pkg.BATCH_STATUS_INITIAL
             , null
             , sort_id
             , perso_priority
             , i_batch_name
             , reissue_reason
         from
             prs_batch
         where
             id = i_batch_id;

        insert into prs_batch_card (
            id
            , batch_id
            , process_order
            , card_instance_id
            , pin_request
            , pin_generated
            , pin_mailer_request
            , pin_mailer_printed
            , embossing_request
            , embossing_done
        )
        select
            prs_batch_card_seq.nextval
            , o_id
            , null process_order
            , card_instance_id
            , i_pin_request
            , 0 pin_generated
            , i_pin_mailer_request
            , 0 pin_mailer_printed
            , i_embossing_request
            , 0 embossing_done            
        from
            prs_batch_card c
        where
            c.batch_id = i_batch_id;
    end;

    procedure clone_batch (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_batch_id                in com_api_type_pkg.t_short_id
        , i_batch_name              in com_api_type_pkg.t_name
        , i_instance_list           in num_tab_tpt
        , i_pin_request             in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request      in com_api_type_pkg.t_dict_value
        , i_embossing_request       in com_api_type_pkg.t_dict_value
    ) is
    begin
        -- update instances 
        update iss_card_instance
           set pin_request        = i_pin_request
             , pin_mailer_request = i_pin_mailer_request
             , embossing_request  = i_embossing_request
         where id in ( 
            select card_instance_id 
              from prs_batch_card
             where batch_id = i_batch_id
        );    
    
        o_id := prs_batch_seq.nextval;
        o_seqnum := 1;

        insert into prs_batch (
            id
            , seqnum
            , inst_id
            , agent_id
            , product_id
            , card_type_id
            , blank_type_id
            , card_count
            , hsm_device_id
            , status
            , status_date
            , sort_id
            , perso_priority
            , batch_name
            , reissue_reason
        )
        select
            o_id
            , o_seqnum
            , inst_id
            , agent_id
            , product_id
            , card_type_id
            , blank_type_id
            , card_count
            , hsm_device_id
            , prs_api_const_pkg.BATCH_STATUS_INITIAL
            , null
            , sort_id
            , perso_priority
            , i_batch_name
            , reissue_reason
        from
            prs_batch
        where
            id = i_batch_id;

        insert into prs_batch_card (
            id
            , batch_id
            , process_order
            , card_instance_id
            , pin_request
            , pin_generated
            , pin_mailer_request
            , pin_mailer_printed
            , embossing_request
            , embossing_done
        )
        select
            prs_batch_card_seq.nextval
            , o_id
            , null process_order
            , card_instance_id
            , i_pin_request
            , 0 pin_generated
            , i_pin_mailer_request
            , 0 pin_mailer_printed
            , i_embossing_request
            , 0 embossing_done
        from
            prs_batch_card c
        where
            c.card_instance_id in (select column_value as id from table(cast(i_instance_list as num_tab_tpt)))
            and c.batch_id = i_batch_id;
    end;

    procedure clone_batch (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_batch_id                in com_api_type_pkg.t_short_id
        , i_batch_name              in com_api_type_pkg.t_name
        , i_first_row               in com_api_type_pkg.t_tiny_id
        , i_last_row                in com_api_type_pkg.t_tiny_id default null
        , i_pin_request             in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request      in com_api_type_pkg.t_dict_value
        , i_embossing_request       in com_api_type_pkg.t_dict_value
    ) is
        l_cursor_sql                com_api_type_pkg.t_text;
        l_sort_id                   com_api_type_pkg.t_short_id;
        l_status                    com_api_type_pkg.t_dict_value;
        l_order_by                  com_api_type_pkg.t_text;
        
    begin
    
        begin
            select
                sort_id
              , status  
            into
                l_sort_id
              , l_status
            from
                prs_sort s
                , prs_batch b
            where
                b.sort_id = s.id
                and b.id = i_batch_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error         => 'PRS_BATCH_NOT_FOUND'
                    , i_env_param1  => i_batch_id
                );
        end;

        -- update instances 
        update iss_card_instance
           set pin_request        = i_pin_request
             , pin_mailer_request = i_pin_mailer_request
             , embossing_request  = i_embossing_request
         where id in ( 
            select card_instance_id 
              from prs_batch_card
             where batch_id = i_batch_id
        );    

        o_id := prs_batch_seq.nextval;
        o_seqnum := 1;
        
        insert into prs_batch (
            id
            , seqnum
            , inst_id
            , agent_id
            , product_id
            , card_type_id
            , blank_type_id
            , card_count
            , hsm_device_id
            , status
            , status_date
            , sort_id
            , perso_priority
            , batch_name
            , reissue_reason
        )
        select
            o_id
            , o_seqnum
            , inst_id
            , agent_id
            , product_id
            , card_type_id
            , blank_type_id
            , card_count
            , hsm_device_id
            , prs_api_const_pkg.BATCH_STATUS_INITIAL
            , null
            , sort_id
            , perso_priority
            , i_batch_name
            , reissue_reason
        from
            prs_batch
        where
            id = i_batch_id;

        l_order_by := nvl(prs_api_card_pkg.enum_sort_condition(l_sort_id), 'card_instance_id');
                        
        l_cursor_sql := l_cursor_sql || '
insert into prs_batch_card (
    id
    , batch_id
    , process_order
    , card_instance_id
    , pin_request
    , pin_generated
    , pin_mailer_request
    , pin_mailer_printed
    , embossing_request
    , embossing_done
) select
    prs_batch_card_seq.nextval
    , x.new_batch_id batch_id
    , null process_order
    , x.card_instance_id
    , ci.pin_request
    , 0 pin_generated
    , ci.pin_mailer_request
    , 0 pin_mailer_printed
    , ci.embossing_request
    , 0 embossing_done
from (
    select
        bc.card_instance_id
        , row_number() over (order by '|| l_order_by ||') rn
        , p.new_batch_id
        , p.first_row
        , p.last_row
    from
        prs_ui_batch_card_vw bc
        , ( select
                :new_batch_id new_batch_id
                , :clone_batch_id batch_id
                , :first_row first_row
                , :last_row last_row
            from
                dual
        ) p
    where
        bc.batch_id = p.batch_id
) x
, iss_card_instance ci
where x.rn >= x.first_row
and (x.rn <= x.last_row or x.last_row is null)
and ci.id = x.card_instance_id';

        trc_log_pkg.debug (
            i_text         => l_cursor_sql
        );
        execute immediate l_cursor_sql
        using
            o_id
            , i_batch_id
            , i_first_row
            , i_last_row;
    exception
        when others then
            trc_log_pkg.debug (
                i_text         => sqlerrm
            );
            raise;

    end;

end; 
/
