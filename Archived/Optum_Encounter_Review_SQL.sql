
SELECT *
  FROM [Optum_Cleanup].[dbo].[Inbound_B2]
  where HealthPlan like 'Aet%' and Source like '%2LR%'
	and Source_File_Name like '%NPI%' 
	and (RenderingProviderNPI is Null and Corrected_Provider_NPIN is Null)


SELECT *
  FROM [Optum_Cleanup].[dbo].[Inbound_B2]
  where HealthPlan like 'OneCare%' and Source like '%2LR%'
	and Source_File_Name like '%NPI%' 
	and (RenderingProviderNPI is Null and Corrected_Provider_NPIN is Null)

SELECt DISTINCT I.LCDO_Name,I.ProviderFirstName,I.ProviderLastName
	FROm Inbound_B2 I 
	WHERE 	ISNULL( I.RenderingProviderNPI ,I.Corrected_Provider_NPIN)  is   NULL 



select *
from Outbound_NAMMCA_2ndRun
where  HEALTH_PLAN_ID = '311M82436'
	and ICD_Code = '25000'

select *
from Outbound_NAMMCA_2ndRun
where  HEALTH_PLAN_ID = '853M82111'
	and ICD_Code = 'I700'

select *
from Inbound_ASM_Full
where  PLAN_MEMBER_ID = '001M82635'
	and DIAG_CODE_1 = '28982'

select *
from Inbound_B2_Phat
where Source like '%2LR%'
	and Source_File_Name like '%NPI%' 


SELECT Inbound_B2_PD.[Inbound_B2_ID]
    ,Inbound_B2_PD.[Priority]
    ,Inbound_B2_PD.[ID]
    ,Inbound_B2_PD.[EmeraldBarcodeID]
    ,Inbound_B2_PD.[HealthPlan]
    ,Inbound_B2_PD.[MemberLastName]
    ,Inbound_B2_PD.[MemberFirstName]
    ,Inbound_B2_PD.[MemberMiddleName]
    ,Inbound_B2_PD.[MemberDOB]
    ,Inbound_B2_PD.[HealthPlanMemberID]
    ,Inbound_B2_PD.[MemberGender]
    ,Inbound_B2_PD.[MemberHIC]
    ,Inbound_B2_PD.[ProviderID]
    ,Inbound_B2_PD.[RenderingProviderNPI]
    ,Inbound_B2_PD.[ChartType]
    ,Inbound_B2_PD.[Prov_Type]
    ,Inbound_B2_PD.[CPT_CODE]
    ,Inbound_B2_PD.[Bill_TYPE]
    ,Inbound_B2_PD.[REVENUE_CODE]
    ,Inbound_B2_PD.[ProviderLastName]
    ,Inbound_B2_PD.[ProviderFirstName]
    ,Inbound_B2_PD.[ProviderSpecialtyCode]
    ,Inbound_B2_PD.[DOSFrom]
    ,Inbound_B2_PD.[DOSTo]
    ,Inbound_B2_PD.[POS]
    ,Inbound_B2_PD.[ICDIndicator]
    ,Inbound_B2_PD.[DiagnosisCode]
    ,Inbound_B2_PD.[Risk_Assessment_Code]
    ,Inbound_B2_PD.[RunTime]
    ,Inbound_B2_PD.[TPID]
    ,Inbound_B2_PD.[SubmissionStatusFlag]
    ,Inbound_B2_PD.[Project]
    ,Inbound_B2_PD.[LCDO_Name]
    ,Inbound_B2_PD.[Source]
    ,Inbound_B2_PD.[HCC]
    ,Inbound_B2_PD.[Source_File_Name]
    ,Inbound_B2_PD.[Status]
    ,Inbound_B2_PD.[Status_Description]
    ,Inbound_B2_PD.[Corrected_Provider_NPIN_Description]
    ,Inbound_B2_PD.[Corrected_Provider_Federal_Tax_ID_Description]
    ,Inbound_B2_PD.[Epi_Encounter_No]
    ,Inbound_B2_PD.[Cus_Provider_Name]
    ,Inbound_B2_PD.[Cus_Provider_Name_Reverse]
    ,Inbound_B2_PD.[Source_Provider_NPIN]
    ,Inbound_B2_PD.[Source_Provider_Federal_Tax_ID]
    ,Inbound_B2_PD.[Created_Date]
	,Inbound_B2_PD.[Corrected_Provider_NPIN]
	,Inbound_B2_PD.[ProviderTIN] 
	,B2_NPI_Master_santosh$.[Corrected_Provider_NPIN] as Corrected_Provider_NPIN_PD
    ,B2_NPI_Master_santosh$.[ProviderTIN] as ProviderTIN_PD
FROM [Optum_Cleanup].[dbo].[Inbound_B2_PD]
join [Optum_Cleanup].[dbo].[B2_NPI_Master_santosh$]
on Inbound_B2_PD.Inbound_B2_ID = B2_NPI_Master_santosh$.Inbound_B2_ID
# add if want to find how many updated 
where Inbound_B2_PD.[Corrected_Provider_NPIN] is Null and B2_NPI_Master_santosh$.[Corrected_Provider_NPIN] is not null 

SELECT HealthPlan,
	   LCDO_Name,
	   COUNT(Inbound_B2_ID)
  FROM [Optum_Cleanup].[dbo].[Inbound_B2_Phat_Updated_NPI]
  where HealthPlan like 'AET%' or HealthPlan like 'ONE%'
  group by HealthPlan, LCDO_Name


SELECT  Outbound_B2_ASM_Encounter.ProviderLastName,
        Outbound_B2_ASM_Encounter.ProviderFirstName,
        Outbound_B2_ASM_Encounter.RenderingProviderNPI,
        Inbound_Provider.TID
  FROM [Optum_Cleanup].[dbo].[Outbound_B2_ASM_Encounter]
  left join Inbound_Provider
    on Outbound_B2_ASM_Encounter.RenderingProviderNPI = Inbound_Provider.NPI
  where (Outbound_B2_ASM_Encounter.Source like '%2LR%' and Outbound_B2_ASM_Encounter.Source_File_Name like '%NPI%')
  and (Outbound_B2_ASM_Encounter.RenderingProviderNPI is not null and Outbound_B2_ASM_Encounter.ProviderTIN is null)


 
/* Break down by LCDO and Health Plan of what epiSource received from Optum
   2LR that needs NPI remediation
   01/18/2017
*/

SELECT LCDO_Name,
		HealthPlan,
		count(Inbound_B2_ID)
  FROM [Optum_Cleanup].[dbo].[Inbound_B2]
  where source like '%2LR%' and Source_File_Name like '%NPI%'
  group by HealthPlan, LCDO_Name
  order by LCDO_Name asc, HealthPlan asc


SELECT LCDO_Name,
    HealthPlan,
    count(Inbound_B2_ID) as 'Count'
  FROM [Optum_Cleanup].[dbo].[Inbound_B2]
  where source like '%2LR%' and Source_File_Name like '%NPI%'
  and ((RenderingProviderNPI is NULL and Corrected_Provider_NPIN is NULL) or
     (ProviderTIN is Null and Corrected_Provider_Federal_Tax_ID is NULL))
  group by HealthPlan, LCDO_Name
  order by LCDO_Name asc, HealthPlan asc


SELECT I.Status,count(1) AS Records
  FROM Inbound_B2 I
where   Source='CDQI.GF_CR_2LR_Review'
 AND Source_File_Name='NonUHC_Needs_NPI_Remediation'  
 group by I.Status