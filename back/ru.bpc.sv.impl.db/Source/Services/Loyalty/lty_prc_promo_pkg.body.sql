create or replace package body lty_prc_promo_pkg is

BULK_LIMIT             constant pls_integer := 100;

procedure check_promotion_level(
    i_inst_id                    in     com_api_type_pkg.t_inst_id
  , i_lang                       in     com_api_type_pkg.t_dict_value default null
) is

    type t_object is record(
        event_object_id com_api_type_pkg.t_long_id
      , object_id       com_api_type_pkg.t_medium_id
      , object_type     com_api_type_pkg.t_dict_value
      , split_hash      com_api_type_pkg.t_tiny_id
      , product_id      com_api_type_pkg.t_short_id
      , contract_id     com_api_type_pkg.t_medium_id
      , contract_type   com_api_type_pkg.t_dict_value
      , seqnum          com_api_type_pkg.t_tiny_id
      , end_date        date
      , event_type      com_api_type_pkg.t_dict_value
    );
    type t_object_tab is table of t_object index by pls_integer;
    l_object_tab                        t_object_tab;
    l_processed_tab                     com_api_type_pkg.t_number_tab;

    l_event_date                        date;
    l_cur_check_promo_level_list        com_api_type_pkg.t_count := 0;

    l_service_id                        com_api_type_pkg.t_short_id;
    l_eff_date                          date;
    l_promo_algorithm_attr_value        com_api_type_pkg.t_dict_value;
    l_com_product_id                    com_api_type_pkg.t_short_id;
    l_label                             com_api_type_pkg.t_name;
    l_description                       com_api_type_pkg.t_full_desc;
    l_lang                              com_api_type_pkg.t_dict_value;

    l_excepted_count                    com_api_type_pkg.t_count := 0;
    l_processed_count                   com_api_type_pkg.t_count := 0;

    cursor cur_check_promo_level_l is
        select sum("count")
          from (select count(1) "count"
                  from evt_event_object e
                     , acc_account      acc
                 where decode(e.status, 'EVST0001', e.procedure_name, null) = 'LTY_PRC_PROMO_PKG.CHECK_PROMOTION_LEVEL'
                   and e.split_hash in (select split_hash from com_api_split_map_vw)
                   and e.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                   and acc.id = e.object_id
                   and nvl2(i_inst_id, acc.inst_id, ost_api_const_pkg.DEFAULT_INST) = nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
                 union all
                 select count(1) "count"
                  from evt_event_object e
                     , iss_card         ca
                 where decode(e.status, 'EVST0001', e.procedure_name, null) = 'LTY_PRC_PROMO_PKG.CHECK_PROMOTION_LEVEL'
                   and e.split_hash in (select split_hash from com_api_split_map_vw)
                   and e.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                   and ca.id = e.object_id
                   and nvl2(i_inst_id, ca.inst_id, ost_api_const_pkg.DEFAULT_INST) = nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
           );

    cursor cur_check_promo_level is
        select e.id                                  as event_object_id
             , acc.id                                as object_id
             , acc_api_const_pkg.ENTITY_TYPE_ACCOUNT as object_type
             , acc.split_hash                        as split_hash
             , con.product_id                        as product_id
             , con.id                                as contract_id
             , con.contract_type
             , con.seqnum
             , con.end_date
             , e.event_type
          from evt_event_object e
             , acc_account      acc
             , prd_contract     con
         where decode(e.status, 'EVST0001', e.procedure_name, null) = 'LTY_PRC_PROMO_PKG.CHECK_PROMOTION_LEVEL'
           and e.split_hash in (select split_hash from com_api_split_map_vw)
           and e.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
           and acc.id = e.object_id
           and nvl2(i_inst_id, acc.inst_id, ost_api_const_pkg.DEFAULT_INST) = nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
           and con.id = acc.contract_id
        union all
        select e.id                                  as event_object_id
             , ca.id                                 as object_id
             , iss_api_const_pkg.ENTITY_TYPE_CARD    as object_type
             , ca.split_hash                         as split_hash
             , con.product_id                        as product_id
             , con.id                                as contract_id
             , con.contract_type
             , con.seqnum
             , con.end_date
             , e.event_type
          from evt_event_object e
             , iss_card         ca
             , prd_contract     con
         where decode(e.status, 'EVST0001', e.procedure_name, null) = 'LTY_PRC_PROMO_PKG.CHECK_PROMOTION_LEVEL'
           and e.split_hash in (select split_hash from com_api_split_map_vw)
           and e.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
           and ca.id = e.object_id
           and nvl2(i_inst_id, ca.inst_id, ost_api_const_pkg.DEFAULT_INST) = nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
           and con.id = ca.contract_id;

