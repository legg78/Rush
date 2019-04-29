create or replace package body rus_prc_form_407_pkg is

function get_reversal_amount(
    i_oper_id        in com_api_type_pkg.t_long_id
  , i_amount_rev     in com_api_type_pkg.t_money
  , i_inst_id        in com_api_type_pkg.t_tiny_id
  , i_date_start     in date
  , i_date_end       in date
) return com_api_type_pkg.t_money
is
    l_amount_origin     com_api_type_pkg.t_money;
    l_oper_date_origin  date;
begin
    select oper_date
      into l_oper_date_origin
      from opr_operation
     where id = i_oper_id;

    if l_oper_date_origin between i_date_start and i_date_end then
        return i_amount_rev * -1;
    else
        return i_amount_rev;
    end if;

exception 
    when others 
    then return i_amount_rev;
end get_reversal_amount;

function get_reversal_count(
    i_oper_id        in com_api_type_pkg.t_long_id
  , i_inst_id        in com_api_type_pkg.t_tiny_id
  , i_date_start     in date
  , i_date_end       in date
) return com_api_type_pkg.t_tiny_id
is
    l_oper_date_origin  date;
begin
    select oper_date
      into l_oper_date_origin
      from opr_operation
     where id = i_oper_id;

    if l_oper_date_origin between i_date_start and i_date_end then
        return -1;
    else
        return 1;
    end if;

exception 
    when others 
    then return 1;
end get_reversal_count;

procedure process_form_407_3(
    i_inst_id        in com_api_type_pkg.t_tiny_id
  , i_agent_id       in com_api_type_pkg.t_short_id  default null
  , i_start_date     in date
  , i_end_date       in date
) 
is
    pragma         autonomous_transaction;     
    l_date_start   date;
    l_date_end     date;
    l_sysdate      date;
