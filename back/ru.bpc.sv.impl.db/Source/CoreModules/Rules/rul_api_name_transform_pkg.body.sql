create or replace package body rul_api_name_transform_pkg as
/************************************************************
 * Transform function. <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 24.01.2012 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: RUL_API_NAME_TRANSFORM_PKG <br />
 * @headcom
 *************************************************************/

procedure set_param(
    i_param_tab           in     com_api_type_pkg.t_param_tab
) is
begin
    g_param_tab.delete;
    g_param_tab := i_param_tab;
end;

function get_next_account return com_api_type_pkg.t_sign is
    l_customer_number    com_api_type_pkg.t_name;
    l_currency           com_api_type_pkg.t_curr_code;
    l_customer_id        com_api_type_pkg.t_medium_id;
    l_account_type       com_api_type_pkg.t_dict_value;

begin
    l_customer_number     := rul_api_param_pkg.get_param_char('CUSTOMER_NUMBER', g_param_tab);
    l_currency            := rul_api_param_pkg.get_param_num('CURRENCY', g_param_tab);
    l_account_type        := rul_api_param_pkg.get_param_char('ACCOUNT_TYPE', g_param_tab, com_api_type_pkg.TRUE, null);

    select
        nvl(max(a.id),0)
    into
        l_customer_id
    from
        prd_customer a
    where
        a.customer_number = upper(l_customer_number);

    return acc_api_account_pkg.next_customer_account(
        i_customer_id  => l_customer_id
      , i_currency     => l_currency
      , i_account_type => l_account_type
    );

end;

function get_next_file    return com_api_type_pkg.t_long_id is
    l_file_type           com_api_type_pkg.t_dict_value;
    l_inst_id             com_api_type_pkg.t_inst_id;
    l_file_purpose        com_api_type_pkg.t_dict_value;
    l_file_attr           com_api_type_pkg.t_short_id;
begin
    l_file_type     := rul_api_param_pkg.get_param_char('FILE_TYPE', g_param_tab);
    l_inst_id       := rul_api_param_pkg.get_param_num('INST_ID', g_param_tab);
    l_file_purpose  := rul_api_param_pkg.get_param_char('FILE_PURPOSE', g_param_tab);
    l_file_attr     := rul_api_param_pkg.get_param_num('FILE_ATTR_ID', g_param_tab); 	

    return prc_api_file_pkg.get_next_file(
        i_file_type    => l_file_type
      , i_inst_id      => l_inst_id
      , i_file_purpose => l_file_purpose
      , i_file_attr    => l_file_attr   	  
    );
end get_next_file;

function get_next_card_seq_number return com_api_type_pkg.t_card_number is
    l_contract_id            com_api_type_pkg.t_medium_id;
    l_card_index             com_api_type_pkg.t_card_number;
    l_card_seqnum            com_api_type_pkg.t_byte_char;
    l_card_index_old         com_api_type_pkg.t_card_number;
    l_card_seqnum_old        com_api_type_pkg.t_byte_char;
    l_high_value             com_api_type_pkg.t_large_id;
    l_index_range_id         com_api_type_pkg.t_short_id;
    l_range_len              com_api_type_pkg.t_tiny_id;
    l_part_length            com_api_type_pkg.t_tiny_id;
    l_bin                    com_api_type_pkg.t_bin;
begin
    l_contract_id         := rul_api_param_pkg.get_param_num('CONTRACT_ID', g_param_tab);
    l_index_range_id      := rul_api_param_pkg.get_param_num('INDEX', g_param_tab);
    l_part_length         := rul_api_param_pkg.get_param_num('PART_LENGTH', g_param_tab);
    l_bin                 := rul_api_param_pkg.get_param_char('BIN', g_param_tab);
    
    begin
        select t.high_value
          into l_high_value
          from rul_name_index_range t
         where t.id = l_index_range_id;
    exception 
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error           => 'RUL_NAME_INDEX_RANGE_NOT_FOUND'
              , i_env_param1      => l_index_range_id
            );
    end;

    l_range_len := length(to_char(l_high_value));
    if l_range_len + 1 > l_part_length then
        com_api_error_pkg.raise_error (
            i_error           => 'RUL_NAME_LENGTH_ERROR'
          , i_env_param1      => l_index_range_id
        );
    end if;
    
    -- find last primary card of contract
    select substr(min(card_number) keep (dense_rank last order by reg_date), -(2 + l_range_len), l_range_len)
      into l_card_index_old
      from (
        select iss_api_token_pkg.decode_card_number(i_card_number => cn.card_number) as card_number
             , reg_date
          from iss_card c
             , iss_card_number cn
         where c.contract_id = l_contract_id
           and c.id          = cn.card_id
           and c.category    = iss_api_const_pkg.CARD_CATEGORY_PRIMARY
    )
    where substr(card_number, 1, length(l_bin)) = l_bin;
    
    -- get last seq number for index
    if l_card_index_old is not null then
        select max(substr(card_number, -2, 1))
          into l_card_seqnum_old
          from (
            select iss_api_token_pkg.decode_card_number(i_card_number => cn.card_number) as card_number
              from iss_card c
                 , iss_card_number cn
             where c.contract_id = l_contract_id
               and c.id          = cn.card_id
        )
        where substr(card_number, -(2 + l_range_len), l_range_len) = l_card_index_old
          and substr(card_number, 1, length(l_bin)) = l_bin;
    end if;
    
    if l_card_seqnum_old is not null and l_card_index_old is not null and l_card_seqnum_old <> '9' then
        l_card_index  := l_card_index_old;
        l_card_seqnum := to_char(to_number(l_card_seqnum_old) + 1);
    else
        l_card_index  := lpad(to_char(rul_api_name_pkg.range_nextval(i_id => l_index_range_id)), l_range_len, '0');
        l_card_seqnum := '1';
    end if;

    return l_card_index || l_card_seqnum;
end;

end rul_api_name_transform_pkg;
/
