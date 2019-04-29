create or replace package body acq_api_terminal_pkg as
/************************************************************* 
* API procedures for ACQ Terminal
* Created by Filimonov A.(filimonov@bpcbt.com)  at 17.11.2009
* Last changed by $Author$ 
* $LastChangedDate::                           $
* Revision: $LastChangedRevision$
* Module: ACQ_API_TERMINAL_PKG
* @headcom
*************************************************************/ 

procedure check_device_id(
    i_device_id              in      com_api_type_pkg.t_short_id
  , i_terminal_type          in      com_api_type_pkg.t_dict_value
  , i_status                 in      com_api_type_pkg.t_dict_value
) is
    l_terminal_number  com_api_type_pkg.t_terminal_number;
begin
    if  i_device_id is not null 
    and i_status        = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
    and i_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM 
    then
        begin
            select t.terminal_number 
              into l_terminal_number
              from acq_terminal t
             where decode(terminal_type, 'TRMT0002', decode(status, 'TRMS0001', device_id)) = i_device_id; --to use functional index
        exception when no_data_found then
            null;
        end;

        if l_terminal_number is not null then
            com_api_error_pkg.raise_error(
                i_error       => 'DEVICE_ALREADY_USED'
              , i_env_param1  => i_device_id
              , i_env_param2  => l_terminal_number
            );
        end if;
    end if;
end;

procedure add_terminal(
    io_terminal_id           in out  com_api_type_pkg.t_short_id
  , i_terminal_number        in      com_api_type_pkg.t_terminal_number
  , i_merchant_id            in      com_api_type_pkg.t_short_id
  , i_mcc                    in      com_api_type_pkg.t_mcc
  , i_contract_id            in      com_api_type_pkg.t_medium_id
  , i_plastic_number         in      com_api_type_pkg.t_card_number
  , i_terminal_type          in      com_api_type_pkg.t_dict_value
  , i_card_data_input_cap    in      com_api_type_pkg.t_dict_value
  , i_crdh_auth_cap          in      com_api_type_pkg.t_dict_value
  , i_card_capture_cap       in      com_api_type_pkg.t_dict_value
  , i_term_operating_env     in      com_api_type_pkg.t_dict_value
  , i_crdh_data_present      in      com_api_type_pkg.t_dict_value
  , i_card_data_present      in      com_api_type_pkg.t_dict_value
  , i_card_data_input_mode   in      com_api_type_pkg.t_dict_value
  , i_crdh_auth_method       in      com_api_type_pkg.t_dict_value
  , i_crdh_auth_entity       in      com_api_type_pkg.t_dict_value
  , i_card_data_output_cap   in      com_api_type_pkg.t_dict_value
  , i_term_data_output_cap   in      com_api_type_pkg.t_dict_value
  , i_pin_capture_cap        in      com_api_type_pkg.t_dict_value
  , i_cat_level              in      com_api_type_pkg.t_dict_value
  , i_status                 in      com_api_type_pkg.t_dict_value
  , i_inst_id                in      com_api_type_pkg.t_inst_id
  , i_device_id              in      com_api_type_pkg.t_short_id
  , i_is_mac                 in      com_api_type_pkg.t_boolean
  , i_gmt_offset             in      pls_integer
  , i_standard_id            in      com_api_type_pkg.t_tiny_id
  , i_version_id             in      com_api_type_pkg.t_tiny_id
  , i_split_hash             in      com_api_type_pkg.t_tiny_id
  , i_cash_dispenser_present in      com_api_type_pkg.t_boolean
  , i_payment_possibility    in      com_api_type_pkg.t_boolean
  , i_use_card_possibility   in      com_api_type_pkg.t_boolean
  , i_cash_in_present        in      com_api_type_pkg.t_boolean
  , i_available_network      in      com_api_type_pkg.t_short_id
  , i_available_operation    in      com_api_type_pkg.t_short_id
  , i_available_currency     in      com_api_type_pkg.t_short_id
  , i_mcc_template_id        in      com_api_type_pkg.t_medium_id
  , i_terminal_profile       in      com_api_type_pkg.t_medium_id   default null
  , i_pin_block_format       in      com_api_type_pkg.t_dict_value  default null
  , i_pos_batch_support      in      com_api_type_pkg.t_dict_value  default null
) is
    l_terminal_number       com_api_type_pkg.t_terminal_number;
    l_id                    com_api_type_pkg.t_long_id;
