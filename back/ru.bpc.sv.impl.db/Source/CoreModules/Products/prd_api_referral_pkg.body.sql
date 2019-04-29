create or replace package body prd_api_referral_pkg as
/*********************************************************
 *  Acquiring/issuing application API  <br />
 *  Created by Sergey Ivanov (sr.ivanov@bpcbt.com)  at 28.09.2018 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: prd_api_referral_pkg <br />
 *  @headcom
 **********************************************************/
procedure add_referrer(
    o_id                      out com_api_type_pkg.t_medium_id
  , i_inst_id              in     com_api_type_pkg.t_inst_id
  , i_split_hash           in     com_api_type_pkg.t_tiny_id
  , i_customer_id          in     com_api_type_pkg.t_medium_id
  , i_referral_code        in     com_api_type_pkg.t_name
  , i_cust_number          in     com_api_type_pkg.t_name default null
  , i_prod_number          in     com_api_type_pkg.t_name default null
  , i_agent_number         in     com_api_type_pkg.t_name default null
) is
    l_split_hash                  com_api_type_pkg.t_tiny_id;
    l_param_tab                   com_api_type_pkg.t_param_tab;
    l_referral_code               com_api_type_pkg.t_name;
    l_referral_count              com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug('prd_api_referral_pkg.add_referrer start');

    o_id := prd_referrer_seq.nextval;

    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(
                            i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                          , i_object_id   => i_customer_id);
    else
        l_split_hash := i_split_hash;
    end if;

    l_param_tab('SYS_DATE')        := com_api_sttl_day_pkg.get_sysdate();
    l_param_tab('TIMESTAMP')       := com_api_sttl_day_pkg.get_sysdate();
    l_param_tab('INST_ID')         := i_inst_id;
    l_param_tab('CUSTOMER_NUMBER') := i_cust_number;
    l_param_tab('PRODUCT_NUMBER')  := i_prod_number;
    l_param_tab('AGENT_NUMBER')    := i_agent_number;

    if i_referral_code is null
    then
        l_referral_code := rul_api_name_pkg.get_name(
                               i_inst_id      => i_inst_id
                             , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_REFERRER_CODE
                             , i_param_tab    => l_param_tab
                           );
    else
        l_referral_code := i_referral_code;
    end if;

    select count(1)
      into l_referral_count
      from prd_referrer_vw rr
     where rr.referral_code = l_referral_code;

    if l_referral_count > 0
    then
        com_api_error_pkg.raise_error(
            i_error      => 'REFERRER_CODE_ALREADY_EXISTS'
          , i_env_param1 => l_referral_code
        );
    end if;

    insert into prd_referrer_vw(
        id
      , inst_id
      , split_hash
      , customer_id
      , referral_code
    ) values (
        o_id
      , i_inst_id
      , l_split_hash
      , i_customer_id
      , l_referral_code
    );

    trc_log_pkg.debug('prd_api_referral_pkg.add_referrer end');

end add_referrer;

procedure add_referral(
    o_id                      out com_api_type_pkg.t_medium_id
  , i_inst_id              in     com_api_type_pkg.t_inst_id
  , i_split_hash           in     com_api_type_pkg.t_tiny_id
  , i_customer_id          in     com_api_type_pkg.t_medium_id
  , i_referrer_id          in     com_api_type_pkg.t_name
) is
    l_split_hash                  com_api_type_pkg.t_tiny_id;
    l_param_tab                   com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug('prd_api_referral_pkg.add_referral start');

    o_id := prd_referral_seq.nextval;

    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(
                            i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                          , i_object_id   => i_customer_id);
    else
        l_split_hash := i_split_hash;
    end if;

    insert into prd_referral_vw(
        id
      , inst_id
      , split_hash
      , customer_id
      , referrer_id
    ) values (
        o_id
      , i_inst_id
      , l_split_hash
      , i_customer_id
      , i_referrer_id
    );

    evt_api_event_pkg.register_event(
        i_event_type    => prd_api_const_pkg.EVENT_REFERRAL_CUST_REGISTER
      , i_eff_date      => com_api_sttl_day_pkg.get_sysdate()
      , i_entity_type   => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
      , i_object_id     => o_id
      , i_inst_id       => i_inst_id
      , i_split_hash    => l_split_hash
      , i_param_tab     => l_param_tab
    );

    trc_log_pkg.debug('prd_api_referral_pkg.add_referral end');

    exception when dup_val_on_index
    then
        com_api_error_pkg.raise_error(
            i_error      => 'REFERRER_CUSTOMER_ALREADY_EXISTS'
          , i_env_param1 => prd_api_customer_pkg.get_customer_number(i_customer_id)
        );
    when others
    then
        raise;
end add_referral;

end;
/
