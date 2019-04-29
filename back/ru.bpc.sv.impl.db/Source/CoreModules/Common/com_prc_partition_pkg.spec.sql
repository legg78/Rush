create or replace package com_prc_partition_pkg as
/************************************************************
*  Maintenance of partitioning. <br />
*  Created by Filimonov A.(filimonov@bpc.ru) at 30.03.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: COM_PRC_PARTITION_PKG <br />
*  @headcom
*************************************************************/

/*
 * Process for creating new partitions and dropping expired ones.
 * @param i_rows    – it is used for manually setting statistics
 *     for a new partition, if parameter is specified then it
 *     should be used to define a number of rows in a new partition
 */
procedure process(
    i_rows              in     com_api_type_pkg.t_medium_id    default null
);

end;
/