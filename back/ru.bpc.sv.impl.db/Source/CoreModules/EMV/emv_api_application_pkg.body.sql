create or replace package body emv_api_application_pkg is
/************************************************************
 * API for EMV application <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 02.09.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: emv_api_application_pkg <br />
 * @headcom
 ************************************************************/
    
    BULK_LIMIT                  constant integer := 400;
    DC_PERSO_CPS_APP            constant com_api_type_pkg.t_name := 'SCPM_EMV_CPS';
    DC_PERSO_VSDC_APP           constant com_api_type_pkg.t_name := 'VSDC0003';
    DC_PERSO_MCHP_APP           constant com_api_type_pkg.t_name := 'MCHP0003';
    
    g_appl_vars                 com_api_type_pkg.t_lob_tab;
    g_tag_values                com_api_type_pkg.t_param2d_tab;

    procedure enum_elements (
        o_elements              in out sys_refcursor
        , i_parent_id           in com_api_type_pkg.t_short_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_object_id           in com_api_type_pkg.t_short_id
    ) is
    begin
        if i_parent_id is not null then
            open o_elements for
                select
                    x.id
                    , x.seqnum
                    , x.parent_id
                    , x.entity_type
                    , x.object_id
                    , x.element_order
                    , x.code
                    , x.tag
                    , x.value
                    , x.is_optional
                    , x.add_length
                    , x.start_position
                    , x.length
                    , (select decode(count(id), 0, 1, 0) from emv_element e where e.parent_id = x.id) is_leaf
                    , x.profile
                from
                    emv_element x
                where
                    x.entity_type = i_entity_type
                    and x.object_id = i_object_id
                    and x.parent_id = i_parent_id
                order by
                    x.element_order;
        else
            open o_elements for
                select
                    x.id
                    , x.seqnum
                    , x.parent_id
                    , x.entity_type
                    , x.object_id
                    , x.element_order
                    , x.code
                    , x.tag
                    , x.value
                    , x.is_optional
                    , x.add_length
                    , x.start_position
                    , x.length
                    , (select decode(count(id), 0, 1, 0) from emv_element e where e.parent_id = x.id) is_leaf
                    , x.profile
                from
                    emv_element x
                where
                    x.entity_type = i_entity_type
                    and x.object_id = i_object_id
                    and x.parent_id is null
                order by
                    x.element_order;
        end if;
    end;
    
    procedure enum_bloks (
        o_blocks                in out sys_refcursor
        , i_application_id      in com_api_type_pkg.t_short_id
    ) is
    begin
        open o_blocks for
            select
                b.id
                , b.seqnum
                , b.application_id
                , b.code
                , b.include_in_sda
                , b.include_in_afl
                , b.transport_key_id
                , b.encryption_id
                , b.block_order
                , b.profile
            from
                emv_block b
            where
                b.application_id = i_application_id
            order by
                b.block_order;
    end;
    
    procedure enum_variables (
        o_variables             in out sys_refcursor
        , i_application_id      in com_api_type_pkg.t_short_id
        , i_variable_type       in com_api_type_pkg.t_dict_value := null
    ) is
    begin
        open o_variables for
            select
                v.id
                , v.seqnum
                , v.application_id
                , v.variable_type
                , v.profile
            from
                emv_variable v
            where
                v.application_id = i_application_id
                and (i_variable_type is null or v.variable_type = i_variable_type)
            order by
                v.id;
    end;

    procedure enum_appls (
        o_appls                 in out sys_refcursor
        , i_appl_scheme_id      in com_api_type_pkg.t_tiny_id
    ) is
    begin
        open o_appls for
            select
                a.id
                , a.seqnum
                , a.aid
                , a.id_owner
                , a.mod_id
                , a.appl_scheme_id
                , get_text (
                   i_table_name    => 'emv_application'
                   , i_column_name => 'name'
                   , i_object_id   => a.id
                   , i_lang        => get_def_lang
                ) name
                , pix
            from
                emv_application a
            where
                a.appl_scheme_id = i_appl_scheme_id
            order by
                a.id
            ;
    end;
    
    function get_emv_appl_scheme (
        i_object_id             in com_api_type_pkg.t_long_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
    ) return emv_api_type_pkg.t_emv_appl_scheme_rec is
        l_result                emv_api_type_pkg.t_emv_appl_scheme_rec;
    begin
        case i_entity_type
            when emv_api_const_pkg.ENTITY_TYPE_EMV_SCHEME then
                select
                    a.id
                    , a.seqnum
                    , a.inst_id
                    , a.type
                into
                    l_result
                from
                    emv_appl_scheme_vw a
                where
                    a.id = i_object_id;
              
            when iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
                select
                    a.id
                    , a.seqnum
                    , a.inst_id
                    , a.type
                into
                    l_result
                from
                    iss_card_instance_vw ci
                    , iss_card oc
                    , iss_product_card_type pd
                    , emv_appl_scheme_vw a
                where 
                    ci.id = i_object_id
                    and oc.id = ci.card_id
                    and pd.bin_id = ci.bin_id
                    and pd.card_type_id = oc.card_type_id
                    and ci.seq_number between pd.seq_number_low and pd.seq_number_high
                    and a.id = pd.emv_appl_scheme_id;
        else
            com_api_error_pkg.raise_error (
                i_error        => 'UNKNOWN_ENTITY_TYPE'
                , i_env_param1 => i_entity_type
            );
        end case;
            
        return l_result;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error        => 'ENTITY_TYPE_NOT_FOUND'
                , i_env_param1 => i_entity_type
                , i_env_param2 => i_object_id
            );
    end;
    
    function get_tag_value (
        i_tag                   in com_api_type_pkg.t_tag
        , i_value               in com_api_type_pkg.t_param_value
        , i_profile             in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_param_value is
        l_result                   com_api_type_pkg.t_param_value;
    begin
        l_result := null;
        if i_value is null then
            if g_tag_values.exists(i_profile) then
                if g_tag_values(i_profile).exists(i_tag) then
                    l_result := g_tag_values(i_profile)(i_tag);
                end if;
            end if;
        end if;

        return nvl(i_value, l_result);
    end;

    function get_element_value (
        i_element_rec           in emv_api_type_pkg.t_emv_element_rec
        , i_profile             in com_api_type_pkg.t_dict_value
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , i_perso_data          in prs_api_type_pkg.t_perso_data_rec
    ) return com_api_type_pkg.t_lob_data is
        l_result                com_api_type_pkg.t_lob_data;
        l_value                 com_api_type_pkg.t_param_value;
        l_length_tlv            com_api_type_pkg.t_param_value;
        l_elements              sys_refcursor;
        l_element_tab           emv_api_type_pkg.t_emv_element_tab;
    begin
        trc_log_pkg.debug (
            i_text          => 'Getting element value [#1]'
            , i_env_param1  => i_element_rec.id
        );
        
        if i_element_rec.is_leaf = com_api_type_pkg.FALSE then
            enum_elements (
                o_elements       => l_elements
                , i_parent_id    => i_element_rec.id
                , i_entity_type  => i_element_rec.entity_type
                , i_object_id    => i_element_rec.object_id
            );
            loop
                fetch l_elements bulk collect into l_element_tab limit BULK_LIMIT;
                for i in 1 .. l_element_tab.count loop
                    l_value := get_element_value (
                        i_element_rec     => l_element_tab(i)
                        , i_profile       => nvl(l_element_tab(i).profile, i_profile)
                        , i_perso_rec     => i_perso_rec
                        , i_perso_method  => i_perso_method
                        , i_perso_data    => i_perso_data
                    );
                    l_result := l_result || l_value;
                end loop;
                exit when l_elements%notfound;
            end loop;
            close l_elements;
        else
            if i_element_rec.tag is not null then
                l_value := emv_api_tag_pkg.get_tag_value (
                    i_tag                => i_element_rec.tag
                    , i_value            => get_tag_value(i_element_rec.tag, i_element_rec.value, i_profile)
                    , i_profile          => nvl(i_element_rec.profile, i_profile)
                    , i_perso_rec        => i_perso_rec
                    , i_perso_method     => i_perso_method
                    , i_perso_data       => i_perso_data
                );
            elsif i_element_rec.value is not null then
                l_value := i_element_rec.value;
            else
                com_api_error_pkg.raise_error (
                    i_error         => 'UNABLE_GET_ELEMENT_VALUE'
                );
            end if;
            l_result := l_value;
        end if;
        if i_element_rec.start_position is not null and i_element_rec.length is not null then
            l_result := substr(l_result, (i_element_rec.start_position+1)*2-1, i_element_rec.length*2);
        end if;
        if l_result is null then
            if i_element_rec.is_optional = com_api_type_pkg.FALSE then
                com_api_error_pkg.raise_error (
                    i_error         => 'UNABLE_GET_MANDATORY_ELEMENT_VALUE'
                );
            end if;
        else
            if i_element_rec.add_length = com_api_type_pkg.TRUE then
                l_length_tlv := prs_api_util_pkg.ber_tlv_length(l_result);
            end if;
        
            l_result := i_element_rec.code || l_length_tlv || l_result;
        end if;
        
        trc_log_pkg.debug (
            i_text          => 'Element [#1] value [#2]'
            , i_env_param1  => i_element_rec.id
            , i_env_param2  => l_result
        );

        return l_result;
    exception
        when others then
            if l_elements%isopen then
                close l_elements;
            end if;
            raise;
    end;
    
    function get_variable_value (
        i_variable_id           in com_api_type_pkg.t_short_id
    ) return com_api_type_pkg.t_lob_data is
        l_result                com_api_type_pkg.t_lob_data;
    begin
        trc_log_pkg.debug (
            i_text          => 'Getting variable value [#1]'
            , i_env_param1  => i_variable_id
        );
      
        if g_appl_vars.exists(i_variable_id) then
            trc_log_pkg.debug (
                i_text  => 'Getting variable value [#1][#2]'
                , i_env_param1  => i_variable_id
                , i_env_param2  => g_appl_vars(i_variable_id)
            );
          
            return g_appl_vars(i_variable_id);
        end if;

        com_api_error_pkg.raise_error (
            i_error         => 'UNABLE_GET_VARIABLE_VALUE'
            , i_env_param1  => i_variable_id
        );
        return l_result;
    end;
    
    function get_variable_value (
        i_var_rec               in emv_api_type_pkg.t_emv_variable_rec
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , i_perso_data          in prs_api_type_pkg.t_perso_data_rec
    ) return com_api_type_pkg.t_lob_data is
        l_elements              sys_refcursor;
        l_element_tab           emv_api_type_pkg.t_emv_element_tab;
        l_result                com_api_type_pkg.t_lob_data;
    begin
        trc_log_pkg.debug (
            i_text          => 'Getting variable [#1]'
            , i_env_param1  => i_var_rec.id
        );
        
        enum_elements (
            o_elements       => l_elements
            , i_parent_id    => null
            , i_entity_type  => emv_api_const_pkg.ENTITY_TYPE_EMV_VAR
            , i_object_id    => i_var_rec.id
        );
        loop
            fetch l_elements bulk collect into l_element_tab limit BULK_LIMIT;
            for j in 1 .. l_element_tab.count loop
                l_result := l_result || get_element_value (
                    i_element_rec     => l_element_tab(j)
                    , i_profile       => i_var_rec.profile
                    , i_perso_rec     => i_perso_rec
                    , i_perso_method  => i_perso_method
                    , i_perso_data    => i_perso_data
                );
            end loop;
            exit when l_elements%notfound;
        end loop;
        close l_elements;
                
        trc_log_pkg.debug (
            i_text          => 'Variable [#1] value [#2]'
            , i_env_param1  => i_var_rec.id
            , i_env_param2  => l_result
        );

        return l_result;
    exception
        when others then
            if l_elements%isopen then
                close l_elements;
            end if;
            raise;
    end;

    function get_variable_by_type (
        i_application_id        in com_api_type_pkg.t_tiny_id
        , i_variable_type       in com_api_type_pkg.t_dict_value
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , i_perso_data          in prs_api_type_pkg.t_perso_data_rec
    ) return com_api_type_pkg.t_lob_data is
        l_result                com_api_type_pkg.t_lob_data;
        l_vars                  sys_refcursor;
        l_var_tab               emv_api_type_pkg.t_emv_variable_tab;
    begin
        trc_log_pkg.debug (
            i_text          => 'Getting variable value by type [#1]'
            , i_env_param1  => i_variable_type
        );
        
        enum_variables (
            o_variables         => l_vars
            , i_application_id  => i_application_id
            , i_variable_type   => i_variable_type
        );
        loop
            fetch l_vars bulk collect into l_var_tab limit BULK_LIMIT;
            for i in 1 .. l_var_tab.count loop
                if g_appl_vars.exists(l_var_tab(i).id) then
                    trc_log_pkg.debug (
                        i_text  => 'Getting variable value [#1][#2]'
                        , i_env_param1  => l_var_tab(i).id
                        , i_env_param2  => substr(g_appl_vars(l_var_tab(i).id), 1, 200)
                    );

                    l_result := g_appl_vars(l_var_tab(i).id);
                else
                    l_result := get_variable_value (
                        i_var_rec         => l_var_tab(i)
                        , i_perso_rec     => i_perso_rec
                        , i_perso_method  => i_perso_method
                        , i_perso_data    => i_perso_data
                    );
                end if;
            end loop;
            exit when l_vars%notfound;
        end loop;
        close l_vars;

        /*if l_result is null then
            com_api_error_pkg.raise_error (
                i_error         => 'UNABLE_GET_VARIABLE_VALUE'
                , i_env_param1  => i_variable_type
            );
        end if;*/
        return l_result;
    exception
        when others then
            if l_vars%isopen then
                close l_vars;
            end if;
            raise;
    end;
    
    procedure init_appl_vars (
        i_application_id        in com_api_type_pkg.t_tiny_id
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , i_perso_data          in prs_api_type_pkg.t_perso_data_rec
    ) is
        l_vars                  sys_refcursor;
        l_var_tab               emv_api_type_pkg.t_emv_variable_tab;
        l_result                com_api_type_pkg.t_lob_data;
        
        procedure finalize is
        begin
            if l_vars%isopen then
                close l_vars;
            end if;
        end;
    begin
        trc_log_pkg.debug (
            i_text  => 'Init application variables...'
        );

        g_appl_vars.delete;

        enum_variables (
            o_variables         => l_vars
            , i_application_id  => i_application_id
        );
        loop
            fetch l_vars bulk collect into l_var_tab limit BULK_LIMIT;
            for i in 1 .. l_var_tab.count loop
                trc_log_pkg.debug (
                    i_text          => 'Processing var [#1]'
                    , i_env_param1  => l_var_tab(i).id
                );

                l_result := get_variable_value (
                    i_var_rec         => l_var_tab(i)
                    , i_perso_rec     => i_perso_rec
                    , i_perso_method  => i_perso_method
                    , i_perso_data    => i_perso_data
                );

                trc_log_pkg.debug (
                    i_text          => 'Value [#1]'
                    , i_env_param1  => l_result
                );

                g_appl_vars(l_var_tab(i).id) := l_result;
            end loop;
            exit when l_vars%notfound;
        end loop;
        close l_vars;

        trc_log_pkg.debug (
            i_text  => 'Init application variables - ok'
        );
    exception
        when others then
            finalize;
            raise;
    end;
    
    procedure clear_appl_vars is
    begin
        g_appl_vars.delete;
    end;
    
    procedure init_appl_tag_values (
        i_appl_scheme_id        in com_api_type_pkg.t_tiny_id
    ) is
        l_tag_values           emv_api_type_pkg.t_emv_tag_value_tab;
    begin
        trc_log_pkg.debug (
            i_text  => 'Init scheme application tags value...'
        );

        g_tag_values.delete;

        select
            v.id
            , v.entity_type
            , v.object_id
            , t.tag
            , v.tag_value
            , v.profile
        bulk collect into
            l_tag_values
        from
            emv_tag_value_vw v
            , emv_tag_vw t
        where
            t.id = v.tag_id
            and v.entity_type = emv_api_const_pkg.ENTITY_TYPE_EMV_SCHEME
            and v.object_id = i_appl_scheme_id;

        for i in 1 .. l_tag_values.count loop
            g_tag_values(l_tag_values(i).profile)(l_tag_values(i).tag) := l_tag_values(i).tag_value;
        end loop;
        
        l_tag_values.delete;

        trc_log_pkg.debug (
            i_text  => 'Init scheme application tags value - ok'
        );
    exception
        when others then
            l_tag_values.delete;
            raise;
    end;

    procedure clear_appl_tag_values is
    begin
        g_tag_values.delete;
    end;

    function associated_tk_cmode (
        i_encryption            in com_api_type_pkg.t_lob_data
    ) return com_api_type_pkg.t_lob_data is
        l_value                 com_api_type_pkg.t_lob_data;
    begin
        l_value := case i_encryption
                       when '83' then '10' -- CBC
                       when '03' then '11' -- ECB
                       else i_encryption
                   end;
          
        return l_value;
    end;

    procedure process_blocks (
        i_application_id        in com_api_type_pkg.t_tiny_id
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , i_perso_data          in prs_api_type_pkg.t_perso_data_rec
        , o_icc_data            out com_api_type_pkg.t_lob_data
        , o_tk_data             out com_api_type_pkg.t_lob_data
    ) is
        l_value                 com_api_type_pkg.t_lob_data;
        
        l_counter               com_api_type_pkg.t_lob_data;
        l_transport_key         com_api_type_pkg.t_lob_data;
        l_encryption            com_api_type_pkg.t_lob_data;
        
        l_blocks                sys_refcursor;
        l_elements              sys_refcursor;
        l_block_tab             emv_api_type_pkg.t_emv_block_tab;
        l_element_tab           emv_api_type_pkg.t_emv_element_tab;
        
        l_tk_tab                emv_api_type_pkg.t_transport_key_data_tab;
        l_tk_empty              emv_api_type_pkg.t_transport_key_data_rec;
        
        procedure finalize is
        begin
            if l_elements%isopen then
                close l_elements;
            end if;
            if l_blocks%isopen then
                close l_blocks;
            end if;
        end;

        procedure format_tk_data is
            i                   com_api_type_pkg.t_lob_data;
        begin
            i := l_tk_tab.first;
            while i is not null loop
                o_tk_data := o_tk_data
                          || l_tk_tab(i).id
                          || l_tk_tab(i).tk_type
                          || l_tk_tab(i).c_mode
                          || rul_api_name_pkg.pad_byte_len(prs_api_util_pkg.dec2hex(l_tk_tab( i ).dgi_count))
                          || l_tk_tab(i).dgi_list
                          ;
                i := l_tk_tab.next(i);
            end loop;
        end;
        
        procedure init_tk_data is
        begin
            l_tk_empty.id := '';
            l_tk_empty.tk_type := '20';
            l_tk_empty.c_mode := '';
            l_tk_empty.dgi_count := 0;
            l_tk_empty.dgi_list := '';
        end;
    begin
        trc_log_pkg.debug (
            i_text  => 'Process blocks'
        );
        
        init_tk_data;

        enum_bloks (
            o_blocks            => l_blocks
            , i_application_id  => i_application_id
        );
        loop
            fetch l_blocks bulk collect into l_block_tab limit BULK_LIMIT;
            for i in 1 .. l_block_tab.count loop
                trc_log_pkg.debug (
                    i_text          => 'Processing DGI [#1]'
                    , i_env_param1  => l_block_tab(i).code
                );
                
                l_value := '';
                
                enum_elements (
                    o_elements       => l_elements
                    , i_parent_id    => null
                    , i_entity_type  => emv_api_const_pkg.ENTITY_TYPE_EMV_BLOCK
                    , i_object_id    => l_block_tab(i).id
                );
                loop
                    fetch l_elements bulk collect into l_element_tab limit BULK_LIMIT;
                    for j in 1 .. l_element_tab.count loop
                        l_value := l_value || get_element_value (
                            i_element_rec     => l_element_tab(j)
                            , i_profile       => nvl(l_element_tab(j).profile, l_block_tab(i).profile)
                            , i_perso_rec     => i_perso_rec
                            , i_perso_method  => i_perso_method
                            , i_perso_data    => i_perso_data
                        );
                    end loop;
                    exit when l_elements%notfound;
                end loop;
                close l_elements;
                /*trc_log_pkg.debug (
                    i_text          => 'l_block_tab(i).code[#1] len[#2] l_value[#3]'
                    , i_env_param1  => l_block_tab(i).code
                    , i_env_param2  => rul_api_name_pkg.pad_byte_len(prs_api_util_pkg.dec2hex(nvl(length(l_value), 0)/2))
                    , i_env_param3  => l_value
                );*/
                o_icc_data := o_icc_data
                           || l_block_tab(i).code
                           || rul_api_name_pkg.pad_byte_len(prs_api_util_pkg.dec2hex(nvl(length(l_value), 0)/2))
                           || l_value
                           ;
                           
                if l_block_tab(i).transport_key_id is not null then
                    trc_log_pkg.debug (
                        i_text          => 'Creating TK Data'
                    );

                    l_transport_key := get_variable_value (
                        i_variable_id  => l_block_tab(i).transport_key_id
                    );
                    
                    l_encryption := get_variable_value (
                        i_variable_id  => l_block_tab(i).encryption_id
                    );
                    
                    l_counter := l_transport_key||'20'||associated_tk_cmode(l_encryption);

                    if not l_tk_tab.exists( l_counter ) then
                        l_tk_tab( l_counter ) := l_tk_empty;
                    end if;
                    l_tk_tab(l_counter).id := l_transport_key;
                    l_tk_tab(l_counter).tk_type := '20';
                    l_tk_tab(l_counter).c_mode := associated_tk_cmode(l_encryption);
                    l_tk_tab(l_counter).dgi_count := nvl(l_tk_tab(l_counter).dgi_count, 0) + 1;
                    l_tk_tab(l_counter).dgi_list := l_tk_tab(l_counter).dgi_list || l_block_tab(i).code;
                end if;
                           
            end loop;
            exit when l_blocks%notfound;
        end loop;
        close l_blocks;
        
        format_tk_data;
        
        trc_log_pkg.debug (
            i_text  => 'Process blocks - ok'
        );
    exception
        when others then
            finalize;
            dbms_output.put_line(sqlerrm);
            raise;
    end;
    
    procedure process_p3_blocks (
        i_application_id        in com_api_type_pkg.t_tiny_id
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , i_perso_data          in prs_api_type_pkg.t_perso_data_rec
        , o_icc_data            out com_api_type_pkg.t_lob_data
    ) is
        l_value                 com_api_type_pkg.t_lob_data;
        
        l_blocks                sys_refcursor;
        l_elements              sys_refcursor;
        l_block_tab             emv_api_type_pkg.t_emv_block_tab;
        l_element_tab           emv_api_type_pkg.t_emv_element_tab;
        
        procedure finalize is
        begin
            if l_elements%isopen then
                close l_elements;
            end if;
            if l_blocks%isopen then
                close l_blocks;
            end if;
        end;
    begin
        trc_log_pkg.debug (
            i_text  => 'Process p3 blocks'
        );

        enum_bloks (
            o_blocks            => l_blocks
            , i_application_id  => i_application_id
        );
        loop
            fetch l_blocks bulk collect into l_block_tab limit BULK_LIMIT;
            for i in 1 .. l_block_tab.count loop
                trc_log_pkg.debug (
                    i_text          => 'Processing DGI [#1]'
                    , i_env_param1  => l_block_tab(i).code
                );

                l_value := '';

                enum_elements (
                    o_elements       => l_elements
                    , i_parent_id    => null
                    , i_entity_type  => emv_api_const_pkg.ENTITY_TYPE_EMV_BLOCK
                    , i_object_id    => l_block_tab(i).id
                );
                loop
                    fetch l_elements bulk collect into l_element_tab limit BULK_LIMIT;
                    for j in 1 .. l_element_tab.count loop
                        l_value := l_value || get_element_value (
                            i_element_rec     => l_element_tab(j)
                            , i_profile       => nvl(l_element_tab(j).profile, l_block_tab(i).profile)
                            , i_perso_rec     => i_perso_rec
                            , i_perso_method  => i_perso_method
                            , i_perso_data    => i_perso_data
                        );
                    end loop;
                    exit when l_elements%notfound;
                end loop;
                close l_elements;
                /*trc_log_pkg.debug (
                    i_text          => 'l_block_tab(i).code[#1] len[#2] l_value[#3]'
                    , i_env_param1  => l_block_tab(i).code
                    , i_env_param2  => rul_api_name_pkg.pad_byte_len(prs_api_util_pkg.dec2hex(nvl(length(l_value), 0)/2))
                    , i_env_param3  => l_value
                );*/
                o_icc_data := o_icc_data
                           || l_value
                           ;
            end loop;
            exit when l_blocks%notfound;
        end loop;
        close l_blocks;

        trc_log_pkg.debug (
            i_text  => 'Process p3 blocks - ok'
        );
    exception
        when others then
            finalize;
            dbms_output.put_line(sqlerrm);
            raise;
    end;

    function get_sad (
        i_application_id        in com_api_type_pkg.t_tiny_id
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , i_perso_data          in prs_api_type_pkg.t_perso_data_rec
    ) return com_api_type_pkg.t_lob2_tab is
        l_result                 com_api_type_pkg.t_lob2_tab;
        l_value                  com_api_type_pkg.t_lob_data;
    begin
        trc_log_pkg.debug (
            i_text  => 'Get static application data'
        );
        
        for r in (
            select
                s.tag
                , s.value
                , s.profile
            from (
                select
                    b.profile
                    , b.code
                    , b.block_order
                    , e.id
                    , e.parent_id
                    , e.element_order
                    , e.tag
                    , e.value
                from
                    emv_block b
                    , emv_element e
                where
                    b.application_id = i_application_id
                    and b.include_in_sda = com_api_const_pkg.TRUE
                    and e.entity_type = emv_api_const_pkg.ENTITY_TYPE_EMV_BLOCK
                    and e.object_id = b.id
                ) s
            where
                s.tag is not null
            connect by prior s.id = s.parent_id
            start with s.parent_id is null
            order siblings by
                s.profile
                , s.block_order
                , s.element_order
        ) loop
            if not l_result.exists(r.profile) then
                l_result(r.profile) := '';
            end if;
            l_value := emv_api_tag_pkg.get_tag_value (
                i_tag                => r.tag
                , i_value            => get_tag_value(r.tag, r.value, r.profile)
                , i_profile          => r.profile
                , i_perso_rec        => i_perso_rec
                , i_perso_method     => i_perso_method
                , i_perso_data       => i_perso_data
            );
            l_result(r.profile) := l_result(r.profile)
                                || r.tag
                                || prs_api_util_pkg.ber_tlv_length(l_value)
                                || l_value;
        end loop;
        
        for r in (
            select
                dict||code profile
                , '9F4A' tag
                , null value
            from
                com_dictionary
            where
                dict = emv_api_const_pkg.PROFILE
            order by
                dict||code
        ) loop
            if not l_result.exists(r.profile) then
                l_result(r.profile) := '';
            end if;
            l_value := emv_api_tag_pkg.get_tag_value (
                i_tag                => r.tag
                , i_value            => get_tag_value(r.tag, r.value, r.profile)
                , i_profile          => r.profile
                , i_perso_rec        => i_perso_rec
                , i_perso_method     => i_perso_method
                , i_perso_data       => i_perso_data
            );
            if l_value is not null then
                l_value := get_tag_value(l_value, null, r.profile);
                if l_value is not null then
                    l_result(r.profile) := l_result(r.profile)
                                        || l_value;
                end if;
            end if;
        end loop;

        trc_log_pkg.debug (
            i_text  => 'Get static application data - ok'
        );
        
        return l_result;
    end;
    
    function get_aid (
        i_application_id        in com_api_type_pkg.t_tiny_id
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , i_perso_data          in prs_api_type_pkg.t_perso_data_rec
    ) return com_api_type_pkg.t_lob2_tab is
        l_result                 com_api_type_pkg.t_lob2_tab;
        l_value                  com_api_type_pkg.t_lob_data;
    begin
        trc_log_pkg.debug (
            i_text  => 'Get application identifier'
        );
        
        l_result.delete;
        
        for r in (
            select
                v.profile
                , e.tag
                , min(e.value) value
            from
                emv_variable v
                , emv_element e
            where
                v.application_id = i_application_id
                and v.variable_type = emv_api_const_pkg.VAR_TYPE_METADATA
                and e.tag = '4F'
                and e.entity_type = emv_api_const_pkg.ENTITY_TYPE_EMV_VAR
                and e.object_id = v.id
            group by
                v.profile
                , e.tag
        ) loop
            if not l_result.exists(r.profile) then
                l_result(r.profile) := '';
            end if;
            l_value := emv_api_tag_pkg.get_tag_value (
                i_tag                => r.tag
                , i_value            => get_tag_value(r.tag, r.value, r.profile)
                , i_profile          => r.profile
                , i_perso_rec        => i_perso_rec
                , i_perso_method     => i_perso_method
                , i_perso_data       => i_perso_data
            );
            l_result(r.profile) := l_result(r.profile)
                                || l_value;
        end loop;
        
        trc_log_pkg.debug (
            i_text  => 'Get application identifier'
        );
        
        return l_result;
    end;
    
    function get_appl_scheme_type(
        i_tag             in  com_api_type_pkg.t_name
      , i_value           in  com_api_type_pkg.t_param_value
      , i_mask_error      in  com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
    )
    return com_api_type_pkg.t_dict_value
    result_cache relies_on(emv_element, emv_block, emv_variable, emv_application, emv_appl_scheme)
    is
        l_appl_scheme_type       com_api_type_pkg.t_dict_value;
    begin
        select s.type
          into l_appl_scheme_type
          from (
                   select nvl(b.application_id, v.application_id) as application_id
                     from emv_element e
                        , emv_block b
                        , emv_variable v
                    where e.tag = i_tag
                      and e.value = i_value
                      and case when e.entity_type = emv_api_const_pkg.ENTITY_TYPE_EMV_BLOCK then e.object_id end = b.id(+)
                      and case when e.entity_type = emv_api_const_pkg.ENTITY_TYPE_EMV_VAR then e.object_id end   = v.id(+)
               ) l
             , emv_application a
             , emv_appl_scheme s
        where l.application_id = a.id
          and a.appl_scheme_id = s.id;

        return l_appl_scheme_type;
    exception 
        when no_data_found then
            return null;
        when too_many_rows then
            if i_mask_error = com_api_const_pkg.TRUE then
                return null;
            else
                com_api_error_pkg.raise_error(
                    i_error         => 'TOO_MANY_APPLICATIONS_WITH_SAME_TAG_VALUE'
                  , i_env_param1    => i_tag
                  , i_env_param2    => i_value
                );
            end if;
    end;
    
    procedure format_appl_data (
        i_application_id        in com_api_type_pkg.t_tiny_id
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , io_perso_data         in out nocopy prs_api_type_pkg.t_perso_data_rec
    ) is
    begin
        trc_log_pkg.debug (
            i_text  => 'Format static/dynamic application data'
        );

        -- get static application data
        io_perso_data.sad := get_sad (
            i_application_id  => i_application_id
            , i_perso_rec     => i_perso_rec
            , i_perso_method  => i_perso_method
            , i_perso_data    => io_perso_data
        );

        -- sign static application data
        prs_api_command_pkg.sign_static_appl_data (
            i_perso_rec        => i_perso_rec
            , i_perso_key      => io_perso_data.perso_key
            , i_hsm_device_id  => io_perso_data.hsm_device_id
            , i_static_data    => io_perso_data.sad
            , o_signed_data    => io_perso_data.ssad
        );
        
        -- generate icc rsa keys
        if i_perso_method.dda_required = com_api_type_pkg.TRUE then
            prs_api_command_pkg.generate_icc_rsa_keys (
                i_perso_rec        => i_perso_rec
                , i_perso_method   => i_perso_method
                , i_perso_key      => io_perso_data.perso_key
                , i_static_data    => io_perso_data.sad
                , i_hsm_device_id  => io_perso_data.hsm_device_id
                , o_result         => io_perso_data.icc_rsa_keys
            );
        end if;
         
        trc_log_pkg.debug (
            i_text  => 'Format static/dynamic application data - ok'
        );
    end;
    
    procedure format_afl_data (
        i_application_id        in com_api_type_pkg.t_tiny_id
        , o_afl_data            out nocopy com_api_type_pkg.t_param_tab
    ) is
    begin
        trc_log_pkg.debug (
            i_text          => 'Format afl data for application [#1]'
            , i_env_param1  => i_application_id
        );
      
        for r in (
            select
                t.file_no
                , t.profile
                , min(t.rec_no) start_rec
                , max(t.rec_no) end_rec
                , sum(t.include_in_sda) sda_count
            from (
                select
                    substr( code, 1, 2 ) file_no
                    , substr( code, 3, 2 ) rec_no
                    , code
                    , include_in_sda
                    , profile
                from
                    emv_block
                where
                    application_id = i_application_id
                    and include_in_afl = com_api_type_pkg.TRUE
            ) t
            group by
                t.profile
                , t.file_no
            order by
                t.profile
                , t.file_no
        ) loop
            if not o_afl_data.exists(r.profile) then
                o_afl_data(r.profile) := '';
            end if;
            o_afl_data(r.profile) := o_afl_data(r.profile)
                                  || prs_api_util_pkg.hex_shift_left_nocycle(r.file_no, 3)
                                  || r.start_rec
                                  || r.end_rec
                                  || prs_api_util_pkg.dec2hex(r.sda_count)
                                  ;
        end loop;
      
        trc_log_pkg.debug (
            i_text  => 'Format afl data - ok'
        );
    end;

    function format_section2 (
        i_aid_count             in com_api_type_pkg.t_tiny_id
        , i_aids_data           in com_api_type_pkg.t_raw_data
        , i_section3_tab        in com_api_type_pkg.t_lob_tab
    ) return com_api_type_pkg.t_lob_data is
        l_section               com_api_type_pkg.t_lob_data;
    begin
        trc_log_pkg.debug (
            i_text  => 'Format section 2'
        );
        
        l_section := '00'                         -- Lcrn
                  || utl_raw.cast_to_raw( '00' ) -- STATUScoll
                  || '00'                         -- NUMBERpid
                  || rul_api_name_pkg.pad_byte_len(prs_api_util_pkg.dec2hex(i_aid_count))
                  || i_aids_data;
        /*trc_log_pkg.debug (
            i_text          => '=>01 l_section[#1]'
            , i_env_param1  => l_section
        );*/
                    
        l_section := rul_api_name_pkg.pad_byte_len (
                         i_src       => prs_api_util_pkg.dec2hex(nvl(length(l_section), 0)/2)
                         , i_length  => 2
                     )
                  || l_section
                  ;
        
        for i in 1 .. i_section3_tab.count loop
        /*trc_log_pkg.debug (
            i_text          => '=>02 i_section3_tab(i)[#1]'
            , i_env_param1  => i_section3_tab(i)
        );*/
            l_section := l_section
                      || i_section3_tab(i);
        end loop;
        /*trc_log_pkg.debug (
            i_text          => '=>03 l_section[#1]'
            , i_env_param1  => substr(l_section, 1, 3900)
        );*/
        l_section := utl_raw.cast_to_raw('02.1')  -- VNL
                  || rul_api_name_pkg.pad_byte_len (
                         i_src       => prs_api_util_pkg.dec2hex(nvl(length(l_section), 0)/2)
                         , i_length  => 2
                     )
                  || l_section
                  ;
        /*trc_log_pkg.debug (
            i_text          => '=>section 2 l_section[#1]'
            , i_env_param1  => l_section
        );*/
        return l_section;
    end;
    
    function format_section3 (
        i_aid                   in com_api_type_pkg.t_name
        , i_id_owner            in com_api_type_pkg.t_name
        , i_icc_data            in com_api_type_pkg.t_lob_data
        , i_tk_data             in com_api_type_pkg.t_lob_data
    ) return com_api_type_pkg.t_lob_data is
        l_section_a1            com_api_type_pkg.t_lob_data;
        l_section_a2            com_api_type_pkg.t_lob_data;
        l_section_b             com_api_type_pkg.t_lob_data;
        l_section_c             com_api_type_pkg.t_lob_data;
        l_section_d             com_api_type_pkg.t_lob_data;
        l_section               com_api_type_pkg.t_lob_data;
        
        l_aid_length            com_api_type_pkg.t_raw_data;
        
        l_icc_data              com_api_type_pkg.t_lob_data;
        
        l_pdi                   com_api_type_pkg.t_raw_data;
        l_proc_steps            com_api_type_pkg.t_raw_data;
    begin
        trc_log_pkg.debug (
            i_text  => 'Format section 3'
        );
        
        trc_log_pkg.debug (
            i_text  => 'Creating section 3a.1'
        );
            
        l_section_a1 := '';
        l_aid_length := rul_api_name_pkg.pad_byte_len(prs_api_util_pkg.dec2hex(nvl(length(i_aid), 0)/2));
        /*trc_log_pkg.debug (
            i_text          => '=> 01 l_aid_length[#1] i_aid[#2]'
            , i_env_param1  => l_aid_length
            , i_env_param2  => i_aid
        );*/
        if i_tk_data is not null then
            l_section_a1 := '01'
                         || i_tk_data;
        end if;
        /*trc_log_pkg.debug (
            i_text          => '=>03 l_section_a1[#1]'
            , i_env_param1  => l_section_a1
        );*/        
        l_section_a1 := l_aid_length
                     || i_aid
                     || rul_api_name_pkg.pad_byte_len(prs_api_util_pkg.dec2hex(nvl(length(l_section_a1), 0)/2))
                     || l_section_a1
                     ;
        /*trc_log_pkg.debug (
            i_text          => '=>04 l_section_a1[#1]'
            , i_env_param1  => l_section_a1
        );*/
        l_section_a1 := rul_api_name_pkg.pad_byte_len(prs_api_util_pkg.dec2hex(nvl(length(l_section_a1), 0)/2))
                     || l_section_a1
                     ;
        /*trc_log_pkg.debug (
            i_text          => '=>05 l_section_a1[#1]'
            , i_env_param1  => l_section_a1
        );*/
        trc_log_pkg.debug (
            i_text  => 'Creating section 3a.2'
        );

        l_pdi := '0000' -- Lorder
              || '0000' -- LverCntl
              || '0000' -- Lenc
              || '0000' -- Lrandom
              || '0000' -- Lgroup
              || '00'   -- SECLEV
              || '00'   -- UPDATEcplc
              ;
        /*trc_log_pkg.debug (
            i_text          => '=>06 l_pdi[#1]'
            , i_env_param1  => l_pdi
        );*/
        l_pdi := rul_api_name_pkg.pad_byte_len (
                     i_src       => prs_api_util_pkg.dec2hex(nvl(length(l_pdi), 0)/2)
                     , i_length  => 2
                 )
           || l_pdi
           ;
        /*trc_log_pkg.debug (
            i_text          => '=>07 l_pdi[#1]'
            , i_env_param1  => l_pdi
        );*/
        l_proc_steps := '0F'   -- act
                     || '01'   -- req
                     || 'EF'   -- tag
                     || l_pdi
                     || '0000' -- lpointer
                     ;
        /*trc_log_pkg.debug (
            i_text          => '=>08 l_proc_steps[#1]'
            , i_env_param1  => l_proc_steps
        );*/
        l_proc_steps := rul_api_name_pkg.pad_byte_len(prs_api_util_pkg.dec2hex(nvl(length(l_proc_steps), 0)/2))
                     || l_proc_steps
                     ;
        /*trc_log_pkg.debug (
            i_text          => '=>09 l_proc_steps[#1]'
            , i_env_param1  => l_proc_steps
        );*/
        l_section_a2 := rul_api_name_pkg.pad_byte_len(prs_api_util_pkg.dec2hex(nvl(length(i_id_owner), 0)/2))
                     || i_id_owner
                     || rul_api_name_pkg.pad_byte_len (
                            i_src       => prs_api_util_pkg.dec2hex(nvl(length(l_proc_steps), 0)/2)
                            , i_length  => 2
                        )
                     || l_proc_steps
                     ;
        /*trc_log_pkg.debug (
            i_text          => '=>10 l_section_a2[#1]'
            , i_env_param1  => l_section_a2
        );*/
        l_section_a2 := rul_api_name_pkg.pad_byte_len (
                            i_src       => prs_api_util_pkg.dec2hex(nvl(length(l_section_a2), 0)/2)
                            , i_length  => 2
                        )
                     || l_section_a2
                     ;
        /*trc_log_pkg.debug (
            i_text          => '=>11 l_section_a2[#1]'
            , i_env_param1  => l_section_a2
        );*/
        trc_log_pkg.debug (
            i_text  => 'Creating section 3b'
        );

        l_section_b := '0000';
        trc_log_pkg.debug (
            i_text          => '=>12 l_section_b[#1]'
            , i_env_param1  => l_section_b
        );
        trc_log_pkg.debug (
            i_text  => 'Creating section 3c'
        );

        l_icc_data := 'EF' || prs_api_util_pkg.ber_tlv_length( i_icc_data ) || i_icc_data;
        /*trc_log_pkg.debug (
            i_text          => '=>13 l_icc_data[#1]'
            , i_env_param1  => l_icc_data
        );*/
        l_section_c := rul_api_name_pkg.pad_byte_len (
                           i_src => prs_api_util_pkg.dec2hex(nvl(length(l_icc_data), 0)/2)
                           , i_length  => 2
                       )
                    || l_icc_data
                    ;
        /*trc_log_pkg.debug (
            i_text          => '=>14 l_icc_data[#1]'
            , i_env_param1  => l_icc_data
        );*/
        trc_log_pkg.debug (
            i_text  => 'Creating section 3d'
        );

        l_section_d := '00';
        /*trc_log_pkg.debug (
            i_text          => '=>15 l_section_d[#1]'
            , i_env_param1  => l_section_d
        );*/
        trc_log_pkg.debug (
            i_text  => 'Constructing section 3'
        );

        l_section := l_section_a1 || l_section_a2 || l_section_b || l_section_c || l_section_d;
        /*trc_log_pkg.debug (
            i_text          => '=>16 l_section[#1]'
            , i_env_param1  => l_section
        );*/
        l_section := rul_api_name_pkg.pad_byte_len (
                          i_src       => prs_api_util_pkg.dec2hex(nvl(length(l_section), 0)/2)
                          , i_length  => 2
                      )
                   || l_section
                   ;
        /*trc_log_pkg.debug (
            i_text          => '=>17 l_section[#1]'
            , i_env_param1  => l_section
        );*/
        trc_log_pkg.debug (
            i_text  => 'Format section 3 - ok'
        );
        return l_section;
    end;
    
    procedure process_application (
        i_appl_scheme_id        in com_api_type_pkg.t_tiny_id
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , io_perso_data         in out nocopy prs_api_type_pkg.t_perso_data_rec
        , io_appl_data          in out nocopy emv_api_type_pkg.t_appl_data_tab
        , i_params              in com_api_type_pkg.t_param_tab
    ) is
        l_appls                 sys_refcursor;
        l_appl_tab              emv_api_type_pkg.t_emv_application_tab;
        l_aid                   com_api_type_pkg.t_lob2_tab;

        l_icc_data              com_api_type_pkg.t_lob_data;
        l_tk_data               com_api_type_pkg.t_lob_data;
        l_appl_data             emv_api_type_pkg.t_appl_data_rec;
        
        procedure clear_aids is
        begin
            l_aid.delete;
        end;
    begin
        trc_log_pkg.debug (
            i_text  => 'Processing emv application...'
        );
        
        init_appl_tag_values (
            i_appl_scheme_id  => i_appl_scheme_id
        );

        enum_appls (
            o_appls             => l_appls
            , i_appl_scheme_id  => i_appl_scheme_id
        );
        loop
            fetch l_appls bulk collect into l_appl_tab limit BULK_LIMIT;
            for i in 1 .. l_appl_tab.count loop
                trc_log_pkg.debug (
                    i_text          => 'Application [#1][#2]'
                    , i_env_param1  => l_appl_tab(i).id
                    , i_env_param2  => l_appl_tab(i).name
                );
                
                -- init aid array
                clear_aids;
                
                if l_appl_tab(i).mod_id is null
                  or rul_api_mod_pkg.check_condition (
                    i_mod_id    => l_appl_tab(i).mod_id
                    , i_params  => i_params
                ) = com_api_const_pkg.TRUE then
                    -- get application name variable
                    if l_appl_data.appl_name is null then
                        l_appl_data.appl_name := get_variable_by_type (
                           i_application_id   => l_appl_tab(i).id
                           , i_variable_type  => emv_api_const_pkg.VAR_TYPE_APPL_NAME
                           , i_perso_rec      => i_perso_rec
                           , i_perso_method   => i_perso_method
                           , i_perso_data     => io_perso_data
                        );
                    end if;

                    case
                    when l_appl_data.appl_name in (DC_PERSO_CPS_APP) then
                        -- format application file locator data
                        format_afl_data (
                            i_application_id  => l_appl_tab(i).id
                            , o_afl_data      => io_perso_data.afl_data
                        );

                        -- format static/dynamic application data
                        format_appl_data (
                            i_application_id  => l_appl_tab(i).id
                            , i_perso_rec     => i_perso_rec
                            , i_perso_method  => i_perso_method
                            , io_perso_data   => io_perso_data
                        );
                        
                    else
                        null;
                        
                    end case;

                    -- init application variables
                    init_appl_vars (
                        i_application_id  => l_appl_tab(i).id
                        , i_perso_rec     => i_perso_rec
                        , i_perso_method  => i_perso_method
                        , i_perso_data    => io_perso_data
                    );
                    
                    -- get application name variable
                    if l_appl_data.appl_name is null then
                        l_appl_data.appl_name := get_variable_by_type (
                           i_application_id   => l_appl_tab(i).id
                           , i_variable_type  => emv_api_const_pkg.VAR_TYPE_APPL_NAME
                           , i_perso_rec      => i_perso_rec
                           , i_perso_method   => i_perso_method
                           , i_perso_data     => io_perso_data
                        );
                    end if;
                    
                    l_appl_data.metadata := get_variable_by_type (
                       i_application_id   => l_appl_tab(i).id
                       , i_variable_type  => emv_api_const_pkg.VAR_TYPE_METADATA
                       , i_perso_rec      => i_perso_rec
                       , i_perso_method   => i_perso_method
                       , i_perso_data     => io_perso_data
                    );
                    
                    l_appl_data.pix := l_appl_tab(i).pix;
                    
                    -- process blocks
                    case 
                    when l_appl_data.appl_name in (DC_PERSO_CPS_APP) then
                        process_blocks (
                            i_application_id  => l_appl_tab(i).id
                            , i_perso_rec     => i_perso_rec
                            , i_perso_method  => i_perso_method
                            , i_perso_data    => io_perso_data
                            , o_icc_data      => l_icc_data
                            , o_tk_data       => l_tk_data
                        );
                        
                    when l_appl_data.appl_name in (DC_PERSO_VSDC_APP, DC_PERSO_MCHP_APP) then
                        process_p3_blocks (
                            i_application_id  => l_appl_tab(i).id
                            , i_perso_rec     => i_perso_rec
                            , i_perso_method  => i_perso_method
                            , i_perso_data    => io_perso_data
                            , o_icc_data      => l_icc_data
                        );
                        
                    else
                        null;
                        
                    end case;

                    if l_appl_tab(i).aid is null then
                        l_aid := get_aid (
                            i_application_id  => l_appl_tab(i).id
                            , i_perso_rec     => i_perso_rec
                            , i_perso_method  => i_perso_method
                            , i_perso_data    => io_perso_data
                        );
                        if l_aid.exists(emv_api_const_pkg.PROFILE_CONTACT) then
                            l_appl_data.aid := l_aid(emv_api_const_pkg.PROFILE_CONTACT);
                        else
                            com_api_error_pkg.raise_error (
                                i_error  => 'UNABLE_GET_AID_VALUE'
                            );
                        end if;
                    else
                        l_appl_data.aid := l_appl_tab(i).aid;
                    end if;

                    -- format icc data
                    case 
                    when l_appl_data.appl_name in (DC_PERSO_CPS_APP) then
                        l_appl_data.icc_data := format_section3 (
                            i_aid         => l_appl_data.aid
                            , i_id_owner  => l_appl_tab(i).id_owner
                            , i_icc_data  => l_icc_data
                            , i_tk_data   => l_tk_data
                        );
                        
                    when l_appl_data.appl_name in (DC_PERSO_VSDC_APP, DC_PERSO_MCHP_APP) then
                        l_appl_data.icc_data := l_icc_data;
                        
                    else
                        null;
                        
                    end case;
                    
                    io_appl_data(io_appl_data.count+1) := l_appl_data;
                end if;
            end loop;
            exit when l_appls%notfound;
        end loop;
        close l_appls;

        trc_log_pkg.debug (
            i_text  => 'Processing emv application - ok'
        );

        clear_aids;
        clear_appl_vars;
        clear_appl_tag_values;
    exception
        when others then
            if l_appls%isopen then
                close l_appls;
            end if;

            clear_aids;
            clear_appl_vars;
            clear_appl_tag_values;

            dbms_output.put_line(sqlerrm);
            raise;
    end;
    
    procedure process_p3_application (
        i_appl_scheme_id        in com_api_type_pkg.t_tiny_id
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , io_perso_data         in out nocopy prs_api_type_pkg.t_perso_data_rec
        , io_appl_data          in out nocopy emv_api_type_pkg.t_appl_data_tab
    ) is
        l_appls                 sys_refcursor;
        l_appl_tab              emv_api_type_pkg.t_emv_application_tab;
        l_aid                   com_api_type_pkg.t_lob2_tab;

        l_icc_data              com_api_type_pkg.t_lob_data;
        l_appl_data             emv_api_type_pkg.t_appl_data_rec;

        procedure clear_aids is
        begin
            l_aid.delete;
        end;
    begin
        trc_log_pkg.debug (
            i_text  => 'Processing p3 application...'
        );

        init_appl_tag_values (
            i_appl_scheme_id  => i_appl_scheme_id
        );

        enum_appls (
            o_appls             => l_appls
            , i_appl_scheme_id  => i_appl_scheme_id
        );
        loop
            fetch l_appls bulk collect into l_appl_tab limit BULK_LIMIT;
            for i in 1 .. l_appl_tab.count loop
                trc_log_pkg.debug (
                    i_text          => 'Application [#1][#2]'
                    , i_env_param1  => l_appl_tab(i).id
                    , i_env_param2  => l_appl_tab(i).name
                );

                -- init aid array
                clear_aids;

                -- format application file locator data
                format_afl_data (
                    i_application_id  => l_appl_tab(i).id
                    , o_afl_data      => io_perso_data.afl_data
                );

                -- format static/dynamic application data
                /*format_appl_data (
                    i_application_id  => l_appl_tab(i).id
                    , i_perso_rec     => i_perso_rec
                    , i_perso_method  => i_perso_method
                    , io_perso_data   => io_perso_data
                );*/

                -- init application variables
                init_appl_vars (
                    i_application_id  => l_appl_tab(i).id
                    , i_perso_rec     => i_perso_rec
                    , i_perso_method  => i_perso_method
                    , i_perso_data    => io_perso_data
                );
                
                -- get application name variable
                l_appl_data.appl_name := get_variable_by_type (
                   i_application_id   => l_appl_tab(i).id
                   , i_variable_type  => emv_api_const_pkg.VAR_TYPE_APPL_NAME
                   , i_perso_rec     => i_perso_rec
                   , i_perso_method  => i_perso_method
                   , i_perso_data    => io_perso_data
                );
                
                l_appl_data.pix := l_appl_tab(i).pix;

                -- process blocks
                process_p3_blocks (
                    i_application_id  => l_appl_tab(i).id
                    , i_perso_rec     => i_perso_rec
                    , i_perso_method  => i_perso_method
                    , i_perso_data    => io_perso_data
                    , o_icc_data      => l_icc_data
                );

                if l_appl_tab(i).aid is null then
                    l_aid := get_aid (
                        i_application_id  => l_appl_tab(i).id
                        , i_perso_rec     => i_perso_rec
                        , i_perso_method  => i_perso_method
                        , i_perso_data    => io_perso_data
                    );
                    if l_aid.exists(emv_api_const_pkg.PROFILE_CONTACT) then
                        l_appl_data.aid := l_aid(emv_api_const_pkg.PROFILE_CONTACT);
                    else
                        com_api_error_pkg.raise_error (
                            i_error  => 'UNABLE_GET_AID_VALUE'
                        );
                    end if;
                else
                    l_appl_data.aid := l_appl_tab(i).aid;
                end if;

                l_appl_data.icc_data := l_icc_data;

                io_appl_data(io_appl_data.count+1) := l_appl_data;
            end loop;
            exit when l_appls%notfound;
        end loop;
        close l_appls;

        trc_log_pkg.debug (
            i_text  => 'Processing emv application - ok'
        );

        clear_aids;
        clear_appl_vars;
        clear_appl_tag_values;
    exception
        when others then
            if l_appls%isopen then
                close l_appls;
            end if;

            clear_aids;
            clear_appl_vars;
            clear_appl_tag_values;

            dbms_output.put_line(sqlerrm);
            raise;
    end;
    
    procedure format_chip_data (
        i_card_number           in com_api_type_pkg.t_card_number
        , i_appl_data           in emv_api_type_pkg.t_appl_data_tab
        , o_chip_data           out raw
    ) is
        l_aid_count             com_api_type_pkg.t_tiny_id;
        l_aids_data             com_api_type_pkg.t_raw_data;

        l_section               com_api_type_pkg.t_lob_data;
        l_section3_tab          com_api_type_pkg.t_lob_tab;

        l_metadata              com_api_type_pkg.t_lob_data;
        l_appl_name             com_api_type_pkg.t_name;
        l_pix                   com_api_type_pkg.t_name;
        
        procedure clear_tabs is
        begin
            l_section3_tab.delete;
        end;
    begin
        trc_log_pkg.debug (
            i_text  => 'Format chip data...'
        );

        l_aid_count := 0;

        for i in 1 .. i_appl_data.count loop
            l_aid_count := l_aid_count + 1;
            /*trc_log_pkg.debug (
                i_text          => '=>(i) len aid [#1] aid[#2]'
                , i_env_param1  => rul_api_name_pkg.pad_byte_len(prs_api_util_pkg.dec2hex(nvl(length(i_appl_data(i).aid), 0)/2))
                , i_env_param2  => i_appl_data(i).aid
            );*/
            l_aids_data := l_aids_data
                        || rul_api_name_pkg.pad_byte_len(prs_api_util_pkg.dec2hex(nvl(length(i_appl_data(i).aid), 0)/2))
                        || i_appl_data(i).aid;
                        
            if i_appl_data(i).metadata is not null then
                l_metadata := l_metadata
                       || 'FF01'
                       || prs_api_util_pkg.ber_tlv_length(i_appl_data(i).metadata)
                       || i_appl_data(i).metadata
                       ;
            end if;
            
            if l_pix is null then
                l_pix := rul_api_name_pkg.pad_byte_len (
                             i_src        => i_appl_data(i).pix
                             , i_pad_type => 'PADTRGHT'
                             , i_length   => 4
                         );
            end if;
            
            if l_appl_name is null then
                l_appl_name := i_appl_data(i).appl_name;
            end if;
            
            /*trc_log_pkg.debug (
                i_text          => '=>(i) len metadata [#1] metadata[#2]'
                , i_env_param1  => prs_api_util_pkg.ber_tlv_length(i_appl_data(i).metadata)
                , i_env_param2  => i_appl_data(i).metadata
            );*/
            l_section3_tab(l_section3_tab.count+1) := i_appl_data(i).icc_data;
            
            l_section := l_section
                      || i_appl_data(i).icc_data;
        end loop;
        /*trc_log_pkg.debug (
            i_text          => '=> l_aids_data [#1] l_metadata[#2]'
            , i_env_param1  => l_aids_data
            , i_env_param2  => l_metadata
        );*/
        
        trc_log_pkg.debug (
            i_text          => 'appl_name[#1]'
            , i_env_param1  => l_appl_name
        );
        
        -- format chip data
        case 
        when l_appl_name in (DC_PERSO_CPS_APP) then
            l_section := format_section2 (
                i_aid_count       => l_aid_count
                , i_aids_data     => l_aids_data
                , i_section3_tab  => l_section3_tab
            );

            trc_log_pkg.debug (
                i_text  => 'Creating EMV chip data'
            );
            
            o_chip_data := utl_raw.cast_to_raw (
                           lpad( i_card_number, 20, '*' )
                        || rul_api_name_pkg.pad_byte_len (
                               i_src       => prs_api_util_pkg.dec2hex(nvl(length(l_metadata),0)/2 )
                               , i_length  => 4
                           )
                        || l_metadata
                        || l_section
                        );
         
        /*o_chip_data :=\* utl_raw.cast_to_varchar2*\( rul_api_name_pkg.pad_byte_len (
                           i_src       => prs_api_util_pkg.dec2hex(nvl(length(o_chip_data),0))
                           , i_length  => 2
                       ))
                    || o_chip_data
                    ;
        o_chip_data := \*utl_raw.cast_to_varchar2*\(rul_api_name_pkg.pad_byte_len (
                           i_src       => prs_api_util_pkg.dec2hex(length(DC_PERSO_APP_NAME))
                           , i_length  => 2
                       ))
                    || DC_PERSO_APP_NAME
                    || o_chip_data
                    ;
        o_chip_data := \*utl_raw.cast_to_varchar2*\('FFFFFFFA')
                    || \*utl_raw.cast_to_varchar2*\(rul_api_name_pkg.pad_byte_len (
                           i_src       => prs_api_util_pkg.dec2hex(nvl(length(o_chip_data), 0))
                           , i_length  => 2
                       ))
                    || o_chip_data
                    ;
        o_chip_data := '{'
                    || to_char(length(o_chip_data ), 'FM0000009')
                    || o_chip_data
                    || chr(13) || chr(10) || chr(13)
                    ;*/
        
        when l_appl_name in (DC_PERSO_VSDC_APP, DC_PERSO_MCHP_APP) then
            -- lenght of TLF data
            l_section := rul_api_name_pkg.pad_byte_len (
                             i_src       => prs_api_util_pkg.ber_tlv_length(l_section)
                             , i_length  => 2
                         )
                      || l_section
                      ;
            -- key data
            l_section := '000000000000000000000000'
                      || l_section
                      ;
            -- lenght of key + data
            l_section := rul_api_name_pkg.pad_byte_len (
                             i_src       => prs_api_util_pkg.ber_tlv_length(l_section)
                             , i_length  => 2
                         )
                      || l_section
                      ;
            -- PIX
            l_section := l_pix
                      || l_section
                      ;
            -- full lenght of TLF data
            l_section := rul_api_name_pkg.pad_byte_len (
                             i_src       => prs_api_util_pkg.ber_tlv_length(l_section)
                             , i_length  => 2
                         )
                      || l_section
                      ;                       
            -- application name + TLF data
            l_appl_name := rul_api_name_pkg.pad_byte_len (
                               i_src       => prs_api_util_pkg.dec2hex(nvl(length(l_appl_name), 0))
                               , i_length  => 2
                           )
                        || prs_api_util_pkg.bin2hex(l_appl_name);
                        
            o_chip_data := hextoraw(l_appl_name)
                       || hextoraw(l_section)
                       ;
            -- lenght of application data
            o_chip_data := rul_api_name_pkg.pad_byte_len (
                              i_src       => prs_api_util_pkg.dec2hex(nvl(dbms_lob.getlength(o_chip_data), 0))
                              , i_length  => 2
                          )
                       || o_chip_data
                       ;
            -- p3 format identifier
            o_chip_data := hextoraw('FFFFFFFA')
                       || o_chip_data
                       ;
            -- full lenght
            o_chip_data := utl_raw.cast_to_raw(lpad(nvl(dbms_lob.getlength(o_chip_data), 0), 7, '0'))
                       || o_chip_data
                       ;
        else
            null;
                          
        end case;
        
        clear_tabs;
        
        trc_log_pkg.debug (
            i_text  => 'Format chip data - ok'
        );
    exception
        when others then
            clear_tabs;
            dbms_output.put_line(sqlerrm);
            raise;
    end;
    
    procedure format_p3chip_data (
        i_appl_data             in emv_api_type_pkg.t_appl_data_tab
        , o_raw_data            out raw
    ) is
        l_section               com_api_type_pkg.t_lob_data;
        
        l_appl_name             com_api_type_pkg.t_name;
        l_pix                   com_api_type_pkg.t_name;
    begin
        trc_log_pkg.debug (
            i_text  => 'Format p3 chip data...'
        );

        --o_chip_data := null;
        
        for i in 1 .. i_appl_data.count loop
            if l_pix is null then
                l_pix := rul_api_name_pkg.pad_byte_len (
                             i_src        => i_appl_data(i).pix
                             , i_pad_type => 'PADTRGHT'
                             , i_length   => 4
                         );
            end if;
            
            if l_appl_name is null then
                l_appl_name := rul_api_name_pkg.pad_byte_len (
                                   i_src       => prs_api_util_pkg.dec2hex(nvl(length(i_appl_data(i).appl_name), 0))
                                   , i_length  => 2
                               )
                            || prs_api_util_pkg.bin2hex(i_appl_data(i).appl_name);
            end if;

            /*trc_log_pkg.debug (
                i_text          => '=>(i) len icc_data [#1] icc_data[#2]'
                , i_env_param1  => prs_api_util_pkg.ber_tlv_length(i_appl_data(i).icc_data)
                , i_env_param2  => i_appl_data(i).icc_data
            );*/
            l_section := l_section
                      || i_appl_data(i).icc_data;
        end loop;
        
        -- lenght of TLF data
        l_section := rul_api_name_pkg.pad_byte_len (
                         i_src       => prs_api_util_pkg.ber_tlv_length(l_section)
                         , i_length  => 2
                     )
                  || l_section
                  ;
        -- key data
        l_section := '000000000000000000000000'
                  || l_section
                  ;
        -- lenght of key + data
        l_section := rul_api_name_pkg.pad_byte_len (
                         i_src       => prs_api_util_pkg.ber_tlv_length(l_section)
                         , i_length  => 2
                     )
                  || l_section
                  ;
        -- PIX
        l_section := l_pix
                  || l_section
                  ;
        -- full lenght of TLF data
        l_section := rul_api_name_pkg.pad_byte_len (
                         i_src       => prs_api_util_pkg.ber_tlv_length(l_section)
                         , i_length  => 2
                     )
                  || l_section
                  ;                       
        -- application name + TLF data
        o_raw_data := hextoraw(l_appl_name)
                   || hextoraw(l_section)
                   ;
        -- lenght of application data
        o_raw_data := rul_api_name_pkg.pad_byte_len (
                          i_src       => prs_api_util_pkg.dec2hex(nvl(dbms_lob.getlength(o_raw_data), 0))
                          , i_length  => 2
                      )
                   || o_raw_data
                   ;
        -- p3 format identifier
        o_raw_data := hextoraw('FFFFFFFA')
                   || o_raw_data
                   ;
        -- full lenght
        o_raw_data := utl_raw.cast_to_raw(lpad(nvl(dbms_lob.getlength(o_raw_data), 0), 7, '0'))
                   || o_raw_data
                   ;

        trc_log_pkg.debug (
            i_text  => 'Format chip data - ok'
        );
    exception
        when others then
            dbms_output.put_line(sqlerrm);
            raise;
    end;

end;
/
