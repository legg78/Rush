CREATE OR REPLACE package body com_ui_country_pkg as
/*********************************************************
 *  UI for Dictionary of Countries <br />
 *  Created by Mashonkin V.(mashonkin@bpcbt.com)  at 06.06.2014 <br />
 *  Last changed by $Author:  $ <br />
 *  $LastChangedDate:: 2014-06-06 12:40:30 +0400#$ <br />
 *  Revision: $LastChangedRevision:  $ <br />
 *  Module: com_ui_country_pkg  <br />
 *  @headcom
 **********************************************************/
procedure add_country (
    i_code                in      com_api_type_pkg.t_curr_code
  , i_name                in      com_api_type_pkg.t_curr_code
  , i_curr_code           in      com_api_type_pkg.t_curr_code
  , i_visa_country_code   in      com_api_type_pkg.t_curr_code
  , i_mastercard_region   in      com_api_type_pkg.t_curr_code
  , i_mastercard_eurozone in      com_api_type_pkg.t_curr_code
  , i_visa_region         in      com_api_type_pkg.t_tiny_id
  , i_description         in      com_api_type_pkg.t_name
  , i_lang                in      com_api_type_pkg.t_dict_value
  , o_country_id          out     com_api_type_pkg.t_medium_id
) is
    l_country_id    com_api_type_pkg.t_medium_id := 0;
    l_count         com_api_type_pkg.t_count := 0;
    country_exists  EXCEPTION;
begin
    trc_log_pkg.debug(i_text => 
        'com_ui_country_pkg.add_country: ' ||
        ' i_code=' || i_code || 
        ' i_name=' || i_name ||
        ' i_curr_code='           || i_curr_code ||
        ' i_visa_country_code='   || i_visa_country_code ||
        ' i_mastercard_region='   || i_mastercard_region ||      
        ' i_mastercard_eurozone=' || i_mastercard_eurozone ||
        ' i_visa_region ='        || i_visa_region || 
        ' i_description='         || trim(i_description)
    );
    --
    select count(id)
      into l_count
      from com_country
     where code = i_code
        or upper(trim(name)) = upper(trim(i_name))
        or upper(trim(nvl(visa_country_code, '~'))) = upper(trim(i_visa_country_code));
    --
    if l_count != 0 then
        raise country_exists;
    else
        select com_country_seq.nextval into l_country_id from dual;
        --
        insert into com_country (
            id
          , seqnum
          , code
          , name
          , curr_code
          , visa_country_code
          , mastercard_region
          , mastercard_eurozone
          , visa_region
        ) values (
            l_country_id
          , 1
          , i_code
          , upper(trim(i_name))
          , trim(i_curr_code)
          , upper(trim(i_visa_country_code))
          , upper(trim(i_mastercard_region))
          , upper(trim(i_mastercard_eurozone))
          , i_visa_region
        )
        returning id into o_country_id;
        --
        com_api_i18n_pkg.add_text(
            i_table_name    => 'com_country'
          , i_column_name   => 'name'
          , i_object_id     => l_country_id
          , i_lang          => coalesce(i_lang, com_ui_user_env_pkg.get_user_lang, com_api_const_pkg.LANGUAGE_ENGLISH)
          , i_text          => i_description
        );
    end if;
exception
    when country_exists then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_COUNTRY'
          , i_env_param1 => i_code
          , i_env_param2 => upper(trim(i_name))
          , i_env_param3 => upper(trim(i_visa_country_code))
        );
end add_country;

procedure modify_country (
  i_country_id            in out  com_api_type_pkg.t_medium_id
  , i_code                in      com_api_type_pkg.t_curr_code
  , i_name                in      com_api_type_pkg.t_curr_code
  , i_curr_code           in      com_api_type_pkg.t_curr_code
  , i_visa_country_code   in      com_api_type_pkg.t_curr_code
  , i_mastercard_region   in      com_api_type_pkg.t_curr_code
  , i_mastercard_eurozone in      com_api_type_pkg.t_curr_code
  , i_visa_region         in      com_api_type_pkg.t_tiny_id
  , i_description         in      com_api_type_pkg.t_name
  , i_lang                in      com_api_type_pkg.t_dict_value
) is
    l_count         com_api_type_pkg.t_count := 0;
    country_exists  EXCEPTION;
begin
    trc_log_pkg.debug(i_text => 
        'com_ui_country_pkg.modify_country: ' ||
        ' i_country_id=' || i_country_id ||
        ' i_code=' || i_code || 
        ' i_name=' || i_name ||
        ' i_curr_code='           || i_curr_code ||
        ' i_visa_country_code='   || i_visa_country_code ||
        ' i_mastercard_region='   || i_mastercard_region ||
        ' i_mastercard_eurozone=' || i_mastercard_eurozone ||
        ' i_visa_region ='        || i_visa_region ||
        ' i_description='         || trim(i_description)
    );
    -- some other country have the same parameters
    select count(id)
      into l_count
      from com_country
     where 
        (code = i_code
           or upper(trim(name)) = upper(trim(i_name))
           or upper(trim(nvl(visa_country_code, '~'))) = upper(trim(i_visa_country_code))
        ) and id != i_country_id;
    --
    if l_count != 0 then
        raise country_exists;
    else
        select count(id)
          into l_count
          from com_country
         where id = i_country_id;
        --
        if l_count != 0 then
            update com_country
               set seqnum               = seqnum + 1
                  , code                = i_code
                  , name                = upper(trim(i_name))
                  , curr_code           = i_curr_code
                  , visa_country_code   = upper(trim(i_visa_country_code))
                  , mastercard_region   = upper(trim(i_mastercard_region))
                  , mastercard_eurozone = upper(trim(i_mastercard_eurozone))
                  , visa_region         = i_visa_region
            where 
                id = i_country_id;
            --
            com_api_i18n_pkg.add_text(
                i_table_name    => 'com_country'
              , i_column_name   => 'name'
              , i_object_id     => i_country_id
              , i_lang          => coalesce(i_lang, com_ui_user_env_pkg.get_user_lang, com_api_const_pkg.LANGUAGE_ENGLISH)
              , i_text          => trim(i_description)
            );
        else
            com_ui_country_pkg.add_country (
                i_code                => i_code
              , i_name                => i_name
              , i_curr_code           => i_curr_code
              , i_visa_country_code   => i_visa_country_code
              , i_mastercard_region   => i_mastercard_region
              , i_mastercard_eurozone => i_mastercard_eurozone
              , i_visa_region         => i_visa_region
              , i_description         => i_description
              , i_lang                => i_lang
              , o_country_id          => i_country_id
            );
        end if;
    end if;
exception
    when country_exists then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_COUNTRY'
          , i_env_param1 => i_code
          , i_env_param2 => upper(trim(i_name))
          , i_env_param3 => upper(trim(i_visa_country_code))
        );
end modify_country;

procedure remove_country (
    i_country_id          in      com_api_type_pkg.t_medium_id
) is
begin
    -- WARNING - many referenceed tables
    -- select * from user_tab_columns where column_name = 'COUNTRY'
    delete from 
        com_country
    where 
        id = i_country_id;
end remove_country;

end com_ui_country_pkg;
/