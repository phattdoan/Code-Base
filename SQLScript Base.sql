,DATES AS (
		SELECT
		  /*ADD_MONTHS(SYSDATE,-12)*/ DATE '2016-08-01' AS START_DT
		  ,/*SYSDATE*/DATE '2017-08-01' AS END_DT   

		FROM DUAL)	

-----------------------------
-- adding row number
-- 
select ROW_NUMBER() OVER (ORDER BY hicn DESC) AS ID
	  , hicn, PA_StartDate, PA_EndDate
from tempdb."##RestatedMMR"


-----------------------------
-- extract year
-- THP, checking member with no_encounter in 2016 and 2016
select d.member_dbid
from ea.member_dxcodes d
left join ea.members m
	on d.member_dbid = m.dbid
where m.client_dbid = 43 and m.current_is_eligible = true
		and (date_part('year', d.date_of_service) != 2016 and date_part('year', d.date_of_service) != 2017)
group by d.member_dbid

-- THP, QA query for checking member with no_encounter in 2016 and 2016
select *
from
	(select d.member_dbid, max(date_part('year', d.date_of_service)) as last_encounter
	from ea.member_dxcodes d
	left join ea.members m
		on d.member_dbid = m.dbid
	where m.client_dbid = 43 and m.current_is_eligible = true
	group by d.member_dbid) as t1
where t1.last_encounter != 2016 and t1.last_encounter != 2017

-----------------------------
select
    n.ClientChartID,
    n1.ComboDOS as dos1,
    n2.ComboDOS as dos2,
    n3.ComboDOS as dos3,
    n4.ComboDOS as dos4,
    n5.ComboDOS as dos5,
    n6.ComboDOS as dos6,
    n7.ComboDOS as dos7,
    n8.ComboDOS as dos8,
    n9.ComboDOS as dos9,
    n10.ComboDOS as dos10,	
    n11.ComboDOS as dos11	
from
    NAMM n
    left outer join NAMM n1 
	on
        n.ClientChartID = n1.ClientChartID
        and n1.ch = '1'
    left outer join NAMM n2 
	on
        n.ClientChartID = n2.ClientChartID
        and n2.ch = '2'
    left outer join NAMM n3 
	on
        n.ClientChartID = n3.ClientChartID
        and n3.ch = '3'
    left outer join NAMM n4 
	on
        n.ClientChartID = n4.ClientChartID
        and n4.ch = '4'
    left outer join NAMM n5 
	on
        n.ClientChartID = n5.ClientChartID
        and n5.ch = '5'
    left outer join NAMM n6 
	on
        n.ClientChartID = n6.ClientChartID
        and n6.ch = '6'
    left outer join NAMM n7 
	on
        n.ClientChartID = n7.ClientChartID
        and n7.ch = '7'
    left outer join NAMM n8 
	on
        n.ClientChartID = n8.ClientChartID
        and n8.ch = '8'
    left outer join NAMM n9 
	on
        n.ClientChartID = n9.ClientChartID
        and n9.ch = '9'
    left outer join NAMM n10 
	on
        n.ClientChartID = n10.ClientChartID
        and n10.ch = '10'
    left outer join NAMM n11 
	on
        n.ClientChartID = n11.ClientChartID
        and n11.ch = '11'



--------------------------------------------------------------------------------------------------------
-- Comorbidities - members w/ only 1 HCC
-- Phat
-- 4/30/2017
--------------------------------------------------------------------------------------------------------
select mem_hcc_codes.member_dbid
		, mem_hcc_codes.member_id, mem_hcc_codes.full_name
		, mem_hcc_codes.date_of_birth, mem_hcc_codes.age
		, mem_hcc_codes.dbid, mem_hcc_codes.pcp_name 
		, mem_hcc_codes.hcc_code, '2016' as year
