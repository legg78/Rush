create or replace package body mcw_prc_mpe_pkg is

    BULK_LIMIT                      constant integer := 100;
    
    ACTIVE                          constant com_api_type_pkg.t_dict_value := 'A';

    g_prev_country_code             com_api_type_pkg.t_curr_code;
    g_prev_mcc                      com_api_type_pkg.t_mcc;

    g_active_records                com_api_type_pkg.t_integer_tab;
    g_inactive_records              com_api_type_pkg.t_integer_tab;
    g_de_number                     com_api_type_pkg.t_tiny_tab;
    g_pds_number                    com_api_type_pkg.t_tiny_tab;
    g_name                          com_api_type_pkg.t_name_tab;
    g_format                        com_api_type_pkg.t_dict_tab;
    g_min_length                    com_api_type_pkg.t_tiny_tab;
    g_max_length                    com_api_type_pkg.t_tiny_tab;
    g_prefix_length                 com_api_type_pkg.t_tiny_tab;
    g_subfield_count                com_api_type_pkg.t_tiny_tab;
    g_error_code                    com_api_type_pkg.t_tiny_tab;
    g_error_text                    com_api_type_pkg.t_desc_tab;
    g_curr_code                     com_api_type_pkg.t_curr_code_tab;
    g_curr_name                     com_api_type_pkg.t_curr_code_tab;
    g_exponent                      com_api_type_pkg.t_tiny_tab;
    g_code                          com_api_type_pkg.t_curr_code_tab;
    g_country_name                  com_api_type_pkg.t_curr_code_tab;
    g_region                        com_api_type_pkg.t_dict_tab;
    g_iss_region                    com_api_type_pkg.t_curr_code_tab;
    g_acq_region                    com_api_type_pkg.t_curr_code_tab;
    g_euro                          com_api_type_pkg.t_curr_code_tab;
    g_pan_low                       com_api_type_pkg.t_card_number_tab;
    g_pan_high                      com_api_type_pkg.t_card_number_tab;
    g_product_id                    com_api_type_pkg.t_curr_code_tab;
    g_brand                         com_api_type_pkg.t_curr_code_tab;
    g_priority                      com_api_type_pkg.t_tiny_tab;
    g_brand_priority                com_api_type_pkg.t_tiny_tab;
    g_member                        com_api_type_pkg.t_card_number_tab;
    g_product_type                  com_api_type_pkg.t_curr_code_tab;
    g_endpoint                      com_api_type_pkg.t_card_number_tab;
    g_mcc                           com_api_type_pkg.t_mcc_tab;
    g_cab_type                      com_api_type_pkg.t_mcc_tab;
    g_cab_program                   com_api_type_pkg.t_mcc_tab;
    g_arrangement_type              com_api_type_pkg.t_curr_code_tab;
    g_arrangement_code              com_api_type_pkg.t_dict_tab;
    g_bin                           com_api_type_pkg.t_card_number_tab;
    g_ird                           com_api_type_pkg.t_curr_code_tab;
    g_mti                           com_api_type_pkg.t_dict_tab;
    g_de024                         com_api_type_pkg.t_curr_code_tab;
    g_de003                         com_api_type_pkg.t_curr_code_tab;
    g_paypass_ind                   com_api_type_pkg.t_curr_code_tab;
    g_sepa                          com_api_type_pkg.t_byte_char_tab;
    g_non_reloadable_ind            com_api_type_pkg.t_curr_code_tab;
    g_npg_ica                       com_api_type_pkg.t_byte_char_tab;

    g_cur_rate_tab                  mcw_api_type_pkg.t_cur_rate_tab;

    g_licensed_product_id           com_api_type_pkg.t_curr_code_tab;
    g_gcms_product_id               com_api_type_pkg.t_curr_code_tab;
    g_card_program_id               com_api_type_pkg.t_curr_code_tab;
    g_product_class                 com_api_type_pkg.t_curr_code_tab;
    g_product_type_id               com_api_type_pkg.t_curr_code_tab;
    g_product_category              com_api_type_pkg.t_curr_code_tab;
    g_product_category_code         com_api_type_pkg.t_curr_code_tab;
    g_comm_product_indicator        com_api_type_pkg.t_curr_code_tab;
    
    g_cr_bin_ranges_rowid           com_api_type_pkg.t_rowid_tab;

    cursor data_cur (
        i_session_file_id in com_api_type_pkg.t_long_id
    ) is
        select
            record_number
            , raw_data
        from
            prc_file_raw_data
        where
            session_file_id = i_session_file_id
        order by
            record_number;


    procedure clear_global_data is
    begin
        g_active_records.delete;
        g_inactive_records.delete;
        g_de_number.delete;
        g_pds_number.delete;
        g_min_length.delete;
        g_max_length.delete;
        g_prefix_length.delete;
        g_subfield_count.delete;
        g_error_code.delete;
        g_error_text.delete;
        g_curr_code.delete;
        g_curr_name.delete;
        g_exponent.delete;
        g_code.delete;
        g_country_name.delete;
        g_region.delete;
        g_iss_region.delete;
        g_acq_region.delete;
        g_euro.delete;
        g_pan_low.delete;
        g_pan_high.delete;
        g_product_id.delete;
        g_brand.delete;
        g_priority.delete;
        g_brand_priority.delete;
        g_member.delete;
        g_product_type.delete;
        g_endpoint.delete;
        g_mcc.delete;
        g_cab_type.delete;
        g_cab_program.delete;
        g_arrangement_type.delete;
        g_arrangement_code.delete;
        g_bin.delete;
        g_ird.delete;
        g_mti.delete;
        g_de024.delete;
        g_de003.delete;
        g_paypass_ind.delete;
        g_npg_ica.delete;

        g_licensed_product_id.delete;
        g_gcms_product_id.delete;
        g_card_program_id.delete;
        g_product_class.delete;
        g_product_type_id.delete;
        g_product_category.delete;
        g_product_category_code.delete;
        g_comm_product_indicator.delete;

    end;
    
    procedure clear_bin_range_crossed as
    begin
        g_cr_bin_ranges_rowid.delete;
    end;

    procedure apply_de_data is
    begin
        if g_inactive_records.count > 0 then
            forall i in values of g_inactive_records
                delete from mcw_de
                where de_number = g_de_number(i);
        end if;

        if g_active_records.count > 0 then
            forall i in values of g_active_records
                merge into
                    mcw_de dst
                using (
                    select
                        g_de_number(i) de_number
                        , g_name(i) name
                        , g_format(i) format
                        , g_min_length(i) min_length
                        , g_max_length(i) max_length
                        , g_prefix_length(i) prefix_length
                        , g_subfield_count(i) subfield_count
                    from dual
                ) src
                on (
                    src.de_number = dst.de_number
                )
                when matched then
                    update
                    set
                        dst.min_length = src.min_length
                        , dst.max_length = src.max_length
                        , dst.prefix_length = src.prefix_length
                        , dst.subfield_count = src.subfield_count
                when not matched then
                    insert (
                        dst.de_number
                        , dst.name
                        , dst.format
                        , dst.min_length
                        , dst.max_length
                        , dst.prefix_length
                        , dst.subfield_count
                    ) values (
                        src.de_number
                        , src.name
                        , src.format
                        , src.min_length
                        , src.max_length
                        , src.prefix_length
                        , src.subfield_count
                    );
        end if;
    end;

    procedure collect_de_data (
        i_active                    in com_api_type_pkg.t_dict_value
        , i_de_number               in com_api_type_pkg.t_tiny_id
        , i_name                    in com_api_type_pkg.t_name
        , i_format                  in com_api_type_pkg.t_dict_value
        , i_min_length              in com_api_type_pkg.t_tiny_id
        , i_max_length              in com_api_type_pkg.t_tiny_id
        , i_prefix_length           in com_api_type_pkg.t_tiny_id
        , i_subfield_count          in com_api_type_pkg.t_tiny_id
        , i_program                 in com_api_type_pkg.t_dict_value
    ) is
        i                           binary_integer;
    begin
        if i_program = 'MCC' then -- process only MC definitions (skip VIS garbage)
            i := g_de_number.count + 1;

            g_de_number(i) := i_de_number;
            g_name(i) := i_name;
            g_format(i) := i_format;
            g_min_length(i) := i_min_length;
            g_max_length(i) := i_max_length;
            g_prefix_length(i) := i_prefix_length;
            g_subfield_count(i) := i_subfield_count;

            if i_active = ACTIVE then
                g_active_records(g_active_records.count + 1) := i;
            else
                g_inactive_records(g_inactive_records.count + 1) := i;
            end if;
        end if;
    end;

    procedure apply_pds_data is
    begin
        if g_inactive_records.count > 0 then
            forall i in values of g_inactive_records
                delete from mcw_pds
                where pds_number = g_pds_number(i);
        end if;

        if g_active_records.count > 0 then
            forall i in values of g_active_records
                merge into
                    mcw_pds dst
                using (
                    select
                        g_pds_number(i) pds_number
                        , g_name(i) name
                        , g_format(i) format
                        , g_min_length(i) min_length
                        , g_max_length(i) max_length
                        , g_subfield_count(i) subfield_count
                    from dual
                ) src
                on (
                    src.pds_number = dst.pds_number
                )
                when matched then
                    update
                    set
                        dst.min_length = src.min_length
                        , dst.max_length = src.max_length
                        , dst.subfield_count = src.subfield_count
                when not matched then
                    insert (
                        dst.pds_number
                        , dst.name
                        , dst.format
                        , dst.min_length
                        , dst.max_length
                        , dst.subfield_count
                    ) values (
                        src.pds_number
                        , src.name
                        , src.format
                        , src.min_length
                        , src.max_length
                        , src.subfield_count
                    );
        end if;
    end;

    procedure collect_pds_data (
        i_active                    in com_api_type_pkg.t_dict_value
        , i_pds_number              in com_api_type_pkg.t_tiny_id
        , i_name                    in com_api_type_pkg.t_name
        , i_format                  in com_api_type_pkg.t_dict_value
        , i_min_length              in com_api_type_pkg.t_tiny_id
        , i_max_length              in com_api_type_pkg.t_tiny_id
        , i_subfield_count          in com_api_type_pkg.t_tiny_id
    ) is
        i                           binary_integer;
    begin
        i := g_pds_number.count + 1;

        g_pds_number(i) := i_pds_number;
        g_name(i) := i_name;
        g_format(i) := i_format;
        g_min_length(i) := i_min_length;
        g_max_length(i) := i_max_length;
        g_subfield_count(i) := i_subfield_count;

        if i_active = ACTIVE then
            g_active_records(g_active_records.count + 1) := i;
        else
            g_inactive_records(g_inactive_records.count + 1) := i;
        end if;
    end;

    procedure apply_error_codes is
    begin
        if g_inactive_records.count > 0 then
            forall i in values of g_inactive_records
                delete from mcw_error_code
                where code = g_error_code(i);
        end if;

        if g_active_records.count > 0 then
            forall i in values of g_active_records
                merge into
                    mcw_error_code dst
                using (
                    select
                        g_error_code(i) code
                        , g_error_text(i) text
                    from dual
                ) src
                on (
                    src.code = dst.code
                )
                when matched then
                    update
                    set
                        dst.text = src.text
                when not matched then
                    insert (
                        dst.code
                        , dst.text
                    ) values (
                        src.code
                        , src.text
                    );
        end if;
    end;

    procedure collect_error_code (
        i_active                    in com_api_type_pkg.t_dict_value
        , i_code                    in com_api_type_pkg.t_tiny_id
        , i_text                    in varchar2
    ) is
        i                           binary_integer;
    begin
        i := g_error_code.count + 1;

        g_error_code(i) := i_code;
        g_error_text(i) := i_text;

        if i_active = ACTIVE then
            g_active_records(g_active_records.count + 1) := i;
        else
            g_inactive_records(g_inactive_records.count + 1) := i;
        end if;
    end;

    procedure apply_currency_data is
    begin
        com_api_currency_pkg.apply_currency_update (
            i_code_tab                  => g_curr_code
            , i_name_tab                => g_curr_name
            , i_exponent_tab            => g_exponent
        );
    end;

    procedure collect_currency_data (
        i_active                    in com_api_type_pkg.t_dict_value
        , i_curr_code               in com_api_type_pkg.t_curr_code
        , i_curr_name               in com_api_type_pkg.t_curr_code
        , i_exponent                in com_api_type_pkg.t_tiny_id
    ) is
        i                           binary_integer;
    begin
        if i_active = ACTIVE then
            i := g_curr_code.count + 1;

            g_curr_code(i) := i_curr_code;
            g_curr_name(i) := i_curr_name;
            g_exponent(i) := i_exponent;
        end if;
    end;

    procedure apply_country_data is
    begin
        com_api_country_pkg.apply_country_update (
            i_code_tab                  => g_code
            , i_name_tab                => g_country_name
            , i_curr_code_tab           => g_curr_code
            , i_region_tab              => g_region
            , i_euro_tab                => g_euro
            , i_desc_tab                => g_name
            , i_sepa_tab                => g_sepa
        );
    end;

    procedure collect_country_data (
        i_active                    in com_api_type_pkg.t_dict_value
        , i_code                    in com_api_type_pkg.t_curr_code
        , i_name                    in com_api_type_pkg.t_curr_code
        , i_curr_code               in com_api_type_pkg.t_curr_code
        , i_region                  in com_api_type_pkg.t_curr_code
        , i_euro                    in com_api_type_pkg.t_curr_code
        , i_desc                    in com_api_type_pkg.t_name
        , i_sepa                    in com_api_type_pkg.t_byte_char     default null
    ) is
        i                           binary_integer;
    begin
        if i_active = ACTIVE then
            if i_code = g_prev_country_code then
                null;
            else
                g_prev_country_code := i_code;

                i := g_code.count + 1;

                g_code(i) := i_code;
                g_country_name(i) := i_name;
                g_curr_code(i) := i_curr_code;
                g_region(i) := i_region;
                g_euro(i) := i_euro;
                g_name(i) := i_desc;
                g_sepa(i) := i_sepa;
            end if;
        end if;
    end;

    procedure apply_def_arrangement is
    begin
        forall i in 1 .. g_region.count
            insert into mcw_def_arrangement_tmp (
                region
                , acq_region
                , iss_region
                , brand
                , priority
                , arrangement_type
                , arrangement_code
            ) values (
                g_region(i)
                , g_acq_region(i)
                , g_iss_region(i)
                , g_brand(i)
                , g_priority(i)
                , g_arrangement_type(i)
                , g_arrangement_code(i)
            );
    end;

    procedure collect_def_arrangement (
        i_active                    in com_api_type_pkg.t_dict_value
        , i_region                  in com_api_type_pkg.t_curr_code
        , i_acq_region              in com_api_type_pkg.t_curr_code
        , i_iss_region              in com_api_type_pkg.t_curr_code
        , i_brand                   in com_api_type_pkg.t_curr_code
        , i_priority                in com_api_type_pkg.t_tiny_id
        , i_arrangement_type        in com_api_type_pkg.t_curr_code
        , i_arrangement_code        in com_api_type_pkg.t_dict_value
    ) is
        i                           binary_integer;
    begin
        if i_active = ACTIVE then
            i := g_region.count + 1;

            g_region(i) := i_region;
            g_acq_region(i) := i_acq_region;
            g_iss_region(i) := i_iss_region;
            g_brand(i) := i_brand;
            g_priority(i) := i_priority;
            g_arrangement_type(i) := i_arrangement_type;
            g_arrangement_code(i) := i_arrangement_code;
        end if;
    end;

    procedure apply_bin_range (
        i_load_temp_tab in     boolean
      , i_load_main_tab in     boolean
    ) is
    begin
        if g_inactive_records.count > 0 then
            if i_load_main_tab then
                forall i in values of g_inactive_records
                    delete from mcw_bin_range
                     where pan_low    = g_pan_low(i)
                       and pan_high   = g_pan_high(i)
                       and product_id = g_product_id(i);
            end if;

            if i_load_temp_tab then
                forall i in values of g_inactive_records
                    delete from mcw_bin_range_tmp
                     where pan_low    = g_pan_low(i)
                       and pan_high   = g_pan_high(i)
                       and product_id = g_product_id(i);
            end if;
        end if;

        if g_active_records.count > 0 then
            if i_load_main_tab then
                forall i in values of g_active_records
                    merge into mcw_bin_range dst
                    using (
                        select g_pan_low(i) pan_low
                             , g_pan_high(i) pan_high
                             , g_product_id(i) product_id
                             , g_brand(i) brand
                             , g_priority(i) priority
                             , g_member(i) member_id
                             , g_product_type(i) product_type
                             , g_code(i) country
                             , g_region(i) region
                             , g_paypass_ind(i) paypass_ind
                             , g_non_reloadable_ind(i) non_reloadable_ind
                          from dual
                    ) src
                    on (
                        src.pan_low        = dst.pan_low
                        and src.pan_high   = dst.pan_high
                        and src.product_id = dst.product_id
                    )
                    when matched then
                        update
                           set dst.brand              = src.brand
                             , dst.priority           = src.priority
                             , dst.member_id          = src.member_id
                             , dst.product_type       = src.product_type
                             , dst.country            = src.country
                             , dst.region             = src.region
                             , dst.paypass_ind        = src.paypass_ind
                             , dst.non_reloadable_ind = src.non_reloadable_ind
                     when not matched then
                        insert (
                            dst.pan_low
                          , dst.pan_high
                          , dst.product_id
                          , dst.brand
                          , dst.priority
                          , dst.member_id
                          , dst.product_type
                          , dst.country
                          , dst.region
                          , dst.paypass_ind
                          , dst.non_reloadable_ind
                        ) values (
                            src.pan_low
                          , src.pan_high
                          , src.product_id
                          , src.brand
                          , src.priority
                          , src.member_id
                          , src.product_type
                          , src.country
                          , src.region
                          , src.paypass_ind 
                          , src.non_reloadable_ind
                        );
            end if;

            if i_load_temp_tab then
                forall i in values of g_active_records
                    merge into
                        mcw_bin_range_tmp dst
                    using (
                        select g_pan_low(i) pan_low
                             , g_pan_high(i) pan_high
                             , g_product_id(i) product_id
                             , g_brand(i) brand
                             , g_priority(i) priority
                             , g_member(i) member_id
                             , g_product_type(i) product_type
                             , g_code(i) country
                             , g_region(i) region
                             , g_paypass_ind(i) paypass_ind
                             , g_non_reloadable_ind(i) non_reloadable_ind
                          from dual
                    ) src
                    on (
                        src.pan_low        = dst.pan_low
                        and src.pan_high   = dst.pan_high
                        and src.product_id = dst.product_id
                    )
                    when matched then
                        update
                           set dst.brand              = src.brand
                             , dst.priority           = src.priority
                             , dst.member_id          = src.member_id
                             , dst.product_type       = src.product_type
                             , dst.country            = src.country
                             , dst.region             = src.region
                             , dst.paypass_ind        = src.paypass_ind
                             , dst.non_reloadable_ind = src.non_reloadable_ind
                    when not matched then
                        insert (
                            dst.pan_low
                          , dst.pan_high
                          , dst.product_id
                          , dst.brand
                          , dst.priority
                          , dst.member_id
                          , dst.product_type
                          , dst.country
                          , dst.region
                          , dst.paypass_ind
                          , dst.non_reloadable_ind
                        ) values (
                            src.pan_low
                          , src.pan_high
                          , src.product_id
                          , src.brand
                          , src.priority
                          , src.member_id
                          , src.product_type
                          , src.country
                          , src.region
                          , src.paypass_ind 
                          , src.non_reloadable_ind
                        );
            end if;
        end if;
    end;
    
    procedure collect_bin_range (
        i_active                  in com_api_type_pkg.t_dict_value
      , i_pan_low                 in com_api_type_pkg.t_card_number
      , i_pan_high                in com_api_type_pkg.t_card_number
      , i_product_id              in com_api_type_pkg.t_curr_code
      , i_brand                   in com_api_type_pkg.t_curr_code
      , i_priority                in com_api_type_pkg.t_tiny_id
      , i_member_id               in com_api_type_pkg.t_card_number
      , i_product_type            in com_api_type_pkg.t_curr_code
      , i_country                 in com_api_type_pkg.t_curr_code
      , i_region                  in com_api_type_pkg.t_curr_code
      , i_paypass_ind             in com_api_type_pkg.t_dict_value
      , i_non_reloadable_ind      in com_api_type_pkg.t_curr_code
      , i_load_main_tab           in boolean
      , i_load_temp_tab           in boolean
    ) is
        i                         binary_integer;
    begin
        i := g_pan_low.count + 1;

        g_pan_low(i)            := i_pan_low;
        g_pan_high(i)           := i_pan_high;
        g_product_id(i)         := i_product_id;
        g_brand(i)              := i_brand;
        g_priority(i)           := i_priority;
        g_member(i)             := i_member_id;
        g_product_type(i)       := i_product_type;
        g_code(i)               := i_country;
        g_region(i)             := i_region;
        g_paypass_ind(i)        := i_paypass_ind;
        g_non_reloadable_ind(i) := i_non_reloadable_ind;

        if i_active = ACTIVE then
            g_active_records(g_active_records.count + 1) := i;
        else
            g_inactive_records(g_inactive_records.count + 1) := i;
        end if;

        if i >= BULK_LIMIT then
            apply_bin_range (
                i_load_main_tab     => i_load_main_tab
              , i_load_temp_tab     => i_load_temp_tab
            );
            clear_global_data;
        end if;
    end;

    -- search crossed ranges and mark to be deleted
    procedure collect_bin_range_crossed(
        i_active                  in com_api_type_pkg.t_dict_value
      , i_pan_low                 in com_api_type_pkg.t_card_number
      , i_pan_high                in com_api_type_pkg.t_card_number
    ) is
    begin
        if i_active = ACTIVE then
            for r in (
                select r.rowid
                     , r.pan_low
                     , r.pan_high
                  from mcw_bin_range r
                 where r.pan_low  <= i_pan_low
                   and r.pan_high >= i_pan_high
                   and not(pan_low = i_pan_low and pan_high = i_pan_high)
            )
            loop
                -- save rowid
                g_cr_bin_ranges_rowid(g_cr_bin_ranges_rowid.count + 1) := r.rowid;
                
                trc_log_pkg.warn(
                    i_text        => 'MPE_BIN_RANGE_CROSSED'
                  , i_env_param1  => r.pan_low
                  , i_env_param2  => r.pan_high
                  , i_env_param3  => i_pan_low
                  , i_env_param4  => i_pan_high
                );
            end loop;
        end if;
    end;
    
    procedure delete_crossed_ranges is
    begin
        if g_cr_bin_ranges_rowid.count > 0 then
            forall i in g_cr_bin_ranges_rowid.first .. g_cr_bin_ranges_rowid.last
                delete mcw_bin_range
                 where rowid = g_cr_bin_ranges_rowid(i);
        end if;
        clear_bin_range_crossed;
    end;

    procedure apply_acq_bin (
        i_load_temp_tab         in boolean
        , i_load_main_tab       in boolean
    ) is
    begin
        if g_inactive_records.count > 0 then
            if i_load_main_tab then
                forall i in values of g_inactive_records
                    delete from mcw_acq_bin
                    where
                        acq_bin = g_bin(i);
            end if;

            if i_load_temp_tab then
                forall i in values of g_inactive_records
                    delete from mcw_acq_bin_tmp
                    where
                        acq_bin = g_bin(i);
            end if;
        end if;

        if g_active_records.count > 0 then
            if i_load_main_tab then
                forall i in values of g_active_records
                    merge into
                        mcw_acq_bin dst
                    using (
                        select
                            g_bin(i) acq_bin
                            , g_brand(i) brand
                            , g_member(i) member_id
                            , g_name(i) country
                            , g_region(i) region
                        from dual
                    ) src
                    on (
                        src.acq_bin = dst.acq_bin
                        and src.brand = dst.brand
                    )
                    when matched then
                        update
                        set
                            dst.member_id = src.member_id
                            , dst.country = src.country
                            , dst.region = src.region
                    when not matched then
                        insert (
                            dst.acq_bin
                            , dst.brand
                            , dst.member_id
                            , dst.country
                            , dst.region
                        ) values (
                            src.acq_bin
                            , src.brand
                            , src.member_id
                            , src.country
                            , src.region
                        );
            end if;

            if i_load_temp_tab then
                forall i in values of g_active_records
                    merge into
                        mcw_acq_bin_tmp dst
                    using (
                        select
                            g_bin(i)      as acq_bin
                            , g_brand(i)  as brand
                            , g_member(i) as member_id
                            , g_name(i)   as country
                            , g_region(i) as region
                        from dual
                    ) src
                    on (
                        src.acq_bin = dst.acq_bin
                        and src.brand = dst.brand
                    )
                    when matched then
                        update
                        set
                            dst.member_id = src.member_id
                            , dst.country = src.country
                            , dst.region = src.region
                    when not matched then
                        insert (
                            dst.acq_bin
                            , dst.brand
                            , dst.member_id
                            , dst.country
                            , dst.region
                        ) values (
                            src.acq_bin
                            , src.brand
                            , src.member_id
                            , src.country
                            , src.region
                        );
            end if;
        end if;
    end;

    procedure collect_acq_bin (
        i_active                    in com_api_type_pkg.t_dict_value
        , i_bin                     in com_api_type_pkg.t_card_number
        , i_brand                   in com_api_type_pkg.t_curr_code
        , i_member_id               in com_api_type_pkg.t_card_number
        , i_region                  in com_api_type_pkg.t_name
        , i_country                 in com_api_type_pkg.t_name
        , i_load_main_tab           in boolean
        , i_load_temp_tab           in boolean
    ) is
        i                           binary_integer;
    begin
        i := g_bin.count + 1;

        g_bin(i) := i_bin;
        g_brand(i) := i_brand;
        g_member(i) := i_member_id;
        g_name(i) := i_country;
        g_region(i) := i_region;

        if i_active = ACTIVE then
            g_active_records(g_active_records.count + 1) := i;
        else
            g_inactive_records(g_inactive_records.count + 1) := i;
        end if;

        if i >= BULK_LIMIT then
            apply_acq_bin (
                i_load_main_tab     => i_load_main_tab
                , i_load_temp_tab     => i_load_temp_tab
            );
            clear_global_data;
        end if;
    end;

    procedure apply_member_info is
    begin
        if g_inactive_records.count > 0 then
            forall i in values of g_inactive_records
                delete from mcw_member_info
                where member_id = g_member(i);
        end if;

        if g_active_records.count > 0 then
            forall i in values of g_active_records
                merge into
                    mcw_member_info dst
                using (
                    select
                        g_member(i) member_id
                        , g_region(i) region
                        , g_endpoint(i) endpoint
                        , g_name(i) name
                        , g_country_name(i) country
                        , g_npg_ica(i) npg_ica
                    from dual
                ) src
                on (
                    src.member_id = dst.member_id
                )
                when matched then
                    update
                    set
                        dst.region = src.region
                        , dst.endpoint = src.endpoint
                        , dst.name = src.name
                        , dst.country = src.country
                        , dst.npg_ica = src.npg_ica
                when not matched then
                    insert (
                        dst.member_id
                        , dst.region
                        , dst.endpoint
                        , dst.name
                        , dst.country
                        , dst.npg_ica
                    ) values (
                        src.member_id
                        , src.region
                        , src.endpoint
                        , src.name
                        , src.country
                        , src.npg_ica
                    );
        end if;
    end;

    procedure collect_member_info (
        i_active                    in com_api_type_pkg.t_dict_value
        , i_member_id               in com_api_type_pkg.t_card_number
        , i_region                  in com_api_type_pkg.t_curr_code
        , i_endpoint                in com_api_type_pkg.t_card_number
        , i_name                    in com_api_type_pkg.t_name
        , i_country                 in com_api_type_pkg.t_curr_code
        , i_npc_ica                 in com_api_type_pkg.t_byte_char
    ) is
        i                           binary_integer;
    begin
        i := g_member.count + 1;

        g_member(i) := i_member_id;
        g_region(i) := i_region;
        g_endpoint(i) := i_endpoint;
        g_name(i) := i_name;
        g_country_name(i) := i_country;
        g_npg_ica(i) := i_npc_ica;

        if i_active = ACTIVE then
            g_active_records(g_active_records.count + 1) := i;
        else
            g_inactive_records(g_inactive_records.count + 1) := i;
        end if;

        if i >= BULK_LIMIT then
            apply_member_info;
            clear_global_data;
        end if;
    end;

    procedure apply_mcc_data is
    begin
        com_api_mcc_pkg.apply_mcc_update (
            i_mcc_tab            => g_mcc
            , i_cab_type_tab     => g_cab_type
            , i_active_records   => g_active_records
        );
        
        if g_inactive_records.count > 0 then
            forall i in values of g_inactive_records
                delete from mcw_mcc
                where
                    mcc = g_mcc(i)
                    and cab_type = g_cab_type(i)
                    and cab_program = g_cab_program(i);
        end if;

        if g_active_records.count > 0 then
            forall i in values of g_active_records
                merge into
                    mcw_mcc dst
                using (
                    select
                        g_mcc(i) mcc
                        , g_cab_type(i) cab_type
                        , g_cab_program(i) cab_program
                    from dual
                ) src
                on (
                    src.mcc = dst.mcc
                    and src.cab_type = dst.cab_type
                    and src.cab_program = dst.cab_program
                )
                when not matched then
                    insert (
                        dst.mcc
                        , dst.cab_type
                        , dst.cab_program
                    ) values (
                        src.mcc
                        , src.cab_type
                        , src.cab_program
                    );
        end if;
        
    end;

    procedure collect_mcc_data (
        i_active                    in com_api_type_pkg.t_dict_value
        , i_mcc                     in com_api_type_pkg.t_mcc
        , i_cab_type                in com_api_type_pkg.t_mcc
        , i_cab_program             in com_api_type_pkg.t_mcc
    ) is
        i                           binary_integer;
    begin
        i := g_mcc.count + 1;

        g_mcc(i) := i_mcc;
        g_cab_type(i) := i_cab_type;
        g_cab_program(i) := i_cab_program;
            
        if i_active = ACTIVE then
            g_active_records(g_active_records.count + 1) := i;
        else
            g_inactive_records(g_inactive_records.count + 1) := i;
        end if;
            
        if i >= BULK_LIMIT then
            apply_mcc_data;
            clear_global_data;
        end if;
    end;

    procedure apply_iss_arrangement is
    begin
        if g_inactive_records.count > 0 then
            forall i in values of g_inactive_records
                delete from mcw_iss_arrangement
                where
                    pan_low = g_pan_low(i)
                    and pan_high = g_pan_high(i)
                    and arrangement_type = g_arrangement_type(i)
                    and arrangement_code = g_arrangement_code(i)
                    and brand = g_brand(i);
        end if;

        if g_active_records.count > 0 then
            forall i in values of g_active_records
                merge into
                    mcw_iss_arrangement dst
                using (
                    select
                        g_pan_low(i) pan_low
                        , g_pan_high(i) pan_high
                        , g_arrangement_type(i) arrangement_type
                        , g_arrangement_code(i) arrangement_code
                        , g_brand(i) brand
                        , g_priority(i) type_priority
                        , g_brand_priority(i) brand_priority
                    from dual
                ) src
                on (
                    src.pan_low = dst.pan_low
                    and src.pan_high = dst.pan_high
                    and src.arrangement_type = dst.arrangement_type
                    and src.arrangement_code = dst.arrangement_code
                    and src.brand = dst.brand
                )
                when matched then
                    update
                    set
                        dst.type_priority = src.type_priority
                        , dst.brand_priority = src.brand_priority
                when not matched then
                    insert (
                        dst.pan_low
                        , dst.pan_high
                        , dst.arrangement_type
                        , dst.arrangement_code
                        , dst.brand
                        , dst.type_priority
                        , dst.brand_priority
                    ) values (
                        src.pan_low
                        , src.pan_high
                        , src.arrangement_type
                        , src.arrangement_code
                        , src.brand
                        , src.type_priority
                        , src.brand_priority
                    );
        end if;
    end;

    procedure collect_iss_arrangement (
        i_active                    in com_api_type_pkg.t_dict_value
        , i_pan_low                 in com_api_type_pkg.t_card_number
        , i_pan_high                in com_api_type_pkg.t_card_number
        , i_type                    in com_api_type_pkg.t_curr_code
        , i_code                    in com_api_type_pkg.t_dict_value
        , i_brand                   in com_api_type_pkg.t_curr_code
        , i_type_priority           in com_api_type_pkg.t_tiny_id
        , i_brand_priority          in com_api_type_pkg.t_tiny_id
    ) is
        i                           binary_integer;
    begin
        i := g_pan_low.count + 1;

        g_pan_low(i) := i_pan_low;
        g_pan_high(i) := i_pan_high;
        g_arrangement_type(i) := i_type;
        g_arrangement_code(i) := i_code;
        g_brand(i) := i_brand;
        g_priority(i) := i_type_priority;
        g_brand_priority(i) := i_brand_priority;

        if i_active = ACTIVE then
            g_active_records(g_active_records.count + 1) := i;
        else
            g_inactive_records(g_inactive_records.count + 1) := i;
        end if;

        if i >= BULK_LIMIT then
            apply_iss_arrangement;
            clear_global_data;
        end if;
    end;

    procedure expand_iss_arrangement is
    begin
        merge into
            mcw_iss_arrangement dst
        using (
            select
                b.pan_low               pan_low
                , b.pan_high            pan_high
                , min(a.priority)       type_priority
                , a.arrangement_type    arrangement_type
                , a.arrangement_code    arrangement_code
                , min(b.priority)       brand_priority
                , b.brand               brand
            from
                mcw_bin_range_tmp b
                , mcw_def_arrangement_tmp a
            where
                b.region = a.iss_region
                and b.brand = a.brand
                and a.arrangement_type = mcw_api_const_pkg.ARRANGEMENT_TYPE_INTERREGIONAL
            group by
                b.pan_low
                , b.pan_high
                , a.arrangement_type
                , a.arrangement_code
                , b.brand
            union all
            select
                b.pan_low               pan_low
                , b.pan_high            pan_high
                , min(a.priority)       type_priority
                , a.arrangement_type    arrangement_type
                , a.arrangement_code    arrangement_code
                , min(b.priority)       brand_priority
                , b.brand               brand
            from
                mcw_bin_range_tmp b
                , mcw_def_arrangement_tmp a
            where
                b.region = a.region and
                b.brand = a.brand and
                a.arrangement_type = mcw_api_const_pkg.ARRANGEMENT_TYPE_REGIONAL
            group by
                b.pan_low
                , b.pan_high
                , a.arrangement_type
                , a.arrangement_code
                , b.brand
        ) src
        on (
            src.pan_low = dst.pan_low
            and src.pan_high = dst.pan_high
            and src.arrangement_type = dst.arrangement_type
            and src.arrangement_code = dst.arrangement_code
            and src.brand = dst.brand
        )
        when matched then
            update
            set
                dst.type_priority = src.type_priority
                , dst.brand_priority = src.brand_priority
        when not matched then
            insert (
                dst.pan_low
                , dst.pan_high
                , dst.arrangement_type
                , dst.arrangement_code
                , dst.brand
                , dst.type_priority
                , dst.brand_priority
            ) values (
                src.pan_low
                , src.pan_high
                , src.arrangement_type
                , src.arrangement_code
                , src.brand
                , src.type_priority
                , src.brand_priority
            );
    end;

    procedure apply_acq_arrangement is
    begin
        if g_inactive_records.count > 0 then
            forall i in values of g_inactive_records
                delete from mcw_acq_arrangement
                where
                    acq_bin = g_bin(i)
                    and arrangement_type = g_arrangement_type(i)
                    and arrangement_code = g_arrangement_code(i)
                    and brand = g_brand(i);
        end if;

        if g_active_records.count > 0 then
            forall i in values of g_active_records
                merge into
                    mcw_acq_arrangement dst
                using (
                    select
                        g_bin(i) acq_bin
                        , g_arrangement_type(i) arrangement_type
                        , g_arrangement_code(i) arrangement_code
                        , g_brand(i) brand
                        , g_priority(i) priority
                    from dual
                ) src
                on (
                    src.acq_bin = dst.acq_bin
                    and src.arrangement_type = dst.arrangement_type
                    and src.arrangement_code = dst.arrangement_code
                    and src.brand = dst.brand
                )
                when matched then
                    update
                    set
                        dst.priority = src.priority
                when not matched then
                    insert (
                        dst.acq_bin
                        , dst.arrangement_type
                        , dst.arrangement_code
                        , dst.brand
                        , dst.priority
                    ) values (
                        src.acq_bin
                        , src.arrangement_type
                        , src.arrangement_code
                        , src.brand
                        , src.priority
                    );
        end if;
    end;

    procedure collect_acq_arrangement (
        i_active                    in com_api_type_pkg.t_dict_value
        , i_bin                     in com_api_type_pkg.t_card_number
        , i_type                    in com_api_type_pkg.t_curr_code
        , i_code                    in com_api_type_pkg.t_dict_value
        , i_brand                   in com_api_type_pkg.t_curr_code
        , i_priority                in com_api_type_pkg.t_tiny_id
    ) is
        i                           binary_integer;
    begin
        i := g_bin.count + 1;

        g_bin(i) := i_bin;
        g_arrangement_type(i) := i_type;
        g_arrangement_code(i) := i_code;
        g_brand(i) := i_brand;
        g_priority(i) := i_priority;

        if i_active = ACTIVE then
            g_active_records(g_active_records.count + 1) := i;
        else
            g_inactive_records(g_inactive_records.count + 1) := i;
        end if;

        if i >= BULK_LIMIT then
            apply_acq_arrangement;
            clear_global_data;
        end if;
    end;

    procedure expand_acq_arrangement is
    begin
        merge into
            mcw_acq_arrangement dst
        using (
            select
                b.acq_bin acq_bin
                , a.priority priority
                , a.arrangement_type arrangement_type
                , a.arrangement_code arrangement_code
                , a.brand brand
            from
                mcw_acq_bin b
                , mcw_def_arrangement_tmp a
            where
                b.region = a.acq_region
                and b.brand = a.brand
                and a.arrangement_type = mcw_api_const_pkg.ARRANGEMENT_TYPE_INTERREGIONAL
            union all
            select
                b.acq_bin acq_bin
                , a.priority priority
                , a.arrangement_type arrangement_type
                , a.arrangement_code arrangement_code
                , a.brand brand
            from
                mcw_acq_bin b
                , mcw_def_arrangement_tmp a
            where
                b.region = a.region
                and b.brand = a.brand
                and a.arrangement_type = mcw_api_const_pkg.ARRANGEMENT_TYPE_REGIONAL
        ) src
        on (
            src.acq_bin = dst.acq_bin
            and src.arrangement_type = dst.arrangement_type
            and src.arrangement_code = dst.arrangement_code
            and src.brand = dst.brand
        )
        when matched then
            update
            set
                dst.priority = src.priority
        when not matched then
            insert (
                dst.acq_bin
                , dst.arrangement_type
                , dst.arrangement_code
                , dst.brand
                , dst.priority
            ) values (
                src.acq_bin
                , src.arrangement_type
                , src.arrangement_code
                , src.brand
                , src.priority
            );
    end;

    procedure apply_product_ird is
    begin
        if g_inactive_records.count > 0 then
            forall i in values of g_inactive_records
                delete from mcw_product_ird
                where
                    arrangement_type = g_arrangement_type(i)
                    and arrangement_code = g_arrangement_code(i)
                    and brand = g_brand(i)
                    and product_id = g_product_id(i)
                    and ird = g_ird(i);
        end if;

        if g_active_records.count > 0 then
            forall i in values of g_active_records
                merge into
                    mcw_product_ird dst
                using (
                    select
                        g_arrangement_type(i) arrangement_type
                        , g_arrangement_code(i) arrangement_code
                        , g_brand(i) brand
                        , g_product_id(i) product_id
                        , g_ird(i) ird
                    from dual
                ) src
                on (
                    src.arrangement_type = dst.arrangement_type
                    and src.arrangement_code = dst.arrangement_code
                    and src.brand = dst.brand
                    and src.product_id = dst.product_id
                    and src.ird = dst.ird
                )
                when not matched then
                    insert (
                        dst.arrangement_code
                        , dst.arrangement_type
                        , dst.product_id
                        , dst.brand
                        , dst.ird
                    ) values (
                        src.arrangement_code
                        , src.arrangement_type
                        , src.product_id
                        , src.brand
                        , src.ird
                    );
        end if;
    end;

    procedure collect_product_ird (
        i_active                    in com_api_type_pkg.t_dict_value
        , i_type                    in com_api_type_pkg.t_curr_code
        , i_code                    in com_api_type_pkg.t_dict_value
        , i_brand                   in com_api_type_pkg.t_curr_code
        , i_product_id              in com_api_type_pkg.t_curr_code
        , i_ird                     in com_api_type_pkg.t_curr_code
    ) is
        i                           binary_integer;
    begin
