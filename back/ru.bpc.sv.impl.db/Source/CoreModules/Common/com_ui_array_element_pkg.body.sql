create or replace package body com_ui_array_element_pkg is
/*********************************************************
*  UI for array <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 01.07.2011 <br />
*  Last changed by $Author: fomichev$ <br />
*  $LastChangedDate:: 2011-07-01 13:31:16 +0400#$ <br />
*  Revision: $LastChangedRevision: 10600 $ <br />
*  Module: com_ui_array_pkg <br />
*  @headcom
**********************************************************/

procedure add_array_element (
    o_id                 out  com_api_type_pkg.t_short_id
  , o_seqnum             out  com_api_type_pkg.t_seqnum
  , i_array_id        in      com_api_type_pkg.t_short_id
  , i_data_type       in      com_api_type_pkg.t_dict_value
  , i_value_char      in      com_api_type_pkg.t_name
  , i_value_number    in      number
  , i_value_date      in      date
  , i_element_number  in      com_api_type_pkg.t_tiny_id        default null
  , i_lang            in      com_api_type_pkg.t_dict_value
  , i_label           in      com_api_type_pkg.t_name           
  , i_description     in      com_api_type_pkg.t_full_desc      default null
) is
    l_element_value           com_api_type_pkg.t_name;
    l_element_number          com_api_type_pkg.t_tiny_id;
    
begin
    l_element_number := i_element_number;
    
    case i_data_type
        when com_api_const_pkg.DATA_TYPE_CHAR then
           l_element_value := i_value_char;
        
        when com_api_const_pkg.DATA_TYPE_NUMBER then
            l_element_value := to_char(i_value_number, com_api_const_pkg.NUMBER_FORMAT);
        
        when com_api_const_pkg.DATA_TYPE_DATE then
            l_element_value := to_char(i_value_date, com_api_const_pkg.DATE_FORMAT);
        else 
            com_api_error_pkg.raise_error (
                i_error       => 'WRONG_ARRAY_ELEMENT_DATA_TYPE'
              , i_env_param1  => i_data_type
            );
    end case;

    o_id := com_array_element_seq.nextval;
    o_seqnum := 1;

    if l_element_number is null then
        select max(element_number) + 1
          into l_element_number
          from com_array_element
         where array_id = i_array_id;
    end if;
    
    insert into com_array_element_vw (
        id
      , seqnum
      , array_id
      , element_value
      , element_number
      , numeric_value
    ) values (
        o_id
      , o_seqnum
      , i_array_id
      , l_element_value
      , l_element_number
      , i_value_number
    );
   
    com_api_i18n_pkg.add_text (
        i_table_name   => 'com_array_element'
      , i_column_name  => 'label'
      , i_object_id    => o_id
      , i_lang         => i_lang
      , i_text         => i_label
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'com_array_element'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_lang         => i_lang
      , i_text         => i_description
    );
end;

procedure modify_array_element (
    i_id              in      com_api_type_pkg.t_short_id
  , io_seqnum         in out  com_api_type_pkg.t_seqnum
  , i_array_id        in      com_api_type_pkg.t_short_id
  , i_data_type       in      com_api_type_pkg.t_dict_value
  , i_value_char      in      com_api_type_pkg.t_name
  , i_value_number    in      number
  , i_value_date      in      date
  , i_element_number  in      com_api_type_pkg.t_tiny_id
  , i_lang            in      com_api_type_pkg.t_dict_value
  , i_label           in      com_api_type_pkg.t_name
  , i_description     in      com_api_type_pkg.t_full_desc
) is
    l_element_value           com_api_type_pkg.t_name;
begin
    case i_data_type
        when com_api_const_pkg.DATA_TYPE_CHAR then
           l_element_value := i_value_char;
        
        when com_api_const_pkg.DATA_TYPE_NUMBER then
            l_element_value := to_char(i_value_number, com_api_const_pkg.NUMBER_FORMAT);
        
        when com_api_const_pkg.DATA_TYPE_DATE then
            l_element_value := to_char(i_value_date, com_api_const_pkg.DATE_FORMAT);
    else 
        com_api_error_pkg.raise_error (
            i_error         => 'WRONG_ARRAY_ELEMENT_DATA_TYPE'
            , i_env_param1  => i_data_type
        );
    end case;
    
    update com_array_element_vw
       set seqnum         =  io_seqnum
         , array_id       =  i_array_id
         , element_value  =  l_element_value
         , element_number =  i_element_number
         , numeric_value  =  i_value_number
     where id = i_id;

    io_seqnum := io_seqnum + 1;

    com_api_i18n_pkg.add_text (
        i_table_name   => 'com_array_element'
      , i_column_name  => 'label'
      , i_object_id    => i_id
      , i_lang         => i_lang
      , i_text         => i_label
    );
    
    com_api_i18n_pkg.add_text (
        i_table_name   => 'com_array_element'
      , i_column_name  => 'description'
      , i_object_id    => i_id
      , i_lang         => i_lang
      , i_text         => i_description
    );

end;

procedure remove_array_element (
    i_id                    in com_api_type_pkg.t_short_id
  , i_seqnum                in com_api_type_pkg.t_seqnum
) is
begin
    com_api_i18n_pkg.remove_text (
        i_table_name => 'com_array_element'
      , i_object_id  => i_id
    );

    update com_array_element_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete from com_array_element_vw
    where id = i_id;
end;

end;
/
