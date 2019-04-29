create or replace package body pmo_prc_schedule_pkg as
/************************************************************
 * process for Payment Order shedule<br />
 * Created by Fomichev A.(fomichev@bpcbt.com)  at 18.07.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: pmo_prc_schedule_pkg <br />
 * @headcom
 ************************************************************/

/**
*   Payment order scheduler processing
*   @param i_order_status - Status of created order
*   @param i_register_event - True if register event
*   @param i_purpose_id - use only for institution based templates w/o schedule and with subscription
*/

procedure process(
    i_order_status      in com_api_type_pkg.t_dict_value    default pmo_api_const_pkg.PMO_STATUS_AWAITINGPROC
  , i_register_event    in com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_purpose_id        in com_api_type_pkg.t_long_id       default null
) is
    l_container_id                  com_api_type_pkg.t_long_id :=  prc_api_session_pkg.get_container_id;
    l_sysdate                       date := com_api_sttl_day_pkg.get_sysdate;

    cursor cu_event_objects is
        select eo.id                as event_object_id
             , eo.entity_type       as entity_type
             , eo.object_id         as object_id
             , eo.eff_date          as eff_date
             , s.amount_algorithm   as amount_algorithm
             , s.event_type         as event_type
             , s.order_id           as template_id
             , t.purpose_id         as purpose_id
             , t.split_hash         as split_hash
             , t.customer_id        as customer_id
             , t.inst_id            as inst_id
             , p.zero_order_status  as zero_order_status
             , s.attempt_limit      as attempt_limit
             , to_number(null)      as original_order_id
             , to_date(null)        as expiration_date
             , t.attempt_count      as order_attempt_count
          from evt_event_object eo
             , pmo_schedule     s
             , pmo_order        t
             , pmo_purpose      p
             , evt_event        e
         where 1 = 1
           and decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'PMO_PRC_SCHEDULE_PKG.PROCESS'
           and eo.entity_type    != pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
           and eo.eff_date       <= l_sysdate
           and eo.event_id        = e.id
           and e.event_type       = eo.event_type
           and eo.entity_type     = s.entity_type
           and eo.object_id       = s.object_id
           and t.id               = s.order_id
           and p.id               = t.purpose_id
           and t.is_template      = com_api_const_pkg.TRUE
           and t.templ_status     = pmo_api_const_pkg.PAYMENT_TMPL_STATUS_VALD
           and t.split_hash in (select split_hash from com_api_split_map_vw)
           and (eo.container_id is null or eo.container_id = l_container_id)
         union all
        select eo.id                as id
             , eo.entity_type       as entity_type
             , eo.object_id         as object_id
             , eo.eff_date          as eff_date
             , s.amount_algorithm   as amount_algorithm
             , s.event_type         as event_type
             , s.order_id           as template_id
             , t.purpose_id         as purpose_id
             , t.split_hash         as split_hash
             , t.customer_id        as customer_id
             , t.inst_id            as inst_id
             , p.zero_order_status  as zero_order_status
             , s.attempt_limit      as attempt_limit
             , eo.object_id         as original_order_id
             , o.expiration_date    as expiration_date
             , t.attempt_count      as order_attempt_count
          from evt_event_object eo
             , pmo_schedule     s
             , pmo_order        t
             , pmo_order        o
             , pmo_purpose      p
             , evt_event        e
         where 1 = 1
           and decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'PMO_PRC_SCHEDULE_PKG.PROCESS'
           and eo.entity_type     = pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
           and eo.eff_date       <= l_sysdate
           and eo.event_id        = e.id
           and eo.event_type      = e.event_type
           and p.id               = t.purpose_id
           and eo.object_id       = o.id
           and o.template_id      = t.id
           and t.id               = s.order_id
           and t.is_template      = com_api_const_pkg.TRUE
           and t.templ_status     = pmo_api_const_pkg.PAYMENT_TMPL_STATUS_VALD
           and t.split_hash in (select split_hash from com_api_split_map_vw)
           and (eo.container_id is null or eo.container_id = l_container_id)
         union all
        -- for the institute based template
        select eo.id                as event_object_id
             , eo.entity_type       as entity_type
             , eo.object_id         as object_id
             , eo.eff_date          as eff_date
             , p.amount_algorithm   as amount_algorithm
             , e.event_type         as event_type
             , t.id                 as template_id
             , t.purpose_id         as purpose_id
             , t.split_hash         as split_hash
             , t.customer_id        as customer_id
             , t.inst_id            as inst_id
             , p.zero_order_status  as zero_order_status
             , to_number(null)      as attempt_limit
             , to_number(null)      as original_order_id
             , t.expiration_date    as expiration_date
             , t.attempt_count      as order_attempt_count
          from evt_event_object eo
             , pmo_order        t
             , pmo_purpose      p
             , evt_event        e
         where 1 = 1
           and decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'PMO_PRC_SCHEDULE_PKG.PROCESS'
           and eo.entity_type    != pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
           and eo.eff_date       <= l_sysdate
           and eo.event_id        = e.id
           and e.event_type       = eo.event_type
           and p.id               = t.purpose_id
           and p.id               = i_purpose_id  
           and t.inst_id          = eo.inst_id
           and t.is_template      = com_api_const_pkg.TRUE
           and t.templ_status     = pmo_api_const_pkg.PAYMENT_TMPL_STATUS_VALD
           and t.split_hash in (select split_hash from com_api_split_map_vw)
           and (eo.container_id is null or eo.container_id = l_container_id)
           ;

    cursor cu_event_objects_count is
    select sum(cnt)
      from (
        select count(1) cnt
          from evt_event_object eo
             , pmo_schedule     s
             , pmo_order        t
             , pmo_purpose      p
             , evt_event        e
         where 1 = 1
           and decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'PMO_PRC_SCHEDULE_PKG.PROCESS'
           and eo.entity_type    != pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
           and eo.eff_date       <= l_sysdate
           and eo.event_id        = e.id
           and e.event_type       = eo.event_type
           and eo.entity_type     = s.entity_type
           and eo.object_id       = s.object_id
           and t.id               = s.order_id
           and p.id               = t.purpose_id
           and t.is_template      = com_api_const_pkg.TRUE
           and t.templ_status     = pmo_api_const_pkg.PAYMENT_TMPL_STATUS_VALD
           and t.split_hash in (select split_hash from com_api_split_map_vw)
           and (eo.container_id is null or eo.container_id = l_container_id)
         union all
        select count(1) cnt
          from evt_event_object eo
             , pmo_schedule     s
             , pmo_order        t
             , pmo_order        o
             , pmo_purpose      p
             , evt_event        e
         where 1 = 1
           and decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'PMO_PRC_SCHEDULE_PKG.PROCESS'
           and eo.entity_type     = pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
           and eo.eff_date       <= l_sysdate
           and eo.event_id        = e.id
           and eo.event_type      = e.event_type
           and p.id               = t.purpose_id
           and eo.object_id       = o.id
           and o.template_id      = t.id
           and t.id               = s.order_id
           and t.is_template      = com_api_const_pkg.TRUE
           and t.templ_status     = pmo_api_const_pkg.PAYMENT_TMPL_STATUS_VALD
           and t.split_hash in (select split_hash from com_api_split_map_vw)
           and (eo.container_id is null or eo.container_id = l_container_id)
         union all
        -- for the institute based template
        select count(1) cnt
          from evt_event_object eo
             , pmo_order        t
             , pmo_purpose      p
             , evt_event        e
         where 1 = 1
           and decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'PMO_PRC_SCHEDULE_PKG.PROCESS'
           and eo.entity_type    != pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
           and eo.eff_date       <= l_sysdate
           and eo.event_id        = e.id
           and e.event_type       = eo.event_type
           and p.id               = t.purpose_id
           and p.id               = i_purpose_id  
           and t.inst_id          = eo.inst_id
           and t.is_template      = com_api_const_pkg.TRUE
           and t.templ_status     = pmo_api_const_pkg.PAYMENT_TMPL_STATUS_VALD
           and t.split_hash in (select split_hash from com_api_split_map_vw)
           and (eo.container_id is null or eo.container_id = l_container_id)
    );

    l_event_object_id_tab           com_api_type_pkg.t_number_tab;
    l_event_object_entity_type_tab  com_api_type_pkg.t_dict_tab;
    l_event_object_object_id_tab    com_api_type_pkg.t_number_tab;
    l_event_object_eff_date_tab     com_api_type_pkg.t_date_tab;
    l_amount_algorithm_tab          com_api_type_pkg.t_dict_tab;
    l_event_type_tab                com_api_type_pkg.t_dict_tab;
    l_template_id_tab               com_api_type_pkg.t_number_tab;
    l_purpose_id_tab                com_api_type_pkg.t_number_tab;
    l_split_hash_tab                com_api_type_pkg.t_number_tab;
    l_customer_id_tab               com_api_type_pkg.t_number_tab;
    l_inst_id_tab                   com_api_type_pkg.t_number_tab;
    l_zero_order_status_tab         com_api_type_pkg.t_dict_tab;
    l_attempt_count_limit_tab       com_api_type_pkg.t_number_tab;
    l_current_attempt_count         com_api_type_pkg.t_tiny_id;
    l_amount_rec                    com_api_type_pkg.t_amount_rec;
    l_payment_order_id              com_api_type_pkg.t_long_id;
    l_record_count                  com_api_type_pkg.t_count            := 0;
    l_excepted_count                com_api_type_pkg.t_count            := 0;
    l_successed_id_tab              com_api_type_pkg.t_number_tab;
    l_param_tab                     com_api_type_pkg.t_param_tab;
    l_original_order_id_tab         com_api_type_pkg.t_number_tab;
    l_expiration_date_tab           com_api_type_pkg.t_date_tab;
    l_date_is_expired               com_api_type_pkg.t_boolean;
    l_order_attempt_count_tab       com_api_type_pkg.t_number_tab;
    l_checks_not_passed             com_api_type_pkg.t_boolean          := com_api_type_pkg.FALSE;
    l_original_order_rec            pmo_api_type_pkg.t_payment_order_rec;
