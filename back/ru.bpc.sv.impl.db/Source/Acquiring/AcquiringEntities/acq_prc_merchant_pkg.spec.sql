create or replace package acq_prc_merchant_pkg is
/*********************************************************
 *  Acquiring process <br />
 *  Created by Andrey Fomichev (fomichev@bpcbt.com) at 10.07.2017 <br />
 *  Last changed by $Author: fomichev $ <br />
 *  $LastChangedDate:: 2017-07-10 18:03:00 +0400#$ <br />
 *  Module: acq_prc_merchant_pkg <br />
 *  @headcom
 **********************************************************/
 
procedure calculate_merchants_statistic(
    i_start_date        in     date
  , i_end_date          in     date
);

end acq_prc_merchant_pkg;
/
