create or replace package body app_ui_flow_step_pkg as
/*******************************************************************
*  API for application's flow <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 03.08.2010 <br />
*  Last changed by $Author: filimonov $ <br />
*  $LastChangedDate:: 2011-12-09 19:19:12 +0400#$ <br />
*  Revision: $LastChangedRevision: 14428 $ <br />
*  Module: app_ui_flow_pkg <br />
*  @headcom
******************************************************************/

procedure add(
    o_id                out     com_api_type_pkg.t_tiny_id
  , o_seqnum            out     com_api_type_pkg.t_tiny_id
  , i_flow_id           in      com_api_type_pkg.t_tiny_id
  , i_step_label        in      com_api_type_pkg.t_name
  , i_appl_status       in      com_api_type_pkg.t_dict_value
  , i_step_source       in      com_api_type_pkg.t_name
  , i_read_only         in      com_api_type_pkg.t_boolean
  , i_display_order     in      com_api_type_pkg.t_tiny_id
  , i_lang              in      com_api_type_pkg.t_dict_value  default null
) is
begin
    select app_flow_step_seq.nextval
          ,1
      into o_id
         , o_seqnum
      from dual;

    insert into app_flow_step_vw (
        id
      , seqnum
      , flow_id
      , appl_status
      , step_source
      , read_only
      , display_order
    ) values (
        o_id
      , o_seqnum
      , i_flow_id
      , i_appl_status
      , i_step_source
      , i_read_only
      , i_display_order
    );

    if i_step_label is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'app_flow_step'
          , i_column_name   => 'label'
          , i_object_id     => o_id
          , i_lang          => i_lang
          , i_text          => i_step_label
        );
    end if;
end;

procedure modify(
    i_id                in      com_api_type_pkg.t_tiny_id
  , io_seqnum           in out  com_api_type_pkg.t_tiny_id
  , i_flow_id           in      com_api_type_pkg.t_tiny_id
  , i_step_label        in      com_api_type_pkg.t_name
  , i_appl_status       in      com_api_type_pkg.t_dict_value
  , i_step_source       in      com_api_type_pkg.t_name
  , i_read_only         in      com_api_type_pkg.t_boolean
  , i_display_order     in      com_api_type_pkg.t_tiny_id
  , i_lang              in      com_api_type_pkg.t_dict_value  default null
) is
begin
    update app_flow_step_vw
    set seqnum            = io_seqnum
      , flow_id           = i_flow_id
      , appl_status       = i_appl_status
      , step_source       = i_step_source
      , read_only         = i_read_only
      , display_order     = i_display_order
    where id = i_id;

    io_seqnum := io_seqnum + 1;

    if i_step_label is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'app_flow_step'
          , i_column_name   => 'label'
          , i_object_id     => i_id
          , i_lang          => i_lang
          , i_text          => i_step_label
        );
    end if;
    
end;

procedure remove(
    i_id      in  com_api_type_pkg.t_short_id
  , i_seqnum  in  com_api_type_pkg.t_tiny_id
) is
begin
    update app_flow_step_vw
    set seqnum  = i_seqnum
    where    id = i_id;

    delete from app_flow_step_vw
    where id = i_id;

    com_api_i18n_pkg.remove_text(
        i_table_name   => 'app_flow_step'
      , i_object_id    => i_id
    );
end;

end;
/
