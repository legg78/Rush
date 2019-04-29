create or replace package body aup_api_scheme_pkg as
/********************************************************* 
 *  API for Authorization online schemes <br /> 
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 30.05.2011 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: aup_api_scheme_pkg <br /> 
 *  @headcom 
 **********************************************************/ 

procedure check_negative(
    i_scheme_id         in      com_api_type_pkg.t_tiny_id
  , i_auth_param        in      com_api_type_pkg.t_param_tab
  , io_resp_code        in out  com_api_type_pkg.t_dict_value
  , o_neg_exist            out  com_api_type_pkg.t_boolean
) is
    l_neg_resp_code     com_api_type_pkg.t_dict_tab;
    l_mods              com_api_type_pkg.t_number_tab;
    l_neg_index         pls_integer;
begin
    trc_log_pkg.debug('check_negative: starting with io_resp_code [' || io_resp_code || ']');

    for r in (
        select mod_id
             , resp_code
          from aup_auth_template a
             , aup_scheme_template b
         where b.scheme_id  = i_scheme_id
           and b.templ_id   = a.id
           and a.templ_type = aup_api_const_pkg.AUTH_TEMPLATE_TYPE_NEGATIVE 
    ) loop
        l_mods(l_mods.count + 1) := r.mod_id;
        l_neg_resp_code(l_neg_resp_code.count + 1) := r.resp_code;
    end loop;

    l_neg_index := 
        rul_api_mod_pkg.select_condition(
            i_mods          => l_mods
          , i_params        => i_auth_param
          , i_mask_error    => com_api_const_pkg.TRUE
        );

    o_neg_exist := 
        case 
            when l_neg_index is not null then com_api_const_pkg.TRUE
            else com_api_const_pkg.FALSE
        end;
    
    if l_neg_index is not null then    
        io_resp_code := nvl(l_neg_resp_code(l_neg_index), io_resp_code);
    end if;

    trc_log_pkg.debug(
        i_text => 'check_negative: io_resp_code [' || io_resp_code ||
                  '], l_neg_index [' || l_neg_index ||
                  '], total count of modifiers in the scheme [' || l_mods.count || ']'
    );
end check_negative;

procedure check_positive(
    i_scheme_id         in      com_api_type_pkg.t_tiny_id
  , i_auth_param        in      com_api_type_pkg.t_param_tab
  , o_pos_exist            out  com_api_type_pkg.t_boolean
) is
    l_mods              com_api_type_pkg.t_number_tab;
    l_pos_index         pls_integer;
begin
    for r in (
        select a.mod_id
          from aup_auth_template a
             , aup_scheme_template b
         where b.scheme_id  = i_scheme_id
           and b.templ_id   = a.id
           and a.templ_type = aup_api_const_pkg.AUTH_TEMPLATE_TYPE_POSITIVE 
    ) loop
        l_mods(l_mods.count+1) := r.mod_id;
    end loop;

    l_pos_index := 
        rul_api_mod_pkg.select_condition(
            i_mods          => l_mods
          , i_params        => i_auth_param
          , i_mask_error    => com_api_const_pkg.TRUE
        );

    o_pos_exist := 
        case 
            when l_pos_index is not null then com_api_const_pkg.TRUE
            else com_api_const_pkg.FALSE
        end;

    trc_log_pkg.debug(
        i_text => 'check_positive: l_pos_index [' || l_pos_index ||
                  '], total count of modifiers in the scheme [' || l_mods.count || ']'
    );
end check_positive;


procedure check_scheme(
    i_scheme_id         in      com_api_type_pkg.t_tiny_id
  , i_auth_param        in      com_api_type_pkg.t_param_tab
  , o_resp_code            out  com_api_type_pkg.t_dict_value
) is
    l_scheme_type       com_api_type_pkg.t_dict_value;
    l_resp_code         com_api_type_pkg.t_dict_value;
    l_pos_exist         com_api_type_pkg.t_boolean;
    l_neg_exist         com_api_type_pkg.t_boolean;
begin
    begin
        select scheme_type
             , resp_code
          into l_scheme_type
             , l_resp_code
          from aup_scheme
         where id = i_scheme_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'AUTHORIZATION_SCHEME_NOT_EXIST'
              , i_env_param1    => i_scheme_id
            );
    end;
    
    trc_log_pkg.debug(
        i_text       => 'Initiate checking by scheme type [#1], response code [#2]'
      , i_env_param1 => l_scheme_type
      , i_env_param2 => l_resp_code
    );

    o_resp_code := aup_api_const_pkg.RESP_CODE_OK;

    case 
