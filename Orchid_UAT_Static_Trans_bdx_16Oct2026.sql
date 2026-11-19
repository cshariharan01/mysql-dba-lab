SELECT
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.CarrierDisplayName')), CHAR CHARACTER SET utf8mb4) AS 'Carrier',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.QuoteFullNumber')), CHAR CHARACTER SET utf8mb4) AS 'Quote Number',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.PolicyFullNumber')), CHAR CHARACTER SET utf8mb4) AS 'Policy Number',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.CreatedBy')), CHAR CHARACTER SET utf8mb4) AS 'Created By',
CASE 
WHEN CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.TransactionType')), CHAR CHARACTER SET utf8mb4) = "CANCEL" THEN CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.CancellationDate')), CHAR CHARACTER SET utf8mb4)
WHEN CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.TransactionType')), CHAR CHARACTER SET utf8mb4) = "ENDORSEMENT" THEN CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.EndorsementEffectiveDate')), CHAR CHARACTER SET utf8mb4)
ELSE
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.PolicyEffectiveDate')), CHAR CHARACTER SET utf8mb4) 
END AS 'Transaction Effective Date',
CASE
WHEN CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.TransactionType')), CHAR CHARACTER SET utf8mb4) ='CANCEL' THEN 'Cancel'
WHEN CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.TransactionType')), CHAR CHARACTER SET utf8mb4) ='ENDORSEMENT' THEN 'Endorsement'
WHEN CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.TransactionType')), CHAR CHARACTER SET utf8mb4) ='REINSTATE' THEN 'Reinstate'
ELSE
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.TransactionType')), CHAR CHARACTER SET utf8mb4)
END AS 'Transaction Type',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.EndorsementQuoteNumber')), CHAR CHARACTER SET utf8mb4) AS 'Endorsement Number',
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.PolicySubNumber')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.PolicySubNumber')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.PolicySubNumber')), CHAR CHARACTER SET utf8mb4)) AS 'Renewal Term',

IF (CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.TransactionType')), CHAR CHARACTER SET utf8mb4)IN ('New Business','RENEWAL','RENEWAL TYPE'),  CONVERT(JSON_UNQUOTE(JSON_EXTRACT(QOT.`_DATA`,_cp850'$.CurrentTermBasePremium')), CHAR CHARACTER SET utf8mb4), CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].ProratedChangeBasePremium')), CHAR CHARACTER SET utf8mb4)) AS 'Premium',
 
IF(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].Tax[0].TaxName')), CHAR CHARACTER SET utf8mb4) LIKE "%Sur%", CONVERT(REPLACE(REPLACE(REPLACE(JSON_EXTRACT(POL.`_DATA`,'$.Account.Insured[0].Location[0].Building[0].Tax[0].TaxAmount'),'"',''),'[',''),']',''),CHAR),"N/A") AS 'Surplus Tax Amount',
IF(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].Tax[1].TaxName')), CHAR CHARACTER SET utf8mb4) LIKE "%wind%", CONVERT(REPLACE(REPLACE(REPLACE(JSON_EXTRACT(POL.`_DATA`,'$.Account.Insured[0].Location[0].Building[0].Tax[1].TaxAmount'),'"',''),'[',''),']',''),CHAR),"N/A") AS 'Wind Tax Amount',
IF(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].Tax[1].TaxName')), CHAR CHARACTER SET utf8mb4) LIKE "%Fire%", CONVERT(REPLACE(REPLACE(REPLACE(JSON_EXTRACT(POL.`_DATA`,'$.Account.Insured[0].Location[0].Building[0].Tax[1].TaxAmount'),'"',''),'[',''),']',''),CHAR),"N/A") AS 'Fire Tax',

