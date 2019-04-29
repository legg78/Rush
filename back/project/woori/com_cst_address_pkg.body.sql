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
procedure collect_address_params (
   i_address_id   in             com_api_type_pkg.t_medium_id
 , i_lang         in             com_api_type_pkg.t_dict_value
 , i_inst_id      in             com_api_type_pkg.t_inst_id
 , ia_params_tab  in out nocopy  com_api_type_pkg.t_param_tab
)
is
begin
    trc_log_pkg.debug(
        i_text => lower($$PLSQL_UNIT) || '.collect_address_params: dummy'
    );
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
  , i_postal_code       in      com_api_type_pkg.t_name         default null
  , i_region_code       in      com_api_type_pkg.t_dict_value   default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_tag_name          in      com_api_type_pkg.t_name
  , io_tag_value        in out  com_api_type_pkg.t_name
)is
    o_addr_line1        com_api_type_pkg.t_name;
    o_addr_line2        com_api_type_pkg.t_name;
    o_addr_line3        com_api_type_pkg.t_name;
    o_addr_line4        com_api_type_pkg.t_name;
    l_string            com_api_type_pkg.t_name;
    l_place             com_api_type_pkg.t_tiny_id;
    l_length            com_api_type_pkg.t_tiny_id;
    l_max_len           com_api_type_pkg.t_tiny_id := 40;
    l_delimiter         com_api_type_pkg.t_dict_value := ' ';

begin
    --Base on Woori bank requirement, address includes Street + Region name + City name + Country name
    -- and is splitted into 4 address lines on the PIN mailer
    l_string := i_street
                || ' '
                || cst_woo_com_pkg.get_mapping_code(i_region, cst_woo_const_pkg.WOORI_REGION_CODE)
                || ' '
                || cst_woo_com_pkg.get_mapping_code(i_city, cst_woo_const_pkg.WOORI_CITY_CODE)
                || ' '
                || com_api_country_pkg.get_country_full_name(i_country);

    trc_log_pkg.debug(
        i_text       => 'address_string = ' || l_string
    );

    l_length := length(l_string);

    if l_length > l_max_len then
        o_addr_line1 := substr(l_string, 0, l_max_len);
        l_place      := instr(o_addr_line1, l_delimiter, -1, 1);
        o_addr_line1 := substr(l_string, 0, l_place);
        o_addr_line2 := substr(l_string, l_place, l_length);

        if length(o_addr_line2) > l_max_len then
            o_addr_line2 := substr(o_addr_line2, 0, l_max_len);
            l_place      := instr(o_addr_line2, l_delimiter, -1, 1);
            o_addr_line2 := substr(o_addr_line2, 0, l_place);
            o_addr_line3 := substr(l_string, length(o_addr_line1) + l_place, l_length);

            if length(o_addr_line3) > l_max_len then
                o_addr_line3 := substr(o_addr_line3, 0, l_max_len);
                l_place      := instr(o_addr_line3, l_delimiter, -1, 1);
                o_addr_line3 := substr(o_addr_line3, 0, l_place);
                o_addr_line4 := substr(l_string, length(o_addr_line1) + length(o_addr_line2) + l_place, l_length);
            end if;
        end if;
    else
        o_addr_line1 := l_string;
    end if;

    case i_tag_name
        when 'DF8020' then
            io_tag_value := nvl(trim(o_addr_line1), '_');
            trc_log_pkg.debug(
                i_text      => 'Tag = DF8020, address_line1 = ' || o_addr_line1
            );
        when 'DF8021' then
            io_tag_value := nvl(trim(o_addr_line2), '_');
            trc_log_pkg.debug(
                i_text      => 'Tag = DF8021, address_line2 = ' || o_addr_line2
            );
        when 'DF8022' then
            io_tag_value := nvl(trim(o_addr_line3), '_');
            trc_log_pkg.debug(
                i_text      => 'Tag = DF8022, address_line3 = ' || o_addr_line3
            );
        when 'DF8023' then
            io_tag_value := nvl(trim(o_addr_line4), '_');
            trc_log_pkg.debug(
                i_text      => 'Tag = DF8023, address_line4 = ' || o_addr_line4
            );
    end case;

end get_address_string;

end com_cst_address_pkg;
/
