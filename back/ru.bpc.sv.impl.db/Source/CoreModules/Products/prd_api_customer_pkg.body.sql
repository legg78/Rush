create or replace package body prd_api_customer_pkg is
/*********************************************************
*  API for customers <br />
*  Created by Kopachev D.(kopachev@bpcsv.com) at 17.11.2010 <br />
*  Module: PRD_API_CUSTOMER_PKG <br />
*  @headcom
**********************************************************/

procedure set_last_modify(
    i_customer_id          in     com_api_type_pkg.t_medium_id
) is
begin
    update prd_customer_vw
       set last_modify_date = get_sysdate
         , last_modify_user = get_user_id
     where id               = i_customer_id;
end;

procedure add_customer (
    o_id                      out com_api_type_pkg.t_medium_id
  , o_seqnum                  out com_api_type_pkg.t_seqnum
  , i_entity_type          in     com_api_type_pkg.t_dict_value
  , i_object_id            in     com_api_type_pkg.t_long_id
  , io_customer_number     in out com_api_type_pkg.t_name
  , i_inst_id              in     com_api_type_pkg.t_inst_id
  , i_category             in     com_api_type_pkg.t_dict_value
  , i_relation             in     com_api_type_pkg.t_dict_value
  , i_resident             in     com_api_type_pkg.t_boolean
  , i_nationality          in     com_api_type_pkg.t_curr_code
  , i_credit_rating        in     com_api_type_pkg.t_dict_value
  , i_money_laundry_risk   in     com_api_type_pkg.t_dict_value
  , i_money_laundry_reason in     com_api_type_pkg.t_dict_value
  , i_status               in     com_api_type_pkg.t_dict_value := null
  , i_ext_entity_type      in     com_api_type_pkg.t_dict_value := null
  , i_ext_object_id        in     com_api_type_pkg.t_long_id    := null
  , i_product_type         in     com_api_type_pkg.t_dict_value := null
  , i_employment_status    in     com_api_type_pkg.t_dict_value := null
  , i_employment_period    in     com_api_type_pkg.t_dict_value := null
  , i_residence_type       in     com_api_type_pkg.t_dict_value := null
  , i_marital_status       in     com_api_type_pkg.t_dict_value := null
  , i_marital_status_date  in     date                          := null
  , i_income_range         in     com_api_type_pkg.t_dict_value := null
  , i_number_of_children   in     com_api_type_pkg.t_dict_value := null
) is
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_param_tab             com_api_type_pkg.t_param_tab;
begin
    if i_entity_type is null then
        com_api_error_pkg.raise_error (
            i_error         => 'ENTITY_TYPE_IS_MANDATORY'
        );
    end if;
    if i_object_id is null and i_entity_type != com_api_const_pkg.ENTITY_TYPE_UNDEFINED then
        com_api_error_pkg.raise_error (
            i_error         => 'OBJECT_ID_IS_MANDATORY'
        );
    end if;

    -- Entity object <i_ext_object_id> should be associated with only one customer,
    -- and it shouldn't be reassigned (automatically), otherwise an error will be rised
    check_association(
        i_customer_id     => null
      , i_ext_entity_type => i_ext_entity_type
      , i_ext_object_id   => i_ext_object_id
    );

    ost_api_institution_pkg.check_status(
        i_inst_id     => i_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_CREATE
    ); 

    o_id         := prd_customer_seq.nextval;
    o_seqnum     := 1;
    l_split_hash := com_api_hash_pkg.get_split_hash(i_value => o_id);
    l_param_tab('CUSTOMER_ID')    := o_id;
    l_param_tab('ENTITY_TYPE')    := i_entity_type;
    l_param_tab('INST_ID')        := i_inst_id;
    l_param_tab('PRODUCT_TYPE')   := i_product_type;

    -- Generate customer number
    if io_customer_number is null then
        io_customer_number := rul_api_name_pkg.get_name (
                                  i_inst_id        => i_inst_id
                                  , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                  , i_param_tab    => l_param_tab
                              );
    else
        if rul_api_name_pkg.check_name(
            i_inst_id              => i_inst_id
          , i_entity_type          => iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
          , i_name                 => io_customer_number
          , i_param_tab            => l_param_tab
          , i_null_format_allowed  => com_api_const_pkg.TRUE
        ) = com_api_const_pkg.TRUE then
            null;
        else
            com_api_error_pkg.raise_error (
                i_error         => 'ENTITY_NAME_DONT_FIT_FORMAT'
                , i_env_param1  => i_inst_id
                , i_env_param2  => iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                , i_env_param3  => io_customer_number
            );
        end if;
    end if;

    io_customer_number := upper(io_customer_number);

    begin
        insert into prd_customer_vw (
            id
          , seqnum
          , entity_type
          , object_id
          , customer_number
          , inst_id
          , split_hash
          , category
          , relation
          , resident
          , nationality
          , credit_rating
          , money_laundry_risk
          , money_laundry_reason
          , last_modify_date
          , last_modify_user
          , status
          , ext_entity_type
          , ext_object_id
          , reg_date
          , employment_status
          , employment_period
          , residence_type
          , marital_status
          , marital_status_date
          , income_range
          , number_of_children
        ) values (
            o_id
          , o_seqnum
          , i_entity_type
          , i_object_id
          , io_customer_number
          , i_inst_id
          , l_split_hash
          , i_category
          , i_relation
          , i_resident
          , i_nationality
          , i_credit_rating
          , i_money_laundry_risk
          , i_money_laundry_reason
          , get_sysdate
          , get_user_id
          , nvl(i_status, prd_api_const_pkg.CUSTOMER_STATUS_ACTIVE)
          , i_ext_entity_type
          , i_ext_object_id
          , get_sysdate
          , i_employment_status
          , i_employment_period
          , i_residence_type
          , i_marital_status
          , i_marital_status_date
          , i_income_range
          , i_number_of_children
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error(
                i_error      =>  'CUSTOMER_ALREADY_EXISTS'
              , i_env_param1 => io_customer_number
              , i_env_param2 => ost_ui_institution_pkg.get_inst_name(i_inst_id)
            );
    end;
    trc_log_pkg.info(
        i_text => 'Create new customer with number=' || io_customer_number||', id='||o_id
    );

    evt_api_event_pkg.register_event(
        i_event_type    => prd_api_const_pkg.EVENT_CUSTOMER_CREATION
      , i_eff_date      => com_api_sttl_day_pkg.get_sysdate()
      , i_entity_type   => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
      , i_object_id     => o_id
      , i_inst_id       => i_inst_id
      , i_split_hash    => l_split_hash
      , i_param_tab     => l_param_tab
    );

end;

procedure modify_customer (
    i_id                   in     com_api_type_pkg.t_medium_id
  , io_seqnum              in out com_api_type_pkg.t_seqnum
  , i_object_id            in     com_api_type_pkg.t_long_id
  , i_customer_number      in     com_api_type_pkg.t_name
  , i_category             in     com_api_type_pkg.t_dict_value
  , i_relation             in     com_api_type_pkg.t_dict_value
  , i_resident             in     com_api_type_pkg.t_boolean
  , i_nationality          in     com_api_type_pkg.t_curr_code
  , i_credit_rating        in     com_api_type_pkg.t_dict_value
  , i_money_laundry_risk   in     com_api_type_pkg.t_dict_value
  , i_money_laundry_reason in     com_api_type_pkg.t_dict_value
  , i_status               in     com_api_type_pkg.t_dict_value := null
  , i_ext_entity_type      in     com_api_type_pkg.t_dict_value := null
  , i_ext_object_id        in     com_api_type_pkg.t_long_id    := null
  , i_product_type         in     com_api_type_pkg.t_dict_value := null
  , i_employment_status    in     com_api_type_pkg.t_dict_value := null
  , i_employment_period    in     com_api_type_pkg.t_dict_value := null
  , i_residence_type       in     com_api_type_pkg.t_dict_value := null
  , i_marital_status       in     com_api_type_pkg.t_dict_value := null
  , i_marital_status_date  in     date                          := null
  , i_income_range         in     com_api_type_pkg.t_dict_value := null
  , i_number_of_children   in     com_api_type_pkg.t_dict_value := null
) is
    l_inst_id                     com_api_type_pkg.t_inst_id;
    l_split_hash                  com_api_type_pkg.t_tiny_id;
    l_param_tab                   com_api_type_pkg.t_param_tab;
begin
    -- Entity object <i_ext_object_id> should be associated with only one customer and vice versa,
    -- and it shouldn't be reassigned (automatically), otherwise an error will be rised
    check_association(
        i_customer_id     => i_id
      , i_ext_entity_type => i_ext_entity_type
      , i_ext_object_id   => i_ext_object_id
    );

    for c in (
        select inst_id
             , split_hash
          from prd_customer_vw
         where id = i_id
    ) loop
        l_inst_id := c.inst_id;
        l_split_hash := c.split_hash;
    end loop;
    
    ost_api_institution_pkg.check_status(
        i_inst_id     => l_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    ); 

    update prd_customer_vw
       set seqnum               = io_seqnum
         , object_id            = nvl(i_object_id, object_id)
         , customer_number      = nvl(upper(i_customer_number), customer_number)
         , category             = nvl(i_category, category)
         , resident             = nvl(i_resident, resident)
         , nationality          = nvl(i_nationality, nationality)
         , relation             = nvl(i_relation, relation)
         , credit_rating        = i_credit_rating
         , money_laundry_risk   = nvl(i_money_laundry_risk, money_laundry_risk)
         , money_laundry_reason = nvl(i_money_laundry_reason, money_laundry_reason)
         , last_modify_date     = get_sysdate
         , last_modify_user     = get_user_id
         , status               = nvl(i_status, status)
         , ext_entity_type      = i_ext_entity_type
         , ext_object_id        = i_ext_object_id
         , employment_status    = i_employment_status
         , employment_period    = i_employment_period
         , residence_type       = i_residence_type
         , marital_status       = i_marital_status
         , marital_status_date  = i_marital_status_date
         , income_range         = i_income_range
         , number_of_children   = i_number_of_children
     where id                   = i_id;

    io_seqnum := io_seqnum + 1;

    trc_log_pkg.info(
        i_text => 'Modify customer with number=' || i_customer_number
    );
    l_param_tab('PRODUCT_TYPE')   := i_product_type;

    evt_api_event_pkg.register_event(
        i_event_type    => prd_api_const_pkg.EVENT_CUSTOMER_MODIFY
      , i_eff_date      => com_api_sttl_day_pkg.get_sysdate()
      , i_entity_type   => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
      , i_object_id     => i_id
      , i_inst_id       => l_inst_id
      , i_split_hash    => l_split_hash
      , i_param_tab     => l_param_tab
    );
end;

procedure remove_customer (
    i_id        in      com_api_type_pkg.t_medium_id
  , i_seqnum    in      com_api_type_pkg.t_seqnum
) is
    l_count             com_api_type_pkg.t_tiny_id;
    l_inst_id           com_api_type_pkg.t_inst_id;
begin
    select count(*)
      into l_count
      from prd_contract_vw
     where customer_id = i_id;

    if l_count > 0 then
        com_api_error_pkg.raise_error (
            i_error       => 'CUSTOMER_IS_ALREADY_USED'
          , i_env_param1  => i_id
        );
    end if;

    select inst_id
      into l_inst_id
      from prd_customer_vw
     where id = i_id;
    
    ost_api_institution_pkg.check_status(
        i_inst_id     => l_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    );

    update prd_customer_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete from prd_customer_vw
    where id      = i_id;
end;

procedure set_customer_status (
    i_id                   in     com_api_type_pkg.t_medium_id
  , i_status               in     com_api_type_pkg.t_dict_value
) is
    l_inst_id     com_api_type_pkg.t_inst_id;
    l_split_hash  com_api_type_pkg.t_tiny_id;
    l_param_tab   com_api_type_pkg.t_param_tab;
begin

    select inst_id
         , split_hash
      into l_inst_id
         , l_split_hash
      from prd_customer_vw
     where id     = i_id;

    ost_api_institution_pkg.check_status(
        i_inst_id     => l_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    );

    update prd_customer_vw
       set status = nvl(i_status, status)
     where id     = i_id;

    evt_api_event_pkg.register_event(
        i_event_type    => prd_api_const_pkg.EVENT_CUSTOMER_MODIFY
      , i_eff_date      => get_sysdate
      , i_entity_type   => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
      , i_object_id     => i_id
      , i_inst_id       => l_inst_id
      , i_split_hash    => l_split_hash
      , i_param_tab     => l_param_tab
    );
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'CUSTOMER_NOT_FOUND'
          , i_env_param1 => i_id
        );
