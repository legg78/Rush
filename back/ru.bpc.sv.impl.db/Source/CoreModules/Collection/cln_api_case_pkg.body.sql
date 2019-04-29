create or replace package body cln_api_case_pkg is

function check_case_exists(
    i_customer_id    in      com_api_type_pkg.t_medium_id
  , i_split_hash     in      com_api_type_pkg.t_tiny_id     default null
) return com_api_type_pkg.t_boolean is
    l_case   cln_api_type_pkg.t_case_rec;
begin
    l_case := 
        get_case(
            i_customer_id => i_customer_id
          , i_split_hash  => i_split_hash
          , i_mask_error  => com_api_const_pkg.FALSE
        );
    if l_case.id is not null then
        return com_api_type_pkg.TRUE;
    else
        return com_api_type_pkg.FALSE;
    end if;

exception
    when com_api_error_pkg.e_application_error then
        if com_api_error_pkg.get_last_error in ('CLN_CASE_IS_NOT_FOUND') then
            return com_api_type_pkg.FALSE;
        end if;
end;

function get_case(
    i_id                in      com_api_type_pkg.t_long_id
) return cln_api_type_pkg.t_case_rec is
    l_case_rec                  cln_api_type_pkg.t_case_rec;
begin
    select c.id
         , c.seqnum
         , c.inst_id
         , c.split_hash
         , c.case_number
         , c.creation_date
         , c.customer_id
         , c.user_id
         , c.status
         , c.resolution
      into l_case_rec
      from cln_case c
     where c.id = i_id;

     return l_case_rec;

exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'COLLECTION_CASE_NOT_FOUND'
        );
end get_case;

function check_case_not_closed(
    i_id                in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean is
    l_case   cln_api_type_pkg.t_case_rec;
begin
    l_case := get_case(i_id  => i_id);

    if l_case.status = cln_api_const_pkg.COLLECTION_CASE_STATUS_CLOSED then
        return com_api_type_pkg.FALSE;
    else
        return com_api_type_pkg.TRUE;
    end if;

end check_case_not_closed;

function check_duplicate_case(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_case_number       in      com_api_type_pkg.t_name
) return com_api_type_pkg.t_boolean is
    l_count  com_api_type_pkg.t_boolean;
begin
    select count(*)
      into l_count
      from cln_case c
     where c.inst_id     = i_inst_id
       and c.case_number = i_case_number
       and rownum        = 1;

    return l_count;

end check_duplicate_case;

procedure add_case(
    o_id                   out  com_api_type_pkg.t_long_id
  , o_seqnum               out  com_api_type_pkg.t_tiny_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_short_id
  , i_case_number       in      com_api_type_pkg.t_name
  , i_creation_date     in      date
  , i_customer_id       in      com_api_type_pkg.t_medium_id
  , i_user_id           in      com_api_type_pkg.t_short_id
  , i_status            in      com_api_type_pkg.t_dict_value default cln_api_const_pkg.COLLECTION_CASE_STATUS_NEW
  , i_resolution        in      com_api_type_pkg.t_dict_value default null
) is
    l_sysdate                   date;
    l_creation_date             date;    
    l_case_number               com_api_type_pkg.t_name;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_status                    com_api_type_pkg.t_dict_value;

begin
    trc_log_pkg.debug(
        i_text        => 'cln_api_case_pkg.add_case Start: i_inst_id=' || i_inst_id || ', i_case_number=' || i_case_number ||
                         ', i_customer_id=' || i_customer_id || ', i_user_id=' || i_user_id || ', i_status=' || i_status ||
                         ', i_resolution=' || i_resolution
    );

    l_split_hash := 
        nvl(i_split_hash
          , com_api_hash_pkg.get_split_hash(
                i_entity_type  => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
              , i_object_id    => i_customer_id
            )
        );
    if check_case_exists(
           i_customer_id => i_customer_id
         , i_split_hash  => l_split_hash
       ) = com_api_const_pkg.TRUE 
    then
        com_api_error_pkg.raise_error(
            i_error      => 'COLL_CASE_OPENED_ON_CUSTOMER'
          , i_env_param1 => i_customer_id
        );
    end if;

    l_sysdate       := com_api_sttl_day_pkg.get_sysdate;
    o_id            := com_api_id_pkg.get_id(cln_case_seq.nextval, l_sysdate);
    o_seqnum        := 1;
    l_case_number   := i_case_number;
    l_creation_date := nvl(i_creation_date, l_sysdate);

    if l_case_number is null then
        rul_api_param_pkg.set_param(
            i_value   => o_id
          , i_name    => 'ID'
          , io_params => l_param_tab
        );

        rul_api_param_pkg.set_param(
            i_value   => i_inst_id
          , i_name    => 'INST_ID'
          , io_params => l_param_tab
        );

        rul_api_param_pkg.set_param(
            i_value   => i_customer_id
          , i_name    => 'CUSTOMER_ID'
          , io_params => l_param_tab
        );

        rul_api_shared_data_pkg.load_params(
            i_entity_type  => cln_api_const_pkg.ENTITY_TYPE_COLLECTION_CASE
          , i_object_id    => o_id
          , io_params      => l_param_tab
        );

        l_case_number := rul_api_name_pkg.get_name(
                             i_inst_id             => i_inst_id
                           , i_entity_type         => cln_api_const_pkg.ENTITY_TYPE_COLLECTION_CASE
                           , i_param_tab           => l_param_tab
                           , i_double_check_value  => null
                         );
        l_case_number := to_char(to_number(l_case_number, com_api_const_pkg.NUMBER_FORMAT));

    end if;

    if check_duplicate_case(
           i_inst_id       => i_inst_id
         , i_case_number   => l_case_number
       ) = com_api_const_pkg.TRUE then

        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_COLLECTION_CASE'
          , i_env_param1 => l_case_number
          , i_env_param2 => i_inst_id
        );
    end if;

    l_status := nvl(i_status, cln_api_const_pkg.COLLECTION_CASE_STATUS_NEW);
    insert into cln_case_vw (
        id
      , seqnum
      , inst_id
      , split_hash
      , case_number
      , creation_date
      , customer_id
      , user_id
      , status
      , resolution
    ) values (
        o_id
      , o_seqnum
      , i_inst_id
      , l_split_hash
      , l_case_number
      , l_creation_date
      , i_customer_id
      , i_user_id
      , l_status
      , i_resolution
    );

    evt_api_event_pkg.register_event(
        i_event_type      => cln_api_const_pkg.EVENT_TYPE_CASE_CREATED
      , i_eff_date        => l_creation_date
      , i_entity_type     => cln_api_const_pkg.ENTITY_TYPE_COLLECTION_CASE
      , i_object_id       => o_id
      , i_inst_id         => i_inst_id
      , i_split_hash      => l_split_hash
      , i_param_tab       => l_param_tab
    );

    trc_log_pkg.debug(
        i_text        => 'cln_api_case_pkg.add_case Finished'
      , i_env_param1  => o_id
    );