--        if i_ird is not null then
        i := g_arrangement_code.count + 1;

        g_arrangement_type(i) := i_type;
        g_arrangement_code(i) := i_code;
        g_brand(i) := i_brand;
        g_product_id(i) := i_product_id;
        g_ird(i) := nvl(i_ird, '%');

        if i_active = ACTIVE then
            g_active_records(g_active_records.count + 1) := i;
        else
            g_inactive_records(g_inactive_records.count + 1) := i;
        end if;

        if i >= BULK_LIMIT then
            apply_product_ird;
            clear_global_data;
        end if;
--        end if;
    end;

    procedure apply_proc_code_ird is
    begin
        if g_inactive_records.count > 0 then
            forall i in values of g_inactive_records
                delete from mcw_proc_code_ird
                where
                    arrangement_type = g_arrangement_type(i)
                    and arrangement_code = g_arrangement_code(i)
                    and mti = g_mti(i)
                    and de024 = g_de024(i)
                    and de003_1 = g_de003(i)
                    and brand = g_brand(i)
                    and ird = g_ird(i);
        end if;

        if g_active_records.count > 0 then
            forall i in values of g_active_records
                merge into
                    mcw_proc_code_ird dst
                using (
                    select
                        g_arrangement_type(i) arrangement_type
                        , g_arrangement_code(i) arrangement_code
                        , g_mti(i) mti
                        , g_de024(i) de024
                        , g_de003(i) de003_1
                        , g_brand(i) brand
                        , g_ird(i) ird
                        , g_paypass_ind(i) paypass_ind
                    from dual
                ) src
                on (
                    src.arrangement_type = dst.arrangement_type
                    and src.arrangement_code = dst.arrangement_code
                    and src.brand = dst.brand
                    and src.mti = dst.mti
                    and src.de024 = dst.de024
                    and src.de003_1 = dst.de003_1
                    and src.ird = dst.ird
                    --and src.paypass_ind= dst.paypass_ind
                )
                when not matched then
                    insert (
                        dst.arrangement_code
                        , dst.arrangement_type
                        , dst.mti
                        , dst.de024
                        , dst.de003_1
                        , dst.brand
                        , dst.ird
                        , dst.paypass_ind
                    ) values (
                        src.arrangement_code
                        , src.arrangement_type
                        , src.mti
                        , src.de024
                        , src.de003_1
                        , src.brand
                        , src.ird
                        , src.paypass_ind
                    );
        end if;
    end;

    procedure collect_proc_code_ird (
        i_active                    in com_api_type_pkg.t_dict_value
        , i_type                    in com_api_type_pkg.t_curr_code
        , i_code                    in com_api_type_pkg.t_dict_value
        , i_brand                   in com_api_type_pkg.t_curr_code
        , i_mti                     in com_api_type_pkg.t_dict_value
        , i_de024                   in com_api_type_pkg.t_dict_value
        , i_de003_1                 in com_api_type_pkg.t_dict_value
        , i_ird                     in com_api_type_pkg.t_curr_code
        , i_paypass_ind             in com_api_type_pkg.t_dict_value
    ) is
        i                           binary_integer := -1;
    begin
        if (
            i_mti = '1240'
            and i_de024 = '200'
        ) then
            i := g_arrangement_code.count + 1;

            g_arrangement_type(i) := i_type;
            g_arrangement_code(i) := i_code;
            g_brand(i) := i_brand;
            g_mti(i) := i_mti;
            g_de024(i) := i_de024;
            g_de003(i) := i_de003_1;
            g_ird(i) := nvl(i_ird, '%');
            g_paypass_ind(i) := i_paypass_ind;

            if i_active = ACTIVE then
                g_active_records(g_active_records.count + 1) := i;
            else
                g_inactive_records(g_inactive_records.count + 1) := i;
            end if;

            if i >= BULK_LIMIT then
                apply_proc_code_ird;
                clear_global_data;
            end if;
        end if;
    end;
    
    procedure apply_cab_program_ird is
    begin
        if g_inactive_records.count > 0 then
            forall i in values of g_inactive_records
                delete from mcw_cab_program_ird
                where
                    arrangement_type = g_arrangement_type(i)
                    and arrangement_code = g_arrangement_code(i)
                    and brand = g_brand(i)
                    and cab_program = g_cab_program(i)
                    and ird = g_ird(i);
        end if;

        if g_active_records.count > 0 then
            forall i in values of g_active_records
                merge into
                    mcw_cab_program_ird dst
                using (
                    select
                        g_arrangement_type(i) arrangement_type
                        , g_arrangement_code(i) arrangement_code
                        , g_brand(i) brand
                        , g_cab_program(i) cab_program
                        , g_ird(i) ird
                    from dual
                ) src
                on (
                    src.arrangement_type = dst.arrangement_type
                    and src.arrangement_code = dst.arrangement_code
                    and src.brand = dst.brand
                    and src.cab_program = dst.cab_program
                    and src.ird = dst.ird
                )
                when not matched then
                    insert (
                        dst.arrangement_code
                        , dst.arrangement_type
                        , dst.cab_program
                        , dst.brand
                        , dst.ird
                    ) values (
                        src.arrangement_code
                        , src.arrangement_type
                        , src.cab_program
                        , src.brand
                        , src.ird
                    );
        end if;
    end;

    procedure collect_cab_prorgam_ird (
        i_active                    in com_api_type_pkg.t_dict_value
        , i_type                    in com_api_type_pkg.t_curr_code
        , i_code                    in com_api_type_pkg.t_dict_value
        , i_brand                   in com_api_type_pkg.t_curr_code
        , i_cab_program             in com_api_type_pkg.t_mcc
        , i_ird                     in com_api_type_pkg.t_curr_code
    ) is
        i                           binary_integer;
    begin
