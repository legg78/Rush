create or replace package body acm_ui_action_pkg as
/*********************************************************
*  UI for menu actions  <br />
*  Created by Krukov E.(krukov@bpcsv.com)  at 15.06.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: ACM_UI_ACTION_PKG <br />
*  @headcom
**********************************************************/

procedure add(
    o_id                       out  com_api_type_pkg.t_tiny_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_call_mode             in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_type           in      com_api_type_pkg.t_dict_value
  , i_group_id              in      com_api_type_pkg.t_tiny_id
  , i_section_id            in      com_api_type_pkg.t_tiny_id
  , i_priv_id               in      com_api_type_pkg.t_short_id
  , i_priv_object_id        in      com_api_type_pkg.t_long_id
  , i_is_default            in      com_api_type_pkg.t_boolean      default null
  , i_label                 in      com_api_type_pkg.t_name
  , i_description           in      com_api_type_pkg.t_full_desc
  , i_lang                  in      com_api_type_pkg.t_dict_value
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_object_type_lov_id    in      com_api_type_pkg.t_tiny_id
) is
    l_count             pls_integer;
    l_is_default        com_api_type_pkg.t_boolean;
begin
    o_id := acm_action_seq.nextval;
    o_seqnum := 1;
    
    l_is_default := nvl(i_is_default, com_api_const_pkg.FALSE);
    
    if l_is_default = com_api_const_pkg.TRUE then
        update acm_action_vw
           set is_default  = com_api_const_pkg.FALSE
         where is_default  = com_api_const_pkg.TRUE
           and entity_type = i_entity_type
           and coalesce(object_type, '~') = coalesce(i_object_type, '~');
           
    else
        select count(1)
          into l_count
          from acm_action_vw
         where is_default  = com_api_const_pkg.TRUE
           and entity_type = i_entity_type
           and coalesce(object_type, '~') = coalesce(i_object_type, '~');
        if l_count = 0 then
             l_is_default := com_api_const_pkg.TRUE;
        end if;
    end if; 

    insert into acm_action_vw(
        id
      , seqnum
      , call_mode
      , entity_type
      , object_type
      , group_id
      , section_id
      , priv_id
      , priv_object_id
      , inst_id
      , is_default
      , object_type_lov_id
    ) values (
        o_id
      , o_seqnum
      , i_call_mode
      , i_entity_type
      , i_object_type
      , i_group_id
      , i_section_id
      , i_priv_id
      , i_priv_object_id
      , i_inst_id
      , l_is_default
      , i_object_type_lov_id
    );

    com_ui_i18n_pkg.add_text(
        i_table_name  => 'acm_action'
      , i_column_name => 'label'
      , i_object_id   => o_id
      , i_text        => i_label
      , i_lang        => i_lang
    );

    com_ui_i18n_pkg.add_text(
        i_table_name  => 'acm_action'
      , i_column_name => 'description'
      , i_object_id   => o_id
      , i_text        => i_description
      , i_lang        => i_lang
    );

end add;

procedure modify(
    i_id                    in      com_api_type_pkg.t_tiny_id
  , io_seqnum               in out  com_api_type_pkg.t_seqnum
  , i_call_mode             in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_type           in      com_api_type_pkg.t_dict_value
  , i_group_id              in      com_api_type_pkg.t_tiny_id
  , i_section_id            in      com_api_type_pkg.t_tiny_id
  , i_priv_id               in      com_api_type_pkg.t_short_id
  , i_priv_object_id        in      com_api_type_pkg.t_long_id
  , i_is_default            in      com_api_type_pkg.t_boolean      default null
  , i_label                 in      com_api_type_pkg.t_name
  , i_description           in      com_api_type_pkg.t_full_desc
  , i_lang                  in      com_api_type_pkg.t_dict_value
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_object_type_lov_id    in      com_api_type_pkg.t_tiny_id
) is 
    l_count             pls_integer;
    l_is_default        com_api_type_pkg.t_boolean;
begin
    l_is_default := nvl(i_is_default, com_api_const_pkg.FALSE);
    
    if l_is_default = com_api_const_pkg.TRUE then
        update acm_action_vw
           set is_default  = com_api_const_pkg.FALSE
             , seqnum      = io_seqnum
         where is_default  = com_api_const_pkg.TRUE
           and entity_type = i_entity_type
           and coalesce(object_type, '~') = coalesce(i_object_type, '~');
           
        io_seqnum := io_seqnum + 1;

    else
        select count(1)
          into l_count
          from acm_action_vw
         where is_default  = com_api_const_pkg.TRUE
           and entity_type = i_entity_type
           and coalesce(object_type, '~') = coalesce(i_object_type, '~')
           and id != i_id;
        if l_count = 0 then
             l_is_default := com_api_const_pkg.TRUE;
        end if;
    end if; 

    update 
        acm_action_vw a
    set
        a.seqnum                = io_seqnum
      , a.call_mode             = i_call_mode
      , a.entity_type           = i_entity_type
      , a.object_type           = i_object_type
      , a.group_id              = i_group_id
      , a.section_id            = i_section_id
      , a.priv_id               = i_priv_id
      , a.priv_object_id        = i_priv_object_id
      , a.inst_id               = i_inst_id
      , a.is_default            = nvl(l_is_default, a.is_default)
      , a.object_type_lov_id    = i_object_type_lov_id
    where a.id = i_id;

    io_seqnum := io_seqnum + 1;

    com_ui_i18n_pkg.add_text(
        i_table_name  => 'acm_action'
      , i_column_name => 'label'
      , i_object_id   => i_id
      , i_text        => i_label
      , i_lang        => i_lang
    );

    com_ui_i18n_pkg.add_text(
        i_table_name  => 'acm_action'
      , i_column_name => 'description'
      , i_object_id   => i_id
      , i_text        => i_description
      , i_lang        => i_lang
    );

end modify;

procedure remove(
    i_id                    in      com_api_type_pkg.t_tiny_id
  , i_seqnum                in      com_api_type_pkg.t_seqnum
) is 
begin

    update
        acm_action_vw a
    set
        a.seqnum = i_seqnum
    where
        a.id = i_id;

    delete from
        acm_action_vw a
    where a.id = i_id;

    com_api_i18n_pkg.remove_text(
        i_table_name => 'acm_action'
      , i_object_id => i_id
    );

end remove;

end acm_ui_action_pkg;
/
