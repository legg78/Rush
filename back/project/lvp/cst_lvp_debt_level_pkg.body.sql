create or replace package body cst_lvp_debt_level_pkg as

procedure set_acc_debt_level(
    i_account_id          com_api_type_pkg.t_account_id
  , i_debt_level          com_api_type_pkg.t_dict_value
  , i_prev_debt_level     com_api_type_pkg.t_name
  , i_eff_date            date
  , i_reason_event        com_api_type_pkg.t_dict_value
  , i_force               com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
)
as
    l_prev_debt_level     com_api_type_pkg.t_name := i_prev_debt_level;
    l_level               com_api_type_pkg.t_tiny_id;
    l_prev_level          com_api_type_pkg.t_tiny_id;
    l_force               com_api_type_pkg.t_boolean  := nvl(i_force, com_api_const_pkg.FALSE);
    l_oper_id             com_api_type_pkg.t_long_id;
    l_oper_type           com_api_type_pkg.t_dict_value;
    l_posting_date        date;
begin
    l_oper_id       := opr_api_shared_data_pkg.get_operation().id;
    l_oper_type     := opr_api_shared_data_pkg.get_operation().oper_type;
    
    trc_log_pkg.debug(
        i_text => 'set_acc_debt_level'  || 
                  ';i_account_id='      || i_account_id ||
                  ';i_debt_level='      || i_debt_level ||
                  ';l_prev_debt_level=' || l_prev_debt_level ||
                  ';i_eff_date='        || to_char(i_eff_date, 'dd.mm.yyyy hh24:mi:ss') ||
                  ';i_reason_event='    || i_reason_event ||
                  ';i_force='           || l_force ||
                  ';l_oper_id='         || l_oper_id ||
                  ';l_oper_type='       || l_oper_type
    );
    
    if l_oper_id is not null and l_oper_type is not null then
        select max(p.posting_date)
          into l_posting_date
          from crd_payment p
         where p.account_id = i_account_id
           and p.oper_id = l_oper_id;
    end if;
    
    if l_prev_debt_level is null then
        l_prev_debt_level :=
            com_api_flexible_data_pkg.get_flexible_value(
                i_field_name  => cst_lvp_const_pkg.DEBT_LEVEL_FLEXIBLE_FIELD
              , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id   => i_account_id
            );
    end if;

    trc_log_pkg.debug(
        i_text => 'prev_level = ' || l_prev_debt_level
    );
    
    l_level      := substr(i_debt_level, -1);
    l_prev_level := substr(l_prev_debt_level, -1);
    
    if  (l_force = com_api_const_pkg.FALSE and l_level < l_prev_level)
     or (l_level = l_prev_level) then
        trc_log_pkg.debug(
            i_text => 'level <= prev_level; return' 
        );
        return;
    end if;
    
    if l_prev_debt_level is not null then
        update cst_lvp_acc_debt_lvl_hist h
           set h.end_date = nvl(l_posting_date, i_eff_date - com_api_const_pkg.ONE_SECOND)
         where flex_field_name = cst_lvp_const_pkg.DEBT_LEVEL_FLEXIBLE_FIELD
           and account_id      = i_account_id
           and h.start_date   <= i_eff_date
           and h.end_date is null;
    end if;
    
    insert into cst_lvp_acc_debt_lvl_hist(
        id
      , flex_field_name
      , account_id
      , debt_level
      , prev_debt_level
      , start_date
      , end_date
      , reason_event
    )
    values (
        cst_lvp_acc_debt_lvl_hist_seq.nextval
      , cst_lvp_const_pkg.DEBT_LEVEL_FLEXIBLE_FIELD
      , i_account_id
      , i_debt_level
      , l_prev_debt_level
      , i_eff_date
      , null
      , i_reason_event
    );
    
    com_api_flexible_data_pkg.set_flexible_value(
        i_field_name  => cst_lvp_const_pkg.DEBT_LEVEL_FLEXIBLE_FIELD
      , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id   => i_account_id
      , i_field_value => i_debt_level
    );
end;

procedure set_acc_debt_level(
    i_account_id          com_api_type_pkg.t_account_id
  , i_debt_level          com_api_type_pkg.t_dict_value
  , i_eff_date            date
  , i_reason_event        com_api_type_pkg.t_dict_value
  , i_force               com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) as
begin
    set_acc_debt_level(
        i_account_id          => i_account_id
      , i_debt_level          => i_debt_level
      , i_prev_debt_level     => null
      , i_eff_date            => i_eff_date
      , i_reason_event        => i_reason_event
      , i_force               => i_force
    );
end;

procedure incr_acc_debt_level(
    i_account_id          com_api_type_pkg.t_account_id
  , i_eff_date            date
  , i_reason_event        com_api_type_pkg.t_dict_value
) as
    l_debt_level          com_api_type_pkg.t_dict_value;
    l_prev_debt_level     com_api_type_pkg.t_name;
    
    l_level               com_api_type_pkg.t_tiny_id;
    l_prev_level          com_api_type_pkg.t_tiny_id;
