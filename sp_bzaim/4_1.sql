declare
	raion varchar2(10);
begin
	if :cb.raion = '%' then raion := 'emp';
	else raion := :cb.raion;	
	end if;

--Åñëè àéïè àäðåñ êîìïüþòåðà íå ïóñòîé ïåðåäàþ ïàðàìåòðû èç ïðîãðàììû íà JASPER îò÷åò

if get_const(102)is not null then
		    host( 'start iexplore.exe "'
		    ||get_jrep(1157)
		    ||'&P_DAT_T='||to_char(to_date(:cb.dat,'dd.mm.rrrr'),'dd.mm.rrrr'));
else 
		    message('Нет интеграции с Jasper-отчетом');
		    message('Нет интеграции с Jasper-отчетом');
		    raise form_trigger_failure;
end if;	

end;
