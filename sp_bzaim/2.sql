CREATE OR REPLACE procedure sp_bzaim
(
v_dat_t date,                    -- Конец даты на программе который выбирает пользователь.Тем самым передает их на Jasper отчет. Например -> 31.05.2022
v_raion spr_t$raion.kod%type,    -- Код нужного района
v_sector st_sector.kod%type,     -- Код нужного сектора
r_g spr_t$raion.kod%type         -- 1 - группировать по районам. 0 - не группировать
)
is 
p_dat_t_1 varchar2(20);        -- начало тек.года
p_dat_t_2 varchar2(20);        -- начало след.года
i number(20);                  -- разница по месяцам
p_tek_mes date;                -- текущий месяц
p_tek_god varchar2(20);        -- текущий год
p_i_dat date;                  -- все месяца тек.года (01.01.2022,01.02.2022,01.03.2022, ... 01.01.2023)

begin
p_dat_t_1 := to_char(TRUNC(v_dat_t,'YEAR'), 'DD/MM/rrrr');       -- 2022 -> 01 || 01 || 2022 -> 01.01.2022. Беру только год из переданный даты. Потом укажу начало тек.года
p_dat_t_2 := last_day(v_dat_t) + 1;                              -- 31.12.2022 + 1 -> 01.01.2023. if 31.05.2022 then + 1 -> 01.06.2022. Переобразую
i := months_between(to_date(p_dat_t_2, 'dd.mm.rrrr'), to_date(p_dat_t_1, 'dd.mm.rrrr'));                      -- Нахожу разницу месяцов, чтобы указать в цикле количество повторений. В нашем случае 01.06.2022 - 01.01.2022=5 
p_i_dat := p_dat_t_1;

delete from wg_bzaim;
loop                                                             --Запускаю цикл 5 раз
    delete from wk_g$dat;
    insert into wk_g$dat(dat_n,dat_k)values(to_date(p_i_dat, 'dd.mm.rrrr'),to_date(last_day(p_i_dat), 'dd.mm.rrrr')+1);  --Заполняю временную таблицу нужными датами. Пример -> сначала заполняется  за январь , потом за февраль до мая. Май не входит     
    insert into wg_bzaim                                         --Заполняю временную таблицу через select
select
    a.kod_t kod_t,
    a.naim_t naim_t,
    a.kod_u kod_u,
    a.naim_u naim_u,
    a.DOLG_NACH dolg_nach,
    a.nach_tek nach_tek,
    a.na_konec dolg_na_konec,
    nvl(a.opl,0) opl,
    nvl(a.peres,0) peres,
    a.kod_raion,
    a.naim_raion,
    a.kol kol,
    nvl(b.kolvo_1,0) kolvo_1,
    nvl(b.nach_kolvo_1,0) nach_kolvo_1,
    nvl(b.kolvo_2,0) kolvo_2,
    nvl(b.nach_kolvo_2,0) nach_kolvo_2,
    case 
    when p_i_dat = '01.01.2022' then 'Январь' 
    when p_i_dat = '01.02.2022' then 'Февраль' 
    when p_i_dat = '01.03.2022' then 'Март' 
    when p_i_dat = '01.04.2022' then 'Апрель' 
    when p_i_dat = '01.05.2022' then 'Май' 
    when p_i_dat = '01.06.2022' then 'Июнь' 
    when p_i_dat = '01.07.2022' then 'Июль' 
    when p_i_dat = '01.08.2022' then 'Август' 
    when p_i_dat = '01.09.2022' then 'Сентябрь' 
    when p_i_dat = '01.10.2022' then 'Октябрь' 
    when p_i_dat = '01.11.2022' then 'Ноябрь' 
    when p_i_dat = '01.12.2022' then 'Декабрь' 
    end mesyac,
    p_i_dat dat_mesyac
from
(
    select
        case when '1' = r_g then a.kod_raion else '999' end kod_raion,
        case when '1' = r_g then a.naim_raion else 'Без группировки' end naim_raion,
        a.kod_t kod_t,
        a.naim_t naim_t,
        a.kod_u kod_u,
        a.naim_u naim_u,
        sum(a.DOLG_NACH) dolg_nach,
        sum(a.nach_tek) nach_tek,
        sum(a.na_konec) na_konec,
        sum(nvl(a.opl,0)) opl,
        sum(nvl(a.peres,0)) peres,
        sum(a.kol) kol
        from rv_vzaimo_raschet_kategoria a
    where ((a.dolg_nach is not null and a.dolg_nach !=0) or (a.nach_tek is not null and a.nach_tek !=0)
or (a.na_konec is not null and a.na_konec !=0)) and a.kod_raion = nvl(v_raion,a.kod_raion) and a.sector = nvl(v_sector,a.sector)
group by a.kod_raion, a.naim_raion, a.kod_t, a.naim_t, a.kod_u, a.naim_u
order by a.kod_raion, a.kod_t, a.kod_u ) a
left join
(
select kod_raion,klas,naim,sum(kol_hv) kol_hv, sum(kolvo_1) kolvo_1 ,sum(kolvo_2) kolvo_2,
sum(nach_kolvo_1) nach_kolvo_1, sum(nach_kolvo_2) nach_kolvo_2
from(
select a.kod_raion kod_raion, a.klas klas, a.kol_hv kol_hv, a.kolvo kolvo_1, 0 kolvo_2,
a.summa nach_kolvo_1, 0 nach_kolvo_2, b.naim naim from rv_vod_limit a
join spr_t$klas_obj b on b.kod = a.klas
where a.kod = 1 and a.naim = '1 категория' and a.kod_raion = nvl(v_raion,a.kod_raion) and a.sector = nvl(v_sector,a.sector)
union all
select a.kod_raion kod_raion, a.klas klas, 0 kol_hv, 0 kolvo_1, a.kolvo kolvo_2,
0 nach_kolvo_1, a.summa nach_kolvo_2, b.naim naim from rv_vod_limit a
join spr_t$klas_obj b on b.kod = a.klas
where a.kod = 2 and a.naim = '2 категория' and a.kod_raion = nvl(v_raion,a.kod_raion) and a.sector = nvl(v_sector,a.sector)
     ) group by kod_raion, klas, naim
) b on b.kol_hv = a.kol
order by a.kod_raion, a.kod_t, a.kod_u;
i := i - 1;                                           -- Теперь i = 4
p_i_dat := last_day(p_i_dat) + 1;                     -- Если в начале p_i_dat = '01.01.2021', Теперь p_i_dat = '01.02.2021'
exit when i=0;                                        -- Выхожу из цикла когда  i = 0
end loop;
end;
/