end add_case;

procedure modify_case(
    i_id                in      com_api_type_pkg.t_long_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_user_id           in      com_api_type_pkg.t_short_id
  , i_status            in      com_api_type_pkg.t_dict_value
  , i_resolution        in      com_api_type_pkg.t_dict_value
) is
begin
    trc_log_pkg.debug(
        i_text        => 'cln_api_case_pkg.modify_case Start: i_id=' || i_id || ', io_seqnum=' || io_seqnum ||
                         ', i_user_id=' || i_user_id || ', i_status=' || i_status || ', i_resolution=' || i_resolution
    );

    select seqnum
      into io_seqnum
      from cln_case 
     where id = i_id;

    io_seqnum := io_seqnum + 1;

    update cln_case_vw
       set seqnum     = io_seqnum
         , user_id    = nvl(i_user_id, user_id)
         , status     = nvl(i_status, status)
         , resolution = nvl(i_resolution, resolution)
     where id = i_id;

    trc_log_pkg.debug(
        i_text        => 'cln_api_case_pkg.modify_case Finished'
    );

end modify_case;

function get_case(
    i_customer_id  in     com_api_type_pkg.t_medium_id
  , i_split_hash   in     com_api_type_pkg.t_tiny_id   default null
  , i_mask_error   in     com_api_type_pkg.t_boolean   default com_api_const_pkg.FALSE
) return cln_api_type_pkg.t_case_rec is
    l_result              cln_api_type_pkg.t_case_rec;
    l_count               com_api_type_pkg.t_short_id;
begin
    select id
         , seqnum
         , inst_id
         , split_hash
         , case_number
         , creation_date
         , customer_id
         , user_id
         , status
         , resolution
      into l_result
      from cln_case c
     where c.customer_id = i_customer_id
       and (c.split_hash = i_split_hash or i_split_hash is null)
       and c.status != cln_api_const_pkg.COLLECTION_CASE_STATUS_CLOSED;
    
    return l_result;
