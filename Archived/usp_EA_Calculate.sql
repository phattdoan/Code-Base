USE [RAFi]
GO

/****** Object:  StoredProcedure [dbo].[usp_EA_Calculate]    Script Date: 2/2/2017 2:38:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- exec [usp_EA_Calculate] 2016

CREATE PROC [dbo].[usp_EA_Calculate] 
	@current_year int
AS
BEGIN

	SET NOCOUNT ON
	SET ROWCOUNT 0

	Exec usp_RAF_Log 'usp_EA_Calculate', 'Start', '', '', ''

	-- Eligibility Data
	Update EA_Members
	Set [Current_Is_Eligible]	= IsNull(Current_Eligible, 0),
		[Prior_Is_Eligible]		= IsNull(Prior_Eligible, 0),
		[Prior2_Is_Eligible]	= IsNull(Prior2_Eligible, 0),
		[Prior3_Is_Eligible]	= IsNull(Prior3_Eligible, 0)
	From EA_Members m
	Left Join (
		Select	Member_Id,
				Max(Case When [Year] = @current_year Then 1 Else 0 End) As Current_Eligible,
				Max(Case When [Year] = @current_year - 1 Then 1 Else 0 End) As Prior_Eligible,
				Max(Case When [Year] = @current_year - 2 Then 1 Else 0 End) As Prior2_Eligible,
				Max(Case When [Year] = @current_year - 3 Then 1 Else 0 End) As Prior3_Eligible
		From [Applecare_Members_Eligibility]
		Group By Member_Id
	) As tbl
	On tbl.Member_Id = m.Member_Id


	-- Demographics
	Update EA_Members
	Set [Current_RAF_Demographic]	= Current_Demo,
		[Prior_RAF_Demographic]		= Prior_Demo,
		[Prior2_RAF_Demographic]	= Prior2_Demo
	From EA_Members m
	Join (
		Select	Member_Id,
				Max(Case When [Year] = @current_year Then Value Else 0 End) As Current_Demo,
				Max(Case When [Year] = @current_year - 1 Then Value Else 0 End) As Prior_Demo,
				Max(Case When [Year] = @current_year - 2 Then Value Else 0 End) As Prior2_Demo
		From [RAF_Member_Demos]
		--Where Member_Id = ''
		Group By Member_Id
	) As tbl
	On tbl.Member_Id = m.Member_Id


	-- HCC Values
	Update EA_Members 
	Set [Current_HCC_Captured]				= IsNull([Current_Captured], 0),
		[Current_HCC_Suspects_YOY]			= IsNull([Current_Suspects_YOY], 0),
		[Current_HCC_Suspects_Clinical]		= IsNull([Current_Suspects_Clinical], 0),
		[Current_HCC_Suspects_Unacceptable] = IsNull([Current_Suspects_Unaccpt], 0),
		[Prior_HCC_Captured]				= IsNull([Prior_Captured], 0),
		[Prior_HCC_Suspects_YOY]			= IsNull([Prior_Suspects_YOY], 0),
		[Prior_HCC_Suspects_Clinical]		= IsNull([Prior_Suspects_Clinical], 0),
		[Prior_HCC_Suspects_Unacceptable]	= IsNull([Prior_Suspects_Unaccpt], 0),
		[Prior2_HCC_Captured]				= IsNull([Prior2_Captured], 0),
		[Prior2_HCC_Suspects_YOY]			= IsNull([Prior2_Suspects_YOY], 0),
		[Prior2_HCC_Suspects_Clinical]		= IsNull([Prior2_Suspects_Clinical], 0),
		[Prior2_HCC_Suspects_Unacceptable]	= IsNull([Prior2_Suspects_Unaccpt], 0)
	From EA_Members m
	Left Join (
		Select  Member_Id,
				Sum(Case When [Year] = @current_year And HCC_Type = 'Captured' Then Hcc_Value Else 0 End) As [Current_Captured],
				Sum(Case When [Year] = @current_year And HCC_Type = 'YOY' Then Hcc_Value Else 0 End) As [Current_Suspects_YOY],
				Sum(Case When [Year] = @current_year And HCC_Type = 'Clinical' Then Hcc_Value Else 0 End) As [Current_Suspects_Clinical],
				Sum(Case When [Year] = @current_year And HCC_Type = 'Unaccpt' Then Hcc_Value Else 0 End) As [Current_Suspects_Unaccpt],
				Sum(Case When [Year] = @current_year - 1 And HCC_Type = 'Captured' Then Hcc_Value Else 0 End) As [Prior_Captured],
				Sum(Case When [Year] = @current_year - 1 And HCC_Type = 'YOY' Then Hcc_Value Else 0 End) As [Prior_Suspects_YOY],
				Sum(Case When [Year] = @current_year - 1 And HCC_Type = 'Clinical' Then Hcc_Value Else 0 End) As [Prior_Suspects_Clinical],
				Sum(Case When [Year] = @current_year - 1 And HCC_Type = 'Unaccpt' Then Hcc_Value Else 0 End) As [Prior_Suspects_Unaccpt],
				Sum(Case When [Year] = @current_year - 2 And HCC_Type = 'Captured' Then Hcc_Value Else 0 End) As [Prior2_Captured],
				Sum(Case When [Year] = @current_year - 2 And HCC_Type = 'YOY' Then Hcc_Value Else 0 End) As [Prior2_Suspects_YOY],
				Sum(Case When [Year] = @current_year - 2 And HCC_Type = 'Clinical' Then Hcc_Value Else 0 End) As [Prior2_Suspects_Clinical],
				Sum(Case When [Year] = @current_year - 2 And HCC_Type = 'Unaccpt' Then Hcc_Value Else 0 End) As [Prior2_Suspects_Unaccpt]
			From (
				-- Inner query to exclude Suspect Codes that get trumped by other suspect codes. They're left in the REF_HCC
				-- table so that their opportunity can be viewed, but it shouldn't be counted in the sum of the member's opportunity
				-- because that would be double counting some value.
				Select * From RAF_HCCs
				Where HCC_Type = 'Captured'
				Union
				Select hc.* 
					From RAF_HCCs hc
				Left Join RAF_HCCs hcTrump 
					On hcTrump.Member_Id = hc.Member_Id 
					And hcTrump.[Year] = hc.[Year] 
					And hcTrump.HCC_Code = hc.Is_Trumped_By
					And hcTrump.HCC_Type <> 'Captured'
				Where  hc.HCC_Type <> 'Captured' And hcTrump.Member_Id is null
			) As tbl
		--Where Member_Id = '105048'
		Group By Member_Id
	) as tbl
	On tbl.Member_Id = m.Member_Id


	-- HCC Values (All Suspects De-Duplicated)
	Update EA_Members 
	Set [Current_HCC_Suspects_All]	= IsNull([Current_Suspects_All], 0),
		[Prior_HCC_Suspects_All]	= IsNull([Prior_Suspects_All], 0),
		[Prior2_HCC_Suspects_All]	= IsNull([Prior2_Suspects_All], 0)
	From EA_Members m
	Left Join (
		Select	Member_Id,
				Sum(Case When [Year] = @current_year Then Hcc_Value Else 0 End) As [Current_Suspects_All],
				Sum(Case When [Year] = @current_year - 1 Then Hcc_Value Else 0 End) As [Prior_Suspects_All],
				Sum(Case When [Year] = @current_year - 2 Then Hcc_Value Else 0 End) As [Prior2_Suspects_All]
		From (
			-- By filtering to suspects only and then grouping out suspect_type we get a de-duplicated 
			-- list of hcc value per member/hcc_code/year. This way if an HCC was a Clinical & YOY suspect 
			-- in the same year we won't count it's value twice.
			Select  Member_Id, HCC_Code, [Year], HCC_Value
			From (
				-- Inner query to exclude Suspect Codes that get trumped by other suspect codes. They're left in the REF_HCC
				-- table so that their opportunity can be viewed, but it shouldn't be counted in the sum of the member's opportunity
				-- because that would be double counting some value.
				Select * From RAF_HCCs
				Where HCC_Type = 'Captured'
				Union
				Select hc.* 
					From RAF_HCCs hc
				Left Join RAF_HCCs hcTrump 
					On hcTrump.Member_Id = hc.Member_Id 
					And hcTrump.[Year] = hc.[Year] 
					And hcTrump.HCC_Code = hc.Is_Trumped_By
					And hcTrump.HCC_Type <> 'Captured'
				Where hc.HCC_Type <> 'Captured' 
					And hcTrump.Member_Id is null
			) As tbl
			Where HCC_Type <> 'Captured' 
			Group By Member_Id, HCC_Code, [Year], HCC_Value
		) as tbl
		--Where Member_Id = ''
		Group By Member_Id
	) As tbl
	On tbl.Member_Id = m.Member_Id





	-- Effective Dates

	Update EA_Members
	Set [Eligibility_Date] = null

	---- Get latest Effective Data for active ranges
	--Update EA_Members
	--Set [Eligibility_Date] = tbl.[Eligibility_Date]
	--From EA_Members m
	--Join (
	--	Select Member_Id, Max([Effective_Date]) As [Eligibility_Date]
	--	From [Applecare_Members_Raw]
	--	Where [Effective_Date] < [End_Date]
	--		And ([End_Date] is Null Or [End_Date] > getdate()) 
	--		--And Member_Id = '4855'
	--	Group By Member_Id
	--) as tbl
	--On tbl.Member_Id = m.Member_Id

	---- If none are found, latest Effective Data for any range
	--Update EA_Members
	--Set [Eligibility_Date] = tbl.[Eligibility_Date]
	--From EA_Members m
	--Join (
	--	Select Member_Id, Max([Effective_Date]) As [Eligibility_Date]
	--	From [Applecare_Members_Raw]
	--	Where [Effective_Date] < [End_Date]
	--		--And Member_Id = '4855'
	--	Group By Member_Id
	--) as tbl
	--On tbl.Member_Id = m.Member_Id
	--Where m.[Eligibility_Date] is null

	-- Get latest Effective Data for active ranges
	Update EA_Members
	Set [Eligibility_Date] = tbl.[Effective_Date],
		[Eligibility_End_Date] = tbl.[End_Date]
	From EA_Members m
	Join (
		Select Member_Id, [Effective_Date], [End_Date] From (
			Select Member_Id, [Effective_Date], [End_Date], Rnk = Rank() Over(Partition By Member_Id Order By Effective_Date Desc, End_Date Desc)
			From [Applecare_Members_Raw]
			Where [Effective_Date] < [End_Date]
				And ([End_Date] is Null Or [End_Date] > getdate()) 
				--And Member_Id = '100132'
		) As tbl
		Where Rnk = 1
		Group By Member_Id, [Effective_Date], [End_Date]
	) as tbl
	On tbl.Member_Id = m.Member_Id

	-- If none are found, latest Effective Data for any range. We do it this way because we can you see some unusual 
	-- overlapping ranges in the data that would otherwise trip up the logic. 
	Update EA_Members
	Set [Eligibility_Date] = tbl.[Effective_Date],
		[Eligibility_End_Date] = tbl.[End_Date]
	From EA_Members m
	Join (
		Select Member_Id, [Effective_Date], [End_Date] From (
			Select Member_Id, [Effective_Date], [End_Date], Rnk = Rank() Over(Partition By Member_Id Order By Effective_Date Desc, End_Date Desc)
			From [Applecare_Members_Raw]
			Where [Effective_Date] <= [End_Date]
				--And Member_Id = '100132'
		) As tbl
		Where Rnk = 1
		Group By Member_Id, [Effective_Date], [End_Date]
	) as tbl
	On tbl.Member_Id = m.Member_Id
	Where m.[Eligibility_Date] is null


	-- Captured = Demo + Hcc_Captured if eligible in that year
	-- Projected = Suspects_All + demo
	-- Opportunity = Suspects All
	Update EA_Members
	Set [Current_RAF_Captured]		= IsNull([Current_HCC_Captured], 0) + IsNull([Current_RAF_Demographic], 0),
		[Prior_RAF_Captured]		= IsNull([Prior_HCC_Captured], 0) + IsNull([Prior_RAF_Demographic], 0),
		[Prior2_RAF_Captured]		= IsNull([Prior2_HCC_Captured], 0) + IsNull([Prior2_RAF_Demographic], 0),
		[Current_RAF_Projected]		= IsNull([Current_HCC_Captured], 0) + IsNull([Current_RAF_Demographic], 0) + IsNull([Current_HCC_Suspects_All], 0),
		[Prior_RAF_Projected]		= IsNull([Prior_HCC_Captured], 0) + IsNull([Prior_RAF_Demographic], 0) + IsNull([Prior_HCC_Suspects_All], 0),
		[Prior2_RAF_Projected]		= IsNull([Prior2_HCC_Captured], 0) + IsNull([Prior2_RAF_Demographic], 0) + IsNull([Prior2_HCC_Suspects_All], 0),
		[Current_Opportunity]		= IsNull([Current_HCC_Suspects_All], 0),
		[Prior_Opportunity]			= IsNull([Prior_HCC_Suspects_All], 0),
		[Prior2_Opportunity]		= IsNull([Prior2_HCC_Suspects_All], 0)
	From EA_Members m


	---- Last Any Encounter
	--Update EA_Members
	--Set Any_Last_Encounter = Last_Dos
	--From EA_Members m
	--Left Join (
	--	Select Member_Id, Max(Dos_To) As Last_Dos
	--	From [Applecare_Claims_Raw2] c
	--	Join Ref_Cpt ct
	--		On ct.Cpt_Code = c.PROCEDURE_CODE
	--	Join Ref_Specialty spc
	--		On spc.Specialty_Code = c.PROVIDER_SPECIALTY
	--		And Risk_Adj_Flag = 'Y'
	--	--Where Datepart(year, DOS_To) = @current_year
	--	Group By Member_Id
	--) As tbl
	--On tbl.Member_Id = m.Member_Id
	
	-- Last Any Encounter
	Update EA_Members
	Set Any_Last_Encounter = (Select Max(Dos) From Applecare_Members_Dos ds Where ds.Member_Id = m.Member_Id)
	From EA_Members m

	---- Last PCP Encounter
	--Update EA_Members
	--Set PCP_Last_Encounter = Last_Dos
	--From EA_Members m
	--Left Join (
	--	Select Member_Id,Max(Dos_To) As Last_Dos
	--	From [Applecare_Claims_Raw2] c
	--	Join Applecare_Providers p 
	--		On p.Provider_Id = c.Provider_Id And PCP_Flag = 1 --Limit to PCPs
	--	Join Ref_Cpt ct
	--		On ct.Cpt_Code = c.PROCEDURE_CODE
	--	Join Ref_Specialty spc
	--		On spc.Specialty_Code = c.PROVIDER_SPECIALTY
	--		And Risk_Adj_Flag = 'Y'
	--	--Where Datepart(year, DOS_To) = @current_year
	--	Group By Member_Id
	--) As tbl
	--On tbl.Member_Id = m.Member_Id

	-- Last Pcp Encounter
	Update EA_Members
	Set PCP_Last_Encounter = (Select Max(Dos) From Applecare_Members_Dos_Pcp ds Where ds.Member_Id = m.Member_Id)
	From EA_Members m

	---- DOS Count for current year
	--Update EA_Members
	--Set Current_DOS_Count = IsNull(Cnt, 0)
	--From EA_Members m
	--Left Join (
	--	Select Member_Id, Count(Distinct(Dos_To)) As Cnt
	--	From [Applecare_Claims_Raw2] c
	--	Join Ref_Cpt ct
	--		On ct.Cpt_Code = c.PROCEDURE_CODE
	--	Join Ref_Specialty spc
	--		On spc.Specialty_Code = c.PROVIDER_SPECIALTY
	--		And Risk_Adj_Flag = 'Y'
	--	Where Datepart(year, DOS_To) = @current_year
	--	Group By Member_Id
	--) As tbl
	--On tbl.Member_Id = m.Member_Id

	---- PCP DOS Count for current year
	--Update EA_Members
	--Set Current_PCP_DOS_Count = IsNull(Cnt, 0)
	--From EA_Members m
	--Left Join (
	--	Select Member_Id, Count(Distinct(Dos_To)) As Cnt
	--	From [Applecare_Claims_Raw2] c
	--	Join Applecare_Providers p 
	--		On p.Provider_Id = c.Provider_Id And PCP_Flag = 1 --Limit to PCPs
	--	Join Ref_Cpt ct
	--		On ct.Cpt_Code = c.PROCEDURE_CODE
	--	Join Ref_Specialty spc
	--		On spc.Specialty_Code = c.PROVIDER_SPECIALTY
	--		And Risk_Adj_Flag = 'Y'
	--	Where Datepart(year, DOS_To) = @current_year
	--	Group By Member_Id
	--) As tbl
	--On tbl.Member_Id = m.Member_Id

	---- DOS Count for prior year
	--Update EA_Members
	--Set Prior_DOS_Count = IsNull(Cnt, 0)
	--From EA_Members m
	--Left Join (
	--	Select Member_Id, Count(Distinct(Dos_To)) As Cnt
	--	From [Applecare_Claims_Raw2] c
	--	Join Ref_Cpt ct
	--		On ct.Cpt_Code = c.PROCEDURE_CODE
	--	Join Ref_Specialty spc
	--		On spc.Specialty_Code = c.PROVIDER_SPECIALTY
	--		And Risk_Adj_Flag = 'Y'
	--	Where Datepart(year, DOS_To) =  @current_year - 1
	--	Group By Member_Id
	--) As tbl
	--On tbl.Member_Id = m.Member_Id

	---- PCP DOS Count for prior year
	--Update EA_Members
	--Set Prior_PCP_DOS_Count = IsNull(Cnt, 0)
	--From EA_Members m
	--Left Join (
	--	Select Member_Id, Count(Distinct(Dos_To)) As Cnt
	--	From [Applecare_Claims_Raw2] c
	--	Join Applecare_Providers p 
	--		On p.Provider_Id = c.Provider_Id And PCP_Flag = 1 --Limit to PCPs
	--	Join Ref_Cpt ct
	--		On ct.Cpt_Code = c.PROCEDURE_CODE
	--	Join Ref_Specialty spc
	--		On spc.Specialty_Code = c.PROVIDER_SPECIALTY
	--		And Risk_Adj_Flag = 'Y'
	--	Where Datepart(year, DOS_To) =  @current_year - 1
	--	Group By Member_Id
	--) As tbl
	--On tbl.Member_Id = m.Member_Id

	---- DOS Count for Prior2 year
	--Update EA_Members
	--Set Prior2_DOS_Count = IsNull(Cnt, 0)
	--From EA_Members m
	--Left Join (
	--	Select Member_Id, Count(Distinct(Dos_To)) As Cnt
	--	From [Applecare_Claims_Raw2] c
	--	Join Ref_Cpt ct
	--		On ct.Cpt_Code = c.PROCEDURE_CODE
	--	Join Ref_Specialty spc
	--		On spc.Specialty_Code = c.PROVIDER_SPECIALTY
	--		And Risk_Adj_Flag = 'Y'
	--	Where Datepart(year, DOS_To) =  @current_year - 2
	--	Group By Member_Id
	--) As tbl
	--On tbl.Member_Id = m.Member_Id

	-- DOS Count for current year
	Update EA_Members
	Set Current_DOS_Count = IsNull(Cnt, 0)
	From EA_Members m
	Left Join (
		Select Member_Id, Count(Distinct(Dos)) As Cnt
		From [Applecare_Members_Dos] c
		Where Datepart(year, Dos) = @current_year
		Group By Member_Id
	) As tbl
	On tbl.Member_Id = m.Member_Id

	-- PCP DOS Count for current year
	Update EA_Members
	Set Current_PCP_DOS_Count = IsNull(Cnt, 0)
	From EA_Members m
	Left Join (
		Select Member_Id, Count(Distinct(Dos)) As Cnt
		From [Applecare_Members_Dos_Pcp] c
		Where Datepart(year, Dos) = @current_year
		Group By Member_Id
	) As tbl
	On tbl.Member_Id = m.Member_Id

	-- DOS Count for prior year
	Update EA_Members
	Set Prior_DOS_Count = IsNull(Cnt, 0)
	From EA_Members m
	Left Join (
		Select Member_Id, Count(Distinct(Dos)) As Cnt
		From [Applecare_Members_Dos] c
		Where Datepart(year, Dos) = @current_year - 1
		Group By Member_Id
	) As tbl
	On tbl.Member_Id = m.Member_Id

	-- PCP DOS Count for prior year
	Update EA_Members
	Set Prior_PCP_DOS_Count = IsNull(Cnt, 0)
	From EA_Members m
	Left Join (
		Select Member_Id, Count(Distinct(Dos)) As Cnt
		From [Applecare_Members_Dos_Pcp] c
		Where Datepart(year, Dos) = @current_year - 1
		Group By Member_Id
	) As tbl
	On tbl.Member_Id = m.Member_Id

	-- DOS Count for prior2 year
	Update EA_Members
	Set Prior2_DOS_Count = IsNull(Cnt, 0)
	From EA_Members m
	Left Join (
		Select Member_Id, Count(Distinct(Dos)) As Cnt
		From [Applecare_Members_Dos] c
		Where Datepart(year, Dos) = @current_year - 2
		Group By Member_Id
	) As tbl
	On tbl.Member_Id = m.Member_Id


	--
	-- Providers
	--

	-- Calculate Number Of Members
	Update EA_Providers
	Set NUMBER_OF_MEMBERS = NumOfMembers 
	From EA_Providers ap
	Join (
		Select PROVIDER_ID, count(*) as NumOfMembers From (
			Select p.PROVIDER_ID,  m.MEMBER_ID
			From EA_Providers p
				Join EA_Members m
					On m.PCP_Id = p.PROVIDER_ID
			Group By p.PROVIDER_ID,  m.MEMBER_ID
			Union
			Select p.PROVIDER_ID,  dx.MEMBER_ID
			From EA_Providers p
				Join EA_Dx dx
					On dx.PROVIDER_ID = p.PROVIDER_ID
			Group By p.PROVIDER_ID,  dx.MEMBER_ID
		) as tbl
		Group By Provider_Id
	) As Nums on Nums.PROVIDER_ID = ap.PROVIDER_ID

	Update EA_Providers
	Set NUMBER_OF_MEMBERS = 0 
	Where NUMBER_OF_MEMBERS is null

	Update EA_Providers
	Set Current_Num_Eligible_Members = Num
	From EA_Providers ap
	Join (
		Select p.Provider_Id, count(*) As Num  From (
			Select p.Provider_Id,  m.Member_id
			From EA_Providers p
				Join EA_Members m
					On m.PCP_Id = p.Provider_Id
			Group By p.Provider_Id,  m.Member_id
			Union
			Select p.Provider_Id,  dx.Member_id
			From EA_Providers p
				Join EA_Dx dx
					On dx.Provider_Id = p.Provider_Id
					--And dx.DOS_Year = @current_year --TODO: Update with Current Year Logic
			Group By p.Provider_Id,  dx.Member_id
		) As p
		join EA_Members m on m.Member_id = p.Member_id
		Where m.Current_Is_Eligible = 1
			--and provider_id = '7'
		Group By Provider_Id
	) As Nums on Nums.Provider_Id = ap.Provider_Id

	Update EA_Providers
	Set Prior_Num_Eligible_Members = Num
	From EA_Providers ap
	Join (
		Select p.Provider_Id, count(*) As Num  From (
			Select p.Provider_Id,  m.Member_id
			From EA_Providers p
				Join EA_Members m
					On m.PCP_Id = p.Provider_Id
			Group By p.Provider_Id,  m.Member_id
			Union
			Select p.Provider_Id,  dx.Member_id
			From EA_Providers p
				Join EA_Dx dx
					On dx.Provider_Id = p.Provider_Id
					--And dx.DOS_Year =  @current_year - 1 --TODO: Update with Current Year Logic
			Group By p.Provider_Id,  dx.Member_id
		) As p
		join EA_Members m on m.Member_id = p.Member_id
		Where m.Prior_Is_Eligible = 1
			--and provider_id = '7'
		Group By Provider_Id
	) As Nums on Nums.Provider_Id = ap.Provider_Id

	Update EA_Providers
	Set Prior2_Num_Eligible_Members = Num
	From EA_Providers ap
	Join (
		Select p.Provider_Id, count(*) As Num  From (
			Select p.Provider_Id,  m.Member_id
			From EA_Providers p
				Join EA_Members m
					On m.PCP_Id = p.Provider_Id
			Group By p.Provider_Id,  m.Member_id
			Union
			Select p.Provider_Id,  dx.Member_id
			From EA_Providers p
				Join EA_Dx dx
					On dx.Provider_Id = p.Provider_Id
					--And dx.DOS_Year =  @current_year - 2 --TODO: Update with Current Year Logic
			Group By p.Provider_Id,  dx.Member_id
		) As p
		join EA_Members m on m.Member_id = p.Member_id
		Where m.Prior2_Is_Eligible = 1
			--and provider_id = '7'
		Group By Provider_Id
	) As Nums on Nums.Provider_Id = ap.Provider_Id


	Update EA_Providers
	Set	Current_Avg_HCC_Captured				= tbl2.Current_Avg_HCC_Captured,
		Current_Avg_HCC_Suspects_Clinical		= tbl2.Current_Avg_HCC_Suspects_Clinical,
		Current_Avg_HCC_Suspects_YOY			= tbl2.Current_Avg_HCC_Suspects_YOY,
		Current_Avg_HCC_Suspects_All			= tbl2.Current_Avg_HCC_Suspects_All,
		Current_Avg_HCC_Suspects_Unacceptable	= tbl2.Current_Avg_HCC_Suspects_Unacceptable,
		Current_Avg_RAF_Demographic				= tbl2.Current_Avg_RAF_Demographic,
		Current_Avg_RAF_Captured				= tbl2.Current_Avg_RAF_Captured,
		Current_Avg_RAF_Projected				= tbl2.Current_Avg_RAF_Projected,
		Current_Avg_Opportunity					= tbl2.Current_Avg_Opportunity
	From EA_Providers p
	Left Join (
		Select tbl.Provider_Id, 
			Current_Avg_HCC_Captured				= Round(Avg(Current_HCC_Captured), 3),
			Current_Avg_HCC_Suspects_Clinical		= Round(Avg(Current_HCC_Suspects_Clinical), 3),
			Current_Avg_HCC_Suspects_YOY			= Round(Avg(Current_HCC_Suspects_YOY), 3),
			Current_Avg_HCC_Suspects_All			= Round(Avg(Current_HCC_Suspects_All), 3),
			Current_Avg_HCC_Suspects_Unacceptable	= Round(Avg(Current_HCC_Suspects_Unacceptable), 3),
			Current_Avg_RAF_Demographic				= Round(Avg(Current_RAF_Demographic), 3),
			Current_Avg_RAF_Captured				= Round(Avg(Current_RAF_Captured), 3),
			Current_Avg_RAF_Projected				= Round(Avg(Current_RAF_Projected), 3),
			Current_Avg_Opportunity					= Round(Avg(Current_HCC_Suspects_All), 3)
		From (
			-- Listing of all Provider/Member combinations, whether from PCP relationship or a Dx in common
			Select p.PROVIDER_ID,  m.MEMBER_ID
			From EA_Providers p 
				Join EA_Members m
					On m.PCP_Id = p.PROVIDER_ID  
			Group By p.PROVIDER_ID,  m.MEMBER_ID
			Union
			Select p.PROVIDER_ID,  dx.MEMBER_ID
			From EA_Providers p
				Join EA_Dx dx
					On dx.PROVIDER_ID = p.PROVIDER_ID 
			Group By p.PROVIDER_ID,  dx.MEMBER_ID
		) As tbl
		Join EA_Members m
			On m.Member_Id = tbl.Member_Id
			And Current_Is_Eligible = 1
		Group By Provider_Id
	) As tbl2
	On tbl2.Provider_Id = p.Provider_Id


	Update EA_Providers
	Set	Prior_Avg_HCC_Captured				= tbl2.Prior_Avg_HCC_Captured,
		Prior_Avg_HCC_Suspects_Clinical		= tbl2.Prior_Avg_HCC_Suspects_Clinical,
		Prior_Avg_HCC_Suspects_YOY			= tbl2.Prior_Avg_HCC_Suspects_YOY,
		Prior_Avg_HCC_Suspects_All			= tbl2.Prior_Avg_HCC_Suspects_All,
		Prior_Avg_HCC_Suspects_Unacceptable	= tbl2.Prior_Avg_HCC_Suspects_Unacceptable,
		Prior_Avg_RAF_Demographic				= tbl2.Prior_Avg_RAF_Demographic,
		Prior_Avg_RAF_Captured				= tbl2.Prior_Avg_RAF_Captured,
		Prior_Avg_RAF_Projected				= tbl2.Prior_Avg_RAF_Projected,
		Prior_Avg_Opportunity					= tbl2.Prior_Avg_Opportunity
	From EA_Providers p
	Left Join (
		Select tbl.Provider_Id, 
			Prior_Avg_HCC_Captured				= Round(Avg(Prior_HCC_Captured), 3),
			Prior_Avg_HCC_Suspects_Clinical		= Round(Avg(Prior_HCC_Suspects_Clinical), 3),
			Prior_Avg_HCC_Suspects_YOY			= Round(Avg(Prior_HCC_Suspects_YOY), 3),
			Prior_Avg_HCC_Suspects_All			= Round(Avg(Prior_HCC_Suspects_All), 3),
			Prior_Avg_HCC_Suspects_Unacceptable	= Round(Avg(Prior_HCC_Suspects_Unacceptable), 3),
			Prior_Avg_RAF_Demographic				= Round(Avg(Prior_RAF_Demographic), 3),
			Prior_Avg_RAF_Captured				= Round(Avg(Prior_RAF_Captured), 3),
			Prior_Avg_RAF_Projected				= Round(Avg(Prior_RAF_Projected), 3),
			Prior_Avg_Opportunity					= Round(Avg(Prior_HCC_Suspects_All), 3)
		From (
			-- Listing of all Provider/Member combinations, whether from PCP relationship or a Dx in common
			Select p.PROVIDER_ID,  m.MEMBER_ID
			From EA_Providers p 
				Join EA_Members m
					On m.PCP_Id = p.PROVIDER_ID  
			Group By p.PROVIDER_ID,  m.MEMBER_ID
			Union
			Select p.PROVIDER_ID,  dx.MEMBER_ID
			From EA_Providers p
				Join EA_Dx dx
					On dx.PROVIDER_ID = p.PROVIDER_ID 
			Group By p.PROVIDER_ID,  dx.MEMBER_ID
		) As tbl
		Join EA_Members m
			On m.Member_Id = tbl.Member_Id
			And Prior_Is_Eligible = 1
		Group By Provider_Id
	) As tbl2
	On tbl2.Provider_Id = p.Provider_Id


	Update EA_Providers
	Set	Prior2_Avg_HCC_Captured				= tbl2.Prior2_Avg_HCC_Captured,
		Prior2_Avg_HCC_Suspects_Clinical		= tbl2.Prior2_Avg_HCC_Suspects_Clinical,
		Prior2_Avg_HCC_Suspects_YOY			= tbl2.Prior2_Avg_HCC_Suspects_YOY,
		Prior2_Avg_HCC_Suspects_All			= tbl2.Prior2_Avg_HCC_Suspects_All,
		Prior2_Avg_HCC_Suspects_Unacceptable	= tbl2.Prior2_Avg_HCC_Suspects_Unacceptable,
		Prior2_Avg_RAF_Demographic				= tbl2.Prior2_Avg_RAF_Demographic,
		Prior2_Avg_RAF_Captured				= tbl2.Prior2_Avg_RAF_Captured,
		Prior2_Avg_RAF_Projected				= tbl2.Prior2_Avg_RAF_Projected,
		Prior2_Avg_Opportunity					= tbl2.Prior2_Avg_Opportunity
	From EA_Providers p
	Left Join (
		Select tbl.Provider_Id, 
			Prior2_Avg_HCC_Captured				= Round(Avg(Prior2_HCC_Captured), 3),
			Prior2_Avg_HCC_Suspects_Clinical		= Round(Avg(Prior2_HCC_Suspects_Clinical), 3),
			Prior2_Avg_HCC_Suspects_YOY			= Round(Avg(Prior2_HCC_Suspects_YOY), 3),
			Prior2_Avg_HCC_Suspects_All			= Round(Avg(Prior2_HCC_Suspects_All), 3),
			Prior2_Avg_HCC_Suspects_Unacceptable	= Round(Avg(Prior2_HCC_Suspects_Unacceptable), 3),
			Prior2_Avg_RAF_Demographic				= Round(Avg(Prior2_RAF_Demographic), 3),
			Prior2_Avg_RAF_Captured				= Round(Avg(Prior2_RAF_Captured), 3),
			Prior2_Avg_RAF_Projected				= Round(Avg(Prior2_RAF_Projected), 3),
			Prior2_Avg_Opportunity					= Round(Avg(Prior2_HCC_Suspects_All), 3)
		From (
			-- Listing of all Provider/Member combinations, whether from PCP relationship or a Dx in common
			Select p.PROVIDER_ID,  m.MEMBER_ID
			From EA_Providers p 
				Join EA_Members m
					On m.PCP_Id = p.PROVIDER_ID  
			Group By p.PROVIDER_ID,  m.MEMBER_ID
			Union
			Select p.PROVIDER_ID,  dx.MEMBER_ID
			From EA_Providers p
				Join EA_Dx dx
					On dx.PROVIDER_ID = p.PROVIDER_ID 
			Group By p.PROVIDER_ID,  dx.MEMBER_ID
		) As tbl
		Join EA_Members m
			On m.Member_Id = tbl.Member_Id
			And Prior2_Is_Eligible = 1
		Group By Provider_Id
	) As tbl2
	On tbl2.Provider_Id = p.Provider_Id


	-- Opportunity Score
	Declare @totalRows int
	Select @totalRows = (Select count(*) From EA_Providers Where Current_Avg_Opportunity > 0)

	Update EA_Providers
	Set Opportunity_Score = IsNull(tbl3.Opportunity_Score, 0)
	From EA_Providers p
	Left Join (
		Select Provider_Id, 
			Case When Rnk_Percent <= 100 And Rnk_Percent > 95 Then 100 
				When  Rnk_Percent <= 95 And Rnk_Percent > 90 Then 95 
				When  Rnk_Percent <= 90 And Rnk_Percent > 85 Then 90 
				When  Rnk_Percent <= 85 And Rnk_Percent > 80 Then 85 
				When  Rnk_Percent <= 80 And Rnk_Percent > 75 Then 80 
				When  Rnk_Percent <= 75 And Rnk_Percent > 70 Then 75 
				When  Rnk_Percent <= 70 And Rnk_Percent > 65 Then 70
				When  Rnk_Percent <= 65 And Rnk_Percent > 60 Then 65
				When  Rnk_Percent <= 60 And Rnk_Percent > 55 Then 60
				When  Rnk_Percent <= 55 And Rnk_Percent > 50 Then 55
				When  Rnk_Percent <= 50 And Rnk_Percent > 45 Then 50
				When  Rnk_Percent <= 45 And Rnk_Percent > 40 Then 45
				When  Rnk_Percent <= 40 And Rnk_Percent > 35 Then 40
				When  Rnk_Percent <= 35 And Rnk_Percent > 30 Then 35
				When  Rnk_Percent <= 30 And Rnk_Percent > 25 Then 30 
				When  Rnk_Percent <= 25 And Rnk_Percent > 20 Then 25
				When  Rnk_Percent <= 20 And Rnk_Percent > 15 Then 20
				When  Rnk_Percent <= 15 And Rnk_Percent > 10 Then 15
				When  Rnk_Percent <= 10 And Rnk_Percent > 5 Then 10
				When  Rnk_Percent <= 5 And Rnk_Percent > 0 Then 5
				Else 0 End As Opportunity_Score
		From (
			Select Provider_Id, (Rnk * 1.0 / @totalRows) * 100 As Rnk_Percent
			From (
				Select	Provider_Id, 
						Current_Avg_Opportunity, 
						Rank() Over(Order By Current_Avg_Opportunity) As Rnk
				From EA_Providers
				Where Current_Avg_Opportunity > 0
			) As tbl
			--Order By Rnk
		) As tbl2
	) As tbl3
	On tbl3.Provider_Id = p.Provider_Id


	UPDATE EA_Providers
	SET Specialties = LEFT(s.Specialties, 1000)
	From EA_Providers p
	Join (
		SELECT DISTINCT Provider_Id, LEFT(Specialties, LEN(Specialties) - 1) As Specialties
		FROM Applecare_Providers_Specialty p1
		CROSS APPLY ( SELECT LTRIM(RTRIM(spc.DESCRIPTION)) + ';'
						 FROM Applecare_Providers_Specialty p2
						 JOIN Applecare_Specialties spc ON spc.Specialty = p2.Specialty
						 WHERE p2.Provider_Id = p1.Provider_Id
						 ORDER BY spc.Specialty
						 FOR XML PATH('') )  D ( Specialties )
	) s On s.Provider_Id = p.Provider_Id



	--HCCs

	Update EA_Dx
	Set HCC_Type = 'Captured'
	Where Suspect_Type is null

	Update EA_Dx
	Set HCC_Type = Suspect_Type
	Where Suspect_Type is not null And Suspect_Type <> ''


	-- Set the new HCC Recap Flags (Current)
	Update EA_Hcc
	Set Current_Is_Recap = Recap,
		Current_Is_Recap_Opp = Recap_Opp
	From EA_Hcc h
	Join (
		SELECT	codes.Member_Id, 
				codes.HCC_Code,
				CASE WHEN dx2.HCC_Code is not null THEN 1 ELSE 0 END As Recap,
				1 as Recap_Opp
		FROM (
			SELECT m.Member_Id, h.hcc_code
			FROM EA_Members m
			JOIN EA_Hcc h ON h.Member_id = m.Member_id 
			JOIN EA_Dx dx ON dx.member_id = m.Member_id AND dx.hcc_code = h.hcc_code 
			WHERE m.current_is_eligible = 1
				AND h.current_suspect_type = 'YOY'
				AND (dx.Suspect_Type IN ('YOY', 'Captured') Or dx.Suspect_Type is null) --Any code in YOY or Cap means it's been Captured on that date
				AND datepart(year, dx.DOS) =  @current_year - 1 --Year before Prior
			GROUP BY m.Member_Id, h.Hcc_Code
		) As Codes
		LEFT JOIN (
			SELECT Member_id, HCC_Code
			FROM EA_Dx dx 
			WHERE datepart(year, DOS) = @current_year AND (Suspect_Type IN ('YOY', 'Captured') Or dx.Suspect_Type is null)
			GROUP BY  Member_Id, HCC_Code
		) AS dx2 ON dx2.Member_Id = Codes.Member_Id AND dx2.Hcc_Code = Codes.Hcc_Code
	) as tbl on tbl.Member_Id = h.Member_Id And tbl.HCC_Code = h.HCC_Code
	Where Interaction_HCC_Code is null

	Update EA_Hcc
	Set Current_Is_Recap = 1,
		Current_Hcc_Status = 'Captured (YOY Recapture)'
	Where Interaction_HCC_Code is null
		And Current_Is_Recap_Opp = 1
		And (Current_Is_Trumped_By is not null and Current_Is_Trumped_By <> '')
		And Current_Is_Recap = 0
	

	-- Set the new HCC Recap Flags (Prior)
	Update EA_Hcc
	Set Prior_Is_Recap = Recap,
		Prior_Is_Recap_Opp = Recap_Opp
	From EA_Hcc h
	Join (
		SELECT	codes.Member_Id, 
				codes.HCC_Code,
				CASE WHEN dx2.HCC_Code is not null THEN 1 ELSE 0 END As Recap,
				1 as Recap_Opp
		FROM (
			SELECT m.Member_Id, h.hcc_code
			FROM EA_Members m
			JOIN EA_Hcc h ON h.Member_id = m.Member_id 
			JOIN EA_Dx dx ON dx.member_id = m.Member_id AND dx.hcc_code = h.hcc_code 
			WHERE m.prior_is_eligible = 1
				AND h.prior_suspect_type = 'YOY'
				AND (dx.Suspect_Type IN ('YOY', 'Captured') Or dx.Suspect_Type is null) --Any code in YOY or Cap means it's been Captured on that date
				AND datepart(year, dx.DOS) = @current_year - 2 --Year before Prior
			GROUP BY m.Member_Id, h.Hcc_Code
		) As Codes
		LEFT JOIN (
			SELECT Member_id, HCC_Code
			FROM EA_Dx dx 
			WHERE datepart(year, DOS) = @current_year - 1 AND (Suspect_Type IN ('YOY', 'Captured') Or dx.Suspect_Type is null)
			GROUP BY  Member_Id, HCC_Code
		) AS dx2 ON dx2.Member_Id = Codes.Member_Id AND dx2.Hcc_Code = Codes.Hcc_Code
	) as tbl on tbl.Member_Id = h.Member_Id And tbl.HCC_Code = h.HCC_Code
	Where Interaction_HCC_Code is null

	Update EA_Hcc
	Set Prior_Is_Recap = 1,
		Prior_Hcc_Status = 'Captured (YOY Recapture)'
	From EA_Hcc
	Where Interaction_HCC_Code is null
		And Prior_Is_Recap_Opp = 1
		And (Prior_Is_Trumped_By is not null And Prior_Is_Trumped_By <> '')
		And Prior_Is_Recap = 0



	-- Set the new HCC Recap Flags (Prior)
	Update EA_Hcc
	Set Prior2_Is_Recap = Recap,
		Prior2_Is_Recap_Opp = Recap_Opp
	From EA_Hcc h
	Join (
		SELECT	codes.Member_Id, 
				codes.HCC_Code,
				CASE WHEN dx2.HCC_Code is not null THEN 1 ELSE 0 END As Recap,
				1 as Recap_Opp
		FROM (
			SELECT m.Member_Id, h.hcc_code
			FROM EA_Members m
			JOIN EA_Hcc h ON h.Member_id = m.Member_id 
			JOIN EA_Dx dx ON dx.member_id = m.Member_id AND dx.hcc_code = h.hcc_code 
			WHERE m.prior2_is_eligible = 1
				AND h.prior2_suspect_type = 'YOY'
				AND (dx.Suspect_Type IN ('YOY', 'Captured') Or dx.Suspect_Type is null) --Any code in YOY or Cap means it's been Captured on that date
				AND datepart(year, dx.DOS) = @current_year - 3 --Year before Prior
			GROUP BY m.Member_Id, h.Hcc_Code
		) As Codes
		LEFT JOIN (
			SELECT Member_id, HCC_Code
			FROM EA_Dx dx 
			WHERE datepart(year, DOS) = @current_year - 2 AND (Suspect_Type IN ('YOY', 'Captured') Or dx.Suspect_Type is null)
			GROUP BY  Member_Id, HCC_Code
		) AS dx2 ON dx2.Member_Id = Codes.Member_Id AND dx2.Hcc_Code = Codes.Hcc_Code
	) as tbl on tbl.Member_Id = h.Member_Id And tbl.HCC_Code = h.HCC_Code
	Where Interaction_HCC_Code is null

	Update EA_Hcc
	Set Prior2_Is_Recap = 1,
		Prior2_Hcc_Status = 'Captured (YOY Recapture)'
	From EA_Hcc
	Where Interaction_HCC_Code is null
		And Prior2_Is_Recap_Opp = 1
		And (Prior2_Is_Trumped_By is not null and Prior2_Is_Trumped_By <> '')
		And Prior2_Is_Recap = 0




	-- DX's

	Update EA_Dx
	Set Source = Claim_Id,
	   code_source = Case When [Claim_Id] like 'Ascender' Then 'Supplemental' Else 'Claim' End
	From EA_Dx dx
	Join (
		Select Provider_Id, Member_Id, ICD_Code, DOS_To, Max(Claim_Id) As Claim_Id
		From [Applecare_Claims]
		Group By Provider_Id, Member_Id, ICD_Code, DOS_To
	) As tbl
	On tbl.Member_Id = dx.Member_Id 
		And tbl.Provider_Id = dx.Provider_Id 
		And tbl.ICD_Code = dx.Dx_Code
		And tbl.DOS_To = dx.DOS


	Update EA_Dx
	Set Source = tbl.Source
	From EA_Dx dx
	Join (
		Select Member_Id, ICD_Code, DOS, Source
		From [Applecare_Supplemental]
		Group By Member_Id, ICD_Code, DOS, Source
	) As tbl
	On tbl.Member_Id = dx.Member_Id  
		And tbl.ICD_Code = dx.Dx_Code
		And tbl.DOS = dx.DOS



	-- fill in the rest with unassigned
	Update EA_Dx 
	Set Provider_id = '9999'
	Where Provider_Id = '' 
		Or Provider_Id is null


	-- Set the DOS for Captured Suspects
	Update EA_Dx 
	Set DOS = Coalesce(Suspect_Dx_Capture_Date, Suspect_Hcc_Capture_Date)
	Where Suspect_Type = 'Suspect' 
		And (Suspect_Dx_Capture_Date is not null Or Suspect_Hcc_Capture_Date is not null)

	-- 
	Update EA_Dx
	Set Is_Chronic = 1
	From EA_Dx dx
	Join Ref_Chronic ref on ref.ICD_Code = dx.Dx_Code and ref.ICD_Version = dx.ICD_Version
	Where dx.Dx_Code_Orig is null Or dx.Dx_Code_Orig = ''

	Update EA_Dx
	Set Is_Chronic = 1
	From EA_Dx dx
	Join Ref_Chronic ref on ref.ICD_Code = dx.Dx_Code_Orig and ref.ICD_Version = dx.ICD_Version_Orig
	Where dx.Dx_Code_Orig is not null and dx.Dx_Code_Orig <> ''

	Update EA_Dx
	Set Is_Chronic = 0
	Where Is_Chronic is null


	-- Update the Dx Statuses
	Update EA_Dx
	Set Dx_Status = 'Captured (New Chronic)'
	From EA_Dx dx
	Where dx.Suspect_Type = 'YOY'
		--and dx.Suspect_Dx_Capture_Date is not null
		and not exists (Select * From EA_Dx dx2 
					Where dx2.Member_Id = dx.Member_Id 
					And dx2.Dx_Code = dx.Dx_Code 
					And datepart(year, dx2.dos) = datepart(year, dx.dos) - 1
					and (Suspect_Type = 'YOY' Or Suspect_Type is null))
	 
	Update EA_Dx
	Set Dx_Status = 'Captured (YOY Recapture)'
	From EA_Dx dx
	Where dx.Suspect_Type = 'YOY'
		--and dx.Suspect_Dx_Capture_Date is not null
		and exists (Select * From EA_Dx dx2 
					Where dx2.Member_Id = dx.Member_Id 
					And dx2.Dx_Code = dx.Dx_Code 
					And datepart(year, dx2.dos) = datepart(year, dx.dos) - 1
					and (Suspect_Type = 'YOY' Or Suspect_Type is null))

	Update EA_Dx
	Set Dx_Status = 'Captured (Clinical)'
	From EA_Dx dx
	Where dx.Suspect_Type = 'Suspect'
		and dx.Suspect_Dx_Capture_Date is not null

	Update EA_Dx
	Set Dx_Status = 'Captured (Acute/Other)'
	From EA_Dx dx
	Where dx.Suspect_Type is null

	Update EA_Dx
	Set Dx_Status = 'Captured (Unaccpt Source)'
	From EA_Dx dx
	Where dx.Suspect_Type = 'Unaccpt Source'
		and dx.Suspect_Dx_Capture_Date is not null

	--Update EA_Dx
	--Set Dx_Status = 'Suspect (YOY)'
	--From EA_Dx dx
	--Where dx.Suspect_Type = 'YOY'
	--	and dx.Suspect_Dx_Capture_Date is null

	Update EA_Dx
	Set Dx_Status = 'Suspect (Clinical)'
	From EA_Dx dx
	Where dx.Suspect_Type = 'Suspect'
		and dx.Suspect_Dx_Capture_Date is null

	Update EA_Dx
	Set Dx_Status = 'Suspect (Unaccpt Source)'
	From EA_Dx dx
	Where dx.Suspect_Type = 'Unaccpt Source'
		and dx.Suspect_Dx_Capture_Date is null




	---- Members Values that needed other calcs up top
	--Update EA_Members 
	--Set Current_DOS_Count		= (Select count(distinct(DOS_To)) 
	--								From Applecare_Claims 
	--								Where Member_Id = m.Member_Id 
	--									And Datepart(year, DOS_To) = @current_year
	--									And Suspect_Type is null), -- Is not a Clinical or Unaccept Suspect
	--	Current_PCP_DOS_Count	= (Select count(distinct(DOS_To)) 
	--								From Applecare_Claims c
	--								Join Applecare_Providers p On p.Provider_Id = c.Provider_Id 
	--								Where Member_Id = m.Member_Id 
	--									And Datepart(year, DOS_To) = @current_year
	--									And Suspect_Type is null
	--									And PCP_Flag = 1), -- Is not a Clinical or Unaccept Suspect
	--	Prior_DOS_Count			= (Select count(distinct(DOS_To)) 
	--								From Applecare_Claims 
	--								Where Member_Id = m.Member_Id 
	--									And Datepart(year, DOS_To) =  @current_year - 1
	--									And Suspect_Type is null), -- Is not a Clinical or Unaccept Suspect
	--	Prior_PCP_DOS_Count		= (Select count(distinct(DOS_To)) 
	--								From Applecare_Claims c
	--								Join Applecare_Providers p On p.Provider_Id = c.Provider_Id 
	--								Where Member_Id = m.Member_Id 
	--									And Datepart(year, DOS_To) =  @current_year - 1
	--									And Suspect_Type is null
	--									And PCP_Flag = 1), -- Is not a Clinical or Unaccept Suspect
	--	Prior2_DOS_Count			= (Select count(distinct(DOS_To)) 
	--								From Applecare_Claims 
	--								Where Member_Id = m.Member_Id 
	--									And Datepart(year, DOS_To) =  @current_year - 2
	--									And Suspect_Type is null) -- Is not a Clinical or Unaccept Suspect
	--From EA_Members m




	-- Calc the Member's Recap Opportunites

	Update EA_Members
	Set Current_Recap_Opp_Count = Current_Recap_Opp
	From EA_Members m
	Join (
		Select	Member_Id, Sum(Current_Is_Recap_Opp) as Current_Recap_Opp
		From EA_Hcc
		Group By Member_Id
	) tbl
	On tbl.Member_Id = m.Member_Id

	Update EA_Members
	Set Prior_Recap_Opp_Count = Prior_Recap_Opp
	From EA_Members m
	Join (
		Select	Member_Id, Sum(Prior_Is_Recap_Opp) as Prior_Recap_Opp
		From EA_Hcc
		Group By Member_Id
	) tbl
	On tbl.Member_Id = m.Member_Id	


/* HCC Level Validation of Dx Codes

	--Captured (New Chronic) : YOY Suspects where the same HCC is found in the following 
	-- year (Suspect is "captured"), but not in the prior year.
	Update EA_Dx
	Set Dx_Status = 'Captured (New Chronic)'
	From EA_Dx dx
	Where dx.Suspect_Type = 'YOY'
		and dx.Suspect_Hcc_Capture_Date is not null -- This HCC was found in the following year
		and not exists (Select * From EA_Dx dx2 
					Where dx2.Member_Id = dx.Member_Id 
					And dx2.Hcc_Code = dx.Hcc_Code 
					And datepart(year, dx2.dos) = datepart(year, dx.dos) - 1
					and (Suspect_Type = 'YOY' Or Suspect_Type is null))
	 
	--Captured (YoY Recapture): YOY Suspects where the same HCC is found in the following 
	--year  (Suspect is "captured") and the prior year (Suspect is "re-captured").
	Update EA_Dx
	Set Dx_Status = 'Captured (YOY Recapture)'
	From EA_Dx dx
	Where dx.Suspect_Type = 'YOY'
		and dx.Suspect_Hcc_Capture_Date is not null
		and exists (Select * From EA_Dx dx2 
					Where dx2.Member_Id = dx.Member_Id 
					And dx2.Hcc_Code = dx.Hcc_Code  
					And datepart(year, dx2.dos) = datepart(year, dx.dos) - 1
					and (Suspect_Type = 'YOY' Or Suspect_Type is null))

	Update EA_Dx
	Set Dx_Status = 'Captured (Clinical)'
	From EA_Dx dx
	Where dx.Suspect_Type = 'Suspect'
		and dx.Suspect_Hcc_Capture_Date is not null

	Update EA_Dx
	Set Dx_Status = 'Captured (Acute/Other)'
	From EA_Dx dx
	Where dx.Suspect_Type is null

	Update EA_Dx
	Set Dx_Status = 'Captured (Unaccpt Source)'
	From EA_Dx dx
	Where dx.Suspect_Type = 'Unaccpt Source'
		and dx.Suspect_Hcc_Capture_Date is not null

	Update EA_Dx
	Set Dx_Status = 'Suspect (YOY)'
	From EA_Dx dx
	Where dx.Suspect_Type = 'YOY'
		and dx.Suspect_hcc_Capture_Date is null

	Update EA_Dx
	Set Dx_Status = 'Suspect (Clinical)'
	From EA_Dx dx
	Where dx.Suspect_Type = 'Suspect'
		and dx.Suspect_Hcc_Capture_Date is null

	Update EA_Dx
	Set Dx_Status = 'Suspect (Unaccpt Source)'
	From EA_Dx dx
	Where dx.Suspect_Type = 'Unaccpt Source'
		and dx.Suspect_Hcc_Capture_Date is null
*/

	Exec usp_RAF_Log 'usp_EA_Calculate', 'End', '', '', ''
END




GO