IF((CONVERT(JSON_UNQUOTE(JSON_EXTRACT(QOT.`_DATA`,_cp850'$.Account.Insured[*].Location[*].Building[*].Fee[0].FeeName')), CHAR CHARACTER SET utf8mb4) LIKE "%Policy Fee%" 
AND CONVERT(JSON_UNQUOTE(JSON_EXTRACT(QOT.`_DATA`,_cp850'$.TransactionType')), CHAR CHARACTER SET utf8mb4)IN ('NEW BUSINESS','RENEWAL','RENEWAL TYPE')),
CONVERT(REPLACE(REPLACE(REPLACE(JSON_EXTRACT(QOT.`_DATA`,'$.Account.Insured[*].Location[*].Building[*].Fee[0].FeeAmount'),'"',''),'[',''),']',''),CHAR),
IF((CONVERT(JSON_UNQUOTE(JSON_EXTRACT(QOT.`_DATA`,_cp850'$.Account.Insured[*].Location[*].Building[*].Fee[0].FeeName')), CHAR CHARACTER SET utf8mb4) LIKE "%Policy Fee%" 
AND 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(QOT.`_DATA`,_cp850'$.TransactionType')), CHAR CHARACTER SET utf8mb4)IN ('CANCEL') AND
CONVERT(REPLACE(REPLACE(REPLACE(JSON_EXTRACT(QOT.`_DATA`,'$.Account.Insured[*].Location[*].Building[*].Fee[0].ProratedChangePremium'),'"',''),'[',''),']',''),CHAR)<>'0.00'
),
CONVERT(REPLACE(REPLACE(REPLACE(JSON_EXTRACT(QOT.`_DATA`,'$.Account.Insured[*].Location[*].Building[*].Fee[0].ProratedChangePremium'),'"',''),'[',''),']',''),CHAR),
CONVERT(REPLACE(REPLACE(REPLACE(JSON_EXTRACT(QOT.`_DATA`,'$.Account.Insured[*].Location[*].Building[*].Fee[0].ProratedChangePremium'),'"',''),'[',''),']',''),CHAR)
)) AS 'Policy Fee',

IF((CONVERT(JSON_UNQUOTE(JSON_EXTRACT(QOT.`_DATA`,_cp850'$.Account.Insured[*].Location[*].Building[*].Fee[1].FeeName')), CHAR CHARACTER SET utf8mb4) LIKE "%Ins%" 
AND CONVERT(JSON_UNQUOTE(JSON_EXTRACT(QOT.`_DATA`,_cp850'$.TransactionType')), CHAR CHARACTER SET utf8mb4)IN ('NEW BUSINESS','RENEWAL','RENEWAL TYPE')),
CONVERT(REPLACE(REPLACE(REPLACE(JSON_EXTRACT(QOT.`_DATA`,'$.Account.Insured[*].Location[*].Building[*].Fee[1].FeeAmount'),'"',''),'[',''),']',''),CHAR),
IF((CONVERT(JSON_UNQUOTE(JSON_EXTRACT(QOT.`_DATA`,_cp850'$.Account.Insured[*].Location[*].Building[*].Fee[1].FeeName')), CHAR CHARACTER SET utf8mb4) LIKE "%Ins%" 
AND CONVERT(JSON_UNQUOTE(JSON_EXTRACT(QOT.`_DATA`,_cp850'$.TransactionType')), CHAR CHARACTER SET utf8mb4)IN ('CANCEL') AND 
CONVERT(REPLACE(REPLACE(REPLACE(JSON_EXTRACT(QOT.`_DATA`,'$.Account.Insured[*].Location[*].Building[*].Fee[1].ProratedChangePremium'),'"',''),'[',''),']',''),CHAR)<>'0.00'
),
CONVERT(REPLACE(REPLACE(REPLACE(JSON_EXTRACT(QOT.`_DATA`,'$.Account.Insured[*].Location[*].Building[*].Fee[1].ProratedChangePremium'),'"',''),'[',''),']',''),CHAR),
CONVERT(REPLACE(REPLACE(REPLACE(JSON_EXTRACT(QOT.`_DATA`,'$.Account.Insured[*].Location[*].Building[*].Fee[1].ProratedChangePremium'),'"',''),'[',''),']',''),CHAR)
)) AS 'Inspection Fee',
CASE
  -- If OverallCommissionAmount key is present
  WHEN JSON_EXTRACT(POL.`_DATA`, _cp850'$.OverAllCommissionAmount') IS NOT NULL THEN
    CASE
      WHEN CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.TransactionType')), CHAR CHARACTER SET utf8mb4) IN ('New Business', 'Renewal', 'Renewal Type')
        THEN CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.OverAllCommissionAmount')), CHAR CHARACTER SET utf8mb4)
      WHEN CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.TransactionType')), CHAR CHARACTER SET utf8mb4) IN ('ENDORSEMENT', 'CANCEL', 'REINSTATE')
        THEN CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.ProratedOverAllCommissionAmount')), CHAR CHARACTER SET utf8mb4)
      ELSE NULL
    END
  -- If OverallCommissionAmount is NOT present, use AgentCommissionAmount
  ELSE 
    CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.GeneralAgency.Agency[0].Agent[0].AgentCommissionAmount')), CHAR CHARACTER SET utf8mb4)
