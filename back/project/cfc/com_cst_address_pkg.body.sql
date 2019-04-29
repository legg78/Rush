create or replace package body com_cst_address_pkg as
/*********************************************************
 *  The package with user-exits for custom address elements <br />
 *
 *  Created by Madan B. (madan@bpcbt.com) at 27.01.2015 <br />
 *  Last changed by $Author: madan $ <br />
 *  $LastChangedDate: 2015-01-27 12:28:00 +0400#$ <br />
 *  Revision: $LastChangedRevision: 1 $ <br />
 *  Module: com_cst_address_pkg <br />
 *  @headcom
 **********************************************************/

/**********************************************************
 * Adding of additional custom address elements.
 * @param i_address_id  ID of the address
 * @param i_lang        User's interface language
 * @param i_inst_id     Institution ID
 * @param ia_params_tab Address elements collection
 **********************************************************/
function get_place_name(
    i_place_code        in       com_api_type_pkg.t_name
  , i_comp_level        in       com_api_type_pkg.t_tiny_id
  , i_lang              in       com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_name is
begin
    for r in (
        select place_name
          from adr_place
         where place_code = i_place_code
           and comp_level = i_comp_level
         order by decode(lang, i_lang, 1, 'LANGENG', 2, 3)
    ) loop
        return r.place_name;
    end loop;

    return null;
end;

procedure collect_address_params (
   i_address_id   in             com_api_type_pkg.t_medium_id
 , i_lang         in             com_api_type_pkg.t_dict_value
 , i_inst_id      in             com_api_type_pkg.t_inst_id
 , ia_params_tab  in out nocopy  com_api_type_pkg.t_param_tab
)
is
    l_place_name      com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug(
        i_text => lower($$PLSQL_UNIT) || '.collect_address_params: dummy'
    );
    for r in (
        select a.place_code
             , a.region_code
             , a.apartment
             , a.postal_code
          from com_address a
         where a.id         = i_address_id
         order by decode(a.lang, i_lang, 1, 'LANGENG', 2, 3)
    ) loop

        l_place_name :=
            get_place_name(
                i_place_code        => r.region_code
              , i_comp_level        => 4
              , i_lang              => i_lang
            );

        rul_api_param_pkg.set_param (
            i_name       => 'REGION_CODE'
            , i_value    => l_place_name
            , io_params  => ia_params_tab
        );

        l_place_name :=
            get_place_name(
                i_place_code        => r.place_code
              , i_comp_level        => 3
              , i_lang              => i_lang
            );

        rul_api_param_pkg.set_param (
            i_name       => 'PLACE_CODE'
            , i_value    => l_place_name
            , io_params  => ia_params_tab
        );

        l_place_name :=
            get_place_name(
                i_place_code        => r.postal_code
              , i_comp_level        => 2
              , i_lang              => i_lang
            );

        rul_api_param_pkg.set_param (
            i_name       => 'POSTAL_CODE'
            , i_value    => l_place_name
            , io_params  => ia_params_tab
        );

        l_place_name :=
            get_place_name(
                i_place_code        => r.apartment
              , i_comp_level        => 1
              , i_lang              => i_lang
            );

        rul_api_param_pkg.set_param (
            i_name       => 'APARTMENT'
            , i_value    => l_place_name
            , io_params  => ia_params_tab
        );
        exit;
    end loop;
end;

/**********************************************************
 * The editing of format of address string
 * @param i_tag_name name of tag in ber-tlv for CardGen
 * @param io_tag_value value of tag in ber-tlv for CardGen
 **********************************************************/
procedure get_address_string(
    i_country           in      com_api_type_pkg.t_country_code default null
  , i_region            in      com_api_type_pkg.t_name         default null
  , i_city              in      com_api_type_pkg.t_name         default null
  , i_street            in      com_api_type_pkg.t_name         default null
  , i_house             in      com_api_type_pkg.t_name         default null
  , i_apartment         in      com_api_type_pkg.t_name         default null
  , i_postal_code       in      varchar2                        default null
  , i_region_code       in      com_api_type_pkg.t_dict_value   default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_tag_name          in      com_api_type_pkg.t_name
  , io_tag_value        in out  com_api_type_pkg.t_name
)is
begin
    --case for i_tag_name
    if i_tag_name = 'DF8021' then
       select i_city || nvl2(i_country, ', ' || com_api_country_pkg.get_visa_code(
                                                    i_country_code => i_country
                                                  , i_raise_error  => com_api_const_pkg.FALSE), '')
         into io_tag_value
         from dual;
    end if;
exception
    when no_data_found then
        io_tag_value := '';
end;

end com_cst_address_pkg;
/