begin
    l_prev_debt_level :=
        com_api_flexible_data_pkg.get_flexible_value(
            i_field_name  => cst_lvp_const_pkg.DEBT_LEVEL_FLEXIBLE_FIELD
          , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id   => i_account_id
        );
    
    l_prev_level := substr(l_prev_debt_level, -1);
    l_level      := least( nvl(l_prev_level, 0) + 1, 5);
    
    l_debt_level := substr(cst_lvp_const_pkg.DEBT_LEVEL_1, 1, 7) || l_level;
    
    set_acc_debt_level(
        i_account_id          => i_account_id
      , i_debt_level          => l_debt_level
      , i_prev_debt_level     => l_prev_debt_level
      , i_eff_date            => i_eff_date
      , i_reason_event        => i_reason_event
      , i_force               => com_api_const_pkg.FALSE
    );
end;

procedure decr_acc_debt_level(
    i_account_id          com_api_type_pkg.t_account_id
  , i_eff_date            date
  , i_reason_event        com_api_type_pkg.t_dict_value
) as
    l_debt_level          com_api_type_pkg.t_dict_value;
    l_prev_debt_level     com_api_type_pkg.t_name;
    
    l_level               com_api_type_pkg.t_tiny_id;
    l_prev_level          com_api_type_pkg.t_tiny_id;
begin
    l_prev_debt_level :=
        com_api_flexible_data_pkg.get_flexible_value(
            i_field_name  => cst_lvp_const_pkg.DEBT_LEVEL_FLEXIBLE_FIELD
          , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id   => i_account_id
        );
    
    if l_prev_debt_level is null then
        return;
    end if;
    
    l_prev_level := substr(l_prev_debt_level, -1);
    l_level      := greatest(l_prev_level - 1, 1);
    l_debt_level := substr(cst_lvp_const_pkg.DEBT_LEVEL_1, 1, 7) || l_level;
    
    set_acc_debt_level(
        i_account_id          => i_account_id
      , i_debt_level          => l_debt_level
      , i_prev_debt_level     => l_prev_debt_level
      , i_eff_date            => i_eff_date
      , i_reason_event        => i_reason_event
      , i_force               => com_api_const_pkg.TRUE
    );
end;

function get_additional_credit_info(
    i_account_id          com_api_type_pkg.t_account_id
)
return  com_api_type_pkg.t_lob_data as
begin
    return 'select ''' || cst_lvp_const_pkg.DEBT_LEVEL_FLEXIBLE_FIELD || ''' as system_name, '''  
                       || com_api_flexible_data_pkg.get_flexible_field_label( 
                              i_field_name   => cst_lvp_const_pkg.DEBT_LEVEL_FLEXIBLE_FIELD
                            , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          ) || ''' as name, ''' 
                       || nvl(com_api_flexible_data_pkg.get_flexible_value(
                              i_field_name  => cst_lvp_const_pkg.DEBT_LEVEL_FLEXIBLE_FIELD
                            , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                            , i_object_id   => i_account_id
                          ), 'null')|| ''' as value' 
                       || ' from dual ';
end;

function get_acc_debt_level(
    i_account_id        com_api_type_pkg.t_account_id
)
return  com_api_type_pkg.t_tiny_id as
    l_debt_level        com_api_type_pkg.t_tiny_id  default 0;
begin
    l_debt_level :=
    to_number(
        substr(
            com_api_flexible_data_pkg.get_flexible_value(
                i_field_name  => cst_lvp_const_pkg.DEBT_LEVEL_FLEXIBLE_FIELD
              , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id   => i_account_id
            )
          , -4
        )
    );
    return l_debt_level;
end;

function get_prev_debt_level(
    i_account_id        com_api_type_pkg.t_account_id
)
return  com_api_type_pkg.t_tiny_id as
    l_prev_debt_level   com_api_type_pkg.t_tiny_id  default 0;
begin    
    select to_number(substr(max(prev_debt_level) keep (dense_rank first order by id desc), -4))
      into l_prev_debt_level
      from cst_lvp_acc_debt_lvl_hist
     where account_id = i_account_id;
     
    return l_prev_debt_level;
exception
    when no_data_found then
        return null;
end;

function get_debt_level_start_date(
    i_account_id        com_api_type_pkg.t_account_id
)
return date as
    l_debt_level_start_date     date;
begin    
    select max(start_date) keep (dense_rank first order by id desc)
      into l_debt_level_start_date
      from cst_lvp_acc_debt_lvl_hist
     where account_id = i_account_id;
     
    return l_debt_level_start_date;
exception
    when no_data_found then
        return null;
end;

end;
/