from
	-- group members and hcc_code to be filtered
		(select  h.member_dbid, h.hcc_code, count(hcc_code)
					, m.member_id, m.full_name 
					, m.date_of_birth, m.age
					, m.dbid, m.pcp_name
		from ea.member_hccs h
		left join ea.members m
			on h.member_dbid = m.dbid
		where m.client_dbid = 1 and h.prior_hcc_status ilike 'Cap%'
				and h.hcc_code not like 'INT%'
			and (h.hcc_code = 'HCC084' or h.hcc_code = 'HCC072'
				or h.hcc_code = 'HCC122' or h.hcc_code = 'HCC114'
				or h.hcc_code = 'HCC086')
		group by h.member_dbid, h.hcc_code
					, m.member_id, m.full_name 
					, m.date_of_birth, m.age 
					, m.dbid, m.pcp_name
		order by member_dbid desc) as mem_hcc_codes 
		
		inner join -- filtering for only members with 1 HCC
		
		(-- find members in 2016 with only 1 HCC, excluding interaction
		select mem_hcc_count.member_dbid
		from 
			(select h.member_dbid, count(h.hcc_code) as hcc_code_count
			from ea.member_hccs h
			left join ea.members m
				on h.member_dbid = m.dbid
			where m.client_dbid = 1 and h.prior_hcc_status ilike 'Cap%'
				  and h.hcc_code not like 'INT%'
				  and m.prior_is_eligible = 'true'
			group by h.member_dbid) as mem_hcc_count
		where mem_hcc_count.hcc_code_count = 1) as mem_w_1hcc
		on mem_hcc_codes.member_dbid = mem_w_1hcc.member_dbid

-- [OBSOLETE] query members in 2016 with only 1HCC for the top 5 HCCs w/ high co-morb
select 	mem_hcc_codes.member_dbid
		, mem_hcc_codes.hcc_code
		, '2016' as year
from
	(-- group members and hcc_code to be filtered
		select h.member_dbid, h.hcc_code, count(hcc_code)
		from ea.member_hccs h
		left join ea.members m
			on h.member_dbid = m.dbid
		where m.client_dbid = 1 and h.prior_hcc_status ilike 'Cap%'
				and h.hcc_code not like 'INT%'
			and (h.hcc_code = 'HCC084' or h.hcc_code = 'HCC072'
				or h.hcc_code = 'HCC122' or h.hcc_code = 'HCC114'
				or h.hcc_code = 'HCC086')
		group by h.member_dbid, h.hcc_code
		order by member_dbid desc) as mem_hcc_codes 
	inner join -- filtering for only members with 1 HCC
		(-- find members in 2016 with only 1 HCC, excluding interaction
		select mem_hcc_count.member_dbid
		from 
			(select h.member_dbid, count(h.hcc_code) as hcc_code_count
			from ea.member_hccs h
			left join ea.members m
				on h.member_dbid = m.dbid
			where m.client_dbid = 1 and h.prior_hcc_status ilike 'Cap%'
				  and h.hcc_code not like 'INT%'
				  and m.prior_is_eligible = 'true'
			group by h.member_dbid) as mem_hcc_count
		where mem_hcc_count.hcc_code_count = 1) as mem_w_1hcc
	on mem_hcc_codes.member_dbid = mem_w_1hcc.member_dbid

union all -- join with 2015 members

select 	mem_hcc_codes.member_dbid
		, mem_hcc_codes.hcc_code
		, '2015' as year
