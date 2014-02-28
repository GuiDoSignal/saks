column SUM for 9999999999 HEAD 'Total #| Rows'
column CNT for 999999 HEAD 'Total #| Dist Values'
column min for 999999 HEAD 'Min #| of Rows'
column AVG for 999999 HEAD 'Avg #| of Rows'
column max for 999999 HEAD 'Max #| of Rows'
column BSEL for 999999.99 HEAD 'Best|Selectivity [%]'
column ASEL for 999999.99 HEAD 'Avg|Selectivity [%]'
column WSEL for 999999.99 HEAD 'Worst|Selectivity [%]'
set lines 2000

SELECT SUM(a) SUM,
  COUNT(a) cnt,
  MIN(a) MIN,
  ROUND(AVG(a),1) AVG,
  MAX(a) MAX,
  ROUND(MIN(a)/SUM(a)*100,2) bsel,
  ROUND(AVG(a)/SUM(a)*100,2) asel,
  ROUND(MAX(a)/SUM(a)*100,2) wsel from
  (SELECT COUNT(*) a FROM &owner_tabela GROUP BY &colunas_separadas_por_virgula
  );