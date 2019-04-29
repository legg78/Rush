create or replace package body iss_api_product_pkg is

function get_product_card_type (
    i_contract_id               in com_api_type_pkg.t_medium_id  default null
    , i_card_type_id            in com_api_type_pkg.t_tiny_id
    , i_seq_number              in com_api_type_pkg.t_tiny_id    default null
    , i_service_id              in com_api_type_pkg.t_short_id   default null
    , i_product_id              in com_api_type_pkg.t_short_id   default null
    , i_bin_id                  in com_api_type_pkg.t_short_id   default null
) return iss_api_type_pkg.t_product_card_type_rec
is
    l_result                    iss_api_type_pkg.t_product_card_type_rec;
    l_product_id                com_api_type_pkg.t_short_id;
begin
    
    l_product_id := i_product_id;
    
    if i_contract_id is not null then
        begin
            select
                product_id
            into
                l_product_id
            from
                prd_contract_vw
            where
                id = i_contract_id;

            trc_log_pkg.debug (
                i_text              => 'Product of contract [#1] is [#2]'
                , i_env_param1      => i_contract_id
                , i_env_param2      => l_product_id
            );
        exception
            when no_data_found then
                trc_log_pkg.debug (
                    i_text              => 'contract [#1] not found'
                    , i_env_param1      => i_contract_id
                );
        end;
    end if;
    
    if i_seq_number is null then
        select
            *
        into
            l_result
        from (
            select
                p.id
                , p.product_id
                , p.card_type_id
                , p.seq_number_low
                , p.seq_number_high
                , p.bin_id
                , p.index_range_id
                , p.number_format_id
                , p.emv_appl_scheme_id
                , p.status
                , p.pin_request
                , p.embossing_request
                , p.pin_mailer_request
                , p.blank_type_id
                , p.perso_priority
                , p.reiss_command
                , p.reiss_start_date_rule
                , p.reiss_expir_date_rule
                , p.reiss_card_type_id
                , p.reiss_contract_id
                , p.state
                , p.perso_method_id
                , p.service_id
                , p.reiss_product_id
                , p.reiss_bin_id
                , p.uid_format_id
            from
                iss_product_card_type p
              where p.product_id = l_product_id
                and p.card_type_id = i_card_type_id
                and (i_service_id is null or p.service_id = i_service_id)
                and (i_bin_id is null or p.bin_id = i_bin_id)
            order by
                p.seq_number_low asc
        ) where
            rownum = 1;
    else
        select
            p.id
            , p.product_id
            , p.card_type_id
            , p.seq_number_low
            , p.seq_number_high
            , p.bin_id
            , p.index_range_id
            , p.number_format_id
            , p.emv_appl_scheme_id
            , p.status
            , p.pin_request
            , p.embossing_request
            , p.pin_mailer_request
            , p.blank_type_id
            , p.perso_priority
            , p.reiss_command
            , p.reiss_start_date_rule
            , p.reiss_expir_date_rule
            , p.reiss_card_type_id
            , p.reiss_contract_id
            , p.state
            , p.perso_method_id
            , p.service_id
            , p.reiss_product_id
            , p.reiss_bin_id
            , p.uid_format_id
        into
            l_result
        from
            iss_product_card_type p
          where p.product_id = l_product_id
            and p.card_type_id = i_card_type_id
            and (i_service_id is null or p.service_id = i_service_id)
            and (i_bin_id is null or p.bin_id = i_bin_id)
            and i_seq_number between p.seq_number_low and p.seq_number_high;
    end if;
            
    return l_result;
exception
    when no_data_found or too_many_rows then
        com_api_error_pkg.raise_error (
            i_error             => 'UNDEFINED_CARD_TYPE_FOR_PRODUCT'
            , i_env_param1      => l_product_id
            , i_env_param2      => i_card_type_id
            , i_env_param3      => i_seq_number
        );
end;


end;
/
