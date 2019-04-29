create or replace package com_api_dictionary_pkg as

procedure check_article(
    i_dict              in      com_api_type_pkg.t_dict_value
  , i_code              in      com_api_type_pkg.t_dict_value
);

function check_article(
    i_dict              in      com_api_type_pkg.t_dict_value
  , i_code              in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean;

procedure get_dictionary_dml (
    i_dict              in      com_api_type_pkg.t_dict_value,
    io_dml              in out  sys_refcursor
);

function get_article_text(
    i_article           in      com_api_type_pkg.t_dict_value
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
) return com_api_type_pkg.t_short_desc;

function get_article_desc(
    i_article           in      com_api_type_pkg.t_dict_value
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
) return com_api_type_pkg.t_text;

function get_article_id(
    i_article           in      com_api_type_pkg.t_dict_value
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
) return com_api_type_pkg.t_short_id;

function get_article_id_by_code(
    i_code              in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_short_id result_cache;

function get_articles_list_desc(
    i_article_list      in      com_api_type_pkg.t_short_desc
  , i_len_article_part  in      com_api_type_pkg.t_byte_id      default null
  , i_text_in_begin     in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
) return com_api_type_pkg.t_text;

end;
/

