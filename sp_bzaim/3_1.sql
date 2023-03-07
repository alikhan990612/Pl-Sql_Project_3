select
	p01 kod_raion,
	p02 naim_raion,
	p03 kod_t,
	p04 naim_t,
	p05 kod_u,
	p06 naim_u,
	to_number(p07) dolg_nach,
	to_number(p08) nach_tek,
	to_number(p09) dolg_na_konec,
	to_number(p10) opl,
	to_number(p11) peres,
	to_number(p12) kol,
	to_number(p13) kolvo_1,
	to_number(p14) nach_kolvo_1,
	to_number(p15) kolvo_2,
	to_number(p16) nach_kolvo_2
from table(jasper.jasper_table(
'begin

-- Запускаю процедуру 

sp_bzaim(to_date('''||$P{P_DAT_T}||''',''dd.mm.rrrr''),null,null,'''||$P{r_g_1}||''');
end;',

--Выбираю нужные данные за несколько месяцов из временной таблицы

'select
        a.kod_raion,
        a.naim_raion,
        a.kod_t,
        a.naim_t,
        a.kod_u,
        a.naim_u,
        sum(a.DOLG_NACH) dolg_nach,
        sum(a.nach_tek) nach_tek,
        sum(a.dolg_na_konec) dolg_na_konec,
        sum(nvl(a.opl,0)) opl,
        sum(nvl(a.peres,0)) peres,
        sum(a.kol) kol,
        sum(a.kolvo_1) kolvo_1,
        sum(a.nach_kolvo_1) nach_kolvo_1,
        sum(a.kolvo_2) kolvo_2,
        sum(a.nach_kolvo_1) nach_kolvo_2
from wg_bzaim a
        group by a.kod_raion, a.naim_raion, a.kod_t, a.naim_t, a.kod_u, a.naim_u
order by a.kod_raion,a.kod_t, a.kod_u'))