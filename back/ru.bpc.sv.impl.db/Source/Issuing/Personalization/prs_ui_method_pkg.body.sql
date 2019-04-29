create or replace package body prs_ui_method_pkg is
/************************************************************
 * User interface for personalization method <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 03.08.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_ui_method_pkg <br />
 * @headcom
 ************************************************************/

    procedure check_already_used (
        i_id                        in com_api_type_pkg.t_tiny_id
    ) is
        l_check_cnt                 pls_integer;
    begin
        select
            count(1)
        into
            l_check_cnt
        from
            prs_method_vw m
        where
            m.id = i_id
            and m.is_active = com_api_type_pkg.TRUE;
        
        if l_check_cnt > 0 then
            com_api_error_pkg.raise_error (
                i_error  => 'CARD_PERSONALIZATION_METHOD_ALREADY_USED'
            );
        end if;
    end;
    
    procedure check_keys (
        i_key_schema_id             in com_api_type_pkg.t_tiny_id
        , i_pin_verify_method       in com_api_type_pkg.t_dict_value
        , i_cvv_required            in com_api_type_pkg.t_boolean
        , i_icvv_required           in com_api_type_pkg.t_boolean
        , i_cvv2_required           in com_api_type_pkg.t_boolean
    ) is
    begin
        for r in (
            select
                k.key_type
                , count( case when k.key_type = s.key_type then 1 end ) cnt
            from (  select
                        d.dict || d.code key_type
                    from
                        com_dictionary_vw d
                    where
                        d.dict = 'ENKT'
                        and d.code in ('CVK', 'CVK2', 'PVK')
                ) k
                left join (
                    select
                        e.key_type
                    from
                        prs_key_schema_entity_vw e
                    where
                        e.key_schema_id = i_key_schema_id
                ) s
                on s.key_type = k.key_type
            group by k.key_type
            having count( case when k.key_type = s.key_type then 1 end ) = 0
        ) loop
            if ( r.key_type = sec_api_const_pkg.SECURITY_DES_KEY_CVK  and i_cvv_required  = com_api_type_pkg.TRUE ) or
               ( r.key_type = sec_api_const_pkg.SECURITY_DES_KEY_CVK2 and i_cvv2_required = com_api_type_pkg.TRUE) or 
               ( r.key_type = sec_api_const_pkg.SECURITY_DES_KEY_CVK  and i_icvv_required = com_api_type_pkg.TRUE ) or               
               ( r.key_type = sec_api_const_pkg.SECURITY_DES_KEY_PVK  and i_pin_verify_method in (prs_api_const_pkg.PIN_VERIFIC_METHOD_PVV, prs_api_const_pkg.PIN_VERIFIC_METHOD_IBM_3624) ) then
                com_api_error_pkg.raise_error (
                    i_error         => 'KEY_TYPE_NOT_FOUND_IN_SCHEMA'
                    , i_env_param1  => r.key_type
                );
            end if;
            
        end loop;
    end;
    
    procedure add (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_pvv_store_method        in com_api_type_pkg.t_dict_value
        , i_pin_store_method        in com_api_type_pkg.t_dict_value
        , i_pin_verify_method       in com_api_type_pkg.t_dict_value
        , i_cvv_required            in com_api_type_pkg.t_boolean
        , i_icvv_required           in com_api_type_pkg.t_boolean
        , i_pvk_index               in com_api_type_pkg.t_tiny_id
        , i_key_schema_id           in com_api_type_pkg.t_tiny_id
        , i_service_code            in com_api_type_pkg.t_module_code
        , i_dda_required            in com_api_type_pkg.t_boolean
        , i_imk_index               in com_api_type_pkg.t_tiny_id
        , i_private_key_component   in com_api_type_pkg.t_dict_value
        , i_private_key_format      in com_api_type_pkg.t_dict_value
        , i_module_length           in com_api_type_pkg.t_tiny_id
        , i_max_script              in com_api_type_pkg.t_tiny_id
        , i_decimalisation_table    in com_api_type_pkg.t_pin_block
        , i_exp_date_format         in com_api_type_pkg.t_dict_value
        , i_pin_length              in com_api_type_pkg.t_tiny_id
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_description             in com_api_type_pkg.t_full_desc
        , i_cvv2_required           in com_api_type_pkg.t_boolean
    ) is
    begin
   
        if i_key_schema_id is not null then
            check_keys (
                i_key_schema_id        => i_key_schema_id
                , i_pin_verify_method  => i_pin_verify_method
                , i_cvv_required       => i_cvv_required
                , i_icvv_required      => i_icvv_required
                , i_cvv2_required      => i_cvv2_required
            );
        end if;
        
        o_id := prs_method_seq.nextval;
        o_seqnum := 1;

        insert into prs_method_vw (
            id
            , inst_id
            , seqnum
            , pvv_store_method
            , pin_store_method
            , pin_verify_method
            , cvv_required
            , icvv_required
            , pvk_index
            , key_schema_id
            , service_code
            , dda_required
            , imk_index
            , private_key_component
            , private_key_format
            , module_length
            , max_script
            , is_active
            , decimalisation_table
            , exp_date_format
            , pin_length
            , cvv2_required
        ) values (
            o_id
            , i_inst_id
            , o_seqnum
            , i_pvv_store_method
            , i_pin_store_method
            , i_pin_verify_method
            , i_cvv_required
            , i_icvv_required
            , i_pvk_index
            , i_key_schema_id
            , i_service_code
            , i_dda_required
            , i_imk_index
            , i_private_key_component
            , i_private_key_format
            , i_module_length
            , i_max_script
            , 0
            , i_decimalisation_table
            , i_exp_date_format
            , i_pin_length
            , i_cvv2_required
        );

        com_api_i18n_pkg.add_text (
            i_table_name      => 'prs_method'
            , i_column_name   => 'description'
            , i_object_id     => o_id
            , i_lang          => i_lang
            , i_text          => i_description
            , i_check_unique  => com_api_type_pkg.TRUE
        );
    end;

    procedure modify (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_pvv_store_method        in com_api_type_pkg.t_dict_value
        , i_pin_store_method        in com_api_type_pkg.t_dict_value
        , i_pin_verify_method       in com_api_type_pkg.t_dict_value
        , i_cvv_required            in com_api_type_pkg.t_boolean
        , i_icvv_required           in com_api_type_pkg.t_boolean
        , i_pvk_index               in com_api_type_pkg.t_tiny_id
        , i_key_schema_id           in com_api_type_pkg.t_tiny_id
        , i_service_code            in com_api_type_pkg.t_module_code
        , i_dda_required            in com_api_type_pkg.t_boolean
        , i_imk_index               in com_api_type_pkg.t_tiny_id
        , i_private_key_component   in com_api_type_pkg.t_dict_value
        , i_private_key_format      in com_api_type_pkg.t_dict_value
        , i_module_length           in com_api_type_pkg.t_tiny_id
        , i_max_script              in com_api_type_pkg.t_tiny_id
        , i_decimalisation_table    in com_api_type_pkg.t_pin_block
        , i_exp_date_format         in com_api_type_pkg.t_dict_value
        , i_pin_length              in com_api_type_pkg.t_tiny_id
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_description             in com_api_type_pkg.t_full_desc
        , i_cvv2_required           in com_api_type_pkg.t_boolean
    ) is
    begin
        for r in (
            select
                id
                , inst_id
                , seqnum
                , pvv_store_method
                , pin_store_method
                , pin_verify_method
                , cvv_required
                , icvv_required
                , pvk_index
                , key_schema_id
                , service_code
                , dda_required
                , imk_index
                , private_key_component
                , private_key_format
                , module_length
                , max_script
                , decimalisation_table
                , exp_date_format
                , pin_length
                , cvv2_required
            from
                prs_method_vw
            where
                id = i_id
        ) loop
            if r.pvv_store_method != i_pvv_store_method
               or r.pvv_store_method != i_pvv_store_method
               or r.pin_store_method != i_pin_store_method
               or r.pin_verify_method != i_pin_verify_method
               or r.cvv_required != i_cvv_required
               or r.icvv_required != i_icvv_required
               or r.key_schema_id != i_key_schema_id
               or r.service_code != i_service_code
               or r.dda_required != i_dda_required
               or r.imk_index != i_imk_index
               or r.private_key_component != i_private_key_component
               or r.private_key_format != i_private_key_format
               or r.module_length != i_module_length
               or r.max_script != i_max_script
               or r.decimalisation_table != i_decimalisation_table
               or r.exp_date_format != i_exp_date_format
               or r.pin_length != i_pin_length 
               or r.cvv2_required != i_cvv2_required then
                check_already_used (
                    i_id  => i_id
                );
            end if;
        end loop;
           
        if i_key_schema_id is not null then

            check_keys (
                i_key_schema_id        => i_key_schema_id
              , i_pin_verify_method  => i_pin_verify_method
              , i_cvv_required       => i_cvv_required
              , i_icvv_required      => i_icvv_required
              , i_cvv2_required      => i_cvv2_required
            );
        end if;

        update
            prs_method_vw
        set
            seqnum = io_seqnum
            , pvv_store_method = i_pvv_store_method
            , pin_store_method = i_pin_store_method
            , pin_verify_method = i_pin_verify_method
            , cvv_required = i_cvv_required
            , icvv_required = i_icvv_required
            , pvk_index = i_pvk_index
            , key_schema_id = i_key_schema_id
            , service_code = i_service_code
            , dda_required = i_dda_required
            , imk_index = i_imk_index
            , private_key_component = i_private_key_component
            , private_key_format = i_private_key_format
            , module_length = i_module_length
            , max_script = i_max_script
            , decimalisation_table = i_decimalisation_table
            , exp_date_format = i_exp_date_format
            , pin_length = i_pin_length
            , cvv2_required = i_cvv2_required
        where
            id = i_id;

        io_seqnum := io_seqnum + 1;

        com_api_i18n_pkg.add_text (
            i_table_name      => 'prs_method'
            , i_column_name   => 'description'
            , i_object_id     => i_id
            , i_lang          => i_lang
            , i_text          => i_description
            , i_check_unique  => com_api_type_pkg.TRUE
        );
    end;

    procedure remove (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
    begin
        check_already_used (
            i_id  => i_id
        );
 
        com_api_i18n_pkg.remove_text (
            i_table_name   => 'prs_method'
            , i_object_id  => i_id
        );
          
        update
            prs_method_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;
            
        delete from
            prs_method_vw
        where
            id = i_id;
    end;

end; 
/