-----------------------------------------------------------------------------------              
        when l_scheme_type = aup_api_const_pkg.AUTH_SCHEME_TYPE_POSITIVE then 
            check_positive(
                i_scheme_id         => i_scheme_id
              , i_auth_param        => i_auth_param
              , o_pos_exist         => l_pos_exist
            );

            if l_pos_exist = com_api_const_pkg.FALSE then
                o_resp_code := l_resp_code;
            end if;            
-----------------------------------------------------------------------------------              
        when l_scheme_type = aup_api_const_pkg.AUTH_SCHEME_TYPE_NEGATIVE then
            check_negative(
                i_scheme_id         => i_scheme_id
              , i_auth_param        => i_auth_param
              , io_resp_code        => l_resp_code
              , o_neg_exist         => l_neg_exist
            );

            if l_neg_exist = com_api_const_pkg.TRUE then
                o_resp_code := l_resp_code;
            end if;
-----------------------------------------------------------------------------------              
        when l_scheme_type = aup_api_const_pkg.AUTH_SCHEME_TYPE_POS_NEG then 
            check_positive(
                i_scheme_id         => i_scheme_id
              , i_auth_param        => i_auth_param
              , o_pos_exist         => l_pos_exist
            );

            if l_pos_exist = com_api_const_pkg.FALSE then
                o_resp_code := l_resp_code;
            else
                check_negative(
                    i_scheme_id         => i_scheme_id
                  , i_auth_param        => i_auth_param
                  , io_resp_code        => l_resp_code
                  , o_neg_exist         => l_neg_exist
                );

                if l_neg_exist = com_api_const_pkg.TRUE then
                    o_resp_code := l_resp_code;
                end if;
            end if;
            
            trc_log_pkg.debug('check_scheme: l_pos_exist [' || l_pos_exist || '], l_neg_exist [' || l_neg_exist || ']');
-----------------------------------------------------------------------------------              
        when l_scheme_type = aup_api_const_pkg.AUTH_SCHEME_TYPE_NEG_POS then
            check_negative(
                i_scheme_id         => i_scheme_id
              , i_auth_param        => i_auth_param
              , io_resp_code        => l_resp_code
              , o_neg_exist         => l_neg_exist
            );

            if l_neg_exist = com_api_const_pkg.TRUE then
                check_positive(
                    i_scheme_id         => i_scheme_id
                  , i_auth_param        => i_auth_param
                  , o_pos_exist         => l_pos_exist
                );
                
                if l_pos_exist = com_api_const_pkg.FALSE then
                    o_resp_code := l_resp_code;
                end if;            
            end if;

            trc_log_pkg.debug('check_scheme: l_neg_exist [' || l_neg_exist || '], l_pos_exist [' || l_pos_exist || ']');
-----------------------------------------------------------------------------------              
        else 
            o_resp_code := aup_api_const_pkg.RESP_CODE_OK;
    end case;
end check_scheme;

procedure check_acquiring_scheme(
    i_terminal_id       in      com_api_type_pkg.t_short_id
  , i_merchant_id       in      com_api_type_pkg.t_short_id
  , i_acq_inst_id       in      com_api_type_pkg.t_inst_id
  , i_oper_date         in      date
  , i_auth_param        in      com_api_type_pkg.t_param_tab
  , o_resp_code            out  com_api_type_pkg.t_dict_value
) is
    l_product_id        com_api_type_pkg.t_short_id;
    l_scheme_id         com_api_type_pkg.t_tiny_id;
    l_entity_type       com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text       => 'Checking by acquiring scheme for i_terminal_id [#1], '
                     || 'i_merchant_id [#2], i_acq_inst_id [#3], i_oper_date [#4]'
      , i_env_param1 => i_terminal_id
      , i_env_param2 => i_merchant_id
      , i_env_param3 => i_acq_inst_id
      , i_env_param4 => i_oper_date
    );

    l_entity_type := acq_api_const_pkg.ENTITY_TYPE_TERMINAL;
    
    select min(scheme_id) keep (dense_rank last order by start_date)
      into l_scheme_id
      from aup_scheme_object
     where entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
       and object_id   = i_terminal_id
       and i_oper_date between start_date and nvl(end_date, i_oper_date);
       
    if l_scheme_id is null then
        l_entity_type := acq_api_const_pkg.ENTITY_TYPE_MERCHANT;

        select min(scheme_id) keep (dense_rank last order by start_date)
          into l_scheme_id
          from aup_scheme_object
         where entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
           and object_id   = i_merchant_id
           and i_oper_date between start_date and nvl(end_date, i_oper_date);
    end if;

    if l_scheme_id is null then
        l_product_id := 
            prd_api_product_pkg.get_product_id(
                i_entity_type   => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
              , i_object_id     => i_merchant_id
            );
            
        l_entity_type := prd_api_const_pkg.ENTITY_TYPE_PRODUCT;

        select min(scheme_id) keep (dense_rank last order by start_date)
          into l_scheme_id
          from aup_scheme_object
         where entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
           and object_id   = l_product_id
           and i_oper_date between start_date and nvl(end_date, i_oper_date);
    end if;

    if l_scheme_id is null then
        l_entity_type := ost_api_const_pkg.ENTITY_TYPE_INSTITUTION;

        select min(scheme_id) keep (dense_rank last order by start_date)
          into l_scheme_id
          from aup_scheme_object
         where entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
           and object_id   = i_acq_inst_id
           and i_oper_date between start_date and nvl(end_date, i_oper_date);
    end if;
    
    if l_scheme_id is not null then
        trc_log_pkg.debug(
            i_text       => 'Authorization acquiring scheme [#1] is defined by entity type [#2]'
          , i_env_param1 => l_scheme_id
          , i_env_param2 => l_entity_type
        );

        check_scheme(
            i_scheme_id     => l_scheme_id
          , i_auth_param    => i_auth_param
          , o_resp_code     => o_resp_code
        );
    else
        o_resp_code := aup_api_const_pkg.RESP_CODE_OK;