from
	(-- group members and hcc_code to be filtered
		select h.member_dbid, h.hcc_code, count(hcc_code)
		from ea.member_hccs h
		left join ea.members m
			on h.member_dbid = m.dbid
		where m.client_dbid = 1 and h.prior2_hcc_status ilike 'Cap%'
				and h.hcc_code not like 'INT%'
			and (h.hcc_code = 'HCC084' or h.hcc_code = 'HCC072'
				or h.hcc_code = 'HCC122' or h.hcc_code = 'HCC114'
				or h.hcc_code = 'HCC086')
		group by h.member_dbid, h.hcc_code
		order by member_dbid desc) as mem_hcc_codes 
	inner join -- filtering for only members with 1 HCC
		(-- find members in 2016 with only 1 HCC, excluding interaction
		select mem_hcc_count.member_dbid
		from 
			(select h.member_dbid, count(h.hcc_code) as hcc_code_count
			from ea.member_hccs h
			left join ea.members m
				on h.member_dbid = m.dbid
			where m.client_dbid = 1 and h.prior2_hcc_status ilike 'Cap%'
				  and h.hcc_code not like 'INT%'
				  and m.prior2_is_eligible = 'true'
			group by h.member_dbid) as mem_hcc_count
		where mem_hcc_count.hcc_code_count = 1) as mem_w_1hcc
	on mem_hcc_codes.member_dbid = mem_w_1hcc.member_dbid
order by mem_hcc_codes.hcc_code desc
--------------------------------------------------------------------------------------------------------
-- QA Query for finding members with only 1 HCC
select *
from ea.member_hccs
where (member_dbid = )
--		and prior_hcc_status ilike 'Capt%'

--------------------------------------------------------------------------------------------------------
-- Housecalls Delivery Range
-- Phat
-- 4/27/2017
--------------------------------------------------------------------------------------------------------
select  received as batch
		, count(barcode) as total_chart_count
		, min(delivery_time) as shortest_range
		, (case when delivery_time = min(delivery_time) then count(barcode) 
				else
					0
				end) as shortest_count
		, max(delivery_time) as longest_range
		, (case when (delivery_time = max(delivery_time) and delivery_time != min(delivery_time)) then count(barcode) 
				else
					0
				end) as longest_count		
from ProdReport
where status like "9%"
group by received


--------------------------------------------------------------------------------------------------------
Create Table as memberDemographic
( select uniqnue_member_id, 

from tblAC_Member
)

--------------------------------------------------------------------------------------------------------
select memElig.memID,
	memElig.memCurrElig,
	memElig.memPriorElig,
	memElig.memPrior2Elig,
	memElig.memPrior3Elig,
	memElig.memCurrDosCount,
	memElig.memPriorDosCount,
	memElig.memPrior2DosCount,
	memElig.memCurrPcpDosCount,
	memElig.memPriorPcpDosCount,
	x2014memHccCap.x2014HccTotal,
	x2015memHccCap.x2015HccTotal,
	x2016memHccCap.x2016HccTotal
from memElig
left join x2014memHccCap
	on memElig.memID = x2014memHccCap.memID
left join x2015memHccCap
	on memElig.memID = x2015memHccCap.memID	
left join x2016memHccCap
	on memElig.memID = x2016memHccCap.memID
;

select memID
from memHccDosCount
where memCurrElig = "1"
	and memPriorElig = "1"
	and memPrior2Elig = "1"
	and memPrior3Elig = "1"
;

select count(memID)
from memHccDosCount
where memCurrElig = "0" or memCurrElig = "1"
	and memPriorElig = "1"
	and memPrior2Elig = "0"
	and memPrior3Elig = "0"
;

select *
from NAMMHOSP
union all
select *
from NAMMPCP
union all
select *
from OCNV
union all
select *
from AppleCare;

<div><a href="http://portal.adp.com" target="_blank"><img alt="Image result for adp logo" height="114" src="https://upload.wikimedia.org/wikipedia/commons/e/ea/ADP_Red_Logo_w_Tag_RGB_Center_updated.png" style="line-height:1.5;background-color:transparent" width="200"></a><br>
<a href="http://www.concur.com" target="_blank"><img alt="Image result for concur logo" height="200" src="http://assets.concur.com/logos/2016_Concur_Logo_Reg_VT_Color.png" style="display:block;margin-right:auto;margin-left:auto;text-align:center" width="191"></a>
</div>