END AS 'AGENT COMMISSION',
CASE
WHEN JSON_EXTRACT(POL.`_DATA`, _cp850'$.OwnerCommissionAmount') IS NOT NULL THEN
    CASE
      WHEN CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.TransactionType')), CHAR CHARACTER SET utf8mb4) IN ('New Business', 'Renewal', 'Renewal Type')
        THEN CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.OwnerCommissionAmount')), CHAR CHARACTER SET utf8mb4)
      WHEN CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.TransactionType')), CHAR CHARACTER SET utf8mb4) IN ('ENDORSEMENT', 'CANCEL', 'REINSTATE')
        THEN CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.ProratedOwnerCommissionAmount')), CHAR CHARACTER SET utf8mb4)
      ELSE NULL
    END
  ELSE NULL
END AS 'MGA COMMISSION',

CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.CreatedBy')), CHAR CHARACTER SET utf8mb4) AS 'Issued By',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.PolicyType')), CHAR CHARACTER SET utf8mb4) AS 'Policy Type',
IF(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(QOT.`_DATA`,_cp850'$.QuoteOfferedDate')), CHAR CHARACTER SET utf8mb4) IN (NULL," ",''),"N/A",CONVERT(JSON_UNQUOTE(JSON_EXTRACT(QOT.`_DATA`,_cp850'$.QuoteOfferedDate')), CHAR CHARACTER SET utf8mb4))  AS 'Offered On',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.CreatedBy')), CHAR CHARACTER SET utf8mb4) AS 'Originally Bounded By',
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.RenewalPurpose')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.RenewalPurpose')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.RenewalPurpose')), CHAR CHARACTER SET utf8mb4)) AS 'Renewal Type',
IF(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Type')), CHAR CHARACTER SET utf8mb4) = 'Individual', 
CONCAT(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].FirstName1')), CHAR CHARACTER SET utf8mb4), ' ',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].LastName2')), CHAR CHARACTER SET utf8mb4)),
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].InsuredName')), CHAR CHARACTER SET utf8mb4)) AS 'Insured Name',
IF ((CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].AdditionalInsured[0].FirstName1')), CHAR CHARACTER SET utf8mb4) = ''
  AND CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].AdditionalInsured[0].LastName2')), CHAR CHARACTER SET utf8mb4) = '')
  OR 
  (CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].AdditionalInsured[0].FirstName1')), CHAR CHARACTER SET utf8mb4) IS NULL),
  'N/A', 
  CONCAT(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].AdditionalInsured[0].FirstName1')), CHAR CHARACTER SET utf8mb4), 
    ' ',CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].AdditionalInsured[0].LastName2')), CHAR CHARACTER SET utf8mb4))) AS 'Additional Named Insured',
	
	
