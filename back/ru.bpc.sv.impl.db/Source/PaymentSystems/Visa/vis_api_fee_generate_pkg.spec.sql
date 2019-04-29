create or replace package vis_api_fee_generate_pkg is

    procedure gen_fee (
        i_card_number    in com_api_type_pkg.t_card_number
        , i_reason_code  in com_api_type_pkg.t_dict_value
        , i_amount       in com_api_type_pkg.t_medium_id
        , i_currency     in com_api_type_pkg.t_curr_code
        , i_oper_date    in date default get_sysdate
    );

end;
/
 