end;

procedure set_main_contract (
    i_id           in       com_api_type_pkg.t_medium_id
  , i_seqnum       in       com_api_type_pkg.t_seqnum
  , i_contract_id  in       com_api_type_pkg.t_medium_id
) is
    l_inst_id     com_api_type_pkg.t_inst_id;
    l_split_hash  com_api_type_pkg.t_tiny_id;
    l_param_tab   com_api_type_pkg.t_param_tab;
begin
    select inst_id
         , split_hash
      into l_inst_id
         , l_split_hash
      from prd_customer_vw
     where id     = i_id;

    ost_api_institution_pkg.check_status(
        i_inst_id     => l_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    );

    update prd_customer_vw
       set seqnum      = i_seqnum
         , contract_id = i_contract_id
     where id          = i_id;

    evt_api_event_pkg.register_event(
        i_event_type    => prd_api_const_pkg.EVENT_CUSTOMER_MODIFY
      , i_eff_date      => get_sysdate
      , i_entity_type   => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
      , i_object_id     => i_id
      , i_inst_id       => l_inst_id
      , i_split_hash    => l_split_hash
      , i_param_tab     => l_param_tab
    );
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'CUSTOMER_NOT_FOUND'
          , i_env_param1 => i_id
        );
end;

procedure get_customer_object (
    i_customer_id         in     com_api_type_pkg.t_medium_id
  , o_object_id              out com_api_type_pkg.t_long_id
  , o_entity_type            out com_api_type_pkg.t_dict_value
  , i_mask_error          in     com_api_type_pkg.t_boolean
) is
begin
    select a.object_id
         , a.entity_type
      into o_object_id
         , o_entity_type
      from prd_customer_vw a
     where a.id = i_customer_id;

