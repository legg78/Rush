create or replace package body acm_ui_filter_pkg as
/*********************************************************
*  UI for access management filters <br />
*  Created by Krukov E.(krukov@bpcsv.com)  at 18.05.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: ACM_UI_FILTER_PKG <br />
*  @headcom
**********************************************************/

procedure add(
    o_id               out com_api_type_pkg.t_short_id
  , o_seqnum           out com_api_type_pkg.t_seqnum
  , i_name          in     com_api_type_pkg.t_name
  , i_lang          in     com_api_type_pkg.t_dict_value
  , i_section_id    in     com_api_type_pkg.t_tiny_id
  , i_inst_id       in     com_api_type_pkg.t_inst_id
  , i_user_id       in     com_api_type_pkg.t_short_id
  , i_display_order in     com_api_type_pkg.t_tiny_id
)is
begin

    o_id := acm_filter_seq.nextval;
    o_seqnum := 1;

    insert into acm_filter_vw(
        id
      , seqnum
      , section_id
      , inst_id
      , user_id
      , display_order
    ) values (
        o_id
      , o_seqnum
      , i_section_id
      , i_inst_id
      , i_user_id
      , i_display_order
    );

    com_api_i18n_pkg.add_text(
        i_table_name  => 'acm_filter'
      , i_column_name => 'name'
      , i_object_id   => o_id
      , i_lang        => i_lang
      , i_text        => i_name
    );

end add;

procedure modify(
    i_id            in     com_api_type_pkg.t_short_id
  , io_seqnum       in out com_api_type_pkg.t_seqnum
  , i_name          in     com_api_type_pkg.t_name
  , i_lang          in     com_api_type_pkg.t_dict_value
  , i_display_order in     com_api_type_pkg.t_tiny_id
) is
begin

    update acm_filter
    set display_order = i_display_order
      , seqnum = io_seqnum
    where id = i_id;

    com_api_i18n_pkg.add_text(
        i_table_name  => 'acm_filter'
      , i_column_name => 'name'
      , i_object_id   => i_id
      , i_lang        => i_lang
      , i_text        => i_name
    );

    io_seqnum := io_seqnum + 1;

end modify;

procedure remove(
    i_id            in     com_api_type_pkg.t_short_id
  , i_seqnum        in     com_api_type_pkg.t_seqnum
) is 
begin

    update
        acm_filter_vw
    set 
        seqnum = i_seqnum
    where id = i_id;

    delete 
        acm_filter_vw 
    where id = i_id;

    com_api_i18n_pkg.remove_text(
        i_table_name => 'acm_filter'
      , i_object_id => i_id
    );

end remove;

end acm_ui_filter_pkg;
/