--        com_api_error_pkg.raise_error(
--            i_error         => 'ACQUIRING_AUTHORIZATION_SCHEME_NOT_DEFINED'
--          , i_env_param1    => i_terminal_id
--          , i_env_param2    => i_merchant_id
--          , i_env_param3    => l_product_id
--          , i_env_param4    => i_acq_inst_id
--        );
    end if;
    
exception
    when others then
        o_resp_code := aup_api_const_pkg.RESP_CODE_ERROR;              
end check_acquiring_scheme;

procedure check_issuing_scheme(
    i_card_id           in      com_api_type_pkg.t_medium_id
  , i_oper_date         in      date
  , i_auth_param        in      com_api_type_pkg.t_param_tab
  , o_resp_code            out  com_api_type_pkg.t_dict_value
) is
    l_product_id        com_api_type_pkg.t_short_id;
    l_scheme_id         com_api_type_pkg.t_tiny_id;
    l_entity_type       com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text       => 'Checking by issuing scheme for i_card_id [#1], i_oper_date [#2]'
      , i_env_param1 => i_card_id
      , i_env_param2 => i_oper_date
    );

    l_entity_type := iss_api_const_pkg.ENTITY_TYPE_CARD;
    
    select min(scheme_id) keep (dense_rank last order by start_date)
      into l_scheme_id
      from aup_scheme_object
     where entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
       and object_id   = i_card_id
       and i_oper_date between start_date and nvl(end_date, i_oper_date);
       
    if l_scheme_id is null then
        l_product_id := 
            prd_api_product_pkg.get_product_id(
                i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id     => i_card_id
            );
            
        l_entity_type := prd_api_const_pkg.ENTITY_TYPE_PRODUCT;
        
        select min(scheme_id) keep (dense_rank last order by start_date)
          into l_scheme_id
          from aup_scheme_object
         where entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
           and object_id   = l_product_id
           and i_oper_date between start_date and nvl(end_date, i_oper_date);
    end if;

    if l_scheme_id is null then
        l_entity_type := iss_api_const_pkg.ENTITY_TYPE_ISS_BIN;
        
        select min(scheme_id) keep (dense_rank last order by start_date)
          into l_scheme_id
          from aup_scheme_object
         where entity_type = iss_api_const_pkg.ENTITY_TYPE_ISS_BIN
           and object_id in (
               select
                   bin_id
               from (
                   select
                       b.id bin_id
                       , row_number() over (order by length(b.bin) desc) rec_num
                   from
                       iss_bin b
                       , iss_card_number c
                   where
                       c.card_number like bin || '%' -- encrypted with token card number begins from BIN, decryption is not required
                       and c.card_id = i_card_id
               ) b
               where
                   b.rec_num = 1
           )
           and i_oper_date between start_date and nvl(end_date, i_oper_date);
    end if;

    if l_scheme_id is null then
        l_entity_type := ost_api_const_pkg.ENTITY_TYPE_INSTITUTION;

        select min(scheme_id) keep (dense_rank last order by start_date)
          into l_scheme_id
          from aup_scheme_object
         where entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
           and object_id in (
               select
                   iss_inst_id
               from (
                   select
                       b.inst_id iss_inst_id
                       , row_number() over (order by length(b.bin) desc) rec_num
                   from
                       iss_bin b
                       , iss_card_number c
                   where
                       c.card_number like bin || '%' -- encrypted with token card number begins from BIN, decryption is not required
                       and c.card_id = i_card_id
               ) b
               where
                   b.rec_num = 1
           )
           and i_oper_date between start_date and nvl(end_date, i_oper_date);
    end if;
    
    if l_scheme_id is not null then
        trc_log_pkg.debug(
            i_text       => 'Authorization issuing scheme [#1] is defined by entity type [#2]'
          , i_env_param1 => l_scheme_id
          , i_env_param2 => l_entity_type
        );

        check_scheme(
            i_scheme_id     => l_scheme_id
          , i_auth_param    => i_auth_param
          , o_resp_code     => o_resp_code
        );
    else
        o_resp_code := aup_api_const_pkg.RESP_CODE_OK;              

