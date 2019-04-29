create or replace function stragg (p1 varchar2)
   return varchar2
   parallel_enable aggregate using stragg_tpr;
/
