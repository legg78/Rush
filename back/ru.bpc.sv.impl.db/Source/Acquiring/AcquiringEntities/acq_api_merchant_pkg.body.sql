create or replace package body acq_api_merchant_pkg as
/*********************************************************
 *  API for merchants in ACQ application <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 22.09.2009 <br />
 *  Module: acq_api_merchant_pkg  <br />
 *  @headcom
 **********************************************************/

function get_arn(
    i_prefix            in      varchar2        default '7'
  , i_acquirer_bin      in      varchar2
  , i_proc_date         in      date            default null
) return varchar2 is
    l_proc_date         date := i_proc_date;
    l_result            varchar2(23);
    l_sequence          number(11);
begin
    if l_proc_date is null then
        l_proc_date := com_api_sttl_day_pkg.get_sysdate;
    end if;

    select acq_arn_seq.nextval into l_sequence from dual;

    l_result := (
        i_prefix
        || lpad(i_acquirer_bin, 6, 0)
        || to_char(l_proc_date, 'YDDD')
        || to_char(l_sequence, 'FM09999999999')
    );

    return l_result || com_api_checksum_pkg.get_luhn_checksum(l_result);
end;

function get_root_merchant_id(
    i_merchant_id       in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_short_id is
    l_result            com_api_type_pkg.t_short_id;
begin
    select id
      into l_result
      from acq_merchant
     where parent_id is null
    connect by id = prior parent_id start with id = i_merchant_id;

    return l_result;
exception
    when no_data_found then
        return i_merchant_id;
end;

function get_merchant_contract(
    i_merchant_id       in      com_api_type_pkg.t_short_id
) return prd_api_type_pkg.t_contract is
    l_contract_id    com_api_type_pkg.t_medium_id;
begin
    begin
        select m.contract_id
          into l_contract_id
          from acq_merchant m
         where m.id = i_merchant_id;
    exception
        when no_data_found then
            return null;
    end;
     
    return prd_api_contract_pkg.get_contract(
               i_contract_id     => l_contract_id
           );
end;

function get_merchant_risk_indicator(
    i_merchant_id       in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_dict_value is
    l_merchant_risk_indicator    com_api_type_pkg.t_dict_value;
begin
    begin
        select m.risk_indicator
          into l_merchant_risk_indicator
          from acq_merchant m
         where m.id = i_merchant_id;
    exception
        when no_data_found then
            return null;
    end;
     
    return l_merchant_risk_indicator;
end;

function get_product_id(
    i_merchant_id       in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_short_id is
    l_result            com_api_type_pkg.t_short_id;
begin
    select c.product_id
      into l_result
      from acq_merchant m, prd_contract c
     where m.id = i_merchant_id and m.contract_id = c.id;

    return l_result;
exception
    when no_data_found then
        return null;
end;

function get_inst_id(
    i_merchant_id       in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_inst_id is
    l_result            com_api_type_pkg.t_inst_id;
begin
    select inst_id
      into l_result
      from acq_merchant
     where id = i_merchant_id;

    return l_result;
exception
    when no_data_found then
        return null;
end;

procedure add_merchant(
    o_merchant_id           in out  com_api_type_pkg.t_short_id
  , i_merchant_number       in      com_api_type_pkg.t_merchant_number
  , i_merchant_name         in      com_api_type_pkg.t_name
  , i_merchant_type         in      com_api_type_pkg.t_dict_value
  , i_parent_id             in      com_api_type_pkg.t_short_id
  , i_mcc                   in      varchar2
  , i_status                in      com_api_type_pkg.t_dict_value
  , i_contract_id           in      com_api_type_pkg.t_medium_id
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_description           in      com_api_type_pkg.t_full_desc    default null
  , i_lang                  in      com_api_type_pkg.t_dict_value   default null
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_partner_id_code       in      com_api_type_pkg.t_auth_code    default null
  , i_risk_indicator        in      com_api_type_pkg.t_dict_value   default null
  , i_mc_assigned_id        in      com_api_type_pkg.t_tag          default null
) is
begin
    if i_contract_id is null then
        com_api_error_pkg.raise_error(
            i_error         => 'CONTRACT_ID_NOT_DEFINED'
        );
    end if;

    if i_merchant_type is null then
        com_api_error_pkg.raise_error(
            i_error         => 'MERCHANT_TYPE_NOT_DEFINED'
        );
    end if;

    if i_mcc is null then
        com_api_error_pkg.raise_error(
            i_error         => 'MCC_NOT_DEFINED'
        );
    end if;

    if i_partner_id_code is not null then

        for rec in (
            select 1
              from acq_merchant m
             where m.partner_id_code = i_partner_id_code
               and m.inst_id         = i_inst_id
               and rownum            = 1
        ) loop
            com_api_error_pkg.raise_error(
                i_error      => 'PARTNER_ID_CODE_IS_NOT_UNIQUE'
              , i_env_param1 => i_partner_id_code
              , i_env_param2 => i_inst_id
            );
        end loop;
    end if;

    ost_api_institution_pkg.check_status(
        i_inst_id     => i_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_CREATE
    );   

    if o_merchant_id is null then
        o_merchant_id := acq_merchant_seq.nextval;
    end if;

    if o_merchant_id = i_parent_id then
        trc_log_pkg.debug(
            i_text          => 'Loop data. Merchant [#1] and parent merchant [#2]'
          , i_env_param1    => o_merchant_id
          , i_env_param2    => i_parent_id
        );
        com_api_error_pkg.raise_error(
            i_error         => 'CYCLIC_MERCHANT_DATA_FOUND'
          , i_env_param1    => o_merchant_id
          , i_env_param2    => i_parent_id
        );
    end if;

    insert into acq_merchant_vw(
        id
      , seqnum
      , merchant_number
      , merchant_name
      , merchant_type
      , parent_id
      , mcc
      , status
      , contract_id
      , inst_id
      , split_hash
      , partner_id_code
      , risk_indicator
      , mc_assigned_id
    ) values (
        o_merchant_id
      , 1
      , i_merchant_number
      , i_merchant_name
      , i_merchant_type
      , i_parent_id
      , i_mcc
      , i_status
      , i_contract_id
      , i_inst_id
      , i_split_hash
      , i_partner_id_code
      , i_risk_indicator
      , i_mc_assigned_id
    );

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'acq_merchant'
          , i_column_name   => 'description'
          , i_object_id     => o_merchant_id
          , i_lang          => i_lang
          , i_text          => i_description
        );
    end if;

end;

procedure modify_merchant(
    i_merchant_id           in      com_api_type_pkg.t_short_id
  , i_merchant_number       in      com_api_type_pkg.t_merchant_number
  , i_merchant_name         in      com_api_type_pkg.t_name
  , i_parent_id             in      com_api_type_pkg.t_short_id
  , i_mcc                   in      com_api_type_pkg.t_mcc
  , i_status                in      com_api_type_pkg.t_dict_value
  , i_contract_id           in      com_api_type_pkg.t_medium_id
  , i_description           in      com_api_type_pkg.t_full_desc    default null
  , i_lang                  in      com_api_type_pkg.t_dict_value   default null
  , i_partner_id_code       in      com_api_type_pkg.t_auth_code    default null
  , i_risk_indicator        in      com_api_type_pkg.t_dict_value   default null
  , i_mc_assigned_id        in      com_api_type_pkg.t_tag          default null
) is
    l_result                com_api_type_pkg.t_short_id;
    l_count                 com_api_type_pkg.t_short_id;
    l_inst_id               com_api_type_pkg.t_inst_id;
begin
    if i_parent_id is not null then
        begin
            select id
              into l_result
              from(
                    select id
                      from acq_merchant
                      connect by prior id = parent_id start with id = i_merchant_id
                    ) t
            where id = i_parent_id;

            trc_log_pkg.debug(
                i_text          => 'Loop data. Merchant [#1] and parent merchant [#2]'
              , i_env_param1    => i_merchant_id
              , i_env_param2    => i_parent_id
            );
            com_api_error_pkg.raise_error(
                i_error         => 'CYCLIC_MERCHANT_DATA_FOUND'
              , i_env_param1    => i_merchant_id
              , i_env_param2    => i_parent_id
            );

        exception
            when no_data_found then
                null;

        end;

    end if;

    select inst_id
      into l_inst_id
      from acq_merchant
     where id = i_merchant_id;

    ost_api_institution_pkg.check_status(
        i_inst_id     => l_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    );

    select count(1)
      into l_count
      from acq_merchant m
     where m.partner_id_code = i_partner_id_code
       and m.partner_id_code is not null
       and m.inst_id         = l_inst_id
       and m.id             != i_merchant_id;
    
    if l_count > 0 then
        com_api_error_pkg.raise_error(
              i_error      => 'PARTNER_ID_CODE_IS_NOT_UNIQUE'
            , i_env_param1 => i_partner_id_code
            , i_env_param2 => l_inst_id
          );
    end if;

    update acq_merchant_vw
       set merchant_number = nvl(i_merchant_number, merchant_number)
         , merchant_name   = nvl(i_merchant_name, merchant_name)
         , parent_id       = nvl(i_parent_id, parent_id)
         , mcc             = nvl(i_mcc, mcc)
         , partner_id_code = nvl(i_partner_id_code, partner_id_code)
   --    , contract_id     = nvl(i_contract_id, contract_id)
         , risk_indicator  = nvl(i_risk_indicator, risk_indicator)
         , mc_assigned_id  = nvl(i_mc_assigned_id, mc_assigned_id)
     where id              = i_merchant_id;

    manage_status_events(
        i_merchant_id     => i_merchant_id
      , i_status          => i_status
    );

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'acq_merchant'
          , i_column_name   => 'description'
          , i_object_id     => i_merchant_id
          , i_lang          => i_lang
          , i_text          => i_description
        );
    end if;

end;

procedure remove_merchant(
    i_merchant_id       in      com_api_type_pkg.t_short_id
) is
    l_inst_id                   com_api_type_pkg.t_inst_id;
begin
    select inst_id
      into l_inst_id
      from acq_merchant m
     where m.id = i_merchant_id;

    ost_api_institution_pkg.check_status(
        i_inst_id     => l_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    );     

    delete from acq_merchant_vw
     where id = i_merchant_id;
end;

procedure get_merchant (
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_merchant_number   in      varchar2
  , o_merchant_id          out  com_api_type_pkg.t_short_id
  , o_split_hash           out  com_api_type_pkg.t_tiny_id
) is
    l_customer_id          com_api_type_pkg.t_medium_id;
begin
    get_merchant (
        i_inst_id          => i_inst_id
      , i_merchant_number  => i_merchant_number
      , o_customer_id      => l_customer_id
      , o_merchant_id      => o_merchant_id
      , o_split_hash       => o_split_hash
    );
exception
    when no_data_found then
        o_merchant_id := null;
        o_split_hash := null;
end;

procedure get_merchant (
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_merchant_number   in      varchar2
  , o_customer_id          out  com_api_type_pkg.t_medium_id
  , o_merchant_id          out  com_api_type_pkg.t_short_id
  , o_split_hash           out  com_api_type_pkg.t_tiny_id
) is
begin
    select m.id
         , m.split_hash
         , c.customer_id
      into o_merchant_id
         , o_split_hash
         , o_customer_id
      from acq_merchant m
         , prd_contract c
     where m.inst_id         = i_inst_id
       and m.merchant_number = i_merchant_number
       and c.id              = m.contract_id;
exception
    when no_data_found then
        o_merchant_id := null;
        o_split_hash  := null;
        o_customer_id := null;
end;

procedure get_merchant(
    i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_merchant_name     in     com_api_type_pkg.t_name
  , o_merchant_id          out com_api_type_pkg.t_short_id
) is
begin
    select m.id
      into o_merchant_id
      from acq_merchant m
     where m.inst_id       = i_inst_id
       and m.merchant_name = i_merchant_name;
exception
    when no_data_found or too_many_rows then
        null;
end;

function get_merchant(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_merchant_number   in      com_api_type_pkg.t_merchant_number
  , i_mask_error        in      com_api_type_pkg.t_boolean            default com_api_const_pkg.FALSE
) return acq_api_type_pkg.t_merchant
is
    l_merchant                  acq_api_type_pkg.t_merchant;
begin
    begin
        select m.id
             , m.seqnum
             , m.merchant_number
             , m.merchant_name
             , m.merchant_type
             , m.parent_id
             , m.mcc
             , m.status
             , m.contract_id
             , c.product_id
             , m.inst_id
             , m.split_hash
             , m.partner_id_code
             , m.risk_indicator
             , m.mc_assigned_id
          into l_merchant
          from acq_merchant m
             , prd_contract c
         where c.id              = m.contract_id
           and m.inst_id         = i_inst_id
           and m.merchant_number = i_merchant_number;
    exception
        when no_data_found then
            if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error      => 'MERCHANT_NOT_FOUND'
                  , i_env_param1 => null
                  , i_env_param2 => i_merchant_number
                  , i_env_param3 => i_inst_id
                );
            end if;
    end;

    return l_merchant;
end;

function get_merchant(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_partner_id_code   in      com_api_type_pkg.t_auth_code
  , i_mask_error        in      com_api_type_pkg.t_boolean            default com_api_const_pkg.FALSE
) return acq_api_type_pkg.t_merchant is
    l_merchant acq_api_type_pkg.t_merchant;
begin  
  begin
        select m.id
             , m.seqnum
             , m.merchant_number
             , m.merchant_name
             , m.merchant_type
             , m.parent_id
             , m.mcc
             , m.status
             , m.contract_id
             , c.product_id
             , m.inst_id
             , m.split_hash
             , m.partner_id_code
             , m.risk_indicator
             , m.mc_assigned_id
          into l_merchant
          from acq_merchant m
             , prd_contract c
         where c.id              = m.contract_id
           and m.inst_id         = i_inst_id
           and m.partner_id_code = i_partner_id_code;
    exception
        when no_data_found then
            if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error      => 'MERCHANT_NOT_FOUND'
                  , i_env_param1 => null
                  , i_env_param2 => i_partner_id_code
                  , i_env_param3 => i_inst_id
                );
            end if;
    end;  

    return l_merchant;
