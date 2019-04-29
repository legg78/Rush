create or replace package iss_api_event_pkg is
/*********************************************************
*  Event API for issuing <br />
*  Created by Khougaev A.(khougaev@bpcsv.com)  at 26.11.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: ISS_API_EVENT_PKG <br />
*  @headcom
**********************************************************/
    procedure create_event_fee;

    procedure calculate_reissue_date;
    
    procedure reissue_card_instance;

    procedure get_card_balance;

end;
/
