create or replace package acc_prc_entry_buffer_pkg is
/**********************************************************
 * Package contains the processes for entry buffer.
 * 
 * Created by Truschelev O.(truschelev@bpcbt.com) at 01.11.2018
 *
 * Module: ACC_PRC_ENTRY_BUFFER_PKG
 **********************************************************/

    -- Defragment blocks for table "acc_entry_buffer" and its indexes
    procedure defragment_acc_entry_buffer;
    
end acc_prc_entry_buffer_pkg;
/
