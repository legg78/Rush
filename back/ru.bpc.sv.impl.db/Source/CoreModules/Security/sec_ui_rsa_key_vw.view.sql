create or replace force view sec_ui_rsa_key_vw as
select
    a.id
    , a.seqnum
    , a.object_id
    , a.entity_type
    , a.lmk_id
    , a.key_type
    , a.key_index
    , a.expir_date
    , a.sign_algorithm
    , a.modulus_length
    , a.exponent
    , a.public_key
    , a.private_key
    , a.public_key_mac
    , get_text (
        i_table_name    => 'sec_rsa_key'
        , i_column_name => 'description'
        , i_object_id   => a.id
        , i_lang        => l.lang
      ) description
    , a.standard_key_type
    , get_article_text (
        i_article => a.standard_key_type
        , i_lang  => l.lang
      ) standard_key_type_name
    , a.generate_date
    , a.generate_user_id
    , l.lang
from
    sec_rsa_key a
    , com_language_vw l
/
