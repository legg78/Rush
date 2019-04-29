create or replace package body acc_ui_balance_type_pkg as
/*******************************************************************
*  Account balance type UI  <br />
*  Created by Khougaev A.(khougaev@bpcsv.com)  at 06.11.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: ACC_UI_BALANCE_TYPE_PKG <br />
*  @headcom
********************************************************************/
procedure add(
    o_id                     out com_api_type_pkg.t_tiny_id
  , o_seqnum                 out com_api_type_pkg.t_seqnum
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_account_type        in     com_api_type_pkg.t_dict_value
  , i_balance_type        in     com_api_type_pkg.t_dict_value
  , i_currency            in     com_api_type_pkg.t_curr_code
  , i_rate_type           in     com_api_type_pkg.t_dict_value
  , i_aval_impact         in     com_api_type_pkg.t_boolean
  , i_status              in     com_api_type_pkg.t_dict_value
  , i_number_format_id    in     com_api_type_pkg.t_tiny_id
  , i_number_prefix       in     com_api_type_pkg.t_name
  , i_update_macros_type  in     com_api_type_pkg.t_tiny_id
  , i_balance_algorithm   in     com_api_type_pkg.t_dict_value default null
) is
    l_date     date  := null;
begin
    begin
        o_id := acc_balance_type_seq.nextval;
        o_seqnum := 1;
        
        if i_status = acc_api_const_pkg.BALANCE_STATUS_ACTIVE then
            l_date := get_sysdate;
        end if;

        insert into acc_balance_type_vw (
            id
            , seqnum
            , account_type
            , balance_type
            , inst_id
            , currency
            , rate_type
            , aval_impact
            , status
            , number_format_id
            , number_prefix
            , update_macros_type
            , balance_algorithm            
        ) values (
              o_id
            , o_seqnum
            , i_account_type
            , i_balance_type
            , i_inst_id
            , i_currency
            , i_rate_type
            , i_aval_impact
            , i_status
            , i_number_format_id
            , i_number_prefix
            , i_update_macros_type
            , i_balance_algorithm
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error             => 'BALANCE_TYPE_ALREADY_EXISTS'
                , i_env_param1      => i_inst_id
                , i_env_param2      => i_account_type
                , i_env_param3      => i_balance_type
            );
    end;

    insert into acc_balance_vw (
        id
        , split_hash
        , account_id
        , balance_type
        , balance
        , rounding_balance
        , currency
        , entry_count
        , status
        , inst_id
        , open_date
    ) select
        acc_balance_seq.nextval
        , a.split_hash
        , a.id
        , i_balance_type
        , 0
        , 0
        , nvl(i_currency, a.currency)
        , 0
        , i_status
        , a.inst_id
        , l_date
    from
        acc_account a
    where
        a.inst_id = i_inst_id
        and a.account_type = i_account_type;
        
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error (
            i_error             => 'BAL_TYPE_OF_ACC_TYPE_ALREADY_EXISTS'
            , i_env_param1      => i_balance_type
            , i_env_param2      => i_account_type
        );            
end;

procedure modify (
    i_id                  in     com_api_type_pkg.t_tiny_id
  , io_seqnum             in out com_api_type_pkg.t_seqnum
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_account_type        in     com_api_type_pkg.t_dict_value
  , i_balance_type        in     com_api_type_pkg.t_dict_value
  , i_currency            in     com_api_type_pkg.t_curr_code
  , i_rate_type           in     com_api_type_pkg.t_dict_value
  , i_aval_impact         in     com_api_type_pkg.t_boolean
  , i_status              in     com_api_type_pkg.t_dict_value
  , i_number_format_id    in     com_api_type_pkg.t_tiny_id
  , i_number_prefix       in     com_api_type_pkg.t_name
  , i_update_macros_type  in     com_api_type_pkg.t_tiny_id
  , i_balance_algorithm   in     com_api_type_pkg.t_dict_value default null
) is
begin
    for c1 in (select a.account_type
                    , a.balance_type
                    , a.currency 
               from acc_balance_type_vw a
               where a.id = i_id)
    loop
        -- check account type
        for c2 in (select b.id from acc_account_vw b
                   where b.account_type = i_account_type)
        loop
            if i_account_type != c1.account_type
               or i_balance_type != c1.balance_type
               or i_currency != c1.currency
            then
                com_api_error_pkg.raise_error (
                    i_error           => 'BALANCE_TYPE_CANNOT_BE_MODIFIED'
                  , i_env_param1      => i_inst_id
                  , i_env_param2      => i_balance_type
                );
            end if;
        end loop;

        update acc_balance_type_vw
        set
            seqnum = io_seqnum
            , currency = i_currency
            , rate_type = i_rate_type
            , aval_impact = i_aval_impact
            , status = i_status
            , number_format_id = i_number_format_id
            , number_prefix = i_number_prefix
            , update_macros_type = i_update_macros_type
            , balance_algorithm  = i_balance_algorithm
        where
            id = i_id
            and inst_id = i_inst_id
            and account_type = i_account_type
            and balance_type = i_balance_type;

        io_seqnum := io_seqnum + 1;
    end loop;
end;

procedure remove (
    i_id                  in     com_api_type_pkg.t_tiny_id
  , i_seqnum              in     com_api_type_pkg.t_seqnum
) is
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_account_type          com_api_type_pkg.t_dict_value;
    l_balance_type          com_api_type_pkg.t_dict_value;
    l_check_cnt             number;
begin
    update
        acc_balance_type_vw
    set
        seqnum = i_seqnum
    where
        id = i_id;

    select
        t1.inst_id
        , t1.account_type
        , t1.balance_type
        , sum(decode(t2.balance_type, t1.balance_type, 0, 1)) other_count
    into
        l_inst_id
        , l_account_type
        , l_balance_type
        , l_check_cnt
    from
        acc_balance_type_vw t1
        , acc_balance_type_vw t2 
    where
        t1.id = i_id
        and t1.inst_id = t2.inst_id
        and t1.account_type = t2.account_type
    group by
        t1.inst_id
        , t1.account_type
        , t1.balance_type;

    if l_check_cnt = 0 then
        com_api_error_pkg.raise_error (
            i_error             => 'AT_LEAST_ONE_BALANCE_REQUIRED'
            , i_env_param1      => l_inst_id
            , i_env_param2      => l_account_type
            , i_env_param3      => l_balance_type
        );
    end if;

    select
        count(*)
    into
        l_check_cnt
    from
        acc_account_vw a
        , acc_balance_vw b
    where
        a.inst_id = l_inst_id
        and a.account_type = l_account_type
        and a.id = b.account_id
        and b.balance_type = l_balance_type
        and rownum < 2;

    if l_check_cnt > 0 then
        com_api_error_pkg.raise_error (
            i_error             => 'BALANCE_TYPE_ALREADY_USED'
            , i_env_param1      => l_inst_id
            , i_env_param2      => l_account_type
            , i_env_param3      => l_balance_type
        );
    end if;

    delete from
        acc_balance_type_vw
    where
        id = i_id;
end;

end;
/
