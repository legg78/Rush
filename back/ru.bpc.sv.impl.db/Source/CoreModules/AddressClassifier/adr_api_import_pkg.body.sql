create or replace package body adr_api_import_pkg as

-- Processing of Incoming DANE files
procedure process_dane(
    i_department_code_tab     in com_api_type_pkg.t_curr_code_tab
  , i_department_name_tab     in com_api_type_pkg.t_name_tab
  , i_municipality_code_tab   in com_api_type_pkg.t_curr_code_tab
  , i_municipality_name_tab   in com_api_type_pkg.t_name_tab
  , i_dane_code_tab           in com_api_type_pkg.t_dict_tab
  , i_country_code            in com_api_type_pkg.t_country_code
  , i_lang                    in com_api_type_pkg.t_dict_value
) is
    l_place_id                   com_api_type_pkg.t_short_id;
    l_country_id                 com_api_type_pkg.t_tiny_id;
    l_comp_id                    com_api_type_pkg.t_tiny_id;
begin
    begin
        select id 
          into l_country_id
          from com_country c 
         where code = i_country_code;
    exception
        when no_data_found then
            l_country_id := adr_api_const_pkg.UNDEFINED_COUNTRY_ID;
    end;
    
    begin
        select c.id
          into l_comp_id
          from adr_component c
         where c.id                = adr_api_const_pkg.ADDRESS_COMPONENT_DEPARTMENT
           and c.country_id        = l_country_id
           and c.lang              = i_lang;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'ADDRESS_COMPONENT_NOT_FOUND'
                , i_env_param1  => l_country_id
                , i_env_param2  => i_lang
                , i_env_param3  => adr_api_const_pkg.ADDRESS_COMPONENT_DEPARTMENT
            );
    end;

    for i in 1 .. i_department_code_tab.count loop
        begin
            select p.id
              into l_place_id
              from adr_place p
                 , adr_component c
             where c.id                = l_comp_id
               and c.country_id        = l_country_id
               and c.lang              = i_lang
               and p.comp_id           = c.id
               and p.lang              = c.lang
               and upper(p.place_name) = upper(i_department_name_tab(i))
               and p.place_code        = i_department_code_tab(i);
        exception
            when no_data_found then
                l_place_id    := adr_place_seq.nextval;
                insert into adr_place (
                    id
                  , parent_id
                  , place_code
                  , place_name
                  , comp_id
                  , comp_level
                  , postal_code
                  , region_code
                  , lang
                ) values (
                    l_place_id
                  , null
                  , i_department_code_tab(i)
                  , i_department_name_tab(i)
                  , l_comp_id
                  , 1
                  , null
                  , i_department_code_tab(i)
                  , i_lang
                );
            when too_many_rows then
                com_api_error_pkg.raise_error(
                    i_error         => 'DUPLICATE_ADDRESS_COMPONENT'
                    , i_env_param1  => i_country_code
                    , i_env_param2  => i_lang
                    , i_env_param3  => i_department_code_tab(i)
                    , i_env_param4  => i_department_name_tab(i)
                );            
        end;
        merge into adr_place a
        using (
               select l_place_id                                          parent_id
                    , i_dane_code_tab(i)                                  place_code
                    , i_municipality_name_tab(i)                          place_name
                    , adr_api_const_pkg.ADDRESS_COMPONENT_MUNICIPALITY    comp_id
                    , 2                                                   comp_level
                    , i_municipality_code_tab(i)                          region_code
                    , i_lang                                              lang
                 from dual
              ) b
           on (a.place_code = b.place_code and a.parent_id = b.parent_id and a.lang = b.lang)
        when matched then
            update
               set a.place_name   = b.place_name
                 , a.comp_id      = b.comp_id
                 , a.comp_level   = b.comp_level
                 , a.region_code  = b.region_code
        when not matched then
            insert (
                id
              , parent_id
              , place_code
              , place_name
              , comp_id
              , comp_level
              , postal_code
              , region_code
              , lang
            ) values (
                adr_place_seq.nextval
              , l_place_id
              , i_dane_code_tab(i)
              , i_municipality_name_tab(i)
              , adr_api_const_pkg.ADDRESS_COMPONENT_MUNICIPALITY
              , 2
              , null
              , i_municipality_code_tab(i)
              , i_lang
            );
    end loop;
end process_dane;

end;
/