exception 
    when no_data_found then
        if nvl(i_mask_error, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error        => 'CLN_CASE_IS_NOT_FOUND'
              , i_env_param1   => i_customer_id
            );
        else
           trc_log_pkg.debug(
               i_text         => 'Collection case is not found for customer [#1]' 
             , i_env_param1   => i_customer_id
           );
           return l_result;
       end if;
    when too_many_rows then           
            select count(1)
              into l_count
              from cln_case c
             where c.customer_id = i_customer_id
               and (c.split_hash = i_split_hash or i_split_hash is null)
               and c.status     != cln_api_const_pkg.COLLECTION_CASE_STATUS_CLOSED;

        if nvl(i_mask_error, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error       => 'CLN_TOO_MANY_ACTIVE_CASES'
              , i_env_param1  => l_count
              , i_env_param2  => i_customer_id 
            );
        else
           trc_log_pkg.debug(
               i_text         => 'Too many open collection cases (#2) found for customer [#1]. Customer can have the only one active collection case.'
              , i_env_param1  => l_count
              , i_env_param2  => i_customer_id 
           );
        end if;

end;

procedure change_case_status(
    i_case_id           in    com_api_type_pkg.t_long_id
  , i_status            in    com_api_type_pkg.t_dict_value
  , i_resolution        in    com_api_type_pkg.t_dict_value
  , i_activity_category in    com_api_type_pkg.t_dict_value
  , i_activity_type     in    com_api_type_pkg.t_dict_value
  , i_split_hash        in    com_api_type_pkg.t_tiny_id default null
) is
    l_old_status              com_api_type_pkg.t_dict_value;
    l_seqnum                  com_api_type_pkg.t_tiny_id;
    l_count                   com_api_type_pkg.t_tiny_id;
    l_id                      com_api_type_pkg.t_long_id;
    l_user_id                 com_api_type_pkg.t_short_id;
    l_sysdate                 date := get_sysdate();
begin
    select c.status
         , c.seqnum
         , c.user_id
      into l_old_status
         , l_seqnum
         , l_user_id
      from cln_case_vw c
     where id = i_case_id;
    
    select count(1)
      into l_count
      from cln_stage_transition st
         , cln_stage f
         , cln_stage t
     where f.id = st.stage_id 
       and t.id = st.transition_stage_id
       and f.status = l_old_status
       and t.status = i_status;
    
    if l_count = 0 then
        com_api_error_pkg.raise_error(
            i_error        => 'CLN_INVALID_STATUS_TRANSITION'
          , i_env_param1   => l_old_status
          , i_env_param2   => i_status
        );
    end if;
    
    modify_case(
        i_id         => i_case_id
      , io_seqnum    => l_seqnum
      , i_user_id    => null
      , i_status     => i_status
      , i_resolution => i_resolution
    );

    cln_api_action_pkg.add_action(
        o_id                => l_id
      , o_seqnum            => l_seqnum
      , i_case_id           => i_case_id
      , i_split_hash        => i_split_hash
      , i_activity_category => i_activity_category
      , i_activity_type     => i_activity_type
      , i_user_id           => l_user_id
      , i_action_date       => l_sysdate
      , i_eff_date          => l_sysdate
      , i_status            => i_status
      , i_resolution        => i_resolution
      , i_commentary        => null
    );
  
end;

procedure change_case_status(
    i_case_id           in    com_api_type_pkg.t_long_id
  , i_reason_code       in    com_api_type_pkg.t_dict_value
  , i_activity_category in    com_api_type_pkg.t_dict_value
  , i_activity_type     in    com_api_type_pkg.t_dict_value
  , i_split_hash        in    com_api_type_pkg.t_tiny_id default null  
) is
    l_new_status              com_api_type_pkg.t_dict_value;
    l_resolution              com_api_type_pkg.t_dict_value;
    l_seqnum                  com_api_type_pkg.t_tiny_id;
    l_id                      com_api_type_pkg.t_long_id;
    l_user_id                 com_api_type_pkg.t_short_id;
    l_sysdate                 date := get_sysdate();
begin
    begin
        select t.status
             , t.resolution
          into l_new_status
             , l_resolution
          from cln_stage_transition st
             , cln_stage t
         where t.id           = st.transition_stage_id
           and st.reason_code = i_reason_code;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error        => 'CLN_REASON_IS_NOT_FOUND'
              , i_env_param1   => i_reason_code
             );
    end;

    modify_case(
        i_id         => i_case_id
      , io_seqnum    => l_seqnum
      , i_user_id    => null
      , i_status     => l_new_status
      , i_resolution => l_resolution
    );

    cln_api_action_pkg.add_action(
        o_id                => l_id
      , o_seqnum            => l_seqnum
      , i_case_id           => i_case_id
      , i_split_hash        => i_split_hash
      , i_activity_category => i_activity_category
      , i_activity_type     => i_activity_type
      , i_user_id           => l_user_id
      , i_action_date       => l_sysdate
      , i_eff_date          => l_sysdate
      , i_status            => l_new_status
      , i_resolution        => l_resolution
      , i_commentary        => null
    );
end;

end;
/
