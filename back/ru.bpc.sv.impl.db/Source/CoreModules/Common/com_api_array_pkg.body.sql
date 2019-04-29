create or replace package body com_api_array_pkg as

function conv_array_elem_v(
    i_array_type_id     in      com_api_type_pkg.t_tiny_id
  , i_array_id          in      com_api_type_pkg.t_short_id     default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_elem_value        in      com_api_type_pkg.t_name
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_type_pkg.TRUE
  , i_error_value       in      com_api_type_pkg.t_name         default null
) return com_api_type_pkg.t_name is
    l_array_id          com_api_type_pkg.t_short_id;
    l_result            com_api_type_pkg.t_name;
begin
    select id
      into l_array_id
      from (
            select a.id
              from com_array a
             where a.array_type_id = i_array_type_id
               and (i_array_id is null or a.id = i_array_id)
               and (i_inst_id is null or a.inst_id = ost_api_const_pkg.DEFAULT_INST or a.inst_id = i_inst_id)
             order by case a.inst_id when ost_api_const_pkg.DEFAULT_INST then 1 else 0 end
           )
     where rownum = 1;
     
    select e.out_element_value
      into l_result
      from com_array_conversion c
         , com_array_conv_elem  e
     where c.in_array_id      = l_array_id
       and e.conv_id          = c.id
       and e.in_element_value = i_elem_value
       and rownum             = 1;
       
    return l_result;
            
exception
    when no_data_found then
        if i_mask_error = com_api_type_pkg.TRUE then
            trc_log_pkg.debug (
                i_text          => 'Conversion array [#1] element [#2] not found, returning default value [#2]'
                , i_env_param1  => i_array_type_id 
                , i_env_param2  => i_elem_value
                , i_env_param3  => i_error_value
            );
            return i_error_value;
        else
            com_api_error_pkg.raise_error (
                i_error         => 'CONVERSION_ARRAY_ELEMENT_NOT_FOUND'
                , i_env_param1  => i_array_type_id
                , i_env_param2  => i_elem_value
                , i_env_param3  => i_error_value
            );
        end if;
end conv_array_elem_v;

function conv_array_elem_v (
    i_lov_id            in      com_api_type_pkg.t_tiny_id
  , i_array_type_id     in      com_api_type_pkg.t_tiny_id
  , i_array_id          in      com_api_type_pkg.t_short_id     default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_elem_value        in      com_api_type_pkg.t_name
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_type_pkg.TRUE
  , i_error_value       in      com_api_type_pkg.t_name         default null
) return com_api_type_pkg.t_name is
    l_array_id          com_api_type_pkg.t_short_id;
    l_result            com_api_type_pkg.t_name;
begin
    select id
      into l_array_id
      from (
            select a.id
              from com_array a
             where a.array_type_id = i_array_type_id
               and (i_array_id is null or a.id = i_array_id)
               and (i_inst_id is null or a.inst_id = ost_api_const_pkg.DEFAULT_INST or a.inst_id = i_inst_id)
             order by case a.inst_id when ost_api_const_pkg.DEFAULT_INST then 1 else 0 end
           )
     where rownum = 1;
     
    select e.out_element_value
      into l_result
      from com_array_conversion c
         , com_array_conv_elem  e
     where c.in_lov_id        = i_lov_id
       and c.out_array_id     = l_array_id
       and e.conv_id          = c.id
       and e.in_element_value = i_elem_value
       and rownum             = 1;
       
    return l_result;
            
exception
    when no_data_found then
        if i_mask_error = com_api_type_pkg.TRUE then
            trc_log_pkg.debug (
                i_text          => 'Conversion array [#1] element [#2] not found, returning default value [#2]'
                , i_env_param1  => i_array_type_id 
                , i_env_param2  => i_elem_value
                , i_env_param3  => i_error_value
            );
            return i_error_value;
        else
            com_api_error_pkg.raise_error (
                i_error         => 'CONVERSION_ARRAY_ELEMENT_NOT_FOUND'
                , i_env_param1  => i_array_type_id
                , i_env_param2  => i_elem_value
                , i_env_param3  => i_error_value
            );
        end if;
end conv_array_elem_v;

