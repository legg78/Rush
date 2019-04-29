create or replace package cst_woo_prc_outgoing_pkg as
pragma serially_reusable;
/************************************************************
 * Export batch files for Woori bank <br />
 * Created by:
    Chau Huynh (huynh@bpcbt.com)
    Man Do     (m.do@bpcbt.com)  at 2017-03-03     <br />
 * Last changed by $Author: Man Do               $ <br />
 * $LastChangedDate:        2017-09-07 10:00     $ <br />
 * Revision: $LastChangedRevision:  440          $ <br />
 * Module: CST_WOO_PRC_OUTGOING_PKG <br />
 * @headcom
 *************************************************************/

procedure batch_file_45(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null
);

procedure batch_file_45_1(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null
);

procedure batch_file_46(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null      
);

procedure batch_file_49(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null
);

procedure batch_file_52(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null     
);

procedure batch_file_56(
    i_inst_id               in      com_api_type_pkg.t_inst_id
);

procedure batch_file_58(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null
);

procedure batch_file_60(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null    
);

procedure batch_file_61(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null        
);

procedure batch_file_62(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null        
);

procedure batch_file_64(
    i_inst_id               in      com_api_type_pkg.t_inst_id
);

procedure batch_file_66(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_start_date            in      date    default null
);

procedure batch_file_72(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null   
);

procedure batch_file_75(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null   
);

procedure batch_file_83(
    i_inst_id               in      com_api_type_pkg.t_inst_id
);

procedure batch_file_83_1(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null
);

procedure batch_file_87(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_start_date            in      date    default null
  , i_end_date              in      date    default null
);

procedure batch_file_88(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_start_date            in      date    default null
);

procedure batch_file_89(
    i_inst_id               in      com_api_type_pkg.t_inst_id
);

procedure batch_file_92(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null    
);

procedure batch_file_110(
    i_inst_id               in      com_api_type_pkg.t_inst_id
);

procedure batch_file_65_1(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null  
);

procedure batch_file_73_1(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null   
);

procedure batch_file_78_1(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null   
);

procedure batch_file_134(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null      
);

procedure batch_file_137(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null    
);

procedure batch_file_131(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_start_date            in      date    default null
);

procedure batch_file_133(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_start_date            in      date    default null
);

procedure batch_file_126(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null
);

procedure batch_file_93(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_start_date            in      date    default null
  , i_end_date              in      date    default null
);

end cst_woo_prc_outgoing_pkg;
/
