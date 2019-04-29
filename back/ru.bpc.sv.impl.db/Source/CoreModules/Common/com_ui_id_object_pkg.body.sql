create or replace package body com_ui_id_object_pkg as
/************************************************************
 * Provides an interface for managing documents. <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 18.03.2011 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: COM_UI_ID_OBJECT_PKG <br />
 * @headcom
 *************************************************************/

procedure add_id_object(
    o_id                 out  com_api_type_pkg.t_medium_id
  , o_seqnum             out  com_api_type_pkg.t_seqnum
  , i_entity_type     in      com_api_type_pkg.t_dict_value
  , i_object_id       in      com_api_type_pkg.t_long_id
  , i_id_type         in      com_api_type_pkg.t_dict_value
  , i_id_series       in      com_api_type_pkg.t_name
  , i_id_number       in      com_api_type_pkg.t_name
  , i_id_issuer       in      com_api_type_pkg.t_name
  , i_id_issue_date   in      date
  , i_id_expire_date  in      date
  , i_id_desc         in      com_api_type_pkg.t_full_desc
  , i_lang            in      com_api_type_pkg.t_dict_value
  , i_inst_id         in      com_api_type_pkg.t_inst_id            default null
  , i_country         in      com_api_type_pkg.t_country_code       default null
) is
begin
    com_api_id_object_pkg.add_id_object(
        o_id             => o_id
      , o_seqnum         => o_seqnum
      , i_entity_type    => i_entity_type
      , i_object_id      => i_object_id
      , i_id_type        => i_id_type
      , i_id_series      => i_id_series
      , i_id_number      => i_id_number
      , i_id_issuer      => i_id_issuer
      , i_id_issue_date  => i_id_issue_date
      , i_id_expire_date => i_id_expire_date
      , i_id_desc        => i_id_desc
      , i_lang           => i_lang
      , i_inst_id        => ost_api_institution_pkg.get_sandbox(i_inst_id)
      , i_country        => i_country
    );
end add_id_object;

procedure modify_id_object(
    i_id              in      com_api_type_pkg.t_medium_id
  , io_seqnum         in out  com_api_type_pkg.t_seqnum
  , i_id_type         in      com_api_type_pkg.t_dict_value
  , i_id_series       in      com_api_type_pkg.t_name
  , i_id_number       in      com_api_type_pkg.t_name
  , i_id_issuer       in      com_api_type_pkg.t_name
  , i_id_issue_date   in      date
  , i_id_expire_date  in      date
  , i_id_desc         in      com_api_type_pkg.t_full_desc
  , i_lang            in      com_api_type_pkg.t_dict_value
  , i_country         in      com_api_type_pkg.t_country_code
) is
begin
    com_api_id_object_pkg.modify_id_object(
        i_id             => i_id
      , io_seqnum        => io_seqnum
      , i_id_type        => i_id_type
      , i_id_series      => i_id_series
      , i_id_number      => i_id_number
      , i_id_issuer      => i_id_issuer
      , i_id_issue_date  => i_id_issue_date
      , i_id_expire_date => i_id_expire_date
      , i_id_desc        => i_id_desc
      , i_lang           => i_lang
      , i_country        => i_country
    );
end modify_id_object;

procedure remove_id_object(
    i_id                in      com_api_type_pkg.t_medium_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
begin
    com_api_id_object_pkg.remove_id_object (
        i_id     => i_id
      , i_seqnum => i_seqnum
    );
end remove_id_object;

procedure get_ident_card_id(
    i_id_type    in      com_api_type_pkg.t_dict_value
  , i_id_series  in      com_api_type_pkg.t_name
  , i_id_number  in      com_api_type_pkg.t_name
  , o_id            out  com_api_type_pkg.t_medium_id
  , o_seqnum        out  com_api_type_pkg.t_seqnum
  , i_inst_id    in      com_api_type_pkg.t_inst_id                 default null
) is
begin
    select
        id
      , seqnum
    into
        o_id
      , o_seqnum
    from (
        select
            id
          , seqnum
        from
            com_id_object_vw
        where
            id_type = trim(i_id_type)
            and (id_series = trim(i_id_series) or (id_series is null and i_id_series is null))
            and id_number = trim(i_id_number)
            and inst_id = ost_api_institution_pkg.get_sandbox(i_inst_id)
        order by id
    )
    where rownum = 1;

    trc_log_pkg.debug (
        i_text       => 'com_ui_object_id_pkg.get_ident_card_id: id[#1] seqnum[#2]'
      , i_env_param1 => o_id
      , i_env_param2 => o_seqnum
    );
exception
    when no_data_found then
        o_id := null;
        o_seqnum := null;
end get_ident_card_id;

function get_id_card_desc(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) return com_api_type_pkg.t_name is
    l_result            com_api_type_pkg.t_name;
begin
    select com_api_dictionary_pkg.get_article_text(id_type, i_lang)||' '||id_series||' '||id_number
      into l_result
      from com_id_object
     where id = (select max(id) from com_id_object where entity_type = i_entity_type and object_id = i_object_id);
     
    return l_result;
    
exception
    when no_data_found then
        return null;      
end;

end com_ui_id_object_pkg;
/