end;

function get_merchant_name(
    i_merchant_id       in      com_api_type_pkg.t_short_id
  , i_mask_error        in      com_api_type_pkg.t_boolean
)
return com_api_type_pkg.t_name
is
    l_merchant_name             com_api_type_pkg.t_name;
begin
    begin
        select merchant_name
          into l_merchant_name
          from acq_merchant m
         where m.id = i_merchant_id;
    exception
        when no_data_found then
            if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error      => 'MERCHANT_IS_NOT_FOUND'
                  , i_env_param1 => i_merchant_id
                );
            end if;
    end;

    return l_merchant_name;
end;

function get_merchant_number(
    i_merchant_id       in      com_api_type_pkg.t_short_id
  , i_mask_error        in      com_api_type_pkg.t_boolean              default com_api_const_pkg.FALSE
)
return com_api_type_pkg.t_name
is
    l_merchant_number             com_api_type_pkg.t_name;
begin
    begin
        select merchant_number
          into l_merchant_number
          from acq_merchant m
         where m.id = i_merchant_id;
    exception
        when no_data_found then
            if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error      => 'MERCHANT_IS_NOT_FOUND'
                  , i_env_param1 => i_merchant_id
                );
            end if;
    end;

    return l_merchant_number;
end;

procedure manage_status_events(
    i_merchant_id  in      com_api_type_pkg.t_short_id
  , i_status       in      com_api_type_pkg.t_dict_value
) is
    l_old_status   com_api_type_pkg.t_dict_value;
    l_count        com_api_type_pkg.t_short_id;
    l_inst_id      com_api_type_pkg.t_inst_id;
    l_status       com_api_type_pkg.t_dict_value;
    l_params       com_api_type_pkg.t_param_tab;