select Member_Id, 
	SubscriberLastName, 
	SubscriberFirstName, 
	SubscriberDOB,
	SubscriberGender,
	PrimaryPayerName
from x837_manipulation
group by Member_Id
;

select *
from FollowUp46_Results
left join ChartAudit_Results
	on FollowUp46_Results.Member_Id_Temp = ChartAudit_Results.Member_Id_Temp 
		and FollowUp46_Results.DxCode = ChartAudit_Results.DxCode
;

select BBB_Weekly_Delivery_10212016_12072016.type,
	BBB_Weekly_Delivery_10212016_12072016.Work_ID,
	BBB_Weekly_Delivery_10212016_12072016.Dx_Code,
	BBB_Weekly_Delivery_10212016_12072016.Flag,
	BBB_Weekly_Delivery_10212016_12072016.Comment,
	Dx_HCC_Value.HCC_Code,
	Dx_HCC_Value.Description,
	Dx_HCC_Value.Value 
from BBB_Weekly_Delivery_10212016_12072016
left join Dx_HCC_Value
	on BBB_Weekly_Delivery_10212016_12072016.Dx_Code = Dx_HCC_Value.Dx_Code
;


select d.dbid, d.provider_dbid, d.member_dbid,
		d.dxcode, d.date_of_service_year, d.hcc_code,
		d.hcc_type, d.description, d.procedure_code, 
		d.dx_status, d.code_source
from ea.member_dxcodes d
left join ea.members m
	on d.member_dbid = m.dbid
where m.client_dbid = '1' and m.current_is_eligible = 'true' 
		and m.prior2_is_eligible = 'true'


select d.dbid, d.provider_dbid, d.member_dbid,
		d.dxcode, d.date_of_service_year, d.hcc_code,
		d.hcc_type, d.description, d.procedure_code, 
		d.dx_status, d.code_source
from ea.member_dxcodes d
left join ea.members m
	on d.member_dbid = m.dbid
where m.client_dbid = '1' and m.current_is_eligible = 'true' 
		and m.prior2_is_eligible = 'true'
group by d.member_dbid, count(d.hcc_code), count(d.dxcode), count(procedure_code)
order by count(d.procedure_code)

select member_id, prior_hcc_captured
from ea.members
where client_dbid = '1' and prior_is_eligible = 'true'
order by prior_hcc_captured desc

select h.hcc_code, count(distinct h.member_dbid)
from ea.member_hccs h 
left join ea.members m
	on h.member_dbid = m.dbid
where m.client_dbid = '1'and prior_hcc_status like 'Captu%'
group by hcc_code

select 	m.member_id, p.dbid AS provider_dbid,
			m.current_is_eligible,  m.prior_is_eligible,
			m.prior2_is_eligible,
			m.prior_raf_suspects_yoy, m.prior_raf_suspects_clin,
			m.prior_hcc_suspects_clin, m.prior_opportunity,
			m.prior_raf_captured, m.prior_raf_projected,
			m.prior_pcp_dos_count, m.prior_dos_count,
			p.prior2_avg_raf_captured as provider_prior2_abg_raf_capture, 
			p.prior2_recapture_rate as provider_prior2_recapture_rate,
			m.prior2_raf_suspects_yoy, m.prior2_raf_suspects_clin,
			m.prior2_hcc_suspects_clin, m.prior2_opportunity,
			m.prior2_raf_captured, m.prior2_raf_projected,
			m.prior2_pcp_dos_count, m.prior2_dos_count,
			p.prior2_avg_raf_captured as provider2_prior_abg_raf_capture, 
			p.prior2_recapture_rate as provider2_prior_recapture_rate
from ea.members m
left join ea.providers p 
	on m.pcp_dbid = p.dbid
where m.client_dbid = '1' and 
		(m.prior_is_eligible = 'true' or m.prior2_is_eligible = 'true')
limit 5

