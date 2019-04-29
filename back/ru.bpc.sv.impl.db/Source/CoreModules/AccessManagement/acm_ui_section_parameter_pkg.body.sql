create or replace package body acm_ui_section_parameter_pkg as
/*********************************************************
*  UI for section parameters  <br />
*  Created by Krukov E.(krukov@bpcsv.com)  at 15.06.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: ACM_UI_SECTION_PARAMETER_PKG <br />
*  @headcom
**********************************************************/
procedure check_unique(
    i_id              in     com_api_type_pkg.t_short_id
    , i_name          in     com_api_type_pkg.t_name
) is
    l_id     com_api_type_pkg.t_short_id;
begin
    select id
      into l_id
      from acm_section_parameter 
     where name = upper(i_name)
       and (i_id is null or i_id != id)
       and rownum = 1;

    com_api_error_pkg.raise_error (
        i_error         => 'PARAMETER_ALREADY_EXISTS'
        , i_env_param1  => upper(i_name)
    );

exception
    when no_data_found then
        null;     
end;

procedure add(
    o_id                 out com_api_type_pkg.t_short_id
  , o_seqnum             out com_api_type_pkg.t_seqnum
  , i_section_id      in     com_api_type_pkg.t_tiny_id
  , i_name            in     com_api_type_pkg.t_name
  , i_data_type       in     com_api_type_pkg.t_dict_value
  , i_lov_id          in     com_api_type_pkg.t_tiny_id
  , i_label           in     com_api_type_pkg.t_name
  , i_description     in     com_api_type_pkg.t_full_desc
  , i_lang            in     com_api_type_pkg.t_dict_value
) is
begin
    check_unique(
        i_id          => o_id
        , i_name      => i_name
    );
    
    o_id     := acm_section_parameter_seq.nextval;
    o_seqnum := 1;

    insert into acm_section_parameter_vw(
        id
      , seqnum
      , section_id
      , name
      , data_type
      , lov_id
    ) values (
        o_id
      , o_seqnum
      , i_section_id
      , upper(i_name)
      , i_data_type
      , i_lov_id
    );

    com_ui_i18n_pkg.add_text(
        i_table_name   => 'acm_section_parameter'
      , i_column_name  => 'label'
      , i_object_id    =>  o_id
      , i_text         => i_label
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE 
    );

    com_ui_i18n_pkg.add_text(
        i_table_name  => 'acm_section_parameter'
      , i_column_name => 'description'
      , i_object_id   =>  o_id
      , i_text        => i_description
      , i_lang        => i_lang
    );

end add;

procedure modify(
    i_id              in     com_api_type_pkg.t_short_id
  , io_seqnum         in out com_api_type_pkg.t_seqnum
  , i_section_id      in     com_api_type_pkg.t_tiny_id
  , i_name            in     com_api_type_pkg.t_name
  , i_data_type       in     com_api_type_pkg.t_dict_value
  , i_lov_id          in     com_api_type_pkg.t_tiny_id
  , i_label           in     com_api_type_pkg.t_name
  , i_description     in     com_api_type_pkg.t_full_desc
  , i_lang            in     com_api_type_pkg.t_dict_value
) is
begin
    check_unique(
        i_id          => i_id
        , i_name      => i_name
    );

    update
        acm_section_parameter_vw a
    set
        a.seqnum     = io_seqnum
      , a.section_id = i_section_id
      , a.name       = upper(i_name)
      , a.data_type  = i_data_type
      , a.lov_id     = i_lov_id
    where
        a.id = i_id;

    io_seqnum := io_seqnum + 1;

    com_ui_i18n_pkg.add_text(
        i_table_name  => 'acm_section_parameter'
      , i_column_name => 'label'
      , i_object_id   =>  i_id
      , i_text        => i_label
      , i_lang        => i_lang
      , i_check_unique => com_api_type_pkg.TRUE 
    );

    com_ui_i18n_pkg.add_text(
        i_table_name  => 'acm_section_parameter'
      , i_column_name => 'description'
      , i_object_id   =>  i_id
      , i_text        => i_description
      , i_lang        => i_lang
    );

end modify;

procedure remove(
    i_id              in     com_api_type_pkg.t_short_id
  , i_seqnum          in     com_api_type_pkg.t_seqnum
) is
begin

    update
        acm_section_parameter_vw a
    set 
        a.seqnum = i_seqnum
    where 
        a.id = i_id;

    delete
        acm_section_parameter_vw a
    where a.id = i_id;

    com_api_i18n_pkg.remove_text(
        i_table_name => 'acm_section_parameter'
      , i_object_id => i_id
    );

end remove;

end acm_ui_section_parameter_pkg;
/
