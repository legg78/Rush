create or replace package body emv_prc_profile_pkg is

    PEK_TK_ID                  constant com_api_type_pkg.t_name := 'PEK_TK_ID';
    KEK_TK_ID                  constant com_api_type_pkg.t_name := 'KEK_TK_ID';
    ECB                        constant com_api_type_pkg.t_name := 'ECB';
    CBC                        constant com_api_type_pkg.t_name := 'CBC';
    RSA_KEK_ALG_ID             constant com_api_type_pkg.t_name := 'RSA_KEK_ALG_ID';
    METADATA                   constant com_api_type_pkg.t_name := 'METADATA';

    type   t_tag_rec is record (
        tagcode         varchar2(64)
        , includelen    varchar2(64)
        , from_         varchar2(64)
        , namespace     varchar2(64)
        , value         varchar2(2000)
        , isoptional    varchar2(64)
        , function_     varchar2(64)
        , index_        varchar2(64)
        , size_         varchar2(64)
    );

    type   t_var_rec is record (
        var_            xmltype
        , name          varchar2(64)
        , tagcode       varchar2(64)
        , includelen    varchar2(64)
        , from_         varchar2(64)
        , value         varchar2(2000)
        , valuetype     varchar2(64)
        , function_     varchar2(64)
    );

    type   t_attr_rec is record (
        name            varchar2(64)
        , value         varchar2(2000)
    );
          
    type   t_dgi_rec is record (
        dgi             varchar2(64)
        , isencrypted   number
        , tkid          varchar2(64)
        , algid         varchar2(64)
    );
    type   t_var_tab is table of pls_integer index by varchar2(64);
                                    
    function get_profile (
        i_namespace                 in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_dict_value is
    begin
        return case i_namespace
            when '0' then -- contact
                emv_api_const_pkg.PROFILE_CONTACT
            when '1' then -- paypass
                emv_api_const_pkg.PROFILE_PAYPASS
            when '2' then -- paywave quick Visa Smart Debit/Credit (qVSDC) 
                emv_api_const_pkg.PROFILE_PAYWAVE_QVSDC
            when '3' then -- paywave Magnetic Stripe Data (MSD) 
                emv_api_const_pkg.PROFILE_PAYWAVE_MSD
            else
                null
            end;
    end;
                
    procedure convert is
        l_var_tab                     t_var_tab;
        l_tag_tab                     com_api_type_pkg.t_param2d_tab;
          
        l_xml_content                 xmltype;

        l_appl_scheme_id              com_api_type_pkg.t_tiny_id;
        l_appl_scheme_seqnum          com_api_type_pkg.t_seqnum;
        
        l_appl_id                     com_api_type_pkg.t_short_id;
        l_appl_seqnum                 com_api_type_pkg.t_seqnum;

        l_var_id                      com_api_type_pkg.t_short_id;
        l_var_seqnum                  com_api_type_pkg.t_seqnum;
      
        l_block_id                    com_api_type_pkg.t_short_id;
        l_block_seqnum                com_api_type_pkg.t_seqnum;
        
        l_element_id                  com_api_type_pkg.t_short_id;
        l_element_seqnum              com_api_type_pkg.t_seqnum;
      
        l_block_order                 com_api_type_pkg.t_tiny_id;
        l_variable_order              com_api_type_pkg.t_tiny_id;
        l_element_order               com_api_type_pkg.t_tiny_id;
      
        l_blocks                      sys_refcursor;
        l_vars                        sys_refcursor;
        l_tags                        sys_refcursor;
        l_attrs                       sys_refcursor;

        l_block                       t_dgi_rec;
        l_tag                         t_tag_rec;
        l_attr                        t_attr_rec;
      
        l_result                      com_api_type_pkg.t_text;
        l_variable_type               com_api_type_pkg.t_name;
      
        l_tk_id                       com_api_type_pkg.t_short_id;
        l_alg_id                      com_api_type_pkg.t_short_id;
        l_afl                         com_api_type_pkg.t_boolean;
        l_sda                         com_api_type_pkg.t_boolean;
        l_namespace                   com_api_type_pkg.t_name;
      
        l_save_variable               com_api_type_pkg.t_boolean;
      
        l_estimated_count             com_api_type_pkg.t_long_id := 0;
        l_excepted_count              com_api_type_pkg.t_long_id := 0;
        l_processed_count             com_api_type_pkg.t_long_id := 0;

        procedure inc_ (
            io_val          in out com_api_type_pkg.t_short_id
            , i_step        in com_api_type_pkg.t_tiny_id := 1
        ) is
        begin
            io_val := nvl(io_val, 0) + i_step;
        end;
        
        function default_value (
            i_code                     in com_api_type_pkg.t_name
            , i_tag                    in com_api_type_pkg.t_name
            , i_value                  in com_api_type_pkg.t_param_value
            , i_profile                in com_api_type_pkg.t_dict_value
        ) return com_api_type_pkg.t_param_value is
            l_result                   com_api_type_pkg.t_param_value;
        begin
            l_result := null;
            dbms_output.put_line('i_code['||i_code||'] i_value['||i_value||'] i_profile['||i_profile||']');
            if i_value is null then
                if l_tag_tab.exists(i_profile) then
                    if l_tag_tab(i_profile).exists(i_tag) then
                        l_result := l_tag_tab(i_profile)(i_tag);
                    end if;
                end if;
            elsif i_code = 'DF05' then
                return utl_raw.cast_to_raw(i_value);
            end if;
        
            return nvl(i_value, l_result);
        end;

        procedure init_def_tag_values (
            i_scheme_id                 in com_api_type_pkg.t_tiny_id
        ) is
            l_profile                   com_api_type_pkg.t_dict_value;
        begin
            l_tag_tab.delete;
            
            for tag in (
                select
                    t.id
                    , re.TagCode
                    , re.value
                    , re.namespace
                from
                    (select l_xml_content xml_content from dual) co
                    , xmltable('/config/tags/tag'
                        PASSING co.xml_content
                        COLUMNS TagCode   VARCHAR2(64) PATH '@TagCode'
                                , value   VARCHAR2(4000) PATH '@value'
                                , namespace VARCHAR2(64) PATH '@namespace'
                    ) re
                    , emv_tag t
                 where
                    t.tag = re.TagCode
            ) loop
                l_profile := get_profile (
                    i_namespace  => tag.namespace
                );
                if l_profile is null then
                    l_profile := emv_api_const_pkg.PROFILE_CONTACT;
                end if;
                
                emv_ui_tag_pkg.set_tag_value (
                    i_tag_id         => tag.id
                    , i_object_id    => i_scheme_id
                    , i_entity_type  => emv_api_const_pkg.ENTITY_TYPE_EMV_SCHEME
                    , i_value        => tag.value
                    , i_profile      => l_profile
                );
            end loop;
        end;
        
        procedure process_tag (
            i_tag_rec                   in t_tag_rec
            , i_parent_id               in com_api_type_pkg.t_short_id default null
            , i_element_order           in com_api_type_pkg.t_tiny_id default 10
            , i_app_name                in com_api_type_pkg.t_name
            , i_dgi                     in com_api_type_pkg.t_tag
            , i_recursive_path          in com_api_type_pkg.t_name default null
            , i_entity_type             in com_api_type_pkg.t_dict_value
            , i_object_id               in com_api_type_pkg.t_short_id
            , io_namespace              in out com_api_type_pkg.t_dict_value
        ) is
            l_element_order             com_api_type_pkg.t_tiny_id;
            l_tags                      sys_refcursor;
            l_recursive_path            com_api_type_pkg.t_name;
            l_element_id                com_api_type_pkg.t_short_id;
            l_element_seqnum            com_api_type_pkg.t_seqnum;
        begin
            if io_namespace is null then
                io_namespace := get_profile (
                    i_namespace  => i_tag_rec.namespace
                );
            end if;
            
            emv_ui_element_pkg.add_element (
                o_id                => l_element_id
                , o_seqnum          => l_element_seqnum
                , i_parent_id       => i_parent_id
                , i_entity_type     => i_entity_type
                , i_object_id       => i_object_id
                , i_element_order   => i_element_order
                , i_code            => i_tag_rec.tagcode
                , i_tag             => i_tag_rec.from_
                , i_value           => default_value(i_tag_rec.tagcode, i_tag_rec.from_, i_tag_rec.value, nvl(io_namespace, emv_api_const_pkg.PROFILE_CONTACT))
                , i_is_optional     => nvl(i_tag_rec.isoptional, 0)
                , i_add_length      => nvl(i_tag_rec.includelen, 0)
                , i_start_position  => i_tag_rec.index_
                , i_length          => i_tag_rec.size_
                , i_profile         => get_profile(i_tag_rec.namespace)
            );
            
            if i_tag_rec.from_ is null then
                l_element_order := 10;
                l_recursive_path := i_recursive_path ||'[@TagCode="'|| i_tag_rec.tagcode ||'"]/Tag';
                
                l_result := '
                select
                    tg.TagCode
                    , tg.includeLen
                    , tg.from_
                    , tg.namespace
                    , tg.value
                    , tg.isOptional
                    , tg.function_
                    , tg.index_
                    , tg.size_
                from
                    (select :l_xml_content xml_content from dual) co
                    , xmltable( ''/config/Apps/App[@name="'
                                 || i_app_name ||'"]/DataGroup[@DGI="'
                                 || i_dgi ||'"]/Tag'
                                 || l_recursive_path ||'''
                        PASSING co.xml_content
                        COLUMNS TagCode        VARCHAR2(64) PATH ''@TagCode''
                                , includeLen VARCHAR2(64)   PATH ''@includeLen''
                                , from_      VARCHAR2(64)   PATH ''@from''
                                , namespace  VARCHAR2(64)   PATH ''@namespace''
                                , value      VARCHAR2(4000) PATH ''@value''
                                , isOptional VARCHAR2(64)   PATH ''@isOptional''
                                , function_  VARCHAR2(64)   PATH ''@function''
                                , index_     VARCHAR2(64)   PATH ''@index''
                                , size_      VARCHAR2(64)   PATH ''@size''
                    ) tg';
                open l_tags for l_result using l_xml_content;
                loop
                    fetch l_tags into l_tag;
                    exit when l_tags%notfound;
                    
                    process_tag ( 
                        i_tag_rec           => l_tag
                        , i_parent_id       => l_element_id
                        , i_element_order   => l_element_order
                        , i_app_name        => i_app_name
                        , i_dgi             => i_dgi
                        , i_recursive_path  => l_recursive_path
                        , i_entity_type     => i_entity_type
                        , i_object_id       => i_object_id
                        , io_namespace      => io_namespace
                    );
                    inc_(l_element_order, 10);
                end loop;
                close l_tags;
            end if;
        exception
            when others then
                if l_tags%isopen then
                    close l_tags;
                end if;
                raise;
        end;
        
        procedure process_var_elm (
            i_var_rec                   in t_var_rec
            , i_parent_id               in com_api_type_pkg.t_short_id default null
            , i_element_order           in com_api_type_pkg.t_tiny_id default 10
            , i_entity_type             in com_api_type_pkg.t_dict_value
            , i_object_id               in com_api_type_pkg.t_short_id
            , o_element_id              out com_api_type_pkg.t_short_id
            , o_element_seqnum          out com_api_type_pkg.t_seqnum
        ) is
            l_from                      com_api_type_pkg.t_name;
        begin
            case upper(i_var_rec.function_)
                when 'GETRSAKEKALGID' then
                    l_from := 'DF8011';
                when 'KEKDERIVATIONDATAEXISTS' then
                    l_from := 'DF8014';
            else
                l_from := null;
            end case;
            
            emv_ui_element_pkg.add_element (
                o_id                => o_element_id
                , o_seqnum          => o_element_seqnum
                , i_parent_id       => i_parent_id
                , i_entity_type     => i_entity_type
                , i_object_id       => i_object_id
                , i_element_order   => i_element_order
                , i_code            => i_var_rec.tagcode
                , i_tag             => nvl(i_var_rec.from_, l_from)
                , i_value           => default_value(i_var_rec.tagcode, nvl(i_var_rec.from_, l_from), i_var_rec.value, emv_api_const_pkg.PROFILE_CONTACT)
                , i_is_optional     => 0
                , i_add_length      => nvl(i_var_rec.includelen, 0)
                , i_start_position  => null
                , i_length          => null
            );
        end;
        
        procedure process_var (
            i_var_rec                   in t_var_rec
            , i_parent_id               in com_api_type_pkg.t_short_id default null
            , i_element_order           in com_api_type_pkg.t_tiny_id default 10
            , i_recursive_path          in com_api_type_pkg.t_name default null
            , i_entity_type             in com_api_type_pkg.t_dict_value
            , i_object_id               in com_api_type_pkg.t_short_id
        ) is
            l_variable                  t_var_rec;
            l_variables                 sys_refcursor;
            l_element_order             com_api_type_pkg.t_tiny_id;
            l_recursive_path            com_api_type_pkg.t_name;
            l_element_id                com_api_type_pkg.t_short_id;
            l_element_seqnum            com_api_type_pkg.t_seqnum;
        begin
            if i_var_rec.name is null then
                process_var_elm (
                    i_var_rec           => i_var_rec
                    , i_parent_id       => i_parent_id
                    , i_element_order   => i_element_order
                    , i_entity_type     => i_entity_type
                    , i_object_id       => i_object_id
                    , o_element_id      => l_element_id
                    , o_element_seqnum  => l_element_seqnum
                );
            end if;
            
            if i_var_rec.from_ is not null then
                null;
            elsif i_var_rec.value is not null then
                null;
            elsif i_var_rec.function_ is not null then
                null;
            elsif i_var_rec.var_ is not null and i_var_rec.var_.isFragment() = 1 then
                l_element_order := 10;
                l_recursive_path := i_recursive_path;
                                  --||'[@name="'|| i_var_rec.name ||'" '
                                  --||'or @TagCode="'|| i_var_rec.tagcode ||'"]/Var';
                                  --||'[@TagCode="'|| i_var_rec.tagcode ||'"]/Var';
                
                l_result := '
                SELECT va.var_, va.name, va.TagCode, va.includeLen
                     , va.from_, va.value, va.valueType
                     , va.function_
                  FROM (select :l_xml_content xml_content from dual) co
                     , xmltable( ''/config/AppVars/Var'|| l_recursive_path ||'''
                                 PASSING co.xml_content
                                 COLUMNS 
                                       var_         XMLTYPE        PATH ''Var''
                                       , name       VARCHAR2(64)   PATH ''@name''
                                       , TagCode    VARCHAR2(64)   PATH ''@TagCode''
                                       , includeLen VARCHAR2(64)   PATH ''@includeLen''
                                       , from_      VARCHAR2(64)   PATH ''@from''
                                       , value      VARCHAR2(4000) PATH ''@value''
                                       , valueType  VARCHAR2(64)   PATH ''@valueType''
                                       , function_  VARCHAR2(64)   PATH ''@function''
                      ) va';
                  
                  open l_variables for l_result using l_xml_content;
                  loop
                    fetch l_variables into l_variable;
                    exit when l_variables%notfound;
                    
                    process_var ( 
                        i_var_rec           => l_variable
                        , i_parent_id       => l_element_id
                        , i_element_order   => l_element_order
                        , i_recursive_path  => l_recursive_path||'[@TagCode="'|| l_variable.tagcode ||'"]/Var'
                        , i_entity_type     => i_entity_type
                        , i_object_id       => i_object_id
                    );
                    inc_(l_element_order, 10);
                end loop;
                close l_variables;
            end if;
        exception
            when others then
                if l_variables%isopen then
                    close l_variables;
                end if;
                raise;
        end;
      
    begin
        trc_log_pkg.debug (
            i_text  => 'Read convert EMV profile'
        );
        
        prc_api_stat_pkg.log_start;

        savepoint read_process_start;

        -- get estimated count
        select
            count(s.id)
        into
            l_estimated_count
        from
            prc_session_file s
            , prc_file_attribute_vw a
            , prc_file_vw f
        where
            s.session_id = prc_api_session_pkg.get_session_id
            and s.file_attr_id = a.id
            and f.id = a.file_id
            and f.file_purpose = prc_api_const_pkg.FILE_PURPOSE_IN
            and f.file_nature = prc_api_const_pkg.FILE_NATURE_CLOB;

        prc_api_stat_pkg.log_estimation (
            i_estimated_count  => l_estimated_count
        );
        
        -- get files
        for r in (
            select
                s.file_name
                , s.file_contents clob_content
            from
                prc_session_file s
                , prc_file_attribute_vw a
                , prc_file_vw f
            where
                s.session_id = prc_api_session_pkg.get_session_id
                and s.file_attr_id = a.id
                and f.id = a.file_id
                and f.file_purpose = prc_api_const_pkg.FILE_PURPOSE_IN
                and f.file_nature = prc_api_const_pkg.FILE_NATURE_CLOB
            order by
                s.id
        ) loop
            trc_log_pkg.debug (
                i_text          => 'Process file [#1]'
                , i_env_param1  => r.file_name
            );
            
            l_xml_content := xmltype(r.clob_content);
            l_save_variable := com_api_type_pkg.TRUE;

            for scheme in (
                select
                    re.schemename
                from
                    (select l_xml_content xml_content from dual) co
                    , xmltable('/config/CardTemplates/CardTemplate'
                        PASSING co.xml_content
                        COLUMNS schemename VARCHAR2(200) PATH '@name'
                    ) re
            ) loop
                -- save scheme
                emv_ui_appl_scheme_pkg.add_appl_scheme (
                    o_id             => l_appl_scheme_id
                    , o_seqnum       => l_appl_scheme_seqnum
                    , i_inst_id      => ost_api_const_pkg.DEFAULT_INST
                    , i_type         => null
                    , i_lang         => get_user_lang
                    , i_name         => scheme.schemename
                    , i_description  => scheme.schemename
                );

                init_def_tag_values (
                    i_scheme_id  => l_appl_scheme_id
                );

                for appl in (
                    select
                        re.appname
                        , re.aid
                        , re.idowner
                    from
                        (select l_xml_content xml_content from dual) co
                        , xmltable('/config/CardTemplates/CardTemplate/AppReference'
                            PASSING co.xml_content
                            COLUMNS AppName   VARCHAR2(200) PATH '@AppName'
                                    , AID     VARCHAR2(64) PATH '@AID'
                                    , IDOWNER VARCHAR2(64) PATH '@IDOWNER'
                        ) re
                ) loop
                    if appl.idowner in ('A000000003', 'A000000004') then
                        emv_ui_appl_scheme_pkg.modify_appl_scheme (
                            i_id             => l_appl_scheme_id
                            , io_seqnum      => l_appl_scheme_seqnum
                            , i_inst_id      => ost_api_const_pkg.DEFAULT_INST
                            , i_type         => case when appl.idowner = 'A000000003' then emv_api_const_pkg.EMV_SCHEME_VISA else emv_api_const_pkg.EMV_SCHEME_MC end
                            , i_lang         => get_user_lang
                            , i_name         => scheme.schemename
                            , i_description  => scheme.schemename
                        );
                    end if;
                    -- save application
                    emv_ui_application_pkg.add_application (
                        o_id                => l_appl_id
                        , o_seqnum          => l_appl_seqnum
                        , i_aid             => appl.aid
                        , i_id_owner        => appl.idowner
                        , i_appl_scheme_id  => l_appl_scheme_id
                        , i_lang            => get_user_lang
                        , i_name            => appl.appname
                    );

                    l_element_order := 10;

                    if l_save_variable = com_api_type_pkg.TRUE then
                        for var in (
                            select
                                va.var_
                                , va.name
                                , va.tagcode
                                , va.includelen
                                , va.from_
                                , va.value
                                , va.valuetype
                                , va.function_
                            from
                                (select l_xml_content xml_content from dual) co
                                , xmltable( '/config/AppVars/Var'
                                  PASSING co.xml_content
                                  COLUMNS var_         XMLTYPE      PATH 'Var'
                                          , name       VARCHAR2(64) PATH '@name'
                                          , TagCode    VARCHAR2(64) PATH '@TagCode'
                                          , includeLen VARCHAR2(64) PATH '@includeLen'
                                          , from_      VARCHAR2(64) PATH '@from'
                                          , value      VARCHAR2(4000) PATH '@value'
                                          , valueType  VARCHAR2(64) PATH '@valueType'
                                          , function_  VARCHAR2(64) PATH '@function'
                                ) va
                            union all
                            select
                                null
                                , 'ECB'
                                , ''
                                , '0'
                                , ''
                                , '03'
                                , ''
                                , ''
                            from
                                dual
                            union all
                            select
                                null
                                , 'CBC'
                                , ''
                                , '0'
                                , ''
                                , '83'
                                , ''
                                , ''
                            from
                                dual
                        ) loop
                            case upper(var.name)
                                when PEK_TK_ID then
                                    l_variable_type := emv_api_const_pkg.VAR_TYPE_TKEY;
                                when KEK_TK_ID then
                                    l_variable_type := emv_api_const_pkg.VAR_TYPE_TKEY;
                                when ECB then
                                    l_variable_type := emv_api_const_pkg.VAR_TYPE_ALGORITHM;
                                when CBC then
                                    l_variable_type := emv_api_const_pkg.VAR_TYPE_ALGORITHM;
                                when RSA_KEK_ALG_ID then
                                    l_variable_type := emv_api_const_pkg.VAR_TYPE_ALGORITHM;
                                when METADATA then
                                    l_variable_type := emv_api_const_pkg.VAR_TYPE_METADATA;
                            else
                                l_variable_type := emv_api_const_pkg.VAR_TYPE_TKEY;
                                -- raise
                            end case;

                            -- save variable
                            emv_ui_variable_pkg.add_variable (
                                o_id                => l_var_id
                                , o_seqnum          => l_var_seqnum
                                , i_application_id  => l_appl_id
                                , i_variable_type   => l_variable_type
                                , i_profile         => nvl(l_namespace, emv_api_const_pkg.PROFILE_CONTACT)
                                , i_lang            => get_user_lang
                                , i_name            => upper(var.name)
                            );

                            if var.name is not null then
                                l_var_tab(var.name) := l_var_id;
                                dbms_output.put_line('i_var_rec.name['||var.name||'] i_object_id['||l_var_id||']');
                            end if;

                            if var.var_ is not null and var.var_.isFragment() = 1 then
                                process_var (
                                    i_var_rec           => var
                                    , i_parent_id       => null
                                    , i_recursive_path  => '[@name="'||var.name||'"]/Var'
                                    , i_element_order   => l_element_order
                                    , i_entity_type     => emv_api_const_pkg.ENTITY_TYPE_EMV_VAR
                                    , i_object_id       => l_var_id
                                );
                            else
                                process_var_elm (
                                    i_var_rec           => var
                                    , i_parent_id       => null
                                    , i_element_order   => l_element_order
                                    , i_entity_type     => emv_api_const_pkg.ENTITY_TYPE_EMV_VAR
                                    , i_object_id       => l_var_id
                                    , o_element_id      => l_element_id
                                    , o_element_seqnum  => l_element_seqnum
                                );
                            end if;

                            inc_(l_element_order, 10);
                            inc_(l_variable_order, 10);
                        end loop;

                        l_save_variable := com_api_type_pkg.FALSE;
                    end if;

                    --
                    l_block_order := 10;
                    l_result := '
                      select dg.DGI, dg.isEncrypted, dg.TKID, dg.AlgID
                        from (select :l_xml_content xml_content from dual) co
                           , xmltable( ''/config/Apps/App[@name="'|| appl.AppName ||'"]/DataGroup''
                                       PASSING co.xml_content
                                       COLUMNS DGI         VARCHAR2(64) PATH ''@DGI''
                                             , isEncrypted VARCHAR2(64) PATH ''@isEncrypted''
                                             , TKID        VARCHAR2(64) PATH ''@TKID''
                                             , AlgID       VARCHAR2(64) PATH ''@AlgID''
                                     ) dg';

                    open l_blocks for l_result using l_xml_content;
                    loop
                        fetch l_blocks into l_block;
                        exit when l_blocks%notfound;

                        -- init
                        l_afl := com_api_type_pkg.FALSE;
                        l_sda := com_api_type_pkg.FALSE;
                        l_namespace := null;
                        l_tk_id := null;
                        l_alg_id := null;
                        l_element_order := 10;

                        l_result := '
                        select att.name, att.value
                        from (select :l_xml_content xml_content from dual) co
                           , xmltable( ''/config/Apps/App[@name="'
                                       || appl.appname ||'"]/DataGroup[@DGI="'
                                       || l_block.dgi ||'"]/Attributes/Attribute''
                                       PASSING co.xml_content
                                       COLUMNS name    VARCHAR2(64)   PATH ''@name''
                                             , value   VARCHAR2(4000)   PATH ''@value''
                                     ) att';

                        open l_attrs for l_result using l_xml_content;
                        loop
                            fetch l_attrs into l_attr;
                            exit when l_attrs%notfound;

                            case upper(l_attr.name)
                                when 'INCLUDEDINAFL'  then
                                    if l_attr.value = '1' then
                                        l_afl := com_api_type_pkg.TRUE;
                                    end if;
                                when 'INCLUDEDINSDA'  then
                                    if l_attr.value = '1' then
                                        l_sda := com_api_type_pkg.TRUE;
                                    end if;
                                when 'NAMESPACE'      then
                                    l_namespace := get_profile (
                                        i_namespace  => l_attr.value
                                    );
                            else
                                null;
                            end case;
                        end loop;
                        close l_attrs;

                        if l_block.isencrypted = '1' then
                            if substr( l_block.tkid, 1, 1 ) = '$' then
                                if l_var_tab.exists(substr(l_block.tkid, 2)) then
                                    l_tk_id := l_var_tab(substr(l_block.tkid, 2));
                                end if;
                            end if;

                            if substr( l_block.algid, 1, 1 ) = '$' then
                                if l_var_tab.exists(substr(l_block.algid, 2)) then
                                    l_alg_id := l_var_tab(substr(l_block.algid, 2));
                                end if;
                            elsif l_block.algid in ('ECB','CBC') then
                                if l_var_tab.exists(l_block.algid) then
                                    l_alg_id := l_var_tab(l_block.algid);
                                end if;
                            end if;
                        end if;

                        l_namespace := nvl(l_namespace, emv_api_const_pkg.PROFILE_CONTACT);

                        -- save block
                        emv_ui_block_pkg.add_block (
                            o_id                  => l_block_id
                            , o_seqnum            => l_block_seqnum
                            , i_application_id    => l_appl_id
                            , i_code              => l_block.dgi
                            , i_include_in_sda    => l_sda
                            , i_include_in_afl    => l_afl
                            , i_transport_key_id  => l_tk_id
                            , i_encryption_id     => l_alg_id
                            , i_block_order       => l_block_order
                            , i_profile           => nvl(l_namespace, emv_api_const_pkg.PROFILE_CONTACT)
                        );
                        
                        l_result := '
                        select
                            tg.TagCode, tg.includeLen, tg.from_, tg.namespace, tg.value
                            , tg.isOptional, tg.function_, tg.index_, tg.size_
                        from
                            (select :l_xml_content xml_content from dual) co
                            , xmltable( ''/config/Apps/App[@name="'
                                       || appl.appname ||'"]/DataGroup[@DGI="'
                                       || l_block.dgi ||'"]/Tag'
                                       || null ||'''
                                PASSING co.xml_content
                                COLUMNS TagCode       VARCHAR2(64)   PATH ''@TagCode''
                                        , includeLen  VARCHAR2(64)   PATH ''@includeLen''
                                        , from_       VARCHAR2(64)   PATH ''@from''
                                        , namespace   VARCHAR2(64)   PATH ''@namespace''
                                        , value       VARCHAR2(4000) PATH ''@value''
                                        , isOptional  VARCHAR2(64)   PATH ''@isOptional''
                                        , function_   VARCHAR2(64)   PATH ''@function''
                                        , index_      VARCHAR2(64)   PATH ''@index''
                                        , size_       VARCHAR2(64)   PATH ''@size''
                            ) tg';

                        open l_tags for l_result using l_xml_content;
                        loop
                            fetch l_tags into l_tag;
                            exit when l_tags%notfound;

                            process_tag (
                                i_tag_rec          => l_tag
                                , i_parent_id      => null
                                , i_element_order  => l_element_order
                                , i_app_name       => appl.appname
                                , i_dgi            => l_block.dgi
                                , i_entity_type    => emv_api_const_pkg.ENTITY_TYPE_EMV_BLOCK
                                , i_object_id      => l_block_id
                                , io_namespace     => l_namespace
                            );
                            inc_(l_element_order, 10);
                        end loop;
                        close l_tags;

                        -- modify profile
                        emv_ui_block_pkg.modify_block (
                            i_id                  => l_block_id
                            , io_seqnum           => l_block_seqnum
                            , i_application_id    => l_appl_id
                            , i_code              => l_block.dgi
                            , i_include_in_sda    => l_sda
                            , i_include_in_afl    => l_afl
                            , i_transport_key_id  => l_tk_id
                            , i_encryption_id     => l_alg_id
                            , i_block_order       => l_block_order
                            , i_profile           => nvl(l_namespace, emv_api_const_pkg.PROFILE_CONTACT)
                        );

                        inc_(l_block_order, 10);
                    end loop;
                    close l_blocks;
                end loop;
            end loop;

            l_tag_tab.delete;
            
            l_processed_count := l_processed_count + 1;

            prc_api_stat_pkg.log_current (
                i_current_count     => l_processed_count
                , i_excepted_count  => l_excepted_count
            );
        end loop;
        
        prc_api_stat_pkg.log_end (
            i_excepted_total     => l_excepted_count
            , i_processed_total  => l_processed_count
            , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
        
        trc_log_pkg.debug (
            i_text  => 'Read convert EMV profile finished...'
        );
    exception
        when others then
            l_tag_tab.delete;
            
            if l_vars%isopen then
                close l_vars;
            end if;
            if l_tags%isopen then
                close l_tags;
            end if;
            if l_attrs%isopen then
                close l_attrs;
            end if;
            if l_blocks%isopen then
                close l_blocks;
            end if;
            dbms_output.put_line(sqlerrm);
            
            rollback to savepoint read_process_start;

            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error (
                    i_error         => 'UNHANDLED_EXCEPTION'
                    , i_env_param1  => sqlerrm
                );
            end if;
            raise;
    end;

end;
/
