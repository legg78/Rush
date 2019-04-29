create or replace package itf_prc_rate_pkg as
/*********************************************************
 *  Process for load currency rates <br />
 *  Created by Kopachev D.(kopachev@bpcbt.com)  at 03.06.2013 <br />
 *  Last changed by $Author: kopachev $ <br />
 *  $LastChangedDate:: 2011-11-15 11:43:12 +0300#$ <br />
 *  Revision: $LastChangedRevision: 13781 $ <br />
 *  Module: com_prc_rate_pkg   <br />
 *  @headcom
 **********************************************************/
    FIELD_TAG_CONVERSION_DATE             constant com_api_type_pkg.t_dict_value := 'DF8230';
    FIELD_TAG_CONVERSION_TIME             constant com_api_type_pkg.t_dict_value := 'DF8231';
    FIELD_TAG_MULTIPLE_FLAG               constant com_api_type_pkg.t_dict_value := 'DF8232';
    FIELD_TAG_COMMA_POSITION              constant com_api_type_pkg.t_dict_value := 'DF8233';
    FIELD_TAG_CONVERSION_RATE             constant com_api_type_pkg.t_dict_value := 'DF8234';
    FIELD_TAG_INSTITUTION_ID              constant com_api_type_pkg.t_dict_value := 'DF8235';
    FIELD_TAG_CURRENCY_CODE               constant com_api_type_pkg.t_dict_value := 'DF8034';
    FIELD_TAG_DIRECTION_TYPE              constant com_api_type_pkg.t_dict_value := 'DF822F';
 
    procedure load_rates_tlv(
        i_rate_type           in   com_api_type_pkg.t_dict_value
    );

    function int_to_float( 
      i_int  in     number, 
      i_pos  in     number 
    )
    return number; 
end;
/