begin
    if i_contract_id is null then
        com_api_error_pkg.raise_error(
            i_error         => 'CONTRACT_ID_NOT_DEFINED'
        );
    end if;

    if i_terminal_type is null then
        com_api_error_pkg.raise_error(
            i_error         => 'TERMINAL_TYPE_NOT_DEFINED'
        );
    end if;
    
    check_device_id(
        i_device_id      => i_device_id
      , i_terminal_type  => i_terminal_type
      , i_status         => i_status
    );

    ost_api_institution_pkg.check_status(
        i_inst_id     => i_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_CREATE
    );

    if io_terminal_id is null then
        select acq_terminal_seq.nextval into io_terminal_id from dual;
    end if;

    l_terminal_number := nvl(i_terminal_number, io_terminal_id);
    trc_log_pkg.debug('i_terminal_profile [' || i_terminal_profile || ']');

    begin
        insert into acq_terminal(
            id
          , seqnum
          , is_template
          , terminal_number
          , terminal_type
          , merchant_id
          , mcc
          , plastic_number
          , card_data_input_cap
          , crdh_auth_cap
          , card_capture_cap
          , term_operating_env
          , crdh_data_present
          , card_data_present
          , card_data_input_mode
          , crdh_auth_method
          , crdh_auth_entity
          , card_data_output_cap
          , term_data_output_cap
          , pin_capture_cap
          , cat_level
          , status
          , is_mac
          , device_id
          , gmt_offset
          , contract_id
          , inst_id
          , split_hash
          , cash_dispenser_present
          , payment_possibility
          , use_card_possibility
          , cash_in_present
          , available_network
          , available_operation
          , available_currency
          , mcc_template_id
          , terminal_profile
          , pin_block_format
          , pos_batch_support
        ) values (
            io_terminal_id
          , 1
          , com_api_type_pkg.FALSE
          , l_terminal_number
          , i_terminal_type
          , i_merchant_id
          , i_mcc
          , i_plastic_number
          , i_card_data_input_cap
          , i_crdh_auth_cap
          , i_card_capture_cap
          , i_term_operating_env
          , i_crdh_data_present
          , i_card_data_present
          , i_card_data_input_mode
          , i_crdh_auth_method
          , i_crdh_auth_entity
          , i_card_data_output_cap
          , i_term_data_output_cap
          , i_pin_capture_cap
          , i_cat_level
          , i_status
          , i_is_mac
          , i_device_id
          , i_gmt_offset
          , i_contract_id
          , i_inst_id
          , i_split_hash
          , i_cash_dispenser_present
          , i_payment_possibility
          , i_use_card_possibility
          , i_cash_in_present
          , i_available_network
          , i_available_operation
          , i_available_currency
          , i_mcc_template_id
          , i_terminal_profile
          , i_pin_block_format
          , i_pos_batch_support
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error(
                i_error         => 'TERMINAL_ALREADY_EXIST'
              , i_env_param1    => l_terminal_number
            );
    end;
    
    cmn_ui_standard_object_pkg.add_standard_object(
        i_entity_type  => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
      , i_object_id    => io_terminal_id
      , i_standard_id  => i_standard_id
    );
        
    if i_version_id is not null then
        cmn_ui_standard_object_pkg.add_standard_version_object(
            o_id          => l_id
          , i_entity_type => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
          , i_object_id   => io_terminal_id
          , i_version_id  => i_version_id
          , i_start_date  => get_sysdate
        );
    end if;
end;

procedure modify_terminal(
    i_terminal_id            in      com_api_type_pkg.t_short_id
  , i_terminal_number        in      varchar2
  , i_merchant_id            in      com_api_type_pkg.t_short_id
  , i_mcc                    in      com_api_type_pkg.t_mcc
  , i_plastic_number         in      com_api_type_pkg.t_card_number
  , i_contract_id            in      com_api_type_pkg.t_medium_id
  , i_card_data_input_cap    in      com_api_type_pkg.t_dict_value
  , i_crdh_auth_cap          in      com_api_type_pkg.t_dict_value
  , i_card_capture_cap       in      com_api_type_pkg.t_dict_value
  , i_term_operating_env     in      com_api_type_pkg.t_dict_value
  , i_crdh_data_present      in      com_api_type_pkg.t_dict_value
  , i_card_data_present      in      com_api_type_pkg.t_dict_value
  , i_card_data_input_mode   in      com_api_type_pkg.t_dict_value
  , i_crdh_auth_method       in      com_api_type_pkg.t_dict_value
  , i_crdh_auth_entity       in      com_api_type_pkg.t_dict_value
  , i_card_data_output_cap   in      com_api_type_pkg.t_dict_value
  , i_term_data_output_cap   in      com_api_type_pkg.t_dict_value
  , i_pin_capture_cap        in      com_api_type_pkg.t_dict_value
  , i_cat_level              in      com_api_type_pkg.t_dict_value
  , i_status                 in      com_api_type_pkg.t_dict_value
  , i_device_id              in      com_api_type_pkg.t_short_id
  , i_is_mac                 in      com_api_type_pkg.t_boolean
  , i_gmt_offset             in      pls_integer
  , i_version_id             in      com_api_type_pkg.t_tiny_id
  , i_cash_dispenser_present in      com_api_type_pkg.t_boolean
  , i_payment_possibility    in      com_api_type_pkg.t_boolean
  , i_use_card_possibility   in      com_api_type_pkg.t_boolean
  , i_cash_in_present        in      com_api_type_pkg.t_boolean
  , i_available_network      in      com_api_type_pkg.t_short_id
  , i_available_operation    in      com_api_type_pkg.t_short_id
  , i_available_currency     in      com_api_type_pkg.t_short_id
  , i_mcc_template_id        in      com_api_type_pkg.t_medium_id
  , i_terminal_profile       in      com_api_type_pkg.t_medium_id   default null
  , i_pin_block_format       in      com_api_type_pkg.t_dict_value  default null
  , i_pos_batch_support      in      com_api_type_pkg.t_dict_value  default null
) is
    l_id                             com_api_type_pkg.t_long_id;
    l_inst_id                        com_api_type_pkg.t_inst_id;
begin
    select inst_id
      into l_inst_id
      from acq_terminal t
     where t.id = i_terminal_id;

    ost_api_institution_pkg.check_status(
        i_inst_id     => l_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    );  

    update acq_terminal
       set card_data_input_cap    = nvl(i_card_data_input_cap    , card_data_input_cap)  
         , crdh_auth_cap          = nvl(i_crdh_auth_cap          , crdh_auth_cap)
         , card_capture_cap       = nvl(i_card_capture_cap       , card_capture_cap)
         , term_operating_env     = nvl(i_term_operating_env     , term_operating_env)
         , crdh_data_present      = nvl(i_crdh_data_present      , crdh_data_present)
         , card_data_present      = nvl(i_card_data_present      , card_data_present)
         , card_data_input_mode   = nvl(i_card_data_input_mode   , card_data_input_mode)
         , crdh_auth_method       = nvl(i_crdh_auth_method       , crdh_auth_method)
         , crdh_auth_entity       = nvl(i_crdh_auth_entity       , crdh_auth_entity)
         , card_data_output_cap   = nvl(i_card_data_output_cap   , card_data_output_cap)
         , term_data_output_cap   = nvl(i_term_data_output_cap   , term_data_output_cap)
         , pin_capture_cap        = nvl(i_pin_capture_cap        , pin_capture_cap)
         , cat_level              = nvl(i_cat_level              , cat_level)
         , status                 = nvl(i_status                 , status)
         , terminal_number        = nvl(i_terminal_number        , terminal_number)
         , merchant_id            = nvl(i_merchant_id            , merchant_id)
         , mcc                    = nvl(i_mcc                    , mcc)
         , plastic_number         = nvl(i_plastic_number         , plastic_number)
         , device_id              = nvl(i_device_id              , device_id)
         , is_mac                 = nvl(i_is_mac                 , is_mac)
         , gmt_offset             = nvl(i_gmt_offset             , gmt_offset)
         , cash_dispenser_present = nvl(i_cash_dispenser_present , cash_dispenser_present)
         , payment_possibility    = nvl(i_payment_possibility    , payment_possibility)
         , use_card_possibility   = nvl(i_use_card_possibility   , use_card_possibility)
         , cash_in_present        = nvl(i_cash_in_present        , cash_in_present)
         , available_network      = nvl(i_available_network      , available_network)
         , available_operation    = nvl(i_available_operation    , available_operation)
         , available_currency     = nvl(i_available_currency     , available_currency)
         , mcc_template_id        = nvl(i_mcc_template_id        , mcc_template_id)
         , terminal_profile       = nvl(i_terminal_profile       , terminal_profile)
         , pin_block_format       = nvl(i_pin_block_format       , pin_block_format)
         , pos_batch_support      = nvl(i_pos_batch_support      , pos_batch_support)
     where id                   = i_terminal_id;
    
    if i_version_id is not null then
        for rec in (
            select id
              from cmn_standard_version_obj v
             where v.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
               and v.object_id   = i_terminal_id
        ) loop
            cmn_ui_standard_object_pkg.remove_standard_version_object(
                i_id => rec.id
            );
        end loop;
                   
        cmn_ui_standard_object_pkg.add_standard_version_object(
            o_id          => l_id
          , i_entity_type => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
          , i_object_id   => i_terminal_id
          , i_version_id  => i_version_id
          , i_start_date  => get_sysdate
        );
    end if;
end;

procedure remove_terminal(
    i_terminal_id   in      com_api_type_pkg.t_short_id
) is
    l_inst_id               com_api_type_pkg.t_inst_id;
begin
    select inst_id
      into l_inst_id
      from acq_terminal t
     where t.id = i_terminal_id;
 
    ost_api_institution_pkg.check_status(
        i_inst_id     => l_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    ); 
    
    delete from acq_terminal_vw
     where id = i_terminal_id;
end;

procedure get_terminal (
    i_inst_id               in      com_api_type_pkg.t_inst_id
    , i_merchant_number     in      varchar2
    , i_terminal_number     in      varchar2
    , o_merchant_id         out     com_api_type_pkg.t_short_id
    , o_terminal_id         out     com_api_type_pkg.t_short_id
) is
begin
    begin
        select
            t.merchant_id
            , t.id
        into
            o_merchant_id
            , o_terminal_id
        from
            acq_merchant m
            , acq_terminal t
        where
            m.inst_id = i_inst_id
            and m.merchant_number = i_merchant_number
            and m.id = t.merchant_id
            and t.terminal_number = i_terminal_number;
    exception 
        when no_data_found then
            select t.merchant_id
                 , t.id
              into o_merchant_id
                 , o_terminal_id
              from acq_merchant m
                 , acq_terminal t
             where m.inst_id = i_inst_id
               and m.merchant_number = i_merchant_number
               and m.id = t.merchant_id
               and reverse(t.terminal_number) like reverse('%' || i_terminal_number);
    end;
exception
    when others then
        o_merchant_id := null;
        o_terminal_id := null;
end;

procedure get_terminal (
    i_merchant_id         in      com_api_type_pkg.t_short_id
    , i_terminal_number     in      varchar2
    , o_terminal_id         out     com_api_type_pkg.t_short_id
) is
begin
    select
        t.id
    into
        o_terminal_id
    from
        acq_terminal t
    where
        t.merchant_id = i_merchant_id
        and t.terminal_number = i_terminal_number;
exception
    when others then
        o_terminal_id := null;
end;

procedure get_merchant(
    i_terminal_number       in      com_api_type_pkg.t_terminal_number
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , o_merchant_number          out  com_api_type_pkg.t_merchant_number
  , o_merchant_id              out  com_api_type_pkg.t_short_id
  , o_terminal_id              out  com_api_type_pkg.t_short_id
  , i_mask_error            in      com_api_type_pkg.t_boolean             default com_api_const_pkg.FALSE
) is
begin
    begin
        select m.merchant_number
             , m.id
             , t.id
          into o_merchant_number
             , o_merchant_id
             , o_terminal_id
          from acq_terminal t
             , acq_merchant m
         where t.terminal_number = i_terminal_number
           and t.inst_id         = i_inst_id
           and m.id              = t.merchant_id;
    exception
        when no_data_found then
            select m.merchant_number
                 , m.id
                 , t.id
              into o_merchant_number
                 , o_merchant_id
                 , o_terminal_id
              from acq_terminal t
                 , acq_merchant m
             where reverse(t.terminal_number) like reverse('%' || i_terminal_number)
               and t.inst_id         = i_inst_id
               and m.id              = t.merchant_id;
    end;
exception
    when no_data_found then
        if i_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error         => 'TERMINAL_NOT_FOUND'
              , i_env_param1    => i_terminal_number
            );
        end if;
    when too_many_rows then
        if i_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error         => 'TOO_MANY_TERMINALS'
              , i_env_param1    => i_terminal_number
            );
        end if;
