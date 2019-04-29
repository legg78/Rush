create or replace package body com_ui_rate_type_pkg is
/************************************************************
 * UI for rate type <br />
 * Created by Khougaev A.(khougaev@bpc.ru)  at 23.04.2010  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: COM_UI_RATE_TYPE_PKG <br />
 * @headcom
 ************************************************************/
procedure add (
    o_id                     out  com_api_type_pkg.t_tiny_id
  , o_seqnum                 out  com_api_type_pkg.t_tiny_id
  , i_rate_type           in      com_api_type_pkg.t_dict_value
  , i_inst_id             in      com_api_type_pkg.t_inst_id
  , i_use_cross_rate      in      com_api_type_pkg.t_boolean
  , i_use_base_rate       in      com_api_type_pkg.t_boolean
  , i_base_currency       in      com_api_type_pkg.t_curr_code
  , i_is_reversible       in      com_api_type_pkg.t_boolean
  , i_warning_level       in      number
  , i_use_double_typing   in      com_api_type_pkg.t_boolean
  , i_use_verification    in      com_api_type_pkg.t_boolean
  , i_adjust_exponent     in      com_api_type_pkg.t_boolean
  , i_exp_period          in      com_api_type_pkg.t_tiny_id
  , i_rounding_accuracy   in      com_api_type_pkg.t_tiny_id
) is
begin
    o_id     := com_rate_type_seq.nextval;
    o_seqnum := 1;

    insert into com_rate_type_vw (
        id
      , seqnum
      , rate_type
      , inst_id
      , use_cross_rate
      , use_base_rate
      , base_currency
      , is_reversible
      , warning_level
      , use_double_typing
      , use_verification
      , adjust_exponent
      , exp_period
      , rounding_accuracy
    ) values (
        o_id
      , o_seqnum
      , i_rate_type
      , i_inst_id
      , i_use_cross_rate
      , i_use_base_rate
      , i_base_currency
      , i_is_reversible
      , i_warning_level
      , i_use_double_typing
      , i_use_verification
      , i_adjust_exponent
      , i_exp_period
      , i_rounding_accuracy
    );
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error (
            i_error       => 'RATE_OF_TYPE_ALREADY_EXISTS'
          , i_env_param1  => i_rate_type
          , i_env_param2  => i_inst_id
        );
end;

procedure modify (
    i_id                  in     com_api_type_pkg.t_tiny_id
  , io_seqnum             in out com_api_type_pkg.t_tiny_id
  , i_use_cross_rate      in     com_api_type_pkg.t_boolean
  , i_use_base_rate       in     com_api_type_pkg.t_boolean
  , i_base_currency       in     com_api_type_pkg.t_curr_code
  , i_is_reversible       in     com_api_type_pkg.t_boolean
  , i_warning_level       in     number
  , i_use_double_typing   in     com_api_type_pkg.t_boolean
  , i_use_verification    in     com_api_type_pkg.t_boolean
  , i_adjust_exponent     in     com_api_type_pkg.t_boolean
  , i_exp_period          in     com_api_type_pkg.t_tiny_id
  , i_rounding_accuracy   in     com_api_type_pkg.t_tiny_id
) is
begin
    update com_rate_type_vw
       set seqnum            = io_seqnum
         , use_cross_rate    = i_use_cross_rate
         , use_base_rate     = i_use_base_rate
         , base_currency     = i_base_currency
         , is_reversible     = i_is_reversible
         , warning_level     = i_warning_level
         , use_double_typing = i_use_double_typing
         , use_verification  = i_use_verification
         , adjust_exponent   = i_adjust_exponent
         , exp_period        = i_exp_period
         , rounding_accuracy = i_rounding_accuracy
     where id                = i_id;

    io_seqnum := io_seqnum + 1;
end;

procedure remove (
    i_id                  in     com_api_type_pkg.t_tiny_id
  , i_seqnum              in     com_api_type_pkg.t_tiny_id
) is
    l_check_cnt           number;
    l_rate_type           com_api_type_pkg.t_dict_value;
    l_inst_id             com_api_type_pkg.t_inst_id;
begin
    for r in (
        select
            inst_id
          , rate_type
        from
            com_rate_type_vw
        where id = i_id
    ) loop
        l_inst_id := r.inst_id;
        l_rate_type := r.rate_type;
    end loop;

    select count(1)
      into l_check_cnt
      from (
        select 1
          from com_rate p
         where inst_id = l_inst_id and rate_type = l_rate_type and rownum < 2
         union all
        select 1
          from fcl_fee_rate
         where inst_id = l_inst_id and rate_type = l_rate_type and rownum < 2
         union all
        select 1
          from fcl_limit_rate
         where inst_id = l_inst_id and rate_type = l_rate_type and rownum < 2
         union all
        select 1
          from com_rate_pair
         where inst_id = l_inst_id and base_rate_type = l_rate_type and rownum < 2 
        );

    if l_check_cnt > 0 then
        com_api_error_pkg.raise_error (
            i_error       => 'RATE_TYPE_ALREADY_USED'
          , i_env_param1  => l_rate_type
          , i_env_param2  => l_inst_id
        );
    end if;
    
    -- remove rate pair
    for pair in (
        select id
             , seqnum
          from com_rate_pair p
         where inst_id = l_inst_id
           and rate_type = l_rate_type      
    ) loop
        com_ui_rate_pair_pkg.remove (
            i_id      => pair.id
          , i_seqnum  => pair.seqnum
        );
    end loop;

    update com_rate_type_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete from com_rate_type_vw
     where id = i_id;
end;

end;
/