--        com_api_error_pkg.raise_error(
--            i_error         => 'ISSUING_AUTHORIZATION_SCHEME_NOT_DEFINED'
--          , i_env_param1    => i_card_id
--          , i_env_param2    => l_product_id
--          , i_env_param3    => i_bin_id
--          , i_env_param4    => i_iss_inst_id
--        );
    end if;
    
exception
    when others then
        o_resp_code := aup_api_const_pkg.RESP_CODE_ERROR;              
end check_issuing_scheme;

procedure add_scheme_card(
    i_card_uid          in      com_api_type_pkg.t_name
  , i_card_number       in      com_api_type_pkg.t_card_number
  , i_system_name       in      com_api_type_pkg.t_name
  , i_start_date        in      date                              default null
  , i_end_date          in      date                              default null
) is
    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.add_scheme_card: ';
    l_card_rec          iss_api_type_pkg.t_card_rec;
    l_card_id           com_api_type_pkg.t_medium_id;
    l_scheme_id         com_api_type_pkg.t_inst_id;
    l_scheme_object_id  com_api_type_pkg.t_long_id;
    l_seqnum            com_api_type_pkg.t_seqnum;
begin
    trc_log_pkg.debug(
        i_text  => LOG_PREFIX 
                || 'i_card_uid ['       || i_card_uid
                || '], i_card_number [' || iss_api_card_pkg.get_card_mask(i_card_number) 
                || '], i_system_name [' || i_system_name
                || '], i_start_date ['  || com_api_type_pkg.convert_to_char(i_start_date)
                || '], i_end_date ['    || com_api_type_pkg.convert_to_char(i_end_date) || ']'
    );

    if i_card_uid is null then
        l_card_id := null;
    else
        l_card_id := iss_api_card_pkg.get_card_id_by_uid(i_card_uid => i_card_uid);
    end if;

    l_card_rec := iss_api_card_pkg.get_card(
                      i_card_id     => l_card_id
                    , i_card_number => i_card_number
                    , i_mask_error  => com_api_type_pkg.FALSE
                  );

    -- Search scheme by its system name and either card's institution or default one
    begin
        select distinct first_value(id) over (order by inst_id)
          into l_scheme_id
          from aup_scheme
         where inst_id in (l_card_rec.inst_id, ost_api_const_pkg.DEFAULT_INST)
           and upper(system_name) = upper(i_system_name);
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error      => 'AUTH_SCHEME_NOT_FOUND'
              , i_env_param1 => i_system_name
              , i_env_param2 => l_card_rec.inst_id
            );
    end;

    if i_start_date is null or i_start_date > nvl(i_end_date, i_start_date) then
        com_api_error_pkg.raise_error(
            i_error      => 'END_DATE_IS_LESS_THAN_START_DATE'
          , i_env_param1 => com_api_type_pkg.convert_to_char(i_start_date)
          , i_env_param2 => com_api_type_pkg.convert_to_char(i_end_date)
        );
    end if;

    begin
        select id
          into l_scheme_object_id
          from aup_scheme_object
         where scheme_id   = l_scheme_id
           and object_id   = l_card_rec.id
           and entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
           and (end_date is null or end_date > get_sysdate);

        aup_ui_scheme_pkg.modify_scheme_object(
            i_scheme_object_id    => l_scheme_object_id
          , io_seqnum             => l_seqnum
          , i_end_date            => i_end_date
        );
    exception
        when no_data_found then
            aup_ui_scheme_pkg.add_scheme_object(
                o_scheme_object_id    => l_scheme_object_id
              , o_seqnum              => l_seqnum
              , i_scheme_id           => l_scheme_id
              , i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id           => l_card_rec.id
              , i_start_date          => i_start_date
              , i_end_date            => i_end_date
            );
    end;
end add_scheme_card;

end;
/