begin
    select nvl(status, acq_api_const_pkg.MERCHANT_STATUS_ACTIVE)
         , inst_id
      into l_old_status
         , l_inst_id
      from acq_merchant
     where id = i_merchant_id;
    trc_log_pkg.debug('acq_api_merchant_pkg.manage_status_events: old_status='||l_old_status
        ||', status='||i_status||', inst_id='||l_inst_id);

    if l_old_status = i_status then
        return;
    elsif i_status = acq_api_const_pkg.MERCHANT_STATUS_SUSPENDED then
        com_api_error_pkg.raise_error(
            i_error      => 'CANNOT_SUSPEND_MERCHANT'
          , i_env_param1 => i_merchant_id
          , i_env_param2 => i_status
        );
    elsif l_old_status =  acq_api_const_pkg.MERCHANT_STATUS_SUSPENDED
        and i_status   =  acq_api_const_pkg.MERCHANT_STATUS_CLOSED
    then
        com_api_error_pkg.raise_error(
            i_error      => 'MERCHANT_ALREADY_SUSPENDED'
          , i_env_param1 => i_merchant_id
          , i_env_param2 => i_status
        );

    elsif l_old_status <> acq_api_const_pkg.MERCHANT_STATUS_CLOSED
        and i_status   =  acq_api_const_pkg.MERCHANT_STATUS_CLOSED
    then
        select count(id)
          into l_count
          from acq_terminal t
         where nvl(t.status, acq_api_const_pkg.TERMINAL_STATUS_ACTIVE) <> acq_api_const_pkg.TERMINAL_STATUS_CLOSED
          and t.merchant_id in (
            select m.id from acq_merchant m
            connect by prior m.id = m.parent_id start with m.id = i_merchant_id);

        if l_count > 0 then
           com_api_error_pkg.raise_error(
               i_error      => 'CANNOT_CLOSE_WORKING_MERCHANT'
             , i_env_param1 => i_merchant_id
             , i_env_param2 => l_count
            );
        end if;
    elsif l_old_status <> acq_api_const_pkg.MERCHANT_STATUS_ACTIVE
         and i_status     = acq_api_const_pkg.MERCHANT_STATUS_CLOSED
    then
        com_api_error_pkg.raise_error(
            i_error      => 'CANNOT_CLOSE_INACTIVE_MERCHANT'
          , i_env_param1 => i_merchant_id
        );
    else
        null;
    end if;

    trc_log_pkg.debug('acq_api_merchant_pkg.manage_status_events: register_event call');

    evt_api_status_pkg.change_status(
        i_initiator   => evt_api_const_pkg.INITIATOR_SYSTEM
      , i_entity_type => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
      , i_object_id   => i_merchant_id
      , i_new_status  => case i_status
                         when acq_api_const_pkg.MERCHANT_STATUS_CLOSED
                         then acq_api_const_pkg.MERCHANT_STATUS_SUSPENDED
                         else i_status
                         end
      , i_reason      => acq_api_const_pkg.STATUS_REASON_SYSTEM
      , o_status      => l_status
      , i_eff_date    => com_api_sttl_day_pkg.get_sysdate
      , i_raise_error => com_api_const_pkg.TRUE
      , i_params      => l_params
    );

    trc_log_pkg.debug('acq_api_merchant_pkg.manage_status_events finished');
