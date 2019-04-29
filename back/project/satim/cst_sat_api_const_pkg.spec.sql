create or replace package cst_sat_api_const_pkg as
/*********************************************************
*  SAT custom API constants <br />
*  Created by Gogolev I. (i.gogolev@bpcbt.com) at 06.06.2018 <br />
*  Module: CST_SAT_API_CONST_PKG <br />
*  @headcom
**********************************************************/

CARD_TO_REISSUE_FILE_HEADER     constant com_api_type_pkg.t_raw_data    :=
    'Institution_ID;Agent_ID;Customer_Number;Product_ID;Card_ID;Card_Number;Card_Type;Start_Date;Reissue_Expiration_Date;Pin_Request;Embossing_Request;Pin_Mailer_Request;Card_Frozen_Reissue;Inherit_Pin_OffSet';
SEPARATE_CHAR_DEFAULT           constant com_api_type_pkg.t_byte_char := ';';
FLEX_CARD_FROZEN_REISSUE        constant com_api_type_pkg.t_name        := 'CST_CARD_FROZEN_REISSUE';
ARRAY_ID_CSTS_REISSUE_EXCLUDE   constant com_api_type_pkg.t_medium_id   := -50000059;
INTERNAL_DATE_FORMAT            constant com_api_type_pkg.t_name        := com_api_const_pkg.XML_DATE_FORMAT;

end cst_sat_api_const_pkg;
/