begin
    trc_log_pkg.debug(
        i_text       => 'Cheking promotial level: START, i_inst_id[#1]'
      , i_env_param1 => i_inst_id 
    );

    prc_api_stat_pkg.log_start;

    l_event_date := get_sysdate;
    l_eff_date   := com_api_sttl_day_pkg.get_sysdate;

    open cur_check_promo_level_l;
    fetch cur_check_promo_level_l into l_cur_check_promo_level_list;
    close cur_check_promo_level_l;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_cur_check_promo_level_list
    );

    savepoint sp_process;

    if l_cur_check_promo_level_list > 0 then
        l_lang := coalesce(i_lang, com_ui_user_env_pkg.get_user_lang());

        open cur_check_promo_level;
        loop
            fetch cur_check_promo_level bulk collect into l_object_tab limit BULK_LIMIT;

            for i in 1 .. l_object_tab.count loop
                savepoint sp_record;

                trc_log_pkg.debug(
                    i_text       => 'Processing contract ID [#1], object type [#2], object ID [#3]'
                  , i_env_param1 => l_object_tab(i).contract_id
                  , i_env_param2 => l_object_tab(i).object_type
                  , i_env_param3 => l_object_tab(i).object_id
                );

                begin
                    l_service_id :=
                        prd_api_service_pkg.get_active_service_id(
                            i_entity_type    => l_object_tab(i).object_type
                          , i_object_id      => l_object_tab(i).object_id
                          , i_attr_type      => case l_object_tab(i).object_type
                                                     when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                         then lty_api_const_pkg.LOYALTY_PROM_LEV_THRES_CYC_ACC
                                                     when iss_api_const_pkg.ENTITY_TYPE_CARD
                                                         then lty_api_const_pkg.LOYALTY_PROM_LEV_THRES_CYC_CAR
                                                end
                          , i_eff_date       => l_eff_date
                        );

                    l_promo_algorithm_attr_value :=
                        prd_api_product_pkg.get_attr_value_char(
                            i_product_id     => l_object_tab(i).product_id
                          , i_entity_type    => l_object_tab(i).object_type
                          , i_object_id      => l_object_tab(i).object_id
                          , i_attr_name      => case l_object_tab(i).object_type
                                                     when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                         then lty_api_const_pkg.LOYALTY_ATTR_PROM_ALGORITH_ACC
                                                     when iss_api_const_pkg.ENTITY_TYPE_CARD
                                                         then lty_api_const_pkg.LOYALTY_ATTR_PROM_ALGORITH_CAR
                                                end
                          , i_params         => evt_api_shared_data_pkg.g_params
                        );

                    lty_api_algo_proc_pkg.set_param(i_name => 'EVENT_TYPE'    , i_value => l_object_tab(i).event_type);
                    lty_api_algo_proc_pkg.set_param(i_name => 'EFFECTIVE_DATE', i_value => l_event_date);
                    lty_api_algo_proc_pkg.set_param(i_name => 'ENTITY_TYPE'   , i_value => l_object_tab(i).object_type);
                    lty_api_algo_proc_pkg.set_param(i_name => 'OBJECT_ID'     , i_value => l_object_tab(i).object_id);
                    lty_api_algo_proc_pkg.set_param(i_name => 'INST_ID'       , i_value => i_inst_id);
                    lty_api_algo_proc_pkg.set_param(i_name => 'SPLIT_HASH'    , i_value => l_object_tab(i).split_hash);
                    lty_api_algo_proc_pkg.set_param(i_name => 'SERVICE_ID'    , i_value => l_service_id);
                    lty_api_algo_proc_pkg.set_param(i_name => 'PRODUCT_ID'    , i_value => l_object_tab(i).product_id);
                    lty_api_algo_proc_pkg.set_param(i_name => 'CONTRACT_ID'   , i_value => l_object_tab(i).contract_id);
                    lty_api_algo_proc_pkg.set_param(i_name => 'CONTRACT_TYPE' , i_value => l_object_tab(i).contract_type);

                    rul_api_algorithm_pkg.execute_algorithm(
                        i_algorithm   => l_promo_algorithm_attr_value
                    );

                    l_com_product_id := lty_api_algo_proc_pkg.get_param_num(i_name => 'PRODUCT_ID');

                    if l_com_product_id <> l_object_tab(i).product_id then
                        l_label :=
                            com_api_i18n_pkg.get_text(
                                i_table_name  => 'PRD_CONTRACT'
                              , i_column_name => 'label'
                              , i_object_id   => l_object_tab(i).contract_id
                              , i_lang        => l_lang
                            );
                        l_description :=
                            com_api_i18n_pkg.get_text(
                                i_table_name  => 'PRD_CONTRACT'
                              , i_column_name => 'description'
                              , i_object_id   => l_object_tab(i).contract_id
                              , i_lang        => l_lang
                            );

                        prd_api_contract_pkg.modify_contract(
                            i_id          => l_object_tab(i).contract_id
                          , io_seqnum     => l_object_tab(i).seqnum
                          , i_product_id  => l_com_product_id
                          , i_end_date    => l_object_tab(i).end_date
                          , i_lang        => l_lang
                          , i_label       => l_label
                          , i_description => l_description
                        );
                    end if;

                    l_processed_tab(l_processed_tab.count() + 1) := l_object_tab(i).event_object_id;

                exception
                    when com_api_error_pkg.e_application_error then
                        rollback to sp_record;

                        l_excepted_count := l_excepted_count + 1;
                end;
            end loop;

            l_processed_count := l_processed_count + nvl(l_processed_tab.count(), 0);

            prc_api_stat_pkg.log_current(
                i_current_count       => l_processed_count
              , i_excepted_count      => l_excepted_count
            );

            evt_api_event_pkg.process_event_object(
                i_event_object_id_tab => l_processed_tab
            );

            l_processed_tab.delete;

            exit when cur_check_promo_level%notfound;
        end loop;

        close cur_check_promo_level;
    end if;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => l_excepted_count
      , i_processed_total => l_processed_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        rollback to sp_process;

        if cur_check_promo_level%isopen then
            close cur_check_promo_level;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
end check_promotion_level;

end;
/
