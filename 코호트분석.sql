# 첫 주문 테이블
select *
from first_ord_table;

# 오더마스터 테이블
select *
from order_master_cohort omc ;

# 테이블 조인
select *
from first_ord_table fot
left join order_master_cohort omc on fot.mem_no = omc.mem_no; 

# 분석에 필요한 데이터 집계
with 
T1 as (
	select distinct fot.mem_no,
			is_promotion,
			case when ord_dt = first_ord_dt then 0
				when ord_dt > first_ord_dt and date(ord_dt) <= date_add(date(first_ord_dt), interval 7 day) then 1
				when ord_dt > date_add(date(first_ord_dt), interval 7 day) and date(ord_dt) <= date_add(date(first_ord_dt), interval 14 day) then 2
				when ord_dt > date_add(date(first_ord_dt), interval 14 day) and date(ord_dt) <= date_add(date(first_ord_dt), interval 21 day) then 3	
				when ord_dt > date_add(date(first_ord_dt), interval 21 day) and date(ord_dt) <= date_add(date(first_ord_dt), interval 28 day) then 4
				else null end as week_number
	from first_ord_table fot 
	left join order_master_cohort omc on fot.mem_no = omc.mem_no 
)
, T2 as (	
	select is_promotion, mem_no, week_number,
			row_number() over(partition by mem_no order by week_number) seq
	from T1
	where week_number is not null)
	
	select is_promotion,  -- 특가 상품 구매자/미구매자 코호트 
			case when week_number = 0 then '1.w-0'
				 when week_number = 1 and seq = 2 then '2.w-1'
				 when week_number = 2 and seq = 3 then '3.w-2'
				 when week_number = 3 and seq = 4 then '4.w-3'
				 when week_number = 4 and seq = 5 then '5.w-4' end as week_range,
			count(mem_no) as mem_cnt
	from T2
	group by 1,2
	order by 1,2;
	
			