function get_elements(
    i_array_id  in  com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_array_element_tab as
    l_elements     com_api_type_pkg.t_array_element_tab;
begin
    for r in (
        select e.id, e.element_number, e.element_value
          from com_array_element e
         where array_id         = i_array_id
    )
    loop
        l_elements(l_elements.count+1).id            := r.id;
        l_elements(l_elements.count).element_number  := r.element_number;
        l_elements(l_elements.count).element_value   := r.element_value;
    end loop;
    
    return l_elements;
end get_elements;

function get_elements(
    i_array_id            in  com_api_type_pkg.t_short_id
  , i_pattern             in  com_api_type_pkg.t_name
  , i_replacement_string  in  com_api_type_pkg.t_name
  , i_start_position      in  com_api_type_pkg.t_tiny_id
  , i_occurrence          in  com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_array_element_cache_tab
is
    l_elements     com_api_type_pkg.t_array_element_cache_tab;
    l_index        com_api_type_pkg.t_name;
begin
    for r in (
        select e.id
             , e.element_number
             , e.element_value
          from com_array_element e
         where array_id = i_array_id
         order by e.seqnum      
    )
    loop
        l_index := regexp_replace(
                       r.element_value
                     , i_pattern
                     , i_replacement_string
                     , i_start_position
                     , i_occurrence
                   );

        l_elements(l_index).id             := r.id;
        l_elements(l_index).element_number := r.element_number;
        l_elements(l_index).element_value  := r.element_value;
    end loop;

    return l_elements;
end get_elements;

procedure sync_dynamic_array_element(
    i_object_id         in      com_api_type_pkg.t_long_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_agent_id          in      com_api_type_pkg.t_agent_id     default null
)is
    l_params            com_api_type_pkg.t_param_tab;
    l_result            com_api_type_pkg.t_boolean;
    l_count             com_api_type_pkg.t_inst_id;
    l_id                com_api_type_pkg.t_short_id;
    l_seqnum            com_api_type_pkg.t_seqnum;

begin
    rul_api_shared_data_pkg.load_params(
        i_entity_type  => i_entity_type
      , i_object_id    => i_object_id
      , io_params      => l_params
      , i_full_set     => com_api_type_pkg.TRUE
    );

    for r in(
        select a.id
             , a.mod_id 
          from com_array a 
             , com_array_type t
         where t.entity_type   = i_entity_type
           and a.array_type_id = t.id 
           and a.inst_id       = i_inst_id 
           and mod_id is not null
           and (i_agent_id is null or a.agent_id = i_agent_id)
    )
    loop     
   
        l_result := rul_api_mod_pkg.check_condition (
            i_mod_id       => r.mod_id
            , i_params     => l_params
        );
        
        if nvl(l_result, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
        
            select count(1)
              into l_count
              from com_array_element_vw
             where array_id = r.id 
               and numeric_value = i_object_id;     
                
            if l_count = 0 then   
                l_id := com_array_element_seq.nextval;
                l_seqnum := 1;

                insert into com_array_element_vw (
                    id
                  , seqnum
                  , array_id
                  , element_value
                  , element_number        
                  , numeric_value
                ) values (
                    l_id
                  , l_seqnum
                  , r.id
                  , i_object_id
                  , null
                  , i_object_id        
                );
            end if;          
        else
            delete from com_array_element_vw 
             where array_id = r.id 
               and numeric_value = i_object_id;     
        end if;
        
    end loop;
    
exception
    when others then
        trc_log_pkg.error(sqlerrm);
    
end sync_dynamic_array_element;

function is_element_in_array(
    i_array_id          in      com_api_type_pkg.t_short_id
  , i_elem_value        in      com_api_type_pkg.t_name  
) return com_api_type_pkg.t_boolean is
    l_data_type         com_api_type_pkg.t_dict_value;
    l_res               com_api_type_pkg.t_boolean;
begin
    begin
        select t.data_type
          into l_data_type
          from com_array a
             , com_array_type t
         where a.array_type_id = t.id
           and a.id = i_array_id;    
           
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'ARRAY_NOT_FOUND'
              , i_env_param1    => i_array_id  
            ); 
    end;
    
    begin
        select com_api_const_pkg.TRUE 
          into l_res
          from com_array_element
         where array_id         = i_array_id
           and element_value    = i_elem_value
           and rownum = 1;
           
    exception
        when no_data_found then
            l_res   :=  com_api_const_pkg.FALSE;
          
    end;
    
    return l_res;
    
end is_element_in_array;    

function get_element_list(
    i_array_id          in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_full_desc
is
    l_element_value_tab         com_api_type_pkg.t_name_tab;
    l_element_list              com_api_type_pkg.t_full_desc;
begin
    if i_array_id is not null then
        select ae.element_value
          bulk collect into l_element_value_tab
          from com_array_element ae
         where ae.array_id = i_array_id;

        for i in 1 .. l_element_value_tab.count loop
            l_element_list := l_element_list || l_element_value_tab(i) || ',';
        end loop;

        if l_element_list is not null then
            l_element_list := ',' || l_element_list;
        end if;
    end if;

    return l_element_list;
end get_element_list;

end com_api_array_pkg;
/