end;

procedure change_status_event is
    l_params           com_api_type_pkg.t_param_tab;
    l_object_id        com_api_type_pkg.t_short_id;
    l_status  com_api_type_pkg.t_dict_value;
begin
    l_params     := evt_api_shared_data_pkg.g_params;

    l_status     := rul_api_param_pkg.get_param_char('MERCHANT_STATUS', l_params);
    l_object_id  := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);
    set_status(
        i_merchant_id  => l_object_id
      , i_status       => l_status
    );
end;

procedure suspend_merchant is
    l_params           com_api_type_pkg.t_param_tab;
    l_object_id        com_api_type_pkg.t_short_id;
begin
    l_params     := evt_api_shared_data_pkg.g_params;

    l_object_id  := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);

    set_status(
        i_merchant_id   =>  l_object_id
      , i_status        =>  acq_api_const_pkg.MERCHANT_STATUS_SUSPENDED
    );
end;

procedure close_merchant(
    i_mask_error        in      com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.close_merchant: ';
    l_params                    com_api_type_pkg.t_param_tab;
    l_object_id                 com_api_type_pkg.t_short_id;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_status                    com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START for evt_api_shared_data_pkg.g_params->OBJECT_ID');

    l_params    := evt_api_shared_data_pkg.g_params;

    l_object_id := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);
    l_inst_id   := rul_api_param_pkg.get_param_num('INST_ID',   l_params);

    -- Check whether there is a merchant with identifier
    begin
        select status
          into l_status
          from acq_merchant
         where id = l_object_id;
    exception
        when no_data_found then
            if i_mask_error = com_api_type_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error      => 'MERCHANT_NOT_FOUND'
                  , i_env_param1 => l_object_id
                );
            end if;
    end;

    if l_status = acq_api_const_pkg.MERCHANT_STATUS_CLOSED then
        trc_log_pkg.debug(LOG_PREFIX || 'END: there is nothing to do with closed merchant [' || l_object_id || ']');

    elsif l_status is null then    
        trc_log_pkg.debug(LOG_PREFIX || 'END: merchant [' || l_object_id || '] has not been found');

    else
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'closing merchant [' || l_object_id || '] with status [#1]'
          , i_env_param1 => l_status
        );

        -- Closing merchant accounts, exlude accounts linked to another merchants
        for rec in (
            select a.account_id
              from acc_account_object a
                 , acc_account ac
             where a.object_id = l_object_id
               and a.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
               and a.account_id = ac.id
               and ac.status <> acc_api_const_pkg.ACCOUNT_STATUS_CLOSED
               and not exists(
                   select 1 from acc_account_object b
                    where a.account_id = b.account_id
                      and a.entity_type = b.entity_type
                      and a.object_id <> b.object_id
               )
        ) loop
            acc_api_account_pkg.close_account(i_account_id => rec.account_id);
        end loop;

        -- Closing terminals connected to a merchant
        for rec in (
            select t.id as terminal_id
              from acq_terminal t
             where t.merchant_id = l_object_id
               and t.status <> acq_api_const_pkg.TERMINAL_STATUS_CLOSED
        ) loop
            evt_api_shared_data_pkg.set_param(
                i_name  => 'OBJECT_ID'
              , i_value => rec.terminal_id
            );
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'going to close terminal [#1]'
              , i_env_param1 => rec.terminal_id
            );
            -- In addition to parameter evt_api_shared_data_pkg->OBJECT_ID this
            -- procedure also uses parameter evt_api_shared_data_pkg->INST_ID
            acq_api_terminal_pkg.close_terminal;
        end loop;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'all terminals connected to the merchant [#1] were closed'
          , i_env_param1 => l_object_id
        );

        -- Closing child sub-merchants of a merchant recursively
        for rec in (
            select m.id as merchant_id
              from acq_merchant m
             where m.parent_id = l_object_id
               and m.status   != acq_api_const_pkg.MERCHANT_STATUS_CLOSED
        ) loop
            evt_api_shared_data_pkg.set_param(
                i_name  => 'OBJECT_ID'
              , i_value => rec.merchant_id
            );
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'going to close sub-merchant [#1]'
              , i_env_param1 => rec.merchant_id
            );
            -- In addition to parameter evt_api_shared_data_pkg->OBJECT_ID this
            -- procedure also uses parameter evt_api_shared_data_pkg->INST_ID
            close_merchant(i_mask_error => i_mask_error);
        end loop;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'all sub-merchant of the merchant [#1] were closed'
          , i_env_param1 => l_object_id
        );

        -- Restore parameter's value from entry point of the procedure
        evt_api_shared_data_pkg.set_param(
            i_name      => 'OBJECT_ID'
          , i_value     => l_object_id
        );

        -- Also it is necessary to close all services are linked with a merchant
        prd_api_service_pkg.close_service(
            i_entity_type => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
          , i_object_id   => l_object_id
          , i_inst_id     => l_inst_id
          , i_params      => l_params
        );

        set_status(
            i_merchant_id   => l_object_id
          , i_status        => acq_api_const_pkg.MERCHANT_STATUS_CLOSED
        );

        trc_log_pkg.debug(LOG_PREFIX || 'END');
    end if;
