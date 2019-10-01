
CREATE PROCEDURE [CROMS].[NLM_GetSecondaryIDs]   
    @p_fromdate_in datetime,
    @p_todate_in datetime
AS   
	
SELECT distinct PRO_PROTOCOL_NUMBER  AS PROTOCOL_NO,
		   [CROMS].NLM_FN_MarkCurrentProtocolAward(PRO_ID)    AS PROTOCOL_SECONDARYID,
		   LST_SECONDARY_IDENTIFIER_TYPE  AS SECONDARY_IDENTIFIER_TYPE,
		   
CASE 
   When(LST_SECONDARY_IDENTIFIER_TYPE ='Other Grant/Funding Number'  OR LST_SECONDARY_IDENTIFIER_TYPE ='Registry Identifier' 
    OR LST_SECONDARY_IDENTIFIER_TYPE ='Other Identifier') THEN  ORG_NAME    -----CAST(CAST(PSC_SECONDARY_ID_DESC_OTY_ID AS NUMERIC) as VARCHAR(30))
	    
	Else PSC_SECONDARY_ID_DESCRIPTION      
	 
End As  SECONDARY_ID_DESCRIPTION                                       
		  
FROM CROMS.PROTOCOLS PRO
	Left JOIN CROMS.PROTOCOL_VERSIONS PVR ON PRO_ID = PVR_PRO_ID	
	Left JOIN CROMS.PROTOCOL_AWARDS PA on PA.PAW_PRO_ID=PRO.PRO_ID
	Left JOIN CROMS.PROTOCOL_SECONDARY_IDENTIFIERS PI ON PI.PSC_PAW_ID=PA.PAW_ID
	Left JOIN  CROMS.LOV_SECONDARY_IDENTIFIER_TYPES LST ON LST.LST_ID=PI.PSC_LST_ID
	Left JOIN CROMS.ORGANIZATION_TYPES OT on OTY_ID=PSC_SECONDARY_ID_DESC_OTY_ID
    Left JOIN CROMS.ORGANIZATIONS O on ORG_ID= OTY_ORG_ID
WHERE PRO_OVERALL_RECRUIT_STATUS  <> 'Unknown'	
	 AND PRO_NLM_SEND_YN = 'Y'
	 AND PRO_NLM_SEND_WEEKLY_YN = 'Y'
	 AND PVR_CURRENT_REVIEW_STATUS = 'Reviewed'	
     AND PRO_LAST_CHANGED_DATE  >= @p_fromdate_in
     AND PRO_LAST_CHANGED_DATE  < @p_todate_in
	 AND PVR_CURRENT_VERSION_YN = 'Y' 
	 AND [CROMS].NLM_FN_MarkCurrentProtocolAward(PRO_ID) IS NOT NULL
ORDER BY PRO_PROTOCOL_NUMBER
GO