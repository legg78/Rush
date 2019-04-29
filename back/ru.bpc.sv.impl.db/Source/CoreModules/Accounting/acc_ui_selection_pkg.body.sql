create or replace package body acc_ui_selection_pkg is
/*********************************************************
*  UI for account selection <br />
*  Created by Khougaev A.(khougaev@bpcsv.ru)  at 20.09.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module:  ACC_UI_SELECTION_PKG <br />
*  @headcom
**********************************************************/
procedure add_selection (
    o_id                         out  com_api_type_pkg.t_tiny_id
  , o_seqnum                     out  com_api_type_pkg.t_seqnum
  , i_check_aval_balance      in      com_api_type_pkg.t_boolean
  , i_lang                    in      com_api_type_pkg.t_dict_value
  , i_description             in      com_api_type_pkg.t_full_desc
) is
begin
    o_id := acc_selection_seq.nextval;
    o_seqnum := 1;
        
    insert into acc_selection_vw (
        id
      , seqnum
      , check_aval_balance
    ) values (
        o_id
      , o_seqnum
      , i_check_aval_balance
    );

    com_api_i18n_pkg.add_text(
        i_table_name    => 'acc_selection' 
      , i_column_name   => 'description' 
      , i_object_id     => o_id
      , i_lang          => i_lang
      , i_text          => i_description
      , i_check_unique  => com_api_type_pkg.TRUE
    );
end;

procedure modify_selection (
    i_id                      in      com_api_type_pkg.t_tiny_id
  , io_seqnum                 in out  com_api_type_pkg.t_seqnum
  , i_check_aval_balance      in      com_api_type_pkg.t_boolean
  , i_lang                    in      com_api_type_pkg.t_dict_value
  , i_description             in      com_api_type_pkg.t_full_desc
) is
begin
    update acc_selection_vw
       set seqnum = io_seqnum
         , check_aval_balance = i_check_aval_balance
     where id     = i_id;
                
    io_seqnum := io_seqnum + 1;

    com_api_i18n_pkg.add_text(
        i_table_name    =>  'acc_selection' 
      , i_column_name   =>  'description' 
      , i_object_id     =>  i_id
      , i_lang          =>  i_lang
      , i_text          =>  i_description
      , i_check_unique  =>  com_api_const_pkg.TRUE
    );
end;

procedure remove_selection (
    i_id                        in com_api_type_pkg.t_tiny_id
  , i_seqnum                  in com_api_type_pkg.t_seqnum
) is
    l_check_cnt                 number;
begin
-- check use
    for rec in (
        select b.id
             , b.rule_id
          from rul_proc_param_vw a
             , rul_rule_param_value_vw b
         where a.lov_id = acc_api_const_pkg.LOV_SELECTION_ALGORITHM
           and a.id     = b.proc_param_id
           and b.param_value = to_char(i_id, com_api_const_pkg.NUMBER_FORMAT))
    loop
        trc_log_pkg.info('Selection used in rule_id = ' || to_char(rec.rule_id));

        com_api_error_pkg.raise_error (
            i_error      => 'ACC_SELECTION_ALREADY_USED'
          , i_env_param1 => i_id 
        );
    end loop;

    select count(id)
      into l_check_cnt
      from acc_selection_step_vw
     where selection_id = i_id;

    if l_check_cnt > 0 then
        com_api_error_pkg.raise_error (
            i_error       => 'ACC_SELECTION_ALREADY_USED'
          , i_env_param1  => i_id 
        );
    else
        com_api_i18n_pkg.remove_text(
            i_table_name  => 'acc_selection' 
          , i_object_id   => i_id
        );

        update acc_selection_vw
           set seqnum = i_seqnum
         where id     = i_id;

        delete from acc_selection_vw
         where id = i_id;

    end if;
end remove_selection;

procedure check_selection_step_order(
    i_selection_id              in com_api_type_pkg.t_tiny_id
  , i_exec_order                in com_api_type_pkg.t_short_id
  , i_step_id                   in com_api_type_pkg.t_short_id := null
) is
    l_count  com_api_type_pkg.t_tiny_id;
begin
    select
        count(1)
    into
        l_count
    from
        acc_selection_step_vw a
    where
        a.selection_id = i_selection_id
    and
        a.exec_order = i_exec_order
    and
        ( a.id <> i_step_id or i_step_id is null );

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_SELECTION_STEP_EXEC_ORDER'
          , i_env_param1 => i_selection_id
          , i_env_param2 => i_exec_order
        );
    end if;

end check_selection_step_order;

procedure add_selection_step (
    o_id                        out com_api_type_pkg.t_tiny_id
    , o_seqnum                  out com_api_type_pkg.t_seqnum
    , i_selection_id            in com_api_type_pkg.t_short_id
    , i_exec_order              in com_api_type_pkg.t_short_id
    , i_step                    in com_api_type_pkg.t_dict_value
) is
begin
    -- check
    check_selection_step_order(
        i_selection_id  => i_selection_id
      , i_exec_order    => i_exec_order
    );

    insert into acc_selection_step_vw (
        id
        , seqnum
        , selection_id
        , exec_order
        , step
    ) values (
        acc_selection_step_seq.nextval
        , 1
        , i_selection_id
        , i_exec_order
        , i_step
    )
    returning
        id
        , seqnum
    into
        o_id
        , o_seqnum;
end;

procedure modify_selection_step (
    i_id                        in com_api_type_pkg.t_tiny_id
    , io_seqnum                 in out com_api_type_pkg.t_seqnum
    , i_selection_id            in com_api_type_pkg.t_short_id
    , i_exec_order              in com_api_type_pkg.t_short_id
    , i_step                    in com_api_type_pkg.t_dict_value
) is
begin
    -- check
    check_selection_step_order(
        i_selection_id      => i_selection_id
      , i_exec_order        => i_exec_order
      , i_step_id           => i_id
    );

    update
        acc_selection_step_vw
    set
        seqnum = io_seqnum
        , exec_order = i_exec_order
    where
        id = i_id;

    io_seqnum := io_seqnum + 1;
end;

procedure remove_selection_step (
    i_id                        in com_api_type_pkg.t_tiny_id
    , i_seqnum                  in com_api_type_pkg.t_seqnum
) is
begin
    update
        acc_selection_step_vw
    set
        seqnum = i_seqnum
    where
        id = i_id;

    delete from
        acc_selection_step_vw
    where
        id = i_id;
end;

end; 
/
