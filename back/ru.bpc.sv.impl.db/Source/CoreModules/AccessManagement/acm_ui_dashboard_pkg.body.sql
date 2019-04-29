create or replace package body acm_ui_dashboard_pkg as
/********************************************************* 
 *  Interface for dashboards <br /> 
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 29.02.2012 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: acm_ui_dashboard_pkg <br /> 
 *  @headcom 
 **********************************************************/ 

procedure add_dashboard(
    o_id             out com_api_type_pkg.t_short_id
  , o_seqnum         out com_api_type_pkg.t_seqnum
  , i_user_id     in     com_api_type_pkg.t_short_id
  , i_inst_id     in     com_api_type_pkg.t_inst_id
  , i_is_shared   in     com_api_type_pkg.t_boolean
  , i_lang        in     com_api_type_pkg.t_dict_value
  , i_label       in     com_api_type_pkg.t_name
  , i_description in     com_api_type_pkg.t_full_desc
) is
    l_id       com_api_type_pkg.t_short_id;
    l_seqnum   com_api_type_pkg.t_seqnum;
begin
    o_id      := acm_dashboard_seq.nextval;
    o_seqnum  := 1;
    
    insert into acm_dashboard_vw(
        id
      , seqnum
      , user_id
      , inst_id
      , is_shared
    ) values (
        o_id
      , o_seqnum
      , i_user_id
      , i_inst_id
      , i_is_shared
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'acm_dashboard'
      , i_column_name  => 'label'
      , i_object_id    => o_id
      , i_text         => i_label
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'acm_dashboard'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_text         => i_description
      , i_lang         => i_lang
    );
    
    add_dashboard_user(
        o_id            => l_id
      , o_seqnum        => l_seqnum
      , i_dashboard_id  => o_id 
      , i_user_id       => i_user_id
      , i_is_default    => com_api_const_pkg.TRUE
    );
end;

procedure modify_dashboard(
    i_id          in     com_api_type_pkg.t_short_id
  , io_seqnum     in out com_api_type_pkg.t_seqnum
  , i_user_id     in     com_api_type_pkg.t_short_id
  , i_inst_id     in     com_api_type_pkg.t_inst_id
  , i_is_shared   in     com_api_type_pkg.t_boolean
  , i_lang        in     com_api_type_pkg.t_dict_value
  , i_label       in     com_api_type_pkg.t_name
  , i_description in     com_api_type_pkg.t_full_desc
) is
begin
    update acm_dashboard_vw
       set user_id   = i_user_id
         , inst_id   = i_inst_id   
         , is_shared = i_is_shared 
     where id        = i_id;
     
     io_seqnum := io_seqnum + 1;

    com_api_i18n_pkg.add_text(
        i_table_name   => 'acm_dashboard'
      , i_column_name  => 'label'
      , i_object_id    => i_id
      , i_text         => i_label
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'acm_dashboard'
      , i_column_name  => 'description'
      , i_object_id    => i_id
      , i_text         => i_description
      , i_lang         => i_lang
    );

end;

procedure remove_dashboard(
    i_id          in     com_api_type_pkg.t_tiny_id
  , i_seqnum      in     com_api_type_pkg.t_seqnum
) is
begin
    delete from acm_dashboard_widget_vw
    where dashboard_id = i_id;
    
    update acm_dashboard_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete from acm_dashboard_vw
    where id      = i_id;

    com_api_i18n_pkg.remove_text(
        i_table_name => 'acm_dashboard'
      , i_object_id  => i_id
    );
end;

procedure add_dashboard_user(
    o_id               out com_api_type_pkg.t_short_id 
  , o_seqnum           out com_api_type_pkg.t_seqnum
  , i_dashboard_id  in     com_api_type_pkg.t_short_id 
  , i_user_id       in     com_api_type_pkg.t_short_id
  , i_is_default    in     com_api_type_pkg.t_boolean
) is 
    l_count com_api_type_pkg.t_short_id;
begin
    o_id      := acm_dashboard_seq.nextval;
    o_seqnum  := 1;
    
    select count(*) 
      into l_count
      from acm_dashboard_user_vw
     where user_id = i_user_id;
    
    insert into acm_dashboard_user_vw(
        id
      , seqnum
      , dashboard_id
      , user_id
      , is_default
    ) values(
        o_id 
      , o_seqnum
      , i_dashboard_id 
      , i_user_id
      , decode(l_count, 0, com_api_const_pkg.TRUE, i_is_default)
    );
    
    if i_is_default = com_api_const_pkg.TRUE then
        update acm_dashboard_user_vw
           set is_default = com_api_const_pkg.FALSE
         where user_id    = i_user_id
           and id        != o_id;
    end if; 
end;

procedure add_dashboard_widget(
    o_id                   out com_api_type_pkg.t_short_id 
  , o_seqnum               out com_api_type_pkg.t_seqnum
  , i_dashboard_id      in     com_api_type_pkg.t_short_id 
  , i_widget_id         in     com_api_type_pkg.t_short_id
  , i_row_number        in     com_api_type_pkg.t_short_id
  , i_column_number     in     com_api_type_pkg.t_short_id
  , i_is_refresh        in     com_api_type_pkg.t_boolean
  , i_refresh_interval  in     com_api_type_pkg.t_short_id
) is 
begin
    o_id      := acm_dashboard_widget_seq.nextval;
    o_seqnum  := 1;
    
    insert into acm_dashboard_widget_vw(
        id
      , seqnum
      , dashboard_id
      , widget_id
      , row_number
      , column_number
      , is_refresh
      , refresh_interval
    ) values(
        o_id 
      , o_seqnum
      , i_dashboard_id
      , i_widget_id
      , i_row_number
      , i_column_number
      , i_is_refresh
      , i_refresh_interval
    );
end;

procedure modify_dashboard_widget(
    i_id                in     com_api_type_pkg.t_short_id
  , io_seqnum           in out com_api_type_pkg.t_seqnum
  , i_is_refresh        in     com_api_type_pkg.t_boolean
  , i_refresh_interval  in     com_api_type_pkg.t_short_id
) is
begin
    update acm_dashboard_widget_vw
       set seqnum           = io_seqnum
         , is_refresh       = i_is_refresh
         , refresh_interval = i_refresh_interval
     where id               = i_id;

    io_seqnum   :=  io_seqnum + 1;
end;

procedure remove_dashboard_widget(
    i_id                in     com_api_type_pkg.t_short_id 
  , i_seqnum            in     com_api_type_pkg.t_seqnum
) is 
begin
    update acm_dashboard_widget_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete from acm_dashboard_widget_vw
    where id      = i_id;
end;

end;
/