exception
    when no_data_found then
        if i_mask_error = com_api_const_pkg.TRUE then
            trc_log_pkg.debug (
                i_text       => 'CUSTOMER_NOT_FOUND'
              , i_env_param1 => i_customer_id
            );
        else
            com_api_error_pkg.raise_error(
                i_error      => 'CUSTOMER_NOT_FOUND'
              , i_env_param1 => i_customer_id
            );
        end if;
end get_customer_object;

procedure find_customer (
    i_client_id_type   in      com_api_type_pkg.t_dict_value
  , i_client_id_value  in      com_api_type_pkg.t_full_desc
  , i_inst_id          in      com_api_type_pkg.t_inst_id
  , i_raise_error      in      com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_error_value      in      com_api_type_pkg.t_medium_id  default null
  , o_customer_id         out  com_api_type_pkg.t_medium_id
  , o_split_hash          out  com_api_type_pkg.t_tiny_id
  , o_inst_id             out  com_api_type_pkg.t_inst_id
  , o_iss_network_id      out  com_api_type_pkg.t_network_id
) is
    l_cmn_method        com_api_type_pkg.t_dict_value;
    l_sandbox           com_api_type_pkg.t_inst_id;
    l_sysdate           date;
begin
    l_sysdate   := com_api_sttl_day_pkg.get_sysdate;
    l_sandbox   := ost_api_institution_pkg.get_sandbox(i_inst_id);
    if i_client_id_type = aup_api_const_pkg.CLIENT_ID_TYPE_CUSTOMER then
        select cu.id
             , cu.split_hash
             , cu.inst_id
             , i.network_id
          into o_customer_id
             , o_split_hash
             , o_inst_id
             , o_iss_network_id
          from prd_customer cu
             , ost_institution i
         where cu.customer_number = upper(i_client_id_value)
           and ost_api_institution_pkg.get_sandbox(cu.inst_id) = l_sandbox
           and cu.inst_id         = i.id;

    elsif i_client_id_type = aup_api_const_pkg.CLIENT_ID_TYPE_CONTRACT then
        select cu.id
             , cu.split_hash
             , cu.inst_id
             , i.network_id
          into o_customer_id
             , o_split_hash
             , o_inst_id
             , o_iss_network_id
          from prd_contract c
             , prd_customer cu
             , ost_institution i
         where c.contract_number = upper(i_client_id_value)
           and cu.id             = c.customer_id
           and ost_api_institution_pkg.get_sandbox(cu.inst_id) = l_sandbox
           and i.id              = cu.inst_id;

    elsif i_client_id_type in (
        aup_api_const_pkg.CLIENT_ID_TYPE_EMAIL
        , aup_api_const_pkg.CLIENT_ID_TYPE_MOBILE
    ) or substr(i_client_id_type, 1, 4) = com_api_const_pkg.COMMUNICATION_METHOD_KEY then

        if i_client_id_type = aup_api_const_pkg.CLIENT_ID_TYPE_EMAIL then
            l_cmn_method := com_api_const_pkg.COMMUNICATION_METHOD_EMAIL;

        elsif i_client_id_type = aup_api_const_pkg.CLIENT_ID_TYPE_MOBILE then
            l_cmn_method := com_api_const_pkg.COMMUNICATION_METHOD_MOBILE;

        else
            l_cmn_method := i_client_id_type;
        end if;

        select cu.id
             , cu.split_hash
             , cu.inst_id
             , i.network_id
          into o_customer_id
             , o_split_hash
             , o_inst_id
             , o_iss_network_id
          from com_contact_object co
             , com_contact_data cd
             , prd_customer cu
             , ost_institution i
         where cd.commun_method  = l_cmn_method
           and cd.commun_address = i_client_id_value
           and ost_api_institution_pkg.get_sandbox(cu.inst_id) = l_sandbox
           and co.contact_id     = cd.contact_id
           and co.entity_type    = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
           and co.object_id      = cu.id
           and cu.inst_id        = i.id
           and (cd.end_date is null or cd.end_date > l_sysdate);

    elsif i_client_id_type = pmo_api_const_pkg.CLIENT_ID_TYPE_SRVP_NUMBER then
        select cu.id
             , cu.split_hash
             , cu.inst_id
             , i.network_id
          into o_customer_id
             , o_split_hash
             , o_inst_id
             , o_iss_network_id
          from prd_customer cu
             , pmo_provider p
             , ost_institution i
         where cu.ext_entity_type = pmo_api_const_pkg.ENTITY_TYPE_SERVICE_PROVIDER
           and cu.ext_object_id   = p.id
           and p.provider_number  = i_client_id_value
           and cu.inst_id         = i.id
           and ost_api_institution_pkg.get_sandbox(cu.inst_id) = l_sandbox;

    end if;
