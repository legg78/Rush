create or replace package body cst_ibbl_prc_merchant_pkg as

procedure process(
    i_fee_type                in     com_api_type_pkg.t_dict_value
  , i_positive_array          in     com_api_type_pkg.t_short_id
  , i_negative_array          in     com_api_type_pkg.t_short_id     default null
  , i_rate_type               in     com_api_type_pkg.t_dict_value   default acq_api_const_pkg.ACQUIRING_RATE_TYPE
  , i_conversion_type         in     com_api_type_pkg.t_dict_value   default com_api_const_pkg.CONVERSION_TYPE_BUYING
  , i_start_date              in     date                            default null
  , i_end_date                in     date                            default null
) is
    type t_merchant_award_rec is record (
        merchant_id           com_api_type_pkg.t_short_id
      , merchant_number       com_api_type_pkg.t_name
      , merchant_fee_id       com_api_type_pkg.t_short_id
      , award_currency        com_api_type_pkg.t_curr_code
      , award_exponent        com_api_type_pkg.t_tiny_id
      , award_amount          com_api_type_pkg.t_money
    );
    type t_merchant_award_typ is table of t_merchant_award_rec index by pls_integer;
    l_merchant_award_tab      t_merchant_award_typ;

    CRLF             constant com_api_type_pkg.t_name           := chr(13) || chr(10);
    l_params                  com_api_type_pkg.t_param_tab;
    l_container_id            com_api_type_pkg.t_long_id;
    l_process_id              com_api_type_pkg.t_short_id;
    l_session_id              com_api_type_pkg.t_long_id;
    l_total_count             com_api_type_pkg.t_count          := 0;
    l_counter                 com_api_type_pkg.t_count          := 0;
    l_fetched_count           com_api_type_pkg.t_count          := 0;
    l_start_date              date;
    l_end_date                date;
    l_result_amount           com_api_type_pkg.t_money;
    l_fee_currency            com_api_type_pkg.t_curr_code;
    l_temp_result             xmltype;
    l_result                  xmltype;
    l_detail                  xmltype;
    l_file                    clob;
    l_file_type               com_api_type_pkg.t_dict_value;
    l_session_file_id         com_api_type_pkg.t_long_id;

    cursor cur_merchant_award is
        select merchant_id
             , merchant_number
             , merchant_fee_id
             , award_currency
             , award_exponent
             , greatest(sum(oper_amount_converted), 0) as award_amount
        from(
            select agg.merchant_number
                 , agg.merchant_id
                 , agg.merchant_fee_id
                 , agg.merchant_fee_currency        as award_currency
                 , fc.exponent                      as award_exponent
                 , case when agg.oper_currency = agg.merchant_fee_currency then
                       agg.oper_amount_agg
                   else
                       com_api_rate_pkg.convert_amount(
                           i_src_amount         => agg.oper_amount_agg
                         , i_src_currency       => agg.oper_currency
                         , i_dst_currency       => agg.merchant_fee_currency
                         , i_rate_type          => i_rate_type
                         , i_inst_id            => agg.inst_id
                         , i_eff_date           => l_end_date
                         , i_mask_exception     => com_api_type_pkg.FALSE
                         , i_conversion_type    => i_conversion_type
                       )
                   end                             as oper_amount_converted
            from(
                select sum(
                           case
                           when ae.oper_type_sign = com_api_const_pkg.DEBIT then
                                decode(
                                    o.is_reversal
                                  , com_api_const_pkg.FALSE
                                  , com_api_const_pkg.CREDIT
                                  , com_api_const_pkg.TRUE
                                  , com_api_const_pkg.DEBIT
                                ) 
                                * ae.oper_type_sign
                                * o.oper_amount
                           when ae.oper_type_sign = com_api_const_pkg.CREDIT then
                                decode(
                                    o.is_reversal
                                  , com_api_const_pkg.FALSE
                                  , com_api_const_pkg.CREDIT
                                  , com_api_const_pkg.TRUE
                                  , com_api_const_pkg.DEBIT
                                )
                                * o.oper_amount
                           end
                       ) as oper_amount_agg
                     , o.oper_currency
                     , me.merchant_id
                     , me.merchant_number
                     , me.merchant_fee_id
                     , me.merchant_fee_currency
                     , p.inst_id
                from opr_operation o
                   , opr_participant p
                   , (select m.id                 as merchant_id
                           , m.merchant_number    as merchant_number
                           , m.merchant_fee_id    as merchant_fee_id
                           , f.currency           as merchant_fee_currency
                       from (select m.id
                                  , m.merchant_number
                                  , prd_api_product_pkg.get_attr_value_number(
                                        i_entity_type       => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                      , i_object_id         => id
                                      , i_attr_name         => acq_api_const_pkg.ACQ_AWARD
                                      , i_mask_error        => com_api_type_pkg.TRUE
                                      , i_use_default_value => com_api_type_pkg.TRUE
                                      , i_default_value     => null
                                    )              as merchant_fee_id
                              from acq_merchant m
                            ) m
                          , fcl_fee f
                       where m.merchant_fee_id  = f.id
                         and f.fee_type         = i_fee_type
                      ) me
                    , (select decode(array_id, i_positive_array, 1, i_negative_array, -1) as oper_type_sign
                            , element_value
                         from com_array_element
                        where array_id in (i_positive_array, i_negative_array)
                      ) ae
                where o.oper_date         >= l_start_date
                  and o.oper_date         <  l_end_date
                  and o.id                 = p.oper_id
                  and p.participant_type   = com_api_const_pkg.PARTICIPANT_ACQUIRER
                  and p.merchant_id        = me.merchant_id
                  and o.oper_type          = ae.element_value
                group by 
                      o.oper_currency
                    , me.merchant_id
                    , me.merchant_number
                    , me.merchant_fee_id
                    , me.merchant_fee_currency
                    , p.inst_id
               ) agg
               , com_currency oc
               , com_currency fc
            where fc.code              = agg.merchant_fee_currency
              and agg.oper_currency    = oc.code
            ) r
        group by
              merchant_number
            , award_currency
            , award_exponent
            , merchant_id
            , merchant_fee_id
        order by
              merchant_number
    ;