begin
    l_sysdate    := get_sysdate;
    l_date_start := nvl(trunc(i_start_date), trunc(add_months(l_sysdate, -3), 'Q'));
    l_date_end   := nvl(trunc(i_end_date), trunc(l_sysdate, 'Q') - 1) + 1 - com_api_const_pkg.ONE_SECOND;
    
    if trunc(l_date_start, 'Q') != trunc(l_date_end, 'Q') then
        -- Raise exception when Start date and End date not in same quartal 
        trc_log_pkg.debug(i_text => 'Start date and End date not in same quartal');
        com_api_error_pkg.raise_error(
            i_error       => 'RUS_WRONG_DATE_RANGE'
          , i_env_param1  => l_date_start
          , i_env_param2  => l_date_end
        );
    end if;
    
    -- Delete data for selected institute and period 
    delete from rus_form_407_3_report
     where inst_id     = i_inst_id
       and report_date = trunc(l_date_start, 'Q');

    -- Delete data
    execute immediate 'truncate table rus_form_407_3_opers';
    -- filling of operations temporary table
    insert into rus_form_407_3_opers
    select a.id as account_id
         , a.inst_id
         , o.id as oper_id
         , o.oper_date
         , o.original_id
         , o.is_reversal
         , o.oper_amount as amount
         , o.oper_currency as currency
         , opr_api_const_pkg.SETTLEMENT_USONTHEM as sttl_type
         , o.merchant_country
         , b.network_id as card_network_id
      from acc_account a
         , prd_customer cust
         , opr_operation o
         , opr_participant pi
         , iss_card c
         , acc_account_object ao
         , (select id, network_id
              from iss_bin b
             where exists (select 1
                             from com_array_element
                            where array_id in (select id from com_array where array_type_id = 4)
                              and com_api_type_pkg.get_number_value (i_data_type => com_api_const_pkg.DATA_TYPE_NUMBER
                                                                   , i_value     => element_value) = b.network_id )
           )                     b
     where substr(a.account_number, 1, length(rus_api_const_pkg.ACCOUNT_PREFIX_ELECTRONIC_FUND)) = rus_api_const_pkg.ACCOUNT_PREFIX_ELECTRONIC_FUND
       and a.inst_id               = i_inst_id
       and a.customer_id           = cust.id
       and cust.entity_type        = com_api_const_pkg.ENTITY_TYPE_PERSON
       and a.id                    = ao.account_id
       and ao.entity_type          = iss_api_const_pkg.ENTITY_TYPE_CARD
       and ao.object_id            = c.id
       and c.id                    = pi.card_id
       and pi.oper_id              = o.id
       and pi.participant_type     = com_api_const_pkg.PARTICIPANT_ISSUER
       and o.oper_amount          != 0
       and o.oper_date            >= l_date_start
       and o.oper_date            <= l_date_end
       and o.status               in (opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES)
       and o.merchant_country     != rus_api_const_pkg.COUNTRY_RUSSIA
       and com_api_array_pkg.is_element_in_array(
               i_array_id          => rus_api_const_pkg.OPER_US_ON_THEM_ARRAY
             , i_elem_value        => o.oper_type
           ) = com_api_const_pkg.TRUE
       and b.id in (select ci.bin_id
                      from iss_card_instance ci
                     where ci.id   = iss_api_card_instance_pkg.get_card_instance_id(i_card_id => c.id))
 union all
    select a.id as account_id
         , a.inst_id
         , o.id as oper_id
         , o.oper_date
         , o.original_id
         , o.is_reversal
         , o.oper_amount as amount
         , o.oper_currency as currency
         , opr_api_const_pkg.SETTLEMENT_THEMONUS as sttl_type
         , o.merchant_country
         , b.network_id as card_network_id
      from acc_account a
         , prd_customer cust
         , opr_operation o
         , opr_participant pi
         , iss_card c
         , acc_account_object ao
         , (select id, network_id
              from iss_bin b
             where exists (select 1
                             from com_array_element
                            where array_id in (select id from com_array where array_type_id = 4)
                              and com_api_type_pkg.get_number_value (i_data_type => com_api_const_pkg.DATA_TYPE_NUMBER
                                                                   , i_value     => element_value) = b.network_id )
           )                     b
     where substr(a.account_number, 1, length(rus_api_const_pkg.ACCOUNT_PREFIX_ELECTRONIC_FUND)) = rus_api_const_pkg.ACCOUNT_PREFIX_ELECTRONIC_FUND
       and a.inst_id               = i_inst_id
       and a.customer_id           = cust.id
       and cust.entity_type        = com_api_const_pkg.ENTITY_TYPE_PERSON
       and a.id                    = ao.account_id
       and ao.entity_type          = iss_api_const_pkg.ENTITY_TYPE_CARD
       and ao.object_id            = c.id
       and c.id                    = pi.card_id
       and pi.oper_id              = o.id
       and pi.participant_type     = com_api_const_pkg.PARTICIPANT_ISSUER
       and o.oper_amount          != 0
       and o.oper_date            >= l_date_start
       and o.oper_date            <= l_date_end
       and o.status               in (opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES)
       and o.merchant_country     != rus_api_const_pkg.COUNTRY_RUSSIA
       and com_api_array_pkg.is_element_in_array(
               i_array_id          => rus_api_const_pkg.OPER_THEM_ON_US_ARRAY
             , i_elem_value        => o.oper_type
           ) = com_api_const_pkg.TRUE
       and b.id in (select ci.bin_id
                      from iss_card_instance ci
                     where ci.id   = iss_api_card_instance_pkg.get_card_instance_id(i_card_id => c.id));

    -- filling of rows: amount\count of transactions (columns 1, 2, 3, 4, 5, 6, 7, 8)
    insert into rus_form_407_3_report
    select opr.inst_id
         , trunc(l_date_start, 'Q') as report_date
         , opr.sttl_type
         , 'Undefined' as counterparty
         , opr.country
         , opr.currency
         , sum(opr.oper_count) as oper_count
         , sum(round(opr.amount/ power(10, curr.exponent))) as amount
         , opr.card_network_id
      from (
            select sum(
                       decode(is_reversal
                            , com_api_const_pkg.FALSE
                            , amount
                            , get_reversal_amount(
                                  i_oper_id    => original_id
                                , i_amount_rev => amount
                                , i_inst_id    => i_inst_id
                                , i_date_start => l_date_start
                                , i_date_end   => l_date_end + 1
                              )
                       )
                   ) as amount
                 , decode(is_reversal
                        , com_api_const_pkg.FALSE
                        , 1
                        , get_reversal_count(
                              i_oper_id    => original_id
                            , i_inst_id    => i_inst_id
                            , i_date_start => l_date_start
                            , i_date_end   => l_date_end + 1
                          )
                   ) as oper_count
                 , oper_id
                 , currency
                 , country
                 , sttl_type
                 , inst_id
                 , card_network_id
              from rus_form_407_3_opers opr
          group by decode(is_reversal
                        , com_api_const_pkg.FALSE
                        , 1
                        , get_reversal_count(
                              i_oper_id    => original_id
                            , i_inst_id    => i_inst_id
                            , i_date_start => l_date_start
                            , i_date_end   => l_date_end + 1
                          )
                   )
                 , oper_id
                 , currency
                 , country
                 , sttl_type
                 , inst_id
                 , card_network_id
           ) opr
         , com_currency curr
     where opr.currency = curr.code 
  group by opr.inst_id
         , opr.sttl_type
         , opr.country
         , opr.currency
         , opr.card_network_id;
           

    trc_log_pkg.debug(i_text => 'rus_prc_form_407_pkg.process_form_407_3 (1, 2, 3, 4, 5, 6, 7, 8)');

    trc_log_pkg.debug(i_text => 'rus_prc_form_407_pkg.process_form_407_3 - ok');

exception 
    when others 
    then raise_application_error (-20001, sqlerrm);
end process_form_407_3;

end;
/