end;

procedure set_status(
    i_merchant_id   in     com_api_type_pkg.t_short_id
  , i_status        in     com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.set_status: ';
    l_inst_id              com_api_type_pkg.t_inst_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START for i_merchant_id [' || i_merchant_id || '], i_status [#1]'
      , i_env_param1 => i_status
    );

    select m.inst_id
      into l_inst_id
      from acq_merchant m
     where m.id = i_merchant_id;

    ost_api_institution_pkg.check_status(
        i_inst_id     => l_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    );

    update acq_merchant
       set status = i_status
     where id     = i_merchant_id;
    
    trc_log_pkg.debug(LOG_PREFIX || 'END, merchant''s status has ' || case when sql%rowcount = 0 then 'NOT ' else null end || 'been changed');
end;

function get_merchant_account_id(
    i_merchant_id   in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_medium_id
is
    l_account_id        com_api_type_pkg. t_medium_id;
begin
    select min(account_id) keep(dense_rank first order by usage_order) s
      into l_account_id
      from acc_account_object
     where entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
       and object_id   = i_merchant_id;

    return l_account_id;
end;

function get_merchant_address_id(
    i_merchant_id   in     com_api_type_pkg.t_short_id
  , i_lang          in     com_api_type_pkg.t_dict_value default null
) return com_api_type_pkg.t_long_id is
    l_result      com_api_type_pkg.t_long_id;
    l_lang        com_api_type_pkg.t_dict_value;
begin
    l_lang := nvl(i_lang, com_ui_user_env_pkg.get_user_lang);

    -- If terminal_address does not exists, we try to find last address in terminal's merchant hierarchy
    select max(o.address_id) keep(dense_rank first order by tree.mrc_level, decode(a.lang, l_lang, 1, 'LANGENG', 2, 3))
      into l_result
      from com_address_object_vw o
         , com_address_vw a
         , (  select x.id, level mrc_level
              from acq_merchant_vw x
           connect by x.id   = prior x.parent_id
             start with x.id = i_merchant_id
         ) tree
     where o.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
       and o.address_type = 'ADTPBSNA'
       and o.object_id = tree.id
       and o.address_id = a.id;

    return l_result;
end;

procedure get_merchant(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_merchant_card_number  in     com_api_type_pkg.t_card_number
  , o_merchant_id              out com_api_type_pkg.t_short_id
) is
    l_card_id       com_api_type_pkg.t_medium_id;
    l_split_hash    com_api_type_pkg.t_tiny_id;
begin
    l_card_id := iss_api_card_pkg.get_card_id(
                     i_card_number  => i_merchant_card_number
                 );

    l_split_hash := com_api_hash_pkg.get_split_hash(
                        i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
                      , i_object_id   => l_card_id
                      , i_mask_error  => com_api_const_pkg.FALSE
                    );

    begin
        select b.object_id
          into o_merchant_id
          from acc_account_object a
             , acc_account_object b
         where a.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
           and a.object_id   = l_card_id
           and a.split_hash  = l_split_hash
           and a.account_id  = b.account_id
           and b.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
           and b.split_hash  = l_split_hash;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error             => 'MERCHANT_IS_NOT_FOUND'
              , i_env_param1        => o_merchant_id
              , i_mask_error        => com_api_type_pkg.FALSE
            );
    end;

    trc_log_pkg.debug(
        i_text           => 'Merchant got [#1][#2]'
      , i_env_param1     => iss_api_card_pkg.get_card_mask(i_merchant_card_number)
      , i_env_param3     => o_merchant_id
    );

end get_merchant;

end;
/