--        if i_ird is not null then
        i := g_arrangement_code.count + 1;

        g_arrangement_type(i) := i_type;
        g_arrangement_code(i) := i_code;
        g_brand(i) := i_brand;
        g_cab_program(i) := i_cab_program;
        g_ird(i) := nvl(i_ird, '%');

        if i_active = ACTIVE then
            g_active_records(g_active_records.count + 1) := i;
        else
            g_inactive_records(g_inactive_records.count + 1) := i;
        end if;

        if i >= BULK_LIMIT then
            apply_cab_program_ird;
            clear_global_data;
        end if;
--        end if;
    end;

    procedure apply_brand_product is
    begin
        if g_inactive_records.count > 0 then
            forall i in values of g_inactive_records
               delete from mcw_brand_product
                where licensed_product_id    = g_licensed_product_id(i) 
                  and gcms_product_id        = g_gcms_product_id(i)
                  and card_program_id        = g_card_program_id(i)
                  and product_class          = g_product_class(i)
                  and product_type_id        = g_product_type_id(i)
                  and product_category       = g_product_category(i)
                  and product_category_code  = g_product_category_code(i)
                  and comm_product_indicator = g_comm_product_indicator(i);
        end if;

        if g_active_records.count > 0 then
            forall i in values of g_active_records
                merge into
                    mcw_brand_product dst
                using (
                    select
                        g_licensed_product_id(i) licensed_product_id
                        , g_gcms_product_id(i) gcms_product_id
                        , g_card_program_id(i) card_program_id
                        , g_product_class(i) product_class
                        , g_product_type_id(i) product_type_id
                        , g_product_category(i) product_category
                        , g_product_category_code(i) product_category_code
                        , g_comm_product_indicator(i) comm_product_indicator
                    from dual
                ) src
                on (
                    src.licensed_product_id        = dst.licensed_product_id
                    and src.gcms_product_id        = dst.gcms_product_id
                    and src.card_program_id        = dst.card_program_id
                    --and src.product_class          = dst.product_class
                    --and src.product_type_id        = dst.product_type_id
                    --and src.product_category       = dst.product_category
                    --and src.product_category_code  = dst.product_category_code
                    --and src.comm_product_indicator = dst.comm_product_indicator
                )
                when matched then
                    update
                    set dst.product_class            = src.product_class
                        , dst.product_type_id        = src.product_type_id
                        , dst.product_category       = src.product_category
                        , dst.product_category_code  = src.product_category_code
                        , dst.comm_product_indicator = src.comm_product_indicator
                                                
                when not matched then
                    insert (
                        dst.licensed_product_id
                        , dst.gcms_product_id
                        , dst.card_program_id
                        , dst.product_class
                        , dst.product_type_id
                        , dst.product_category
                        , dst.product_category_code
                        , dst.comm_product_indicator
                    ) values (
                        src.licensed_product_id
                        , src.gcms_product_id
                        , src.card_program_id
                        , src.product_class
                        , src.product_type_id
                        , src.product_category
                        , src.product_category_code
                        , src.comm_product_indicator
                    );
        end if;
    end;

    procedure collect_brand_product (
        i_active                    in com_api_type_pkg.t_dict_value
        , i_licensed_product_id     in com_api_type_pkg.t_curr_code
        , i_gcms_product_id         in com_api_type_pkg.t_curr_code
        , i_card_program_id         in com_api_type_pkg.t_curr_code
        , i_product_class           in com_api_type_pkg.t_curr_code
        , i_product_type_id         in com_api_type_pkg.t_curr_code
        , i_product_category        in com_api_type_pkg.t_curr_code
        , i_product_category_code   in com_api_type_pkg.t_curr_code
        , i_comm_product_indicator  in com_api_type_pkg.t_curr_code
    ) is
        i                           binary_integer;
    begin
        i := g_licensed_product_id.count + 1;

        g_licensed_product_id(i)    := i_licensed_product_id;
        g_gcms_product_id(i)        := i_gcms_product_id;
        g_card_program_id(i)        := i_card_program_id;
        g_product_class(i)          := i_product_class;
        g_product_type_id(i)        := i_product_type_id;
        g_product_category(i)       := i_product_category;
        g_product_category_code(i)  := i_product_category_code;
        g_comm_product_indicator(i) := i_comm_product_indicator;

        if i_active = ACTIVE then
            g_active_records(g_active_records.count + 1) := i;
        else
            g_inactive_records(g_inactive_records.count + 1) := i;
        end if;
    end;

    procedure apply_collected_data (
        i_table_name                in com_api_type_pkg.t_oracle_name
        , i_load_temp_tab           in boolean
        , i_load_main_tab           in boolean
    ) is
    begin
        if i_table_name = mcw_api_const_pkg.TABLE_DE then
            apply_de_data;

        elsif i_table_name = mcw_api_const_pkg.TABLE_PDS then
            apply_PDS_data;

        elsif i_table_name = mcw_api_const_pkg.TABLE_ERROR_CODE then
            apply_error_codes;

        elsif i_table_name = mcw_api_const_pkg.TABLE_CURRENCY then
            apply_currency_data;

        elsif i_table_name = mcw_api_const_pkg.TABLE_COUNTRY then
            apply_country_data;

        elsif i_table_name = mcw_api_const_pkg.TABLE_DEF_ARRANGEMENT then
            apply_def_arrangement;

        elsif i_table_name = mcw_api_const_pkg.TABLE_ACCOUNT then
            apply_bin_range (
                i_load_temp_tab   => i_load_temp_tab
                , i_load_main_tab => i_load_main_tab
            );
        elsif i_table_name = mcw_api_const_pkg.TABLE_BIN then
            apply_acq_bin (
                i_load_temp_tab   => i_load_temp_tab
                , i_load_main_tab => i_load_main_tab
            );

        elsif i_table_name = mcw_api_const_pkg.TABLE_MEMBER_INFO then
            apply_member_info;

        elsif i_table_name = mcw_api_const_pkg.TABLE_MCC then
            apply_mcc_data;

        elsif i_table_name = mcw_api_const_pkg.TABLE_ISS_ARRANGEMENT then
            apply_iss_arrangement;

        elsif i_table_name = mcw_api_const_pkg.TABLE_ACQ_ARRANGEMENT then
            apply_acq_arrangement;

        elsif i_table_name = mcw_api_const_pkg.TABLE_PRODUCT_IRD then
            apply_product_ird;

        elsif i_table_name = mcw_api_const_pkg.TABLE_PROC_CODE_IRD then
            apply_proc_code_ird;

        elsif i_table_name = mcw_api_const_pkg.TABLE_CAB_PROGRAM_IRD then
            apply_cab_program_ird;

        elsif i_table_name = mcw_api_const_pkg.TABLE_BRAND_PRODUCT then
            apply_brand_product;
        end if;

        clear_global_data;
    end;

    procedure update_net_bin_range (
        i_iss_network_id            in com_api_type_pkg.t_tiny_id
        , i_iss_inst_id             in com_api_type_pkg.t_inst_id
        , i_card_network_id         in com_api_type_pkg.t_tiny_id
        , i_card_inst_id            in com_api_type_pkg.t_inst_id
        , i_standard_id             in com_api_type_pkg.t_tiny_id
    ) is
        l_net_bin_range_tab         net_api_type_pkg.t_net_bin_range_tab;
    begin
        -- Fetch all new records with net BIN range into collection and check them
        select
            r.pan_low
            , r.pan_high
            , length(r.pan_low)
            , min(m.priority)
            , min(m.card_type_id) keep (dense_rank first order by m.priority)
            , min(r.country)
            , i_iss_network_id
            , i_iss_inst_id
            , i_card_network_id
            , i_card_inst_id
            , mcw_api_const_pkg.MODULE_CODE_MASTERCARD
            , null -- activation_date
            , null
        bulk collect into
            l_net_bin_range_tab
        from
            mcw_bin_range r
            , net_card_type_map m
        where
            m.standard_id = i_standard_id
            and r.brand || r.product_id like m.network_card_type
            and r.country like nvl(m.country, '%')
        group by
            r.pan_low
            , r.pan_high;

        -- If check is not passed then appropriate error exception will be raised
        net_api_bin_pkg.check_bin_range(
            i_bin_range_tab => l_net_bin_range_tab
        );

        -- Otherwise, net BIN ranges is updated normally 
        delete from
            net_bin_range
        where
            iss_network_id = i_card_network_id
            and iss_inst_id = i_card_inst_id
            and module_code = mcw_api_const_pkg.MODULE_CODE_MASTERCARD;

        forall i in l_net_bin_range_tab.first .. l_net_bin_range_tab.last
            insert into net_bin_range (
                pan_low
                , pan_high
                , pan_length
                , priority
                , card_type_id
                , country
                , iss_network_id
                , iss_inst_id
                , card_network_id
                , card_inst_id
                , module_code
                , activation_date
                , account_currency
            ) values (
                l_net_bin_range_tab(i).pan_low
                , l_net_bin_range_tab(i).pan_high
                , l_net_bin_range_tab(i).pan_length
                , l_net_bin_range_tab(i).priority
                , l_net_bin_range_tab(i).card_type_id
                , l_net_bin_range_tab(i).country
                , l_net_bin_range_tab(i).iss_network_id
                , l_net_bin_range_tab(i).iss_inst_id
                , l_net_bin_range_tab(i).card_network_id
                , l_net_bin_range_tab(i).card_inst_id
                , l_net_bin_range_tab(i).module_code
                , l_net_bin_range_tab(i).activation_date
                , l_net_bin_range_tab(i).account_currency
            );

        for r in (
            select
                  r.brand 
                , r.product_id
                , r.pan_low
                , r.pan_high
            from
                mcw_bin_range r
            where not exists (select null from net_card_type_map m where r.brand || r.product_id like m.network_card_type and m.standard_id = i_standard_id)
              and r.brand != 'VIS'
        ) loop
            trc_log_pkg.error(
                i_text          => 'IMPOSSIBLE_DEFINE_CARD_TYPE'
              , i_env_param1    => i_card_network_id
              , i_env_param2    => r.brand || r.product_id
              , i_env_param3    => r.pan_low
            );
        end loop;

        net_api_bin_pkg.rebuild_bin_index;

    end update_net_bin_range;

    procedure load (
        i_network_id      in com_api_type_pkg.t_tiny_id
      , i_inst_id         in com_api_type_pkg.t_inst_id
      , i_card_network_id in com_api_type_pkg.t_tiny_id
      , i_card_inst_id    in com_api_type_pkg.t_inst_id
      , i_table           in com_api_type_pkg.t_oracle_name
      , i_expansion       in com_api_type_pkg.t_boolean
      , i_record_format   in com_api_type_pkg.t_dict_value
    ) is
        l_table                 com_api_type_pkg.t_oracle_name;

        l_recnum_tab            com_api_type_pkg.t_number_tab;
        l_data_tab              com_api_type_pkg.t_varchar2_tab;
        l_data_count            binary_integer;

        l_file_type             varchar2(4);
        INC                     varchar2(4) := 'INC';
        FULL                    varchar2(4) := 'FULL';

        l_total_count           number;
        l_table_count           number;

        l_recnum                number := 0;
        l_table_recnum          number := 0;

        l_table_name            com_api_type_pkg.t_oracle_name;
        l_prev_table_name       com_api_type_pkg.t_oracle_name;
        l_table_names           com_api_type_pkg.t_oracle_name_tab;
        
        l_estimated_count       com_api_type_pkg.t_long_id := 0;
        l_excepted_count        com_api_type_pkg.t_long_id := 0;
        l_processed_count       com_api_type_pkg.t_long_id := 0;
        
        l_session_file_id       com_api_type_pkg.t_long_id;
        l_session_files         com_api_type_pkg.t_number_tab;

        l_need_expansion        com_api_type_pkg.t_boolean;
        l_load_temp_tab         boolean;
        l_load_main_tab         boolean;

        l_iss_inst_id           com_api_type_pkg.t_inst_id := i_inst_id;
        l_card_inst_id          com_api_type_pkg.t_inst_id := i_card_inst_id;
        l_card_network_id       com_api_type_pkg.t_inst_id := i_card_network_id;
        l_iss_network_id        com_api_type_pkg.t_tiny_id := i_network_id;
        l_standard_id           com_api_type_pkg.t_tiny_id;
        l_curr_standard_version com_api_type_pkg.t_tiny_id;
        l_stage                 number;
        
        function convert_table_name return com_api_type_pkg.t_dict_value is
        begin
            if nvl(i_table, mcw_api_const_pkg.TABLE_KEY || mcw_api_const_pkg.TABLE_FULL) in (mcw_api_const_pkg.TABLE_KEY || mcw_api_const_pkg.TABLE_FULL) then
                return mcw_api_const_pkg.TABLE_FULL;
            end if;
            return i_table;
        end;

    begin
        savepoint mpe_start_load;
        
        l_table := convert_table_name;
        
        l_stage := -9;
        
        trc_log_pkg.debug (
            i_text          => 'starting loading MPE file'
        );
        
        prc_api_stat_pkg.log_start;
        
        trc_log_pkg.debug (
            i_text          => 'estimate records'
        );
        -- estimate records for load
        select count(1)
          into l_estimated_count
          from prc_session_file s
             , prc_file_attribute a
             , prc_file f
             , prc_file_raw_data d
         where a.id              = s.file_attr_id
           and f.id              = a.file_id
           and f.file_purpose    = prc_api_file_pkg.get_file_purpose_in
           and s.session_id      = get_session_id
           and d.session_file_id = s.id;

        prc_api_stat_pkg.log_estimation (
            i_estimated_count => l_estimated_count
        );
        
        trc_log_pkg.debug (
            i_text         => 'Estimate records for load [#1]'
            , i_env_param1 => l_estimated_count
        );
        
        if l_card_inst_id is null then
            l_card_inst_id := net_api_network_pkg.get_inst_id(l_card_network_id);
        end if;
        if l_iss_network_id is null then
            l_iss_network_id := l_card_network_id;
        end if;
        if l_iss_inst_id is null then
            l_iss_inst_id := net_api_network_pkg.get_inst_id(l_iss_network_id);
        end if;
        l_standard_id := net_api_network_pkg.get_offline_standard(i_network_id => l_card_network_id);
        
        l_need_expansion := nvl(i_expansion, com_api_type_pkg.TRUE);
                
        select id
          bulk collect into l_session_files
          from prc_session_file
         where session_id = get_session_id
      order by id;
            
        for i in 1..l_session_files.count loop
            
            l_session_file_id := l_session_files(i);
            
            l_file_type       := null;
            l_total_count     := 0;
            l_table_count     := 0;
            l_recnum          := 0;
            l_table_recnum    := 0;
            l_prev_table_name := null;
            l_load_main_tab   := false;
            l_load_temp_tab   := false;
            
            clear_bin_range_crossed;
            
            open data_cur (
                i_session_file_id  => l_session_file_id
            );

            l_stage := -8;
            loop
                fetch data_cur bulk collect into l_recnum_tab, l_data_tab limit BULK_LIMIT;

                l_data_count := l_data_tab.count;

                l_stage := -7;
                for i in 1 .. l_data_count loop

                    l_recnum := l_recnum + 1;

                    if substr(l_data_tab(i), 1, 11) = 'UPDATE FILE' then -- header of update file
                        l_file_type := INC;

                    elsif substr(l_data_tab(i), 1, 16) = 'REPLACEMENT FILE' then -- header of full replacement file
                        l_file_type := FULL;

                    elsif l_file_type is null then -- no previous header found
                        com_api_error_pkg.raise_error(
                            i_error         => 'MPE_INVALID_HEADER'
                          , i_env_param1    => l_recnum_tab(i)
                          , i_env_param2    => l_data_tab(i)
                        );

                    elsif substr(l_data_tab(i), 1, 21) = 'TRAILER RCD  ZZZZZZZZ' then -- file trailer
                        l_total_count := to_number(substr(l_data_tab(i), 23, 8));

                        if (
                            l_total_count = l_recnum_tab(i)
                            and l_total_count = l_recnum
                            and l_prev_table_name is null
                        ) then
                            null;
                        else
                            com_api_error_pkg.raise_error(
                                i_error         => 'MPE_WRONG_TOTAL'
                              , i_env_param1    => l_recnum_tab(i)
                              , i_env_param2    => l_recnum
                              , i_env_param3    => l_total_count
                              , i_env_param4    => l_data_tab(i)
                            );
                        end if;

                        l_processed_count := l_processed_count + 1;
                        exit;

                    elsif substr(l_data_tab(i), 1, 24) = 'TRAILER RECORD TABLEZZZZ' then -- file trailer
                        l_total_count := to_number(substr(l_data_tab(i),26,8));

                        if (
                            l_total_count = l_recnum_tab(i)
                            and l_total_count = l_recnum
                            and l_prev_table_name is null
                        ) then
                            null;
                        else
                            com_api_error_pkg.raise_error(
                                i_error         => 'MPE_WRONG_TOTAL'
                              , i_env_param1    => l_recnum_tab(i)
                              , i_env_param2    => l_recnum
                              , i_env_param3    => l_total_count
                              , i_env_param4    => l_data_tab(i)
                            );
                        end if;

                        l_processed_count := l_processed_count + 1;
                        exit;

                    elsif (
                        substr(l_data_tab(i), 1, 15) = 'TRAILER RECORD '
                        or substr(l_data_tab(i), 1, 13) = 'TRAILER RCD  '
                    ) then  -- intermediate table trailer

                        l_stage := 1001;

                        if substr(l_data_tab(i), 1, 13) = 'TRAILER RCD  ' then
                            l_table_name := substr(l_data_tab(i), 13, 8);
                            l_table_count := to_number(substr(l_data_tab(i), 23, 8));
                        else
                            l_table_name := substr(l_data_tab(i), 16, 8);
                            l_table_count := to_number(substr(l_data_tab(i), 26, 8));
                        end if;

                        if l_table_recnum = l_table_count and l_prev_table_name = l_table_name then

                            apply_collected_data (
                                i_table_name        => l_prev_table_name
                                , i_load_main_tab   => l_load_main_tab
                                , i_load_temp_tab   => l_load_temp_tab
                            );

                            if l_table_name = mcw_api_const_pkg.TABLE_ACCOUNT then
                                delete_crossed_ranges;
                                update_net_bin_range (
                                    i_iss_network_id     => l_iss_network_id
                                    , i_iss_inst_id      => l_iss_inst_id
                                    , i_card_network_id  => l_card_network_id
                                    , i_card_inst_id     => l_card_inst_id
                                    , i_standard_id      => l_standard_id
                                );
                            end if;

                            if l_table_name = mcw_api_const_pkg.TABLE_ISS_ARRANGEMENT and l_need_expansion = com_api_type_pkg.TRUE then
                                expand_iss_arrangement;
                            end if;

                            if l_table_name = mcw_api_const_pkg.TABLE_ACQ_ARRANGEMENT and l_need_expansion = com_api_type_pkg.TRUE then
                                expand_acq_arrangement;
                            end if;

                            l_table_recnum := 0;
                            l_prev_table_name := null;
                            l_load_main_tab := false;
                            l_load_temp_tab := false;

                            clear_global_data;

                        else
                            com_api_error_pkg.raise_error(
                                i_error         => 'MPE_WRONG_TABLE_TRAILER'
                              , i_env_param1    => l_recnum_tab(i)
                              , i_env_param2    => l_table_recnum
                              , i_env_param3    => l_table_count
                              , i_env_param4    => l_prev_table_name
                              , i_env_param5    => l_table_name
                              , i_env_param6    => l_data_tab(i)
                            );
                        end if;

                    else
                        l_stage := 1;

                        l_table_name  := substr(l_data_tab(i), 12, 8);

                        if l_table_name = mcw_api_const_pkg.TABLE_KEYS then
                            l_stage := 2;
                            l_table_names(substr(l_data_tab(i), 244, 3)) := substr(l_data_tab(i), 20, 8);

                        else
                            if l_need_expansion = com_api_type_pkg.TRUE then
                                l_stage := 3;
                                l_table_name := l_table_names(substr(l_data_tab(i), 9, 3));

                                l_stage := 4;
                                if l_table_name is not null then
                                    l_data_tab(i) := (
                                        'YYYYMMDDHH' -- to_char(to_date(substr(l_data_tab(i), 1, 7), 'YYDDDHH24'), 'YYYYMMDDHH24')
                                        || substr(l_data_tab(i), 8, 1)
                                        || l_table_name
                                        || substr(l_data_tab(i), 12)
                                    );
                                end if;
                            end if;
                        end if;

                        l_stage := 5;
                        if l_prev_table_name = l_table_name then
                            l_table_recnum := l_table_recnum + 1;
                        else
                            if l_prev_table_name is null then
                                l_table_recnum := 1;
                                l_prev_table_name := l_table_name;
                            else
                                com_api_error_pkg.raise_error(
                                    i_error         => 'MPE_WRONG_TABLE_SEQUENCE'
                                  , i_env_param1    => l_table_name
                                  , i_env_param2    => l_prev_table_name
                                  , i_env_param3    => l_recnum_tab(i)
                                  , i_env_param4    => l_data_tab(i)
                                );
                            end if;
                        end if;

                        if (
                            (l_table_name = l_table or l_table = mcw_api_const_pkg.TABLE_FULL)

                            or ( -- TABLE_ACCOUNT will be used to expand TABLE_ISS_ARRANGEMENT
                                l_table = mcw_api_const_pkg.TABLE_ISS_ARRANGEMENT
                                and l_table_name = mcw_api_const_pkg.TABLE_ACCOUNT
                                and l_need_expansion = com_api_type_pkg.TRUE
                            )

                            or ( -- TABLE_BIN will be used to expand TABLE_ACQ_ARRANGEMENT
                                l_table = mcw_api_const_pkg.TABLE_ACQ_ARRANGEMENT
                                and l_table_name = mcw_api_const_pkg.TABLE_BIN
                                and l_need_expansion = com_api_type_pkg.TRUE
                            )

                            or ( -- TABLE_DEF_ARRANGEMENT will be used to expand TABLE_ISS_ARRANGEMENT and TABLE_ACQ_ARRANGEMENT
                                l_table in (mcw_api_const_pkg.TABLE_ISS_ARRANGEMENT, mcw_api_const_pkg.TABLE_ACQ_ARRANGEMENT)
                                and l_table_name = mcw_api_const_pkg.TABLE_DEF_ARRANGEMENT
                                and l_need_expansion = com_api_type_pkg.TRUE
                            )

                        ) then

                            if l_table_name = mcw_api_const_pkg.TABLE_DE then

                                l_stage := 6;

                                if l_table_recnum = 1 and l_file_type = FULL then
                                    delete from mcw_de;
                                end if;

                                collect_de_data (
                                    i_active                => trim(substr(l_data_tab(i), 11, 1))
                                    , i_de_number           => trim(substr(l_data_tab(i), 23, 3))
                                    , i_name                => trim(substr(l_data_tab(i), 26, 57))
                                    , i_format              => trim(substr(l_data_tab(i), 83, 3))
                                    , i_min_length          => trim(substr(l_data_tab(i), 86, 3))
                                    , i_max_length          => trim(substr(l_data_tab(i), 89, 3))
                                    , i_prefix_length       => trim(substr(l_data_tab(i), 95, 1))
                                    , i_subfield_count      => trim(substr(l_data_tab(i), 96, 2))
                                    , i_program             => trim(substr(l_data_tab(i), 20, 3))
                                );

                            elsif l_table_name = mcw_api_const_pkg.TABLE_PDS then

                                l_stage := 7;

                                if l_table_recnum = 1 and l_file_type = FULL then
                                    delete from mcw_pds;
                                end if;

                                collect_pds_data (
                                    i_active              => trim(substr(l_data_tab(i), 11, 1))
                                  , i_pds_number          => trim(substr(l_data_tab(i), 20, 4))
                                  , i_name                => trim(substr(l_data_tab(i), 24, 57))
                                  , i_format              => trim(substr(l_data_tab(i), 81, 3))
                                  , i_min_length          => trim(substr(l_data_tab(i), 84, 3))
                                  , i_max_length          => trim(substr(l_data_tab(i), 87, 3))
                                  , i_subfield_count      => trim(substr(l_data_tab(i), 90, 2))
                                );

                            elsif l_table_name = mcw_api_const_pkg.TABLE_ERROR_CODE then

                                l_stage := 8;

                                if l_table_recnum = 1 and l_file_type = FULL then
                                    delete from mcw_error_code;
                                end if;

                                collect_error_code (
                                    i_active                => trim(substr(l_data_tab(i), 11, 1))
                                    , i_code                => trim(substr(l_data_tab(i), 20, 4))
                                    , i_text                => trim(substr(l_data_tab(i), 24, 255))
                                );

                            elsif l_table_name = mcw_api_const_pkg.TABLE_CURRENCY then

                                l_stage := 9;

                                collect_currency_data (
                                    i_active                => trim(substr(l_data_tab(i), 11, 1))
                                    , i_curr_code           => trim(substr(l_data_tab(i), 20, 3))
                                    , i_curr_name           => trim(substr(l_data_tab(i), 23, 3))
                                    , i_exponent            => trim(substr(l_data_tab(i), 26, 1))
                                );

                            elsif l_table_name = mcw_api_const_pkg.TABLE_COUNTRY then

                                l_stage := 10;

                                if l_table_recnum = 1 then
                                    g_prev_country_code := null;
                                end if;

                                collect_country_data (
                                    i_active                => trim(substr(l_data_tab(i), 11, 1))
                                    , i_code                => trim(substr(l_data_tab(i), 28, 3))
                                    , i_name                => trim(substr(l_data_tab(i), 20, 3))
                                    , i_curr_code           => trim(substr(l_data_tab(i), 31, 3))
                                    , i_region              => trim(substr(l_data_tab(i), 27, 1))
                                    , i_euro                => trim(substr(l_data_tab(i), 67, 1))
                                    , i_desc                => trim(substr(l_data_tab(i), 34, 30))
                                    , i_sepa                => trim(substr(l_data_tab(i), 87, 1))
                                );

                            elsif l_table_name = mcw_api_const_pkg.TABLE_DEF_ARRANGEMENT then

                                l_stage := 11;

                                if l_need_expansion = com_api_type_pkg.TRUE and l_table in (mcw_api_const_pkg.TABLE_ISS_ARRANGEMENT, mcw_api_const_pkg.TABLE_ACQ_ARRANGEMENT, mcw_api_const_pkg.TABLE_FULL) then
                                    if l_table_recnum = 1 then
                                        delete from mcw_def_arrangement_tmp;
                                    end if;

                                    collect_def_arrangement (
                                        i_active                => trim(substr(l_data_tab(i), 11, 1))
                                        , i_region              => trim(substr(l_data_tab(i), 20, 1))
                                        , i_acq_region          => trim(substr(l_data_tab(i), 21, 1))
                                        , i_iss_region          => trim(substr(l_data_tab(i), 22, 1))
                                        , i_brand               => trim(substr(l_data_tab(i), 23, 3))
                                        , i_priority            => trim(substr(l_data_tab(i), 26, 2))
                                        , i_arrangement_type    => trim(substr(l_data_tab(i), 28, 1))
                                        , i_arrangement_code    => trim(substr(l_data_tab(i), 29, 6))
                                    );
                                end if;

                            elsif l_table_name = mcw_api_const_pkg.TABLE_ACCOUNT then

                                l_stage := 14;

                                l_load_main_tab := l_table in (mcw_api_const_pkg.TABLE_ACCOUNT, mcw_api_const_pkg.TABLE_FULL);
                                l_load_temp_tab := l_need_expansion = com_api_type_pkg.TRUE and l_table in (mcw_api_const_pkg.TABLE_ISS_ARRANGEMENT
                                                                                             , mcw_api_const_pkg.TABLE_FULL);

                                if l_load_main_tab and l_table_recnum = 1 and l_file_type = FULL then
                                    delete from mcw_bin_range;
                                end if;

                                if l_table_recnum = 1 then
                                    delete from mcw_bin_range_tmp;
                                end if;
                                
                                if l_load_main_tab and l_file_type = INC then
                                    collect_bin_range_crossed(
                                        i_active              => trim(substr(l_data_tab(i), 11, 1))
                                      , i_pan_low             => trim(substr(l_data_tab(i), 20, 19))
                                      , i_pan_high            => trim(substr(l_data_tab(i), 42, 19))
                                    );
                                end if;
                                -- Specific processing depending on current standard version
                                l_curr_standard_version := cmn_api_standard_pkg.get_current_version(
                                    i_network_id  => i_card_network_id
                                );

                                collect_bin_range (
                                    i_active              => trim(substr(l_data_tab(i), 11, 1))
                                  , i_pan_low             => trim(substr(l_data_tab(i), 20, 19))
                                  , i_pan_high            => trim(substr(l_data_tab(i), 42, 19))
                                  , i_product_id          => trim(substr(l_data_tab(i), 39, 3))
                                  , i_brand               => trim(substr(l_data_tab(i), 61, 3))
                                  , i_priority            => trim(substr(l_data_tab(i), 64, 2))
                                  , i_member_id           => trim(substr(l_data_tab(i), 66, 11))
                                  , i_product_type        => trim(substr(l_data_tab(i), 77, 1))
                                  , i_country             => trim(substr(l_data_tab(i), 88, 3))
                                  , i_region              => trim(substr(l_data_tab(i), 91, 1))
                                  , i_paypass_ind         => trim(substr(l_data_tab(i), 160, 1))
                                  , i_non_reloadable_ind  => trim(substr(l_data_tab(i), 174, 2))
                                  , i_load_main_tab       => l_load_main_tab
                                  , i_load_temp_tab       => l_load_temp_tab
                                );

                            elsif l_table_name = mcw_api_const_pkg.TABLE_BIN then

                                l_stage := 15;

                                l_load_main_tab := l_table in (mcw_api_const_pkg.TABLE_BIN, mcw_api_const_pkg.TABLE_FULL);
                                l_load_temp_tab := l_need_expansion = com_api_type_pkg.TRUE and l_table in (mcw_api_const_pkg.TABLE_ACQ_ARRANGEMENT
                                                                                             , mcw_api_const_pkg.TABLE_FULL);

                                if l_load_main_tab and l_table_recnum = 1 and l_file_type = FULL then
                                    delete from mcw_acq_bin;
                                end if;

                                if l_table_recnum = 1 then
                                    delete from mcw_acq_bin_tmp;
                                end if;

                                collect_acq_bin (
                                    i_active                => trim(substr(l_data_tab(i), 11, 1))
                                    , i_bin                 => trim(substr(l_data_tab(i), 20, 6))
                                    , i_brand               => trim(substr(l_data_tab(i), 26, 3))
                                    , i_member_id           => trim(substr(l_data_tab(i), 29, 11))
                                    , i_region              => trim(substr(l_data_tab(i), 51, 6))
                                    , i_country             => trim(substr(l_data_tab(i), 57, 60))
                                    , i_load_main_tab       => l_load_main_tab
                                    , i_load_temp_tab       => l_load_temp_tab
                                );

                            elsif l_table_name = mcw_api_const_pkg.TABLE_MEMBER_INFO then

                                l_stage := 16;

                                if l_table_recnum = 1 and l_file_type = FULL then
                                    delete from mcw_member_info;
                                end if;

                                collect_member_info (
                                    i_active                => trim(substr(l_data_tab(i), 11, 1))
                                    , i_member_id           => trim(substr(l_data_tab(i), 20, 11))
                                    , i_region              => trim(substr(l_data_tab(i), 33, 1))
                                    , i_endpoint            => trim(substr(l_data_tab(i), 40, 7))
                                    , i_name                => trim(substr(l_data_tab(i), 54, 30))
                                    , i_country             => trim(substr(l_data_tab(i), 87, 3))
                                    , i_npc_ica             => trim(substr(l_data_tab(i), 114, 1))
                                );

                            elsif l_table_name = mcw_api_const_pkg.TABLE_MCC then

                                l_stage := 17;

                                if l_table_recnum = 1 then
                                    g_prev_mcc := null;
                                end if;

                                collect_mcc_data (
                                    i_active                => trim(substr(l_data_tab(i), 11, 1))
                                    , i_mcc                 => trim(substr(l_data_tab(i), 21, 4))
                                    , i_cab_program         => trim(substr(l_data_tab(i), 25, 4))
                                    , i_cab_type            => trim(substr(l_data_tab(i), 30, 1))
                                );

                            elsif l_table_name = mcw_api_const_pkg.TABLE_ISS_ARRANGEMENT then

                                l_stage := 18;

                                if l_table_recnum = 1 and l_file_type = FULL then
                                    delete from mcw_iss_arrangement;
                                end if;

                                collect_iss_arrangement (
                                    i_active                => trim(substr(l_data_tab(i), 11, 1))
                                    , i_pan_low             => trim(substr(l_data_tab(i), 20, 19))
                                    , i_pan_high            => trim(substr(l_data_tab(i), 49, 19))
                                    , i_type                => trim(substr(l_data_tab(i), 39, 1))
                                    , i_code                => trim(substr(l_data_tab(i), 40, 6))
                                    , i_brand               => trim(substr(l_data_tab(i), 46, 3))
                                    , i_type_priority       => trim(substr(l_data_tab(i), 68, 2))
                                    , i_brand_priority      => trim(substr(l_data_tab(i), 70, 2))
                                );

                            elsif l_table_name = mcw_api_const_pkg.TABLE_ACQ_ARRANGEMENT then

                                l_stage := 19;

                                if l_table_recnum = 1 and l_file_type = FULL then
                                    delete from mcw_acq_arrangement;
                                end if;

                                collect_acq_arrangement (
                                    i_active                => trim(substr(l_data_tab(i), 11, 1))
                                    , i_bin                 => trim(substr(l_data_tab(i), 20, 6))
                                    , i_type                => trim(substr(l_data_tab(i), 26, 1))
                                    , i_code                => trim(substr(l_data_tab(i), 27, 6))
                                    , i_brand               => trim(substr(l_data_tab(i), 33, 3))
                                    , i_priority            => trim(substr(l_data_tab(i), 36, 2))
                                );

                            elsif l_table_name = mcw_api_const_pkg.TABLE_PRODUCT_IRD then

                                l_stage := 20;

                                if l_table_recnum = 1 and l_file_type = FULL then
                                    delete from mcw_product_ird;
                                end if;

                                collect_product_ird (
                                    i_active                => trim(substr(l_data_tab(i), 11, 1))
                                    , i_type                => trim(substr(l_data_tab(i), 23, 1))
                                    , i_code                => trim(substr(l_data_tab(i), 24, 6))
                                    , i_brand               => trim(substr(l_data_tab(i), 20, 3))
                                    , i_product_id          => trim(substr(l_data_tab(i), 32, 3))
                                    , i_ird                 => trim(substr(l_data_tab(i), 30, 2))
                                );

                            elsif l_table_name = mcw_api_const_pkg.TABLE_PROC_CODE_IRD then

                                l_stage := 21;

                                if l_table_recnum = 1 and l_file_type = FULL then
                                    delete from mcw_proc_code_ird;
                                end if;

                                collect_proc_code_ird (
                                    i_active                => trim(substr(l_data_tab(i), 11, 1))
                                    , i_type                => trim(substr(l_data_tab(i), 23, 1))
                                    , i_code                => trim(substr(l_data_tab(i), 24, 6))
                                    , i_brand               => trim(substr(l_data_tab(i), 20, 3))
                                    , i_mti                 => trim(substr(l_data_tab(i), 32, 4))
                                    , i_de024               => trim(substr(l_data_tab(i), 36, 3))
                                    , i_de003_1             => trim(substr(l_data_tab(i), 39, 2))
                                    , i_ird                 => trim(substr(l_data_tab(i), 30, 2))
                                    , i_paypass_ind         => trim(substr(l_data_tab(i), 83, 1))
                                );
                            elsif l_table_name = mcw_api_const_pkg.TABLE_CAB_PROGRAM_IRD then
                                l_stage := 22;

                                if l_table_recnum = 1 and l_file_type = FULL then
                                    delete from mcw_cab_program_ird;
                                end if;

                                collect_cab_prorgam_ird (
                                    i_active                => trim(substr(l_data_tab(i), 11, 1))
                                    , i_type                => trim(substr(l_data_tab(i), 23, 1))
                                    , i_code                => trim(substr(l_data_tab(i), 24, 6))
                                    , i_brand               => trim(substr(l_data_tab(i), 20, 3))
                                    , i_cab_program         => trim(substr(l_data_tab(i), 32, 4))
                                    , i_ird                 => trim(substr(l_data_tab(i), 30, 2))
                                );
                                
                            elsif l_table_name = mcw_api_const_pkg.TABLE_BRAND_PRODUCT then    

                                l_stage := 23;
                            
                                if l_table_recnum = 1 and l_file_type = FULL then
                                    delete from mcw_brand_product;
                                end if;
                            
                                collect_brand_product (
                                    i_active                   => trim(substr(l_data_tab(i), 11, 1))
                                    , i_licensed_product_id    => trim(substr(l_data_tab(i), 20, 3))
                                    , i_gcms_product_id        => trim(substr(l_data_tab(i), 23, 3))
                                    , i_card_program_id        => trim(substr(l_data_tab(i), 26, 3))
                                    , i_product_class          => trim(substr(l_data_tab(i), 29, 3))
                                    , i_product_type_id        => trim(substr(l_data_tab(i), 32, 1))
                                    , i_product_category       => trim(substr(l_data_tab(i), 33, 1))
                                    , i_product_category_code  => trim(substr(l_data_tab(i), 34, 1))
                                    , i_comm_product_indicator => trim(substr(l_data_tab(i), 35, 1))
                                ); 
                                
                                trc_log_pkg.debug (
                                    i_text => 'collect_brand_product: ' ||
                                              'i_active = [' || trim(substr(l_data_tab(i), 11, 1)) || ']' || 
                                              ', i_licensed_product_id = [' || trim(substr(l_data_tab(i), 20, 3)) || ']' || 
                                              ', i_gcms_product_id = [' || trim(substr(l_data_tab(i), 23, 3)) || ']' || 
                                              ', i_card_program_id = [' || trim(substr(l_data_tab(i), 26, 3)) || ']' || 
                                              ', i_product_class = ['   || trim(substr(l_data_tab(i), 29, 3)) || ']' || 
                                              ', i_product_type_id = [' || trim(substr(l_data_tab(i), 32, 1)) || ']' || 
                                              ', i_product_category = ['|| trim(substr(l_data_tab(i), 33, 1)) || ']' || 
                                              ', i_product_category_code = ['  || trim(substr(l_data_tab(i), 34, 1)) || ']' || 
                                              ', i_comm_product_indicator = [' || trim(substr(l_data_tab(i), 35, 1)) || ']'  
                                );
                                                           
                            end if;
                        end if;

                        l_stage := 100;
                    end if;
                    
                    l_processed_count := l_processed_count + 1;
                end loop;
                
                prc_api_stat_pkg.log_current (
                    i_current_count    => l_processed_count
                    , i_excepted_count => l_excepted_count
                );

                exit when data_cur%notfound;
            end loop;

            if data_cur%isopen then
                close data_cur;
            end if;
        end loop;
        
        trc_log_pkg.debug (
            i_text          => 'finished loading MPE'
        );

        prc_api_stat_pkg.log_end (
            i_excepted_total    => l_excepted_count
          , i_processed_total   => l_processed_count
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
    exception
        when others then
            rollback to savepoint mpe_start_load;
            
            if data_cur%isopen then
                close data_cur;
            end if;
            
            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );
            
            trc_log_pkg.error (
                i_text          => 'MPE_LOAD_ERROR'
                , i_env_param1  => l_session_file_id
                , i_env_param2  => l_recnum
                , i_env_param3  => l_stage
                , i_env_param4  => sqlerrm
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                raise;
            elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error(
                    i_error         => 'UNHANDLED_EXCEPTION'
                  , i_env_param1    => sqlerrm
                );
            end if;
            raise;
    end;
    
    procedure collect_currecy_date(
        i_cur_rate_rec        in mcw_api_type_pkg.t_cur_rate_rec
    )
    is
        i binary_integer;
    begin
        i := g_cur_rate_tab.count + 1;

        g_cur_rate_tab(i) := i_cur_rate_rec;
    end;

    procedure applay_currency_rate(
        i_id                  in com_api_type_pkg.t_long_id    
    )
    is
    begin
        if g_cur_rate_tab.count >0 then                
            mcw_api_currency_pkg.put_currency_rate (
                i_msg_id         => i_id
                , i_cur_rate_tab => g_cur_rate_tab
            );               
        end if;
    end;    
    
    procedure save_currency_update(
        i_data                in com_api_type_pkg.t_text
      , i_date                in date   
    )
    is    
        l_cur_rate_rec      mcw_api_type_pkg.t_cur_rate_rec;
        
        function normalize_rate (
            i_rate      in com_api_type_pkg.t_name
            , i_def_pos in number default 7
        ) return number is
        begin
            return to_number(substr(i_rate, 1, 8) || ',' ||
                             substr(i_rate, 9, 7), '99999999D9999999', 'NLS_NUMERIC_CHARACTERS = '',.''');
        end;  

    begin
        l_cur_rate_rec.p0164_1  := substr(i_data,2,3);
        l_cur_rate_rec.p0164_2  := normalize_rate(substr(i_data,11,15));
        l_cur_rate_rec.p0164_3  := 'B';
        l_cur_rate_rec.p0164_4  := i_date;
        l_cur_rate_rec.p0164_5  := '99';
        l_cur_rate_rec.de050    := substr(i_data,5,3);
    
        collect_currecy_date(i_cur_rate_rec => l_cur_rate_rec);

        l_cur_rate_rec.p0164_2  := normalize_rate(substr(i_data,26,15)); 
        l_cur_rate_rec.p0164_3  := 'M';

        collect_currecy_date(i_cur_rate_rec => l_cur_rate_rec);

        l_cur_rate_rec.p0164_2  := normalize_rate(substr(i_data,41,15) );
        l_cur_rate_rec.p0164_3  := 'S';
            
        collect_currecy_date(i_cur_rate_rec => l_cur_rate_rec); 
    end;
    
    procedure load_currency (
        i_network_id          in com_api_type_pkg.t_tiny_id
      , i_inst_id             in com_api_type_pkg.t_tiny_id
    )
    is    
        l_estimated_count       com_api_type_pkg.t_long_id := 0;
        l_excepted_count        com_api_type_pkg.t_long_id := 0;
        l_processed_count       com_api_type_pkg.t_long_id := 0;
        
        l_session_file_id       com_api_type_pkg.t_long_id;
        l_session_files         com_api_type_pkg.t_number_tab;
        
        l_data_tab              com_api_type_pkg.t_varchar2_tab;
        l_recnum_tab            com_api_type_pkg.t_number_tab;
        l_data_count            binary_integer;
        
        l_recnum                number;
        l_total                 number;
        
        l_id                    com_api_type_pkg.t_long_id;
        l_date                  date;                     
        
        procedure save_currency
        is
            l_cur_update_rec    mcw_api_type_pkg.t_cur_update_rec;
        begin
            l_cur_update_rec := null;

            -- init
            l_cur_update_rec.id := opr_api_create_pkg.get_id;
            l_id                := l_cur_update_rec.id;
            l_cur_update_rec.file_id := mcw_file_seq.nextval;
            l_cur_update_rec.network_id := i_network_id;

            l_cur_update_rec.inst_id := i_inst_id;

            mcw_api_currency_pkg.put_message (
                i_cur_update_rec   => l_cur_update_rec
            );        
        end;

    begin
        savepoint cur_start_load;
        
        prc_api_stat_pkg.log_start;
        
        g_cur_rate_tab.delete;
        
        trc_log_pkg.debug (
            i_text          => 'estimate records'
        );
        -- estimate records for load
        select
            count(1)
        into
            l_estimated_count
        from
            prc_session_file s
            , prc_file_attribute a
            , prc_file f
            , prc_file_raw_data d
        where
            a.id = s.file_attr_id
            and f.id = a.file_id
            and f.file_purpose = prc_api_file_pkg.get_file_purpose_in
            and s.session_id   = get_session_id
            and d.session_file_id = s.id;
            
        save_currency;

        prc_api_stat_pkg.log_estimation (
            i_estimated_count => l_estimated_count
        );
        
        trc_log_pkg.debug (
            i_text         => 'Estimate records for load [#1]'
            , i_env_param1 => l_estimated_count
        );    
        
        trc_log_pkg.debug (
            i_text         => 'Processing incoming currency update' 
        );
        
        select
            id
        bulk collect into
            l_session_files
        from
            prc_session_file
        where
            session_id = get_session_id
        order by
            id;
            
        for i in 1..l_session_files.count loop
            
            l_session_file_id := l_session_files(i);
            l_recnum := 0;
        
           open data_cur (
                i_session_file_id  => l_session_file_id
            );

            loop
                fetch data_cur bulk collect into l_recnum_tab, l_data_tab limit BULK_LIMIT;

                l_data_count := l_data_tab.count;
                
                for i in 1 .. l_data_count loop
                    if (substr(l_data_tab(i), 1, 1) = 'D') then
                        l_recnum := l_recnum + 1;
                        save_currency_update(
                            i_data   => l_data_tab(i)
                          , i_date   => l_date
                        );
                    elsif (substr(l_data_tab(i), 1, 1) = 'H') then
                        l_date := to_date(substr(l_data_tab(i), 2, 8), 'YYYYMMDD');
                    elsif (substr(l_data_tab(i), 1, 1) = 'T') then
                        l_total := to_number(substr(l_data_tab(i), 2, 6));
                    elsif substr(l_data_tab(i), 1, 1) = chr(26) then
                        trc_log_pkg.warn(
                            i_text       => 'UNKNOWN_RECORD_TYPE'
                          , i_env_param1 => substr(l_data_tab(i), 1, 1)
                          , i_env_param2 => l_recnum
                        );
                    else
                        com_api_error_pkg.raise_error(
                            i_error      => 'UNKNOWN_RECORD_TYPE' 
                          , i_env_param1 => substr(l_data_tab(i), 1, 1)
                          , i_env_param2 => l_recnum
                        );
                    end if; 

                    l_processed_count := l_processed_count + 1;
                end loop;
                
                prc_api_stat_pkg.log_current (
                    i_current_count    => l_processed_count
                    , i_excepted_count => l_excepted_count
                );

                exit when data_cur%notfound;
            end loop;            
        
            if data_cur%isopen then
                close data_cur;
            end if;
            
        end loop;    
        
        If l_recnum <> l_total then
            trc_log_pkg.error (
                i_text          => 'MC_CURR_LOAD_TOTAL_ERROR'
                , i_env_param1  => l_recnum
                , i_env_param2  => l_total
            );          
        end if;

        applay_currency_rate(i_id => l_id);

        trc_log_pkg.debug (
            i_text          => 'finished loading MC Currency'
        );            

        prc_api_stat_pkg.log_end (
            i_excepted_total    => l_excepted_count
          , i_processed_total   => l_processed_count
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
    exception
        when others then
            rollback to savepoint cur_start_load;   

            if data_cur%isopen then
                close data_cur;
            end if;            

            trc_log_pkg.error (
                i_text          => 'MC_CURR_LOAD_ERROR'
                , i_env_param1  => l_session_file_id
                , i_env_param2  => l_recnum
                , i_env_param3  => sqlerrm
            );

            raise;
    end;

end;
/