select *
from ea.providers
where client_dbid = '1' and 
		(full_name = 'SWEENY, ALFREDO' or full_name = 'WONG, DONNA LYNN' or
		full_name = 'SCHNEIDER, MARK' or full_name = 'SECHRIST, MARTIN' or
		full_name like 'BARRIENTOS, DOMINGO') 
limit 5

select *
from ea.members m
left join ea.providers p 
	on m.pcp_dbid = p.dbid
where m.client_dbid = '1' and 
		(m.prior_is_eligible = 'true' or m.prior2_is_eligible = 'true' or m.current_is_eligible = 'true') and 
		(p.full_name = 'SWEENY, ALFREDO' or p.full_name = 'WONG, DONNA LYNN' or
		p.full_name = 'SCHNEIDER, MARK' or p.full_name = 'SECHRIST, MARTIN' or
		p.full_name like 'BARRIENTOS, DOMINGO') 


# need to test
SELECT m.member_id, h.member_dbid, m.client_dbid, m.full_name,
       m.current_hcc_captured, m.current_hcc_suspects_all, m.current_is_eligible,
      m.prior_hcc_captured, m.prior_hcc_suspects_all, m.prior_is_eligible,
      m.prior2_hcc_captured,  m.prior2_hcc_suspects_all, m.prior2_is_eligible,
      COUNT(CASE WHEN  h.current_hcc_status ilike  'captured%' THEN 1 END) AS Current_Captured
      , COUNT(CASE WHEN  h.Prior_hcc_status ilike  'captured%' THEN 1 END) AS Prior_Captured
      , COUNT(CASE WHEN  h.Prior2_hcc_status ilike  'captured%' THEN 1 END) AS Prior2_Captured
FROM ea.members m
inner join ea.member_hccs h
ON m.dbid = h.member_dbid
WHERE client_dbid = '1' and prior_captured = '0' and prior_is_eligible = 'true'-- To Filter out Applecare client.
Group by
m.member_id, h.member_dbid, m.client_dbid, m.full_name,
       m.current_hcc_captured, m.current_hcc_suspects_all, m.current_is_eligible,
      m.prior_hcc_captured, m.prior_hcc_suspects_all, m.prior_is_eligible,
      m.prior2_hcc_captured,  m.prior2_hcc_suspects_all, m.prior2_is_eligible

-------------------------------------------------------------------------------------
###################
Nested SQL
###################

SELECT h.HCC_Code
	, h.HCC_Description
	, count(DISTINCT CASE WHEN h.current_hcc_status ilike 'captured%' and a.current_is_eligible = 'True'  THEN h.member_dbid END) AS Current_Captured
	, count(DISTINCT CASE WHEN h.current_hcc_status ilike 'suspect%' and a.current_is_eligible = 'True'  THEN h.member_dbid END) AS Current_Suspected
	, ( select count(DISTINCT dbid)
		from ea.members as a
		where a.client_dbid = '1' and a.current_is_eligible =  'True') as Eligible_members_2017
	, count(DISTINCT CASE WHEN h.prior_hcc_status ilike 'captured%' and a.prior_is_eligible = 'True'  THEN h.member_dbid END) AS Prior_Captured
	, count(DISTINCT CASE WHEN h.prior_hcc_status ilike 'suspect%' and a.prior_is_eligible = 'True'  THEN h.member_dbid END) AS Prior_Suspected
	, ( select count(DISTINCT dbid)
		from ea.members as a
		where a.client_dbid = '1' and a.prior_is_eligible =  'True') as Eligible_members_2016
	, count(DISTINCT CASE WHEN h.prior2_hcc_status ilike 'captured%' and a.prior2_is_eligible = 'True'  THEN h.member_dbid END) AS Prior2_Captured
	, count(DISTINCT CASE WHEN h.prior2_hcc_status ilike 'suspect%'and a.prior2_is_eligible = 'True'  THEN h.member_dbid END) AS Prior2_Suspected
	, ( select count(DISTINCT dbid)
		from ea.members as a
		where a.client_dbid = '1' and a.prior2_is_eligible =  'True') as Eligible_members_2015
