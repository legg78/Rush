create or replace package body app_api_note_pkg as
/*********************************************************
 *  Acquiring/issuing application API  <br />
 *  Created by Sergey Ivanov (sr.ivanov@bpcbt.com)  at 16.08.2018 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: app_api_note_pkg <br />
 *  @headcom
 **********************************************************/
procedure process_note(
    i_appl_data_id     in     com_api_type_pkg.t_long_id
  , i_entity_type      in     com_api_type_pkg.t_dict_value
  , i_object_id        in     com_api_type_pkg.t_medium_id
) is
    l_id_tab                  com_api_type_pkg.t_number_tab;
    l_id_tab_child            com_api_type_pkg.t_number_tab;
    l_note_type               com_api_type_pkg.t_dict_value;
    l_note_header             com_api_type_pkg.t_text;
    l_note_text               com_api_type_pkg.t_text;
    l_start_date              date;
    l_end_date                date;
    l_note_id                 com_api_type_pkg.t_long_id;
    l_lang_tab                com_api_type_pkg.t_dict_tab;
begin
    trc_log_pkg.debug('app_api_note_pkg.process_note start');
    

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'NOTE'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );
    
    for j in 1..nvl(l_id_tab.count, 0) loop
        app_api_application_pkg.get_element_value(
            i_element_name   => 'NOTE_TYPE'
          , i_parent_id      => l_id_tab(j)
          , o_element_value  => l_note_type
        );

        app_api_application_pkg.get_appl_data_id(
            i_element_name      => 'NOTE_CONTENT'
          , i_parent_id         => l_id_tab(j)
          , o_appl_data_id      => l_id_tab_child
          , o_appl_data_lang    => l_lang_tab
        );

        for k in 1..nvl(l_id_tab_child.count, 0) loop
            app_api_application_pkg.get_element_value(
                i_element_name   => 'NOTE_HEADER'
              , i_parent_id      => l_id_tab_child(k)
              , o_element_value  => l_note_header
            );
            app_api_application_pkg.get_element_value(
                i_element_name   => 'NOTE_TEXT'
              , i_parent_id      => l_id_tab_child(k)
              , o_element_value  => l_note_text
            );
            app_api_application_pkg.get_element_value(
                i_element_name   => 'START_DATE'
              , i_parent_id      => l_id_tab_child(k)
              , o_element_value  => l_start_date
            );
            app_api_application_pkg.get_element_value(
                i_element_name   => 'END_DATE'
              , i_parent_id      => l_id_tab_child(k)
              , o_element_value  => l_end_date
            );
            ntb_ui_note_pkg.add(
                o_id            => l_note_id
              , i_entity_type   => i_entity_type
              , i_object_id     => i_object_id
              , i_note_type     => l_note_type
              , i_lang          => l_lang_tab(k)
              , i_header        => l_note_header
              , i_text          => l_note_text
              , i_start_date    => l_start_date
              , i_end_date      => l_end_date
            );
        end loop;
    end loop;
    trc_log_pkg.debug('app_api_note_pkg.process_note end');
    
end process_note;

end;
/

