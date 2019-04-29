create or replace package body acm_ui_widget_pkg as
/********************************************************* 
 *  Interface for widgets <br /> 
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 29.02.2012 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: acm_ui_widget_pkg <br /> 
 *  @headcom 
 **********************************************************/ 

procedure add_widget(
    o_id             out com_api_type_pkg.t_tiny_id
  , o_seqnum         out com_api_type_pkg.t_seqnum
  , i_path        in     com_api_type_pkg.t_full_desc
  , i_css_name    in     com_api_type_pkg.t_name
  , i_is_external in     com_api_type_pkg.t_boolean
  , i_width       in     com_api_type_pkg.t_tiny_id
  , i_height      in     com_api_type_pkg.t_tiny_id
  , i_priv_id     in     com_api_type_pkg.t_tiny_id
  , i_params_path in     com_api_type_pkg.t_full_desc
  , i_lang        in     com_api_type_pkg.t_dict_value
  , i_label       in     com_api_type_pkg.t_name
  , i_description in     com_api_type_pkg.t_full_desc
) is
begin
    o_id      := acm_widget_seq.nextval;
    o_seqnum  := 1;
    
    insert into acm_widget_vw(
        id
      , seqnum
      , path
      , css_name
      , is_external
      , width
      , height
      , priv_id
      , params_path
    ) values (
        o_id
      , o_seqnum
      , i_path
      , i_css_name
      , i_is_external
      , i_width
      , i_height
      , i_priv_id
      , i_params_path
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'acm_widget'
      , i_column_name  => 'label'
      , i_object_id    => o_id
      , i_text         => i_label
      , i_lang         => i_lang
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'acm_widget'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_text         => i_description
      , i_lang         => i_lang
    );
end;


procedure modify_widget(
    i_id          in     com_api_type_pkg.t_tiny_id
  , io_seqnum     in out com_api_type_pkg.t_seqnum
  , i_path        in     com_api_type_pkg.t_full_desc
  , i_css_name    in     com_api_type_pkg.t_name
  , i_is_external in     com_api_type_pkg.t_boolean
  , i_width       in     com_api_type_pkg.t_tiny_id
  , i_height      in     com_api_type_pkg.t_tiny_id
  , i_priv_id     in     com_api_type_pkg.t_tiny_id
  , i_params_path in     com_api_type_pkg.t_full_desc
  , i_lang        in     com_api_type_pkg.t_dict_value
  , i_label       in     com_api_type_pkg.t_name
  , i_description in     com_api_type_pkg.t_full_desc
) is
begin
    update acm_widget_vw
       set seqnum      = io_seqnum
         , path        = i_path
         , css_name    = i_css_name
         , is_external = i_is_external
         , width       = i_width
         , height      = i_height
         , priv_id     = i_priv_id
         , params_path = i_params_path
     where id          = i_id;
     
    io_seqnum := io_seqnum + 1;
    
    com_api_i18n_pkg.add_text(
        i_table_name   => 'acm_widget'
      , i_column_name  => 'label'
      , i_object_id    => i_id
      , i_text         => i_label
      , i_lang         => i_lang
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'acm_widget'
      , i_column_name  => 'description'
      , i_object_id    => i_id
      , i_text         => i_description
      , i_lang         => i_lang
    );
end;

procedure remove_widget(
    i_id          in     com_api_type_pkg.t_tiny_id
  , i_seqnum      in     com_api_type_pkg.t_seqnum
) is
    l_count                     pls_integer;
begin
    select 
        count(*)
    into
        l_count 
    from 
        acm_dashboard_widget_vw
    where
        widget_id = i_id;

    if l_count > 0 then
        com_api_error_pkg.raise_error (
            i_error  =>  'WIDGET_ALREADY_USED'
        );
    end if;

    update acm_widget_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete from acm_widget_vw
    where id      = i_id;
    
    com_api_i18n_pkg.remove_text(
        i_table_name => 'acm_widget'
      , i_object_id  => i_id
    );
end;

end;
/