from ea.member_hccs h					
inner join ea.members as a
on h.member_dbid = a.dbid
where  a.client_dbid = '1'
group by h.hcc_code, h.hcc_description
order by h.hcc_code asc

select 	(select count(distinct dbid)
				from ea.members
				where client_dbid = 1 and current_hcc_captured = 0 and current_is_eligible = 'True'
				) as member_wout_hcc_2017 
			,(select count(distinct dbid)
				from ea.members
				where client_dbid = 1 and current_hcc_captured != '0' and current_is_eligible = 'True'
				) as member_with_hcc_2017
			,(select count(distinct dbid)
				from ea.members
				where client_dbid = 1 and current_is_eligible = 'True'
				) as eligible_members_2017
			,(select count(distinct dbid)
				from ea.members
				where client_dbid = 1 and prior_hcc_captured = 0 and prior_is_eligible = 'True'
				) as member_wout_hcc_2016 
			,(select count(distinct dbid)
				from ea.members
				where client_dbid = 1 and prior_hcc_captured != '0' and prior_is_eligible = 'True'
				) as member_with_hcc_2016
			,(select count(distinct dbid)
				from ea.members
				where client_dbid = 1 and prior_is_eligible = 'True'
				) as eligible_members_2016
			,(select count(distinct dbid)
				from ea.members
				where client_dbid = 1 and prior2_hcc_captured = 0 and prior2_is_eligible = 'True'
				) as member_wout_hcc_2015 
			,(select count(distinct dbid)
				from ea.members
				where client_dbid = 1 and prior2_hcc_captured != '0' and prior2_is_eligible = 'True'
				) as member_with_hcc_2015
			,(select count(distinct dbid)
				from ea.members
				where client_dbid = 1 and prior2_is_eligible = 'True'
				) as eligible_members_2015	
from ea.members
limit 1

select 	member_id, pcp_dbid, age, gender, health_plan_name,
			zip, prior2_dos_count, prior2_pcp_dos_count,
			prior2_raf_captured, prior2_hcc_captured, prior2_raf_projected,
			prior2_dos_count, prior2_pcp_dos_count,
			prior2_raf_captured, prior2_hcc_captured, prior2_raf_projected,


select 	member_id, case when (current_year_eligibility_status = 'Churn' or 
				prior_year_eligibility_status = 'Churn' or  prior2_eligibility_status = 'Churn') then 'yes'  
				else 'no' end as churn,
			pcp_dbid, age, gender, health_plan_name, zip, 
			current_dos_count, current_pcp_dos_count,
			current_raf_captured, current_hcc_captured, current_raf_projected,
			prior_dos_count, prior_pcp_dos_count,
			prior_raf_captured, prior_hcc_captured, prior_raf_projected,
			prior2_raf_captured, prior2_hcc_captured, prior2_raf_projected
from ea.members
where client_dbid = 1