exception
    when no_data_found then
        if i_raise_error = com_api_const_pkg.TRUE then
            com_api_error_pkg.raise_error(
                i_error      => 'CLIENT_NOT_FOUND'
              , i_env_param1 => i_client_id_type
              , i_env_param2 => i_client_id_value
            );
        else
            o_customer_id    := i_error_value;
            o_split_hash     := null;
            o_inst_id        := null;
            o_iss_network_id := null;
         end if;
    when too_many_rows then
        if i_raise_error = com_api_const_pkg.TRUE then
            com_api_error_pkg.raise_error(
                i_error      => 'TOO_MANY_CLIENTS'
              , i_env_param1 => i_client_id_type
              , i_env_param2 => i_client_id_value
            );
        else
            o_customer_id    := i_error_value;
            o_split_hash     := null;
            o_inst_id        := null;
            o_iss_network_id := null;
         end if;
    when others then
        if i_raise_error = com_api_const_pkg.TRUE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
              , i_env_param2 => i_client_id_type
              , i_env_param3 => i_client_id_value
            );
        else
            o_customer_id    := i_error_value;
            o_split_hash     := null;
            o_inst_id        := null;
            o_iss_network_id := null;
         end if;
end;

procedure get_customer_data (
    i_customer_id        in      com_api_type_pkg.t_medium_id
  , i_lang               in      com_api_type_pkg.t_dict_value
  , o_category              out  com_api_type_pkg.t_dict_value
  , o_person_first_name     out  com_api_type_pkg.t_name
  , o_person_second_name    out  com_api_type_pkg.t_name
  , o_person_surname        out  com_api_type_pkg.t_name
  , o_person_gender         out  com_api_type_pkg.t_dict_value
  , o_customer_number       out  com_api_type_pkg.t_name
) is
begin
    for rec in (
        select c.category
             , c.entity_type
             , c.object_id
             , c.customer_number
             , c.contract_id
             , c.split_hash
             , case c.entity_type
               when com_api_const_pkg.ENTITY_TYPE_PERSON then p.first_name
               else null
               end person_name
             , case c.entity_type
               when com_api_const_pkg.ENTITY_TYPE_PERSON then p.surname
               else null
               end person_surname
             , case c.entity_type
               when com_api_const_pkg.ENTITY_TYPE_PERSON then p.second_name
               else null
               end person_patronymic
             ,case c.entity_type
               when com_api_const_pkg.ENTITY_TYPE_PERSON then p.gender
               else null
               end person_gender
          from prd_customer c
             , com_person p
             , com_contact_object co
             , com_contact ct
         where c.id               = i_customer_id
           and c.object_id        = p.id(+)
           and co.contact_type(+) = com_api_const_pkg.CONTACT_TYPE_PRIMARY
           and co.entity_type(+)  = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
           and co.object_id(+)    = c.id
           and co.contact_id      = ct.id(+)
         order by decode (p.lang
                        , i_lang, 1
                        , ct.preferred_lang, 2
                        , com_api_const_pkg.DEFAULT_LANGUAGE, 3
                        , 9999
                  )
    ) loop
        o_category           := rec.category;
        o_person_first_name  := rec.person_name;
        o_person_second_name := rec.person_patronymic;
        o_person_surname     := rec.person_surname;
        o_person_gender      := rec.person_gender;
        o_customer_number    := rec.customer_number;
        exit;
    end loop;