CONVERT(CONCAT(JSON_UNQUOTE(JSON_EXTRACT(QOT.`_DATA`,_cp850'$.Account.Insured[0].Location[0].StreetNumberAddress1'))), CHAR CHARACTER SET utf8mb4) AS 'Address 1',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].City')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].City')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].City')), CHAR CHARACTER SET utf8mb4)) AS 'City',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Zipcode1')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Zipcode1')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Zipcode1')), CHAR CHARACTER SET utf8mb4)) AS 'Zipcode',
'N/A' AS 'Zone',
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].County')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].County')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].County')), CHAR CHARACTER SET utf8mb4)) AS 'County',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].StateRegionCode')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].StateRegionCode')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].StateRegionCode')), CHAR CHARACTER SET utf8mb4)) AS 'State',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].CoastalWaterDistance')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].CoastalWaterDistance')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].CoastalWaterDistance')), CHAR CHARACTER SET utf8mb4)) AS 'Distance from Coastal Waters',
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].ConstructionType')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].ConstructionType')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].ConstructionType')), CHAR CHARACTER SET utf8mb4)) AS 'Construction Type',
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.SublineDisplayName')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.SublineDisplayName')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.SublineDisplayName')), CHAR CHARACTER SET utf8mb4)) AS 'Form',
DATE_FORMAT(STR_TO_DATE(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.PolicyEffectiveDate')), CHAR CHARACTER SET utf8mb4), '%m/%d/%Y'), '%m/%d/%Y') AS 'Effective Date',
DATE_FORMAT(STR_TO_DATE(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.PolicyExpirationDate')), CHAR CHARACTER SET utf8mb4), '%m/%d/%Y'), '%m/%d/%Y') AS 'Expiration Date',
IF((QOT.QUOTE_TYPE IN ('New Business','Renewal') AND QOT.QUOTE_STATUS IN('Bound','Issued')),
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(QOT.`_DATA`,_cp850'$.BoundDate')),CHAR CHARACTER SET utf8mb4),
IF((QOT.QUOTE_TYPE IN ('ENDORSEMENT') AND  CONVERT(JSON_UNQUOTE(JSON_EXTRACT(QOT.`_DATA`,_cp850'$.TransactionType')), CHAR CHARACTER SET utf8mb4) IN('ENDORSEMENT','REINSTATE') AND QOT.QUOTE_STATUS IN('Bound','Issued')),
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.EndorsementIssuedDate')), CHAR CHARACTER SET utf8mb4),
IF((QOT.QUOTE_TYPE IN ('ENDORSEMENT') AND CONVERT(JSON_UNQUOTE(JSON_EXTRACT(QOT.`_DATA`,_cp850'$.TransactionType')), CHAR CHARACTER SET utf8mb4)='CANCEL'  AND QOT.QUOTE_STATUS ='Issued'),
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(QOT.`_DATA`,_cp850'$.CancellationDate')), CHAR CHARACTER SET utf8mb4),
'N/A'
))) AS 'Bound Date',
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].DwellingCoverage')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].DwellingCoverage')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].DwellingCoverage')), SIGNED)) AS 'Coverage A',
 
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].OtherStructureCovadjAmount')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].OtherStructureCovadjAmount')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].OtherStructureCovadjAmount')), SIGNED)) AS 'Coverage B',
 
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].PersonalPropertyAmount')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].PersonalPropertyAmount')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].PersonalPropertyAmount')), SIGNED)) AS 'Coverage C',
 
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].LossOfUseCovadjAmount')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].LossOfUseCovadjAmount')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].LossOfUseCovadjAmount')), SIGNED)) AS 'Coverage D',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].WindCoverage')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].WindCoverage')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].WindCoverage')), CHAR CHARACTER SET utf8mb4)) AS 'Wind Cov Included',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].OtherStructureCovadjAmount')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].OtherStructureCovadjAmount')), CHAR CHARACTER SET utf8mb4) IS NULL AND 
TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].PersonalPropertyAmount')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].PersonalPropertyAmount')), CHAR CHARACTER SET utf8mb4) IS NULL AND 
TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].LossOfUseCovadjAmount')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].LossOfUseCovadjAmount')), CHAR CHARACTER SET utf8mb4) IS NULL, 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].DwellingCoverage')), CHAR CHARACTER SET utf8mb4), 
(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].DwellingCoverage')), CHAR CHARACTER SET utf8mb4)+
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].OtherStructureCovadjAmount')), CHAR CHARACTER SET utf8mb4) + 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].PersonalPropertyAmount')), CHAR CHARACTER SET utf8mb4)+ 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].LossOfUseCovadjAmount')), CHAR CHARACTER SET utf8mb4))) AS 'TIV',


IF(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.CarrierDisplayName')), CHAR CHARACTER SET utf8mb4) IN ("Lloyds_Canopius","Lloyd's Canopius"),
    'N/A',
    CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].MiscSurchargeAmount')), CHAR CHARACTER SET utf8mb4)
) AS 'Misc. Surcharge',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].TermInMonths')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].TermInMonths')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].TermInMonths')), CHAR CHARACTER SET utf8mb4)) AS 'Term',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.GeneralAgency.Agency[0].Name')), CHAR CHARACTER SET utf8mb4)) = '' OR 

CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.GeneralAgency.Agency[0].Name')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 

CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.GeneralAgency.Agency[0].Name')), CHAR CHARACTER SET utf8mb4)) AS 'Broker',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].ProtectionClass')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].ProtectionClass')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].ProtectionClass')), CHAR CHARACTER SET utf8mb4)) AS 'Protection Class',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].SquareFt')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].SquareFt')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].SquareFt')), CHAR CHARACTER SET utf8mb4)) AS 'Square Footage',
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].DateBuilt')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].DateBuilt')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].DateBuilt')), CHAR CHARACTER SET utf8mb4)) AS 'Year Built',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].HurricaneShutter')), CHAR CHARACTER SET utf8mb4) AS 'Hurricane Shutters',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].StormHurricane')), CHAR CHARACTER SET utf8mb4) AS 'Storm Shutter / Hurricane Strap',
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].RoofUpdated')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].RoofUpdated')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].RoofUpdated')), CHAR CHARACTER SET utf8mb4)) AS 'Roof Fully Updated',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].IsHipRoofAvailable')), CHAR CHARACTER SET utf8mb4) AS 'Is Hip Roof Available',
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].AopPolicyDeductibleAmount')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].AopPolicyDeductibleAmount')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].AopPolicyDeductibleAmount')), CHAR CHARACTER SET utf8mb4)) AS 'AOP Deductible',
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].WindDeductibleAmount')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].WindDeductibleAmount')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].WindDeductibleAmount')), CHAR CHARACTER SET utf8mb4)) AS 'Wind Deductible',

IF(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].CondoYN')), CHAR CHARACTER SET utf8mb4) = 'No',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].NumberOfStories')), CHAR CHARACTER SET utf8mb4),
IF (CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].CondoYN')), CHAR CHARACTER SET utf8mb4) = 'Yes',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].CondoNumberofStories')), CHAR CHARACTER SET utf8mb4),
'N/A' )) AS 'Number Of Stories',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].FireAlarm')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].FireAlarm')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].FireAlarm')), CHAR CHARACTER SET utf8mb4)) AS 'Central Station Fire Alarm',
 
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].BurglarAlarm')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].BurglarAlarm')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].BurglarAlarm')), CHAR CHARACTER SET utf8mb4)) AS 'Central Station Burglar Alarm',
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].InteriorSprinkler')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].InteriorSprinkler')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].InteriorSprinkler')), CHAR CHARACTER SET utf8mb4))AS 'Sprinklers',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].ResType')), CHAR CHARACTER SET utf8mb4) AS 'Type Of Residence',
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].EarthquakeDeductible')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].EarthquakeDeductible')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].EarthquakeDeductible')), CHAR CHARACTER SET utf8mb4)) AS 'Earthquake Deductible',
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.GeneralAgency.Agency[0].AgencyNumber')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.GeneralAgency.Agency[0].AgencyNumber')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.GeneralAgency.Agency[0].AgencyNumber')), CHAR CHARACTER SET utf8mb4)) AS 'Broker Code',

CONCAT(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.GeneralAgency.Agency[0].Agent[0].FirstName1')), CHAR CHARACTER SET utf8mb4), ' ',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.GeneralAgency.Agency[0].Agent[0].LastName2')), CHAR CHARACTER SET utf8mb4)) AS  'Broker Contact',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.GeneralAgency.Agency[0].Agent[0].AgentCommunication[0].EmailAddress')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.GeneralAgency.Agency[0].Agent[0].AgentCommunication[0].EmailAddress')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.GeneralAgency.Agency[0].Agent[0].AgentCommunication[0].EmailAddress')), CHAR CHARACTER SET utf8mb4)) AS 'Broker Contact Email',

CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.CreatedBy')), CHAR CHARACTER SET utf8mb4) AS 'Quote Created By',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.CreatedBy')), CHAR CHARACTER SET utf8mb4) AS 'Transacted By',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.CreatedBy')), CHAR CHARACTER SET utf8mb4) AS 'Bound By',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Occupancy')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Occupancy')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Occupancy')), CHAR CHARACTER SET utf8mb4)) AS 'Occupancy Type',
 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].NumberOfBuildings')), CHAR CHARACTER SET utf8mb4) AS 'Number of Units',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].MitigationOpenings')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].MitigationOpenings')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].MitigationOpenings')), CHAR CHARACTER SET utf8mb4)) AS 'Opening Protection',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].RoofToWallConnection')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].RoofToWallConnection')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].RoofToWallConnection')), CHAR CHARACTER SET utf8mb4)) AS 'Roof Anchor',
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].RoofMaterial')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].RoofMaterial')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].RoofMaterial')), CHAR CHARACTER SET utf8mb4)) AS 'Roof Covering',
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].RoofShape')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].RoofShape')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].RoofShape')), CHAR CHARACTER SET utf8mb4)) AS 'Roof Shape',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].HeatingUpdated')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].HeatingUpdated')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].HeatingUpdated')), CHAR CHARACTER SET utf8mb4)) AS 'Heating Type Year of Update',
 
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].PlumbingType')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].PlumbingType')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].PlumbingType')), CHAR CHARACTER SET utf8mb4)) AS 'Plumbing Type',
 
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].PlumbingUpdated')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].PlumbingUpdated')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].PlumbingUpdated')), CHAR CHARACTER SET utf8mb4)) AS 'Plumbing Type Year of Update',
 
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].ElectricServiceType')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].ElectricServiceType')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].ElectricServiceType')), CHAR CHARACTER SET utf8mb4)) AS 'Electric Type',
 
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].ElectricUpdated')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].ElectricUpdated')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].ElectricUpdated')), CHAR CHARACTER SET utf8mb4)) AS 'Electric Type Year of Update',

IF(
(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.CarrierDisplayName')), CHAR CHARACTER SET utf8mb4) IN("Lloyds_Canopius","Lloyd's Canopius")),
IF(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].ExtendedReplacementCostCanopius')), CHAR CHARACTER SET  utf8mb4) ='' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].ExtendedReplacementCostCanopius')), CHAR CHARACTER SET  utf8mb4) IS NULL,"N/A",
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].ExtendedReplacementCostCanopius')), CHAR CHARACTER SET  utf8mb4))
,IF(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].IncreasedReplacementCost')), CHAR CHARACTER SET utf8mb4) ='' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].IncreasedReplacementCost')), CHAR CHARACTER SET utf8mb4) IS NULL,"N/A",
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].IncreasedReplacementCost')), CHAR CHARACTER SET utf8mb4))) AS 'Extended Replacement Cost',

IF(JSON_UNQUOTE(JSON_EXTRACT(QOT._DATA,'$.MarketType')) = 'Brokerage', 'N/A', IF(
(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.CarrierDisplayName')), CHAR CHARACTER SET utf8mb4) IN("Lloyds_Canopius","Lloyd's Canopius","Vave Underwriting Agency, Inc.")),
IF(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].WaterDamageSublimitCanopius')), CHAR CHARACTER SET  utf8mb4) ='' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].WaterDamageSublimitCanopius')), CHAR CHARACTER SET  utf8mb4) IS NULL,"N/A",
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].WaterDamageSublimitCanopius')), CHAR CHARACTER SET  utf8mb4))
,IF(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].WaterDamageSublimit')), CHAR CHARACTER SET utf8mb4) ='' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].WaterDamageSublimit')), CHAR CHARACTER SET utf8mb4) IS NULL,"N/A",
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].WaterDamageSublimit')), CHAR CHARACTER SET utf8mb4)))) AS 'Water Damage Sub-Limit',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].FloodZone')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].FloodZone')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].FloodZone')), CHAR CHARACTER SET utf8mb4)) AS 'Flood Zone'

FROM 
POL_POLICY_V2

INNER JOIN POL_POLICY_VER_V2 POL ON POL_POLICY_V2.ID = POL.ID 
INNER JOIN QOT_QUOTE_V2 QOT ON QOT.ID = POL.QUOTE_ID AND  QOT.OWNER_ID = POL.OWNER_ID
INNER JOIN REF_CARRIER_MAPPING ON REF_CARRIER_MAPPING.REF_CARRIER_MAPPING_ID = JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850 '$.CarrierID'))
AND REF_CARRIER_MAPPING.OWNER_ID = 4742
AND POL.OWNER_ID = 4742
AND CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL.`_DATA`,_cp850'$.PolicyType')), CHAR CHARACTER SET utf8mb4) IN ('Policy','Renewal')

AND DATE_FORMAT(DATE(POL.CREATED_DATE), '%Y-%m-%d %H:%i:%s')
>='2026-01-01' AND DATE_FORMAT(DATE(POL.CREATED_DATE), '%Y-%m-%d %H:%i:%s')
<='2026-01-07'

;