--------------------------------------------------------------------------------------------------------
SELECT p.full_name, p.provider_id, h.HCC_Code
	, h.HCC_Description
	, count(DISTINCT CASE WHEN h.current_hcc_status ilike 'captured%' and a.current_is_eligible = 'True'  THEN h.member_dbid END) AS Current_Captured
	, count(DISTINCT CASE WHEN h.current_hcc_status ilike 'suspect%' and a.current_is_eligible = 'True'  THEN h.member_dbid END) AS Current_Suspected
	, ( select count(DISTINCT dbid)
		from ea.members as a
		where a.client_dbid = '1' and a.current_is_eligible =  'True') as Eligible_members_2017
	, count(DISTINCT CASE WHEN h.prior_hcc_status ilike 'captured%' and a.prior_is_eligible = 'True'  THEN h.member_dbid END) AS Prior_Captured
	, count(DISTINCT CASE WHEN h.prior_hcc_status ilike 'suspect%' and a.prior_is_eligible = 'True'  THEN h.member_dbid END) AS Prior_Suspected
	, ( select count(DISTINCT dbid)
		from ea.members as a
		where a.client_dbid = '1' and a.prior_is_eligible =  'True') as Eligible_members_2016
	, count(DISTINCT CASE WHEN h.prior2_hcc_status ilike 'captured%' and a.prior2_is_eligible = 'True'  THEN h.member_dbid END) AS Prior2_Captured
	, count(DISTINCT CASE WHEN h.prior2_hcc_status ilike 'suspect%'and a.prior2_is_eligible = 'True'  THEN h.member_dbid END) AS Prior2_Suspected
	, ( select count(DISTINCT dbid)
		from ea.members as a
		where a.client_dbid = '1' and a.prior2_is_eligible =  'True') as Eligible_members_2015
from ea.member_hccs h					
inner join ea.members as a
on h.member_dbid = a.dbid
inner join ea.providers as p
on a.pcp_dbid = p.dbid
where  a.client_dbid = '1'
group by p.full_name, p.provider_id, h.hcc_code, h.hcc_description


--------------------------------------------------------------------------------------------------------
# joining 2 tables
SELECT * 
from 
(select p.full_name, p.provider_id, p.dbid, h.hcc_Code
	, h.HCC_Description
	, count(DISTINCT CASE WHEN h.current_hcc_status ilike 'captured%' and a.current_is_eligible = 'True'  THEN h.member_dbid END) AS Current_Captured
	, count(DISTINCT CASE WHEN h.current_hcc_status ilike 'suspect%' and a.current_is_eligible = 'True'  THEN h.member_dbid END) AS Current_Suspected
	, count(DISTINCT CASE WHEN h.prior_hcc_status ilike 'captured%' and a.prior_is_eligible = 'True'  THEN h.member_dbid END) AS Prior_Captured
	, count(DISTINCT CASE WHEN h.prior_hcc_status ilike 'suspect%' and a.prior_is_eligible = 'True'  THEN h.member_dbid END) AS Prior_Suspected
	, count(DISTINCT CASE WHEN h.prior2_hcc_status ilike 'captured%' and a.prior2_is_eligible = 'True'  THEN h.member_dbid END) AS Prior2_Captured
	, count(DISTINCT CASE WHEN h.prior2_hcc_status ilike 'suspect%'and a.prior2_is_eligible = 'True'  THEN h.member_dbid END) AS Prior2_Suspected
from ea.member_hccs h					
inner join ea.members as a
on h.member_dbid = a.dbid
inner join ea.providers as p
on a.pcp_dbid = p.dbid
where  a.client_dbid = '1'
group by p.full_name, p.provider_id, p.dbid, h.hcc_code, h.hcc_description) table1

inner join

(select pcp_dbid
		 , count(DISTINCT CASE WHEN current_is_eligible = 'True'  THEN dbid END) AS prov_eligible_members_2017
		 , count(DISTINCT CASE WHEN prior_is_eligible = 'True'  THEN dbid END) AS prov_eligible_members_2016
		 , count(DISTINCT CASE WHEN prior2_is_eligible = 'True'  THEN dbid END) AS prov_eligible_members_2015		 
from ea.members
where client_dbid = 1
group by pcp_dbid) as table2
on table1.dbid = table2.pcp_dbid

--------------------------------------------------------------------------------------------------------
--Unpivot the table.
SELECT VendorID, Employee, Orders
FROM 
   (SELECT VendorID, Emp1, Emp2, Emp3, Emp4, Emp5
   FROM pvt) p
UNPIVOT
   (Orders FOR Employee IN 
      (Emp1, Emp2, Emp3, Emp4, Emp5)
)AS unpvt;