end;

procedure load_customer_data (
    i_customer_id    in            com_api_type_pkg.t_medium_id
  , i_lang           in            com_api_type_pkg.t_dict_value
  , io_params        in out nocopy com_api_type_pkg.t_param_tab
) is
    l_category              com_api_type_pkg.t_dict_value;
    l_first_name            com_api_type_pkg.t_name;
    l_second_name           com_api_type_pkg.t_name;
    l_surname               com_api_type_pkg.t_name;
    l_customer_number       com_api_type_pkg.t_name;
    l_person_gender         com_api_type_pkg.t_dict_value;
begin
    get_customer_data (
        i_customer_id         => i_customer_id
      , i_lang                => i_lang
      , o_category            => l_category
      , o_person_first_name   => l_first_name
      , o_person_second_name  => l_second_name
      , o_person_surname      => l_surname
      , o_person_gender       => l_person_gender
      , o_customer_number     => l_customer_number
    );

    rul_api_param_pkg.set_param (
        i_name     => 'CUSTOMER_CATEGORY'
      , i_value    => l_category
      , io_params  => io_params
    );

    rul_api_param_pkg.set_param (
        i_name     => 'PERSON_NAME'
      , i_value    => l_first_name
      , io_params  => io_params
    );

    rul_api_param_pkg.set_param (
        i_name     => 'PERSON_SURNAME'
      , i_value    => l_second_name
      , io_params  => io_params
    );

    rul_api_param_pkg.set_param (
        i_name     => 'PERSON_PATRONYMIC'
      , i_value    => l_surname
      , io_params  => io_params
    );

    rul_api_param_pkg.set_param (
        i_name     => 'PERSON_GENDER'
      , i_value    => l_person_gender
      , io_params  => io_params
    );

    rul_api_param_pkg.set_param (
        i_name     => 'CUSTOMER_NUMBER'
      , i_value    => l_customer_number
      , io_params  => io_params
    );
end;

function get_customer_number(
    i_customer_id         in     com_api_type_pkg.t_medium_id
  , i_inst_id             in     com_api_type_pkg.t_inst_id    default null
  , i_mask_error          in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
) return  com_api_type_pkg.t_name
is
    l_customer_number     com_api_type_pkg.t_name;
begin
    begin
        select c.customer_number
          into l_customer_number
          from prd_customer c
         where c.id = i_customer_id
           and (i_inst_id is null or c.inst_id = i_inst_id);
    exception
        when no_data_found then
            if nvl(i_mask_error, com_api_const_pkg.TRUE) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error      => 'CUSTOMER_NOT_FOUND'
                  , i_env_param1 => i_customer_id
                  , i_env_param2 => i_inst_id
                );
            end if;
    end;

    return l_customer_number;
