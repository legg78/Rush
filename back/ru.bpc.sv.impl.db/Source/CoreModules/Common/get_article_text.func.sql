create or replace function get_article_text(
    i_article           in      com_api_type_pkg.t_dict_value
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
) return com_api_type_pkg.t_short_desc is
begin
  return com_api_dictionary_pkg.get_article_text(
      i_article => i_article
    , i_lang    => i_lang
  );
end get_article_text;
/