end;

function get_merchant_id(
    i_terminal_id           in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_short_id is
    l_result                com_api_type_pkg.t_short_id;
begin
    select merchant_id
      into l_result
      from acq_terminal
     where id = i_terminal_id;

    return l_result;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error         => 'TERMINAL_NOT_FOUND'
          , i_env_param1    => i_terminal_id
        );
end;

function get_merchant_number(
    i_terminal_number       in      com_api_type_pkg.t_terminal_number
  , i_inst_id               in      com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_merchant_number is
    l_result                com_api_type_pkg.t_merchant_number;
begin
    select m.merchant_number
      into l_result
      from acq_terminal t
         , acq_merchant m
     where t.terminal_number = i_terminal_number
       and t.inst_id         = i_inst_id
       and m.id              = t.merchant_id;

    return l_result;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error         => 'TERMINAL_NOT_FOUND'
          , i_env_param1    => i_terminal_number
        );
end;

function get_product_id(
    i_terminal_id           in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_short_id is
    l_result                com_api_type_pkg.t_short_id;
begin
    select product_id
      into l_result
      from acq_terminal t,
           prd_contract c
     where t.id = i_terminal_id
       and t.contract_id = c.id;

    return l_result;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error         => 'TERMINAL_NOT_FOUND'
          , i_env_param1    => i_terminal_id
        );