end;

function get_customer_id(
    i_customer_number       in     com_api_type_pkg.t_name
  , i_inst_id               in     com_api_type_pkg.t_inst_id    default null
  , i_mask_error            in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
) return  com_api_type_pkg.t_medium_id
is
    l_customer_id           com_api_type_pkg.t_medium_id;
begin
    begin
        begin
            select c.id
              into l_customer_id
              from prd_customer c
             where reverse(c.customer_number) = reverse(upper(i_customer_number))
               and (i_inst_id is null or c.inst_id = i_inst_id);
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error       => 'CUSTOMER_NOT_FOUND'
                  , i_env_param1  => i_customer_number
                  , i_env_param2  => i_inst_id
                  , i_mask_error  => i_mask_error
                );
            when too_many_rows then
                -- It is impossible to locate customer because <i_inst_id> is NULL and <i_customer_number> is not unique 
                com_api_error_pkg.raise_error(
                    i_error       => 'NOT_ENOUGH_DATA_TO_FIND_CUSTOMER'
                  , i_mask_error  => i_mask_error
                );
        end;
    exception
        when com_api_error_pkg.e_application_error then
            if nvl(i_mask_error, com_api_const_pkg.TRUE) = com_api_const_pkg.FALSE then
                raise;
            end if;
    end;

    return l_customer_id;
end;

