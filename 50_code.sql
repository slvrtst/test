CREATE OR REPLACE FUNCTION bid_winner_set(a_id INTEGER) RETURNS int LANGUAGE plpgsql AS
$_$
-- a_id: ID тендера
-- функция рассчитывает победителей заданного тендера
-- и заполняет поля bid.is_winner и bid.win_amount 
declare
   am INTEGER;
  a_tender_id int;
 a_product_id int;
   begin 
	   select tender_id,product_id into a_tender_id,a_product_id from bid where id=a_id;
	with a as (select a.id,case 
		 		when b.amount-sum(a.amount) over (partition by a.tender_id,a.product_id order by a.id desc)>0 
	 				then a.amount
				when b.amount-sum(a.amount) over (partition by a.tender_id,a.product_id order by a.id desc)+a.amount>0 
					then b.amount-sum(a.amount) over (partition by a.tender_id,a.product_id order by a.id desc)+a.amount  
			end pred
			from bid a
	inner join tender_product b on a.tender_id =b.id and a.product_id =b.product_id  
where  b.id=a_tender_id and b.product_id=a_product_id)
select pred
into am
from a
where id=a_id;
	return am;
end

;
$_$;