end;

function get_terminal_number(
    i_terminal_id       in      com_api_type_pkg.t_short_id
  , i_mask_error        in      com_api_type_pkg.t_boolean            default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_name is
    l_terminal_number           com_api_type_pkg.t_name;
begin
    begin
        select terminal_number
          into l_terminal_number
          from acq_terminal t
         where t.id = i_terminal_id;
    exception
        when no_data_found then
            if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error         => 'TERMINAL_NOT_FOUND'
                  , i_env_param1    => i_terminal_id
                );
            end if;
    end;

    return l_terminal_number;
end;

function get_inst_id(
    i_terminal_id           in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_inst_id is
    l_result                com_api_type_pkg.t_inst_id;
begin
    select inst_id
      into l_result
      from acq_terminal
     where id = i_terminal_id;

    return l_result;
exception
    when no_data_found then
        return null;
end;


function get_terminal_address_id(
    i_terminal_id           in      com_api_type_pkg.t_short_id
  , i_lang                  in      com_api_type_pkg.t_dict_value default null 
) return com_api_type_pkg.t_long_id is
    l_result      com_api_type_pkg.t_long_id;
    l_lang        com_api_type_pkg.t_dict_value;
begin
    l_lang := nvl(i_lang, com_ui_user_env_pkg.get_user_lang);
    
    select min(o.address_id) keep(dense_rank first order by decode(a.lang, l_lang, 1, 'LANGENG', 2, 3))
      into l_result
      from com_address_object_vw o
         , com_address_vw a
     where o.entity_type  = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
       and o.address_type = com_api_const_pkg.ADDRESS_TYPE_BUSINESS  --'ADTPBSNA'
       and o.object_id    = i_terminal_id
       and a.id           = o.address_id;

    if l_result is null then
        for r in (
            select merchant_id
              from acq_terminal_vw
             where id = i_terminal_id
        ) loop
            return acq_api_merchant_pkg.get_merchant_address_id (
                i_merchant_id  => r.merchant_id
              , i_lang         => l_lang
            );
        end loop;
    end if;

    return l_result;
end;

function get_pos_batch_method (
    i_terminal_id           in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_dict_value is
    l_params                com_api_type_pkg.t_param_tab;
begin
    return prd_api_product_pkg.get_attr_value_char(
        i_product_id  => get_product_id(i_terminal_id)
      , i_entity_type => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
      , i_object_id   => i_terminal_id
      , i_attr_name   => 'ACQ_POS_BATCH_METHOD'
      , i_params      => l_params
      , i_eff_date    => get_sysdate
    );
exception
    when others then
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
            return acq_api_const_pkg.POS_BATCH_METHOD_VALIDATION;
        end if;
        raise;
end;

function get_partial_approval (
    i_terminal_id           in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean is
    l_params                com_api_type_pkg.t_param_tab;
begin
    return prd_api_product_pkg.get_attr_value_number(
        i_product_id  => get_product_id(i_terminal_id)
      , i_entity_type => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
      , i_object_id   => i_terminal_id
      , i_attr_name   => 'PARTIAL_APPROVAL_TERMINAL_SUPPORT'
      , i_params      => l_params
      , i_eff_date    => get_sysdate
    );
exception
    when others then
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
            return com_api_type_pkg.FALSE;
        end if;
        raise;
end;

function get_purchase_amount (
    i_terminal_id           in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean is
    l_params                com_api_type_pkg.t_param_tab;
begin
    return prd_api_product_pkg.get_attr_value_number(
        i_product_id  => get_product_id(i_terminal_id)
      , i_entity_type => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
      , i_object_id   => i_terminal_id
      , i_attr_name   => 'PURCHASE_AMOUNT_ONLY'
      , i_params      => l_params
      , i_eff_date    => get_sysdate
    );
exception
    when others then
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
            return com_api_type_pkg.FALSE;
        end if;
        raise;
end;

procedure close_terminal is
    LOG_PREFIX  constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.close_terminal: ';
    l_params             com_api_type_pkg.t_param_tab;
    l_inst_id            com_api_type_pkg.t_inst_id;
    l_object_id          com_api_type_pkg.t_short_id;
begin
    l_params    := evt_api_shared_data_pkg.g_params;

    l_object_id := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);
    l_inst_id   := rul_api_param_pkg.get_param_num('INST_ID', l_params);

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'START with l_object_id [' || l_object_id
                             || '], l_inst_id [' || l_inst_id || ']'
    );

    -- Closing terminal accounts, exlude accounts linked to another terminals
    for rec in (
        select account_id
          from acc_account acc
          join acc_account_object a    on a.account_id = acc.id
         where object_id = l_object_id
           and entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
           and not exists(
                   select 1 from acc_account_object b
                    where a.account_id = b.account_id
                      and a.entity_type = b.entity_type
                      and a.object_id <> b.object_id
               )
           and acc.status != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED
    ) loop
        acc_api_account_pkg.close_account(i_account_id => rec.account_id);
    end loop;

    set_status(
        i_terminal_id => l_object_id
      , i_status      => acq_api_const_pkg.TERMINAL_STATUS_CLOSED
    );

    -- Also it is necessary to close all services are linked with a terminal
    prd_api_service_pkg.close_service(
        i_entity_type => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
      , i_object_id   => l_object_id
      , i_inst_id     => l_inst_id
      , i_params      => l_params
    );

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'END'
    );
end close_terminal;

procedure set_status(
    i_terminal_id  in     com_api_type_pkg.t_short_id
  , i_status       in     com_api_type_pkg.t_dict_value
) is
    l_inst_id               com_api_type_pkg.t_inst_id;
begin
    trc_log_pkg.debug('acq_api_terminal_pkg.set_status: status='||i_status
                    ||', i_terminal_id='||i_terminal_id);

    select inst_id
      into l_inst_id
      from acq_terminal t
     where t.id = i_terminal_id;
 
    ost_api_institution_pkg.check_status(
        i_inst_id     => l_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    ); 

    update acq_terminal
       set status = i_status
     where id = i_terminal_id;
end;

function get_terminal(
    i_terminal_number       in      com_api_type_pkg.t_terminal_number
  , i_inst_id               in      com_api_type_pkg.t_inst_id             default null
  , i_mask_error            in      com_api_type_pkg.t_boolean             default com_api_const_pkg.FALSE
) return acq_api_type_pkg.t_terminal is
    l_terminal       acq_api_type_pkg.t_terminal;
begin
    begin
        select id
             , seqnum
             , is_template
             , terminal_number
             , terminal_type
             , merchant_id
             , mcc
             , plastic_number
             , card_data_input_cap
             , crdh_auth_cap
             , card_capture_cap
             , term_operating_env
             , crdh_data_present
             , card_data_present
             , card_data_input_mode
             , crdh_auth_method
             , crdh_auth_entity
             , card_data_output_cap
             , term_data_output_cap
             , pin_capture_cap
             , cat_level
             , gmt_offset
             , is_mac
             , device_id
             , status
             , contract_id
             , inst_id
             , split_hash
             , cash_dispenser_present
             , payment_possibility
             , use_card_possibility
             , cash_in_present
             , available_network
             , available_operation
             , available_currency
             , mcc_template_id
             , terminal_profile
             , pin_block_format
             , pos_batch_support
          into l_terminal
          from acq_terminal t
         where t.terminal_number = i_terminal_number
           and (t.inst_id = i_inst_id or i_inst_id is null);
    exception
        when no_data_found then
            select id
                 , seqnum
                 , is_template
                 , terminal_number
                 , terminal_type
                 , merchant_id
                 , mcc
                 , plastic_number
                 , card_data_input_cap
                 , crdh_auth_cap
                 , card_capture_cap
                 , term_operating_env
                 , crdh_data_present
                 , card_data_present
                 , card_data_input_mode
                 , crdh_auth_method
                 , crdh_auth_entity
                 , card_data_output_cap
                 , term_data_output_cap
                 , pin_capture_cap
                 , cat_level
                 , gmt_offset
                 , is_mac
                 , device_id
                 , status
                 , contract_id
                 , inst_id
                 , split_hash
                 , cash_dispenser_present
                 , payment_possibility
                 , use_card_possibility
                 , cash_in_present
                 , available_network
                 , available_operation
                 , available_currency
                 , mcc_template_id
                 , terminal_profile
                 , pin_block_format
                 , pos_batch_support
              into l_terminal
              from acq_terminal t
             where reverse(t.terminal_number) like reverse('%' || i_terminal_number)
               and (t.inst_id = i_inst_id or i_inst_id is null);
    end;
    
    return l_terminal;
exception
    when no_data_found then
        if i_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error         => 'TERMINAL_NOT_FOUND'
              , i_env_param1    => i_terminal_number
            );
        end if;
        return l_terminal;
    when too_many_rows then
        if i_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error         => 'TOO_MANY_TERMINALS'
              , i_env_param1    => i_terminal_number
            );
        end if;
        return l_terminal;
end;

end;
/