function get_customer_id(
    i_ext_entity_type       in     com_api_type_pkg.t_dict_value
  , i_ext_object_id         in     com_api_type_pkg.t_long_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_medium_id
is
    l_customer_id         com_api_type_pkg.t_medium_id;
begin
    begin
        select a.id
          into l_customer_id
          from prd_customer a
         where a.ext_entity_type = i_ext_entity_type
           and a.ext_object_id   = i_ext_object_id
           and a.inst_id         = nvl(i_inst_id, a.inst_id)
           and rownum = 1;
    exception
        when no_data_found then
            null;
    end;

    return l_customer_id;
end get_customer_id;

function get_customer_id(
    i_entity_type           in     com_api_type_pkg.t_dict_value
  , i_object_id             in     com_api_type_pkg.t_long_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id    default null
  , i_mask_error            in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_medium_id
is
    l_customer_id           com_api_type_pkg.t_medium_id;
    l_contract_id           com_api_type_pkg.t_medium_id;
    l_inst_id               com_api_type_pkg.t_inst_id;
begin
    l_inst_id  := coalesce(
                      i_inst_id
                    , ost_api_institution_pkg.get_object_inst_id(
                          i_entity_type => i_entity_type
                        , i_object_id   => i_object_id
                        , i_mask_errors => com_api_const_pkg.TRUE
                      )
                  );
    
    case i_entity_type
        when acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
            
            select b.customer_id
              into l_customer_id
              from acq_merchant a
                 , prd_contract b
             where a.id          = i_object_id
               and a.contract_id = b.id
               and a.split_hash  = b.split_hash
               and b.inst_id     = nvl(l_inst_id, b.inst_id);
               
        when acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
            
            select b.customer_id
              into l_customer_id
              from acq_terminal a
                 , prd_contract b
             where a.id              = i_object_id
                   and a.contract_id = b.id
                   and a.split_hash  = b.split_hash
                   and b.inst_id     = nvl(l_inst_id, b.inst_id);
               
        when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
            
            select b.customer_id
              into l_customer_id
              from acc_account a
                 , prd_contract b
             where a.id          = i_object_id
               and a.contract_id = b.id
               and a.split_hash  = b.split_hash
               and b.inst_id     = nvl(l_inst_id, b.inst_id);
               
        when iss_api_const_pkg.ENTITY_TYPE_CARD then
            
            select b.customer_id
              into l_customer_id
              from iss_card a
                 , prd_contract b
             where a.id          = i_object_id
               and a.contract_id = b.id
               and a.split_hash  = b.split_hash
               and b.inst_id     = nvl(l_inst_id, b.inst_id);
               
        when iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
        
            select c.customer_id
              into l_customer_id
              from iss_card a
                 , iss_card_instance b
                 , prd_contract c
             where b.id          = i_object_id
               and a.id          = b.card_id
               and a.contract_id = c.id
               and a.split_hash  = b.split_hash
               and c.inst_id     = nvl(l_inst_id, c.inst_id);
               
        when iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER then

            select distinct 
                   a.customer_id, a.contract_id
              into l_customer_id, l_contract_id
              from iss_card a
             where a.cardholder_id = i_object_id
               and a.inst_id       = nvl(l_inst_id, a.inst_id);
           
        when iss_api_const_pkg.ENTITY_TYPE_CUSTOMER then
            
            select a.id
              into l_customer_id
              from prd_customer a
             where a.id          = i_object_id
               and a.inst_id     = nvl(l_inst_id, a.inst_id);
           
        when prd_api_const_pkg.ENTITY_TYPE_CONTRACT then
            
            select a.customer_id
              into l_customer_id
              from prd_contract a
             where a.id          = i_object_id
               and a.inst_id     = nvl(l_inst_id, a.inst_id);

        else
            com_api_error_pkg.raise_error(
                i_error      => 'INVALID_SEARCH_ENTITY'
              , i_env_param1 => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
              , i_env_param2 => i_entity_type
              , i_env_param3 => i_object_id
              , i_env_param4 => i_inst_id
            );
    end case;

    return l_customer_id;

exception
    when no_data_found or too_many_rows then
        if i_mask_error = com_api_const_pkg.TRUE then
            return null;
        else
            com_api_error_pkg.raise_error(
                i_error      => 'INVALID_SEARCH_ENTITY'
              , i_env_param1 => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
              , i_env_param2 => i_entity_type
              , i_env_param3 => i_object_id
              , i_env_param4 => i_inst_id
            );
        end if;

    when others then
        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then
            if i_mask_error = com_api_const_pkg.TRUE then
                return null;
            else
                raise;
            end if;
        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end get_customer_id;

procedure find_customer(
    i_acq_inst_id           in     com_api_type_pkg.t_inst_id
  , i_host_id               in     com_api_type_pkg.t_tiny_id
  , o_customer_id              out com_api_type_pkg.t_medium_id
) is
begin
    select b.id
      into o_customer_id
      from net_member   a
         , prd_customer b
     where a.id              = i_host_id
       and b.inst_id         = i_acq_inst_id
       and b.ext_entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
       and b.ext_object_id   = a.inst_id;

exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error => 'CUSTOMER_NOT_FOUND'
        );
end find_customer;

procedure find_customer(
    i_acq_inst_id           in      com_api_type_pkg.t_inst_id
  , i_payment_order_id      in      com_api_type_pkg.t_tiny_id
  , o_customer_id              out  com_api_type_pkg.t_medium_id
) is
begin
    select b.id
      into o_customer_id
      from prd_customer b
         , pmo_purpose  p
         , pmo_order    o
     where o.id              = i_payment_order_id
       and p.id              = o.purpose_id
       and b.inst_id         = i_acq_inst_id
       and b.ext_entity_type = pmo_api_const_pkg.ENTITY_TYPE_SERVICE_PROVIDER
       and b.ext_object_id   = p.provider_id;

exception
    when no_data_found then
        null;
--        com_api_error_pkg.raise_error(
--            i_error => 'CUSTOMER_NOT_FOUND'
--        );
end;

procedure find_customer(
    i_purpose_id                    com_api_type_pkg.t_long_id
  , o_customer_id              out  com_api_type_pkg.t_medium_id
  , o_split_hash               out  com_api_type_pkg.t_tiny_id
  , o_inst_id                  out  com_api_type_pkg.t_inst_id
  , o_iss_network_id           out  com_api_type_pkg.t_network_id
) is
begin
    select c.id
         , c.split_hash
         , c.inst_id
         , i.network_id
      into o_customer_id
         , o_split_hash
         , o_inst_id
         , o_iss_network_id
      from prd_customer    c
         , pmo_purpose     p
         , ost_institution i
     where p.id              = i_purpose_id
       and c.ext_entity_type = pmo_api_const_pkg.ENTITY_TYPE_SERVICE_PROVIDER
       and c.ext_object_id   = p.provider_id
       and i.id              = c.inst_id;

exception
    when no_data_found then
        null;
--        com_api_error_pkg.raise_error(
--            i_error => 'CUSTOMER_NOT_FOUND'
--        );
end;

/*
 * It closes customer (marks it as incative) and all its entities and services.
 */
procedure close_customer(
    i_customer_id           in     com_api_type_pkg.t_medium_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_end_date              in     date
  , i_params                in     com_api_type_pkg.t_param_tab
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.close_customer: ';
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_customer_id [#1], i_inst_id [#2], i_end_date [#3]'
      , i_env_param1 => i_customer_id
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_end_date
    );

    ost_api_institution_pkg.check_status(
        i_inst_id     => i_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    ); 

    -- Close all customer's contracts with all their linked entities and services
    for c in (
        select c.id
          from prd_contract c
         where c.customer_id = i_customer_id
           and c.inst_id     = i_inst_id
    ) loop
        prd_api_contract_pkg.close_contract(
            i_contract_id => c.id
          , i_inst_id     => i_inst_id
          , i_end_date    => coalesce(i_end_date, com_api_sttl_day_pkg.get_sysdate())
          , i_params      => i_params
        );
    end loop;

    prd_api_service_pkg.close_service(
        i_entity_type => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
      , i_object_id   => i_customer_id
      , i_inst_id     => i_inst_id
      , i_params      => i_params
    );

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'set new status of customer [#1]'
      , i_env_param1  => prd_api_const_pkg.CUSTOMER_STATUS_INACTIVE
    );
    set_customer_status(
        i_id          => i_customer_id
      , i_status      => prd_api_const_pkg.CUSTOMER_STATUS_INACTIVE
    );

    trc_log_pkg.debug(LOG_PREFIX || 'DONE');
end close_customer;

/*
 * It rises an error if customer is already associated with another entity object (agent/institution) or vice versa.
 */
procedure check_association(
    i_customer_id           in     com_api_type_pkg.t_medium_id
  , i_ext_entity_type       in     com_api_type_pkg.t_dict_value
  , i_ext_object_id         in     com_api_type_pkg.t_long_id
) is
    l_customer_id           com_api_type_pkg.t_medium_id;
begin
    trc_log_pkg.debug(
        i_text => lower($$PLSQL_UNIT) || '.check_association: i_customer_id [' || i_customer_id 
                                      || '], i_ext_entity_type [' || i_ext_entity_type
                                      || '], i_ext_object_id [' || i_ext_object_id || ']'
    );
    if i_ext_object_id is not null then
        -- No one customer should be associated with entity object <i_ext_object_id>
        l_customer_id := get_customer_id(
                             i_ext_entity_type => i_ext_entity_type
                           , i_ext_object_id   => i_ext_object_id
                           , i_inst_id         => null
                         );
        if i_customer_id is null and l_customer_id is not null -- adding new customer
           or
           nvl(l_customer_id, i_customer_id) != i_customer_id  -- modifying customer
        then
            com_api_error_pkg.raise_error(
                i_error      => 'ENTITY_IS_ALREADY_ASSOCIATED_WITH_CUSTOMER'
              , i_env_param1 => i_ext_entity_type
              , i_env_param2 => i_ext_object_id
              , i_env_param3 => l_customer_id
            );
        end if;

        -- No one entity object should be associated with customer <i_customer_id>,
        -- so we prevent automatically reassociation by modifying a customer
        declare
            l_ext_entity_type       com_api_type_pkg.t_dict_value;
            l_ext_object_id         com_api_type_pkg.t_long_id;
        begin
            select c.ext_entity_type
                 , c.ext_object_id
              into l_ext_entity_type
                 , l_ext_object_id
              from prd_customer c
             where c.id = i_customer_id;
            
            if l_ext_object_id is not null then
                com_api_error_pkg.raise_error(
                    i_error      => 'ENTITY_IS_ALREADY_ASSOCIATED_WITH_CUSTOMER'
                  , i_env_param1 => l_ext_entity_type
                  , i_env_param2 => l_ext_object_id
                  , i_env_param3 => i_customer_id
                );
            end if;
        exception
            when no_data_found then
                null;
        end;
    end if;
end check_association;

function get_customer_aging(
    i_customer_id           in     com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_tiny_id
is
    l_active_credit_accounts_count com_api_type_pkg.t_count    := 0;
    l_return                       com_api_type_pkg.t_tiny_id;
begin
    select count(1) 
      into l_active_credit_accounts_count
      from acc_account a
         , prd_service_object o
         , prd_service s
     where a.customer_id     = i_customer_id
       and a.status         != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED
       and o.object_id       = a.id
       and o.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
       and o.split_hash      = a.split_hash
       and o.status          = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE
       and o.service_id      = s.id
       and s.service_type_id = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID;

    if l_active_credit_accounts_count > 0 then
        select nvl(max(aging_period), 0)
          into l_return
          from(
                select i.account_id
                     , max(aging_period) keep (dense_rank last order by invoice_date) as aging_period
                  from acc_account a
                     , crd_invoice i
                 where a.customer_id = i_customer_id
                   and a.status != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED
                   and i.account_id = a.id
                   and a.split_hash = i.split_hash
                 group by account_id
          );
    end if;

    return l_return;

end get_customer_aging;


function get_customer_data(
    i_customer_id         in      com_api_type_pkg.t_medium_id
  , i_inst_id             in      com_api_type_pkg.t_inst_id     default null
  , i_mask_error          in      com_api_type_pkg.t_boolean     default com_api_const_pkg.TRUE
) return prd_api_type_pkg.t_customer
is
    l_customer_rec                prd_api_type_pkg.t_customer;
begin
    select c.id
         , c.category
         , c.relation
         , c.resident
         , c.nationality
         , c.credit_rating
         , c.employment_status
         , c.employment_period
         , c.residence_type
         , c.marital_status_date
         , c.income_range
         , c.number_of_children
         , c.marital_status
      into l_customer_rec.id
         , l_customer_rec.category
         , l_customer_rec.relation
         , l_customer_rec.resident
         , l_customer_rec.nationality
         , l_customer_rec.credit_rating
         , l_customer_rec.employment_status
         , l_customer_rec.employment_period
         , l_customer_rec.residence_type
         , l_customer_rec.marital_status_date
         , l_customer_rec.income_range
         , l_customer_rec.number_of_children
         , l_customer_rec.marital_status
      from prd_customer c
     where c.id           = i_customer_id
       and (i_inst_id is null or c.inst_id = i_inst_id);

    return l_customer_rec;
exception
    when no_data_found
      or com_api_error_pkg.e_application_error
    then
        if nvl(i_mask_error, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE then
            return l_customer_rec;
        else
            com_api_error_pkg.raise_error(
                i_error      => 'CUSTOMER_NOT_FOUND'
              , i_env_param1 => i_customer_id
              , i_env_param2 => i_inst_id
            );
        end if;
    when com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );

end get_customer_data;


end;
/