begin
    trc_log_pkg.debug(
        i_text  => 'cst_ibbl_prc_merchant_pkg.merchant_award:'
                || ' i_fee_type ['          || i_fee_type
                || '], i_positive_array ['  || i_positive_array
                || '], i_negative_array ['  || i_negative_array
                || '], i_rate_type ['       || i_rate_type
                || '], i_conversion_type [' || i_conversion_type
                || '], i_start_date ['      || i_start_date
                || '], i_end_date ['        || i_end_date
                || ']'
    );

    l_container_id          := prc_api_session_pkg.get_container_id;
    l_process_id            := prc_api_session_pkg.get_process_id;
    l_session_id            := prc_api_session_pkg.get_session_id;

    trc_log_pkg.debug(
        i_text       => 'l_container_id [#1], l_process_id [#2], l_session_id [#3]'
      , i_env_param1 => l_container_id
      , i_env_param2 => l_process_id
      , i_env_param3 => l_session_id
    );

    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    prc_api_stat_pkg.log_start;

    savepoint sp_merchant_award;

    prc_api_file_pkg.open_file(
        o_sess_file_id          => l_session_file_id
      , i_file_type             => l_file_type
      , i_file_purpose          => prc_api_const_pkg.FILE_PURPOSE_OUT
      , io_params               => l_params
    );

    if i_start_date is null then
        select max(start_time)
          into l_start_date
          from prc_session
         where process_id = l_process_id
           and id <> l_session_id;
        l_start_date  := nvl(l_start_date, add_months(trunc(com_api_sttl_day_pkg.get_sysdate), -1));
    else 
        l_start_date  := i_start_date;
    end if;

    if i_end_date is null then
        select max(start_time)
          into l_end_date
          from prc_session
         where id = l_session_id;
    else 
        l_end_date    := i_end_date;
    end if;

    trc_log_pkg.debug(
        i_text  => 'cst_ibbl_prc_merchant_pkg.merchant_award:'
                || ' l_start_date ['        || l_start_date
                || '], l_end_date ['        || l_end_date
                || '], l_session_file_id [' || l_session_file_id
                || '], l_file_type ['       || l_file_type
                || ']'
    );

    open cur_merchant_award;

    fetch cur_merchant_award bulk collect into l_merchant_award_tab;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_merchant_award_tab.count
    );

    for i in 1 .. l_merchant_award_tab.count loop

        l_fee_currency := l_merchant_award_tab(i).award_currency;

        fcl_api_fee_pkg.get_fee_amount(
            i_fee_id            => l_merchant_award_tab(i).merchant_fee_id
          , i_base_amount       => l_merchant_award_tab(i).award_amount
          , i_base_currency     => l_merchant_award_tab(i).award_currency
          , i_entity_type       => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
          , i_object_id         => l_merchant_award_tab(i).merchant_id
          , io_fee_currency     => l_fee_currency
          , o_fee_amount        => l_result_amount
        );

        if l_result_amount <> 0 then
            select xmlagg(
                       xmlelement(
                           "merchant"
                         , xmlattributes(l_merchant_award_tab(i).merchant_number as "number")
                         , xmlelement("date"        ,    to_char(l_end_date, 'YYYYMMDDHHMISS'))
                         , xmlelement("currency"    ,    l_merchant_award_tab(i).award_currency)
                         , xmlelement("exponent"    ,    l_merchant_award_tab(i).award_exponent)
                         , xmlelement("amount"      ,    l_result_amount)
                       )
                   )
              into l_temp_result
              from dual;

            select xmlconcat(l_detail, l_temp_result)
              into l_detail
              from dual;
        end if;

    end loop;

    close cur_merchant_award;

    select 
        xmlelement(
            "awards"
          , l_detail
        ) r
     into l_result
     from dual;

    l_file := l_result.getclobval();

    l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

    prc_api_file_pkg.put_file(
        i_sess_file_id        => l_session_file_id
      , i_clob_content        => l_file
      , i_add_to              => com_api_const_pkg.FALSE
    );

    l_counter     := l_counter + 1;

    trc_log_pkg.debug('file saved, count=' || l_counter || ', length=' || length(l_file));

    l_total_count := l_total_count + l_fetched_count;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => 0
      , i_processed_total => l_total_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug('Generating merchant awards XML-file: FINISHED');

exception
    when others then
        rollback to sp_merchant_award;
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process;

end cst_ibbl_prc_merchant_pkg;
/