begin
    prc_api_stat_pkg.log_start;

    open cu_event_objects_count;
    fetch cu_event_objects_count into l_record_count;
    close cu_event_objects_count;

    trc_log_pkg.debug(
        i_text       => 'pmo_prc_schedule_pkg.process estimation [#1]'
      , i_env_param1 => l_record_count
    );

    prc_api_stat_pkg.log_estimation(
        i_estimated_count     => l_record_count
    );

    if l_record_count > 0 then

        l_record_count := 0;

        open cu_event_objects;

        loop
            fetch cu_event_objects bulk collect into
                l_event_object_id_tab
              , l_event_object_entity_type_tab
              , l_event_object_object_id_tab
              , l_event_object_eff_date_tab
              , l_amount_algorithm_tab
              , l_event_type_tab
              , l_template_id_tab
              , l_purpose_id_tab
              , l_split_hash_tab
              , l_customer_id_tab
              , l_inst_id_tab
              , l_zero_order_status_tab
              , l_attempt_count_limit_tab
              , l_original_order_id_tab
              , l_expiration_date_tab
              , l_order_attempt_count_tab
            limit 1000;

            for i in 1 .. l_event_object_id_tab.count loop
                savepoint order_start;

                -- reset odrer id to make possible several order per template
                l_payment_order_id := null;

                begin
                    l_checks_not_passed := com_api_const_pkg.FALSE;

                    l_date_is_expired :=
                        pmo_api_order_pkg.check_is_pmo_expired(
                            i_expiration_date   => l_expiration_date_tab(i)
                          , i_order_id          => l_original_order_id_tab(i)
                          , i_entity_type       => l_event_object_entity_type_tab(i)
                          , i_object_id         => l_event_object_object_id_tab(i)
                          , i_inst_id           => l_inst_id_tab(i)
                          , i_split_hash        => l_split_hash_tab(i)
                          , i_param_tab         => l_param_tab
                        );

                    trc_log_pkg.debug(
                        'event: event_object_id = '
                        || l_event_object_id_tab(i)
                        || ', l_customer_id = '
                        || l_customer_id_tab(i)
                        || ', l_amount_algorithm = '
                        || l_amount_algorithm_tab(i)
                        || ', l_original_order_id_tab = '
                        || l_original_order_id_tab(i)
                        || ', l_expiration_date_tab = '
                        || l_expiration_date_tab(i)
                        || ', l_order_attempt_count_tab = '
                        || l_order_attempt_count_tab(i)
                        || ', l_date_is_expired = '
                        || l_date_is_expired
                        || ', l_original_order_id_tab = '
                        || l_original_order_id_tab(i)
                        || ', entity_type = '
                        || l_event_object_entity_type_tab(i)
                        || ', object id = '
                        || l_event_object_object_id_tab(i)
                        || ' , template id = '
                        || l_template_id_tab(i)
                    );

                    if l_date_is_expired = com_api_const_pkg.TRUE then
                        trc_log_pkg.debug(
                            i_text      => 'Expiration date check failed. Expiration date [#1], current date [#2].'
                          , i_env_param1 => l_expiration_date_tab(i)
                          , i_env_param2 => get_sysdate
                        );

                        l_checks_not_passed := com_api_const_pkg.TRUE;
                    end if;

                    if      l_order_attempt_count_tab(i) > l_attempt_count_limit_tab(i)
                        and l_event_object_entity_type_tab(i) = pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
                    then
                        trc_log_pkg.debug(
                            i_text      => 'Attempt count check failed. Order attempt count [#1], template attempt count [#2].'
                          , i_env_param1 => l_order_attempt_count_tab(i)
                        );

                        l_checks_not_passed := com_api_const_pkg.TRUE;
                    end if;

                    if l_checks_not_passed = com_api_const_pkg.TRUE then
                        update evt_event_object eo
                           set eo.status = evt_api_const_pkg.EVENT_STATUS_DO_NOT_PROCES
                             , eo.proc_session_id = get_session_id
                         where eo.id = l_event_object_id_tab(i);

                        continue;
                    end if;

                    l_amount_rec.currency := null;
                    l_amount_rec.amount   := 0;

                    if l_original_order_id_tab(i) is not null then
                        l_original_order_rec :=
                            pmo_api_order_pkg.get_order(
                                i_order_id          => l_original_order_id_tab(i)
                              , i_mask_error        => com_api_const_pkg.FALSE
                            );
                    end if;

                    pmo_api_order_pkg.calc_order_amount(
                        i_amount_algorithm      => l_amount_algorithm_tab(i)
                      , i_entity_type           => l_event_object_entity_type_tab(i)
                      , i_object_id             => l_event_object_object_id_tab(i)
                      , i_eff_date              => l_event_object_eff_date_tab(i)
                      , i_template_id           => l_template_id_tab(i)
                      , i_split_hash            => l_split_hash_tab(i)
                      , i_original_order_rec    => l_original_order_rec
                      , i_order_id              => null
                      , io_amount               => l_amount_rec
                    );

                    if nvl(l_amount_rec.amount, 0) > 0 then
                        begin
                            select o.id
                                 , nvl(o.attempt_count, 0)
                              into l_payment_order_id
                                 , l_current_attempt_count
                              from pmo_order o
                             where o.template_id = l_template_id_tab(i)
                               and o.status = pmo_api_const_pkg.PMO_STATUS_PREPARATION
                               and o.event_date = l_event_object_eff_date_tab(i);

                            trc_log_pkg.debug(
                                i_text          => 'payment order found [#1], template id [#2], template_attempt_count [#3], current_attempt_count [#4]'
                              , i_env_param1    => l_payment_order_id
                              , i_env_param2    => l_template_id_tab(i)
                              , i_env_param3    => l_attempt_count_limit_tab(i)
                              , i_env_param4    => l_current_attempt_count
                            );

                            if l_current_attempt_count <= nvl(l_attempt_count_limit_tab(i), l_current_attempt_count) then
                                update pmo_order_vw
                                   set amount                = l_amount_rec.amount
                                     , currency              = l_amount_rec.currency
                                     , event_date            = l_event_object_eff_date_tab(i)
                                     , status                = coalesce(l_zero_order_status_tab(i), i_order_status, pmo_api_const_pkg.PMO_STATUS_AWAITINGPROC)
                                     , inst_id               = l_inst_id_tab(i)
                                     , attempt_count         = nvl(attempt_count, 0) + 1
                                     , split_hash            = l_split_hash_tab(i)
                                     , is_template           = com_api_const_pkg.FALSE
                                     , is_prepared_order     = com_api_const_pkg.FALSE
                                 where id = l_payment_order_id;
                            end if;

                        exception
                            when no_data_found then
                                pmo_api_order_pkg.add_order_with_params(
                                    io_payment_order_id     => l_payment_order_id
                                  , i_entity_type           => l_event_object_entity_type_tab(i)
                                  , i_object_id             => l_event_object_object_id_tab(i)
                                  , i_customer_id           => l_customer_id_tab(i)
                                  , i_split_hash            => l_split_hash_tab(i)
                                  , i_purpose_id            => l_purpose_id_tab(i)
                                  , i_template_id           => l_template_id_tab(i)
                                  , i_amount_rec            => l_amount_rec
                                  , i_eff_date              => l_event_object_eff_date_tab(i)
                                  , i_order_status          => coalesce(i_order_status, pmo_api_const_pkg.PMO_STATUS_AWAITINGPROC)
                                  , i_inst_id               => l_inst_id_tab(i)
                                  , i_attempt_count         => 1 + nvl(l_attempt_count_limit_tab(i), 0)
                                  , i_payment_order_number  => null
                                  , i_expiration_date       => l_expiration_date_tab(i)
                                  , i_register_event        => i_register_event
                                  , i_param_tab             => l_param_tab
                                );

                            when too_many_rows then
                                com_api_error_pkg.raise_error (
                                    i_error         => 'TOO_MANY_PAYMENT_ORDERS_FOUND'
                                  , i_env_param1    => l_template_id_tab(i)
                                );
                        end;
                    end if;

                    l_successed_id_tab(l_successed_id_tab.count + 1) := l_event_object_id_tab(i);

                exception
                    when others then
                        rollback to savepoint order_start;
                        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
                            l_excepted_count := l_excepted_count + 1;
                        else
                            raise;
                        end if;
                end;
                l_record_count     := l_record_count + 1;
                
                if mod(l_record_count, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count     => l_record_count
                      , i_excepted_count    => l_excepted_count
                    );
                end if;

            end loop;

            evt_api_event_pkg.process_event_object(
                i_event_object_id_tab  => l_successed_id_tab
            );

            trc_log_pkg.debug(
                i_text => 'updated to PROCESSED ' || sql%rowcount
            );

            forall i in 1..l_event_object_id_tab.count
                update evt_event_object
                   set status = evt_api_const_pkg.EVENT_STATUS_DO_NOT_PROCES
                 where status = evt_api_const_pkg.EVENT_STATUS_READY
                   and id     = l_event_object_id_tab(i);

            prc_api_stat_pkg.log_current(
                i_current_count       => l_record_count
              , i_excepted_count      => l_excepted_count
            );

            exit when cu_event_objects%notfound;
        end loop;

        close cu_event_objects;

    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => l_excepted_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug(
        i_text => 'pmo_prc_schedule_pkg.process end'
    );

exception
    when others then
        if cu_event_objects%isopen then
            close cu_event_objects;
        end if;

        if cu_event_objects_count%isopen then
            close cu_event_objects_count;
        end if;

        prc_api_stat_pkg.log_end(
            i_processed_total   => l_record_count
          , i_excepted_total    => l_excepted_count
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process;

end pmo_prc_schedule_pkg;
/
