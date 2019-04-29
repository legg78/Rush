create or replace package body amx_api_file_pkg is

procedure format_trailer_counts_amounts(
    io_credit_count        in out com_api_type_pkg.t_long_id
  , io_debit_count         in out com_api_type_pkg.t_long_id
  , io_credit_amount       in out com_api_type_pkg.t_money
  , io_debit_amount        in out com_api_type_pkg.t_money
  , io_total_amount        in out com_api_type_pkg.t_money
)is
begin
    io_credit_count  := case when length(io_credit_count) > amx_api_const_pkg.MAX_DIGIT_DRCR_COUNT_FIELD
                             then to_number(substr(to_char(io_credit_count), -1 * amx_api_const_pkg.MAX_DIGIT_DRCR_COUNT_FIELD))
                             else io_credit_count
                        end;
    io_debit_count   := case when length(io_debit_count) > amx_api_const_pkg.MAX_DIGIT_DRCR_COUNT_FIELD
                             then to_number(substr(to_char(io_debit_count), -1 * amx_api_const_pkg.MAX_DIGIT_DRCR_COUNT_FIELD))
                             else io_debit_count
                        end;
    io_credit_amount := case when length(io_credit_amount) > amx_api_const_pkg.MAX_DIGIT_DRCR_AMOUNT_FIELD
                             then to_number(substr(to_char(io_credit_amount), -1 * amx_api_const_pkg.MAX_DIGIT_DRCR_AMOUNT_FIELD))
                             else io_credit_amount
                        end;
    io_debit_amount  := case when length(io_debit_amount) > amx_api_const_pkg.MAX_DIGIT_DRCR_AMOUNT_FIELD
                             then to_number(substr(to_char(io_debit_amount), -1 * amx_api_const_pkg.MAX_DIGIT_DRCR_AMOUNT_FIELD))
                             else io_debit_amount
                        end;
    io_total_amount  := case when length(io_total_amount) > amx_api_const_pkg.MAX_DIGIT_TOTAL_AMOUNT_FIELD
                             then to_number(substr(to_char(io_total_amount), -1 * amx_api_const_pkg.MAX_DIGIT_TOTAL_AMOUNT_FIELD))
                             else io_total_amount
                        end;
end;

procedure generate_file_number (
    i_cmid                in     com_api_type_pkg.t_cmid
  , i_transmittal_date    in     date
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_network_id          in     com_api_type_pkg.t_tiny_id
  , i_action_code         in     com_api_type_pkg.t_curr_code
  , i_func_code           in     com_api_type_pkg.t_curr_code   default null
  , o_file_number            out com_api_type_pkg.t_auth_code
)is
    l_file_number           com_api_type_pkg.t_short_id;
begin
    select nvl( max(to_number(file_number))
                keep (dense_rank first order by decode(trunc(transmittal_date,'DD'), trunc(i_transmittal_date, 'DD'), 1, 2))
              , 0)
      into l_file_number
      from amx_file
     where is_incoming       = com_api_type_pkg.FALSE
       and forw_inst_code    = i_cmid
       and action_code       = i_action_code
       and network_id        = i_network_id
       and func_code         = nvl(i_func_code, func_code)
       and regexp_like(file_number, '\d{6}');
    
    if i_action_code in (amx_api_const_pkg.ACTION_CODE_TEST, amx_api_const_pkg.ACTION_CODE_TEST_RETRANS) 
    then
        if l_file_number in (999999, 0) then
            o_file_number := '900000';
        else    
            o_file_number := lpad(to_char(l_file_number) + 1, 6, '0');
        end if;    
    else
        if l_file_number in (899999, 0) then
            o_file_number := '000001';
        else    
            o_file_number := lpad(to_char(l_file_number) + 1, 6, '0');
        end if;    
    end if;
    
    trc_log_pkg.debug (
        i_text         => 'l_file_number ['||l_file_number||'], o_file_number [' || o_file_number || ']'
    );
    
end;

procedure check_file_processed(
    i_amx_file             in     amx_api_type_pkg.t_amx_file_rec
)is
    l_count                pls_integer;
begin
    select 1
      into l_count
      from amx_file
     where file_number    = i_amx_file.file_number
       and is_incoming    = i_amx_file.is_incoming
       and network_id     = i_amx_file.network_id
       and nvl(forw_inst_code, 'null')   = nvl(i_amx_file.forw_inst_code, 'null')
       and nvl(receiv_inst_code, 'null') = nvl(i_amx_file.receiv_inst_code, 'null')
       and nvl(action_code, 'null')      = nvl(i_amx_file.action_code, 'null')
       and nvl(func_code, 'null')        = nvl(i_amx_file.func_code, 'null');

    com_api_error_pkg.raise_fatal_error(
        i_error         => 'AMX_FILE_ALREADY_PROCESSED'
      , i_env_param1    => i_amx_file.file_number
      , i_env_param2    => i_amx_file.is_incoming
      , i_env_param3    => i_amx_file.network_id
      , i_env_param4    => i_amx_file.receiv_inst_code
      , i_env_param5    => i_amx_file.action_code
      , i_env_param6    => i_amx_file.func_code
    );
exception
    when no_data_found then
        null;
end;

end;
/
