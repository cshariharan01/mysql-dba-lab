SELECT 
IF('AL'='ALL','ALL','AL') AS 'State 1',
IF('MONTGOMERY'='ALL' ,'ALL','MONTGOMERY') AS 'County 1',
'AGY6787' AS 'Broker Code 1',
IF('ALL'='ALL','ALL','ALL') AS 'Policy Type 1',
IF('Transverse 2 MSTO'='ALL','ALL','Transverse 2 MSTO') AS 'Company 1',
DATE_FORMAT(STR_TO_DATE('2026-01-01', '%m/%d/%Y'), '%m/%d/%Y') AS 'Start Date',
DATE_FORMAT(STR_TO_DATE('2026-01-30', '%m/%d/%Y'), '%m/%d/%Y') AS 'End Date',
 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.CarrierDisplayName')), CHAR CHARACTER SET utf8mb4) AS 'Carrier', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.QuoteFullNumber')), CHAR CHARACTER SET utf8mb4) AS 'Quote #',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.PolicyFullNumber')), CHAR CHARACTER SET utf8mb4) AS 'Policy #',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.PolicySubNumber')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.PolicySubNumber')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.PolicySubNumber')), CHAR CHARACTER SET utf8mb4)) AS 'Renewal Term',

CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.QuoteOfferedDate')), CHAR CHARACTER SET utf8mb4) AS 'Offered On', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.CreatedBy')), CHAR CHARACTER SET utf8mb4) AS 'Quote Created By',
IF(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.PolicyType')), CHAR CHARACTER SET utf8mb4) = 'Policy', 'NEW BUSINESS', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.PolicyType')), CHAR CHARACTER SET utf8mb4)) AS 'Policy Type',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.PolicyStatus')), CHAR CHARACTER SET utf8mb4) AS 'Policy Status',
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.RenewalPurpose')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.RenewalPurpose')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.RenewalPurpose')), CHAR CHARACTER SET utf8mb4)) AS 'Renewal Type',
IF(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.PolicyType')), CHAR CHARACTER SET utf8mb4) = 'ENDORSEMENT', 
DATE_FORMAT(STR_TO_DATE(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.EndorsementEffectiveDate')), CHAR CHARACTER SET utf8mb4), '%m/%d/%Y'), '%m/%d/%Y'),
DATE_FORMAT(STR_TO_DATE(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.PolicyEffectiveDate')), CHAR CHARACTER SET utf8mb4), '%m/%d/%Y'), '%m/%d/%Y')) AS 'Eff Date',
DATE_FORMAT(STR_TO_DATE(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.PolicyExpirationDate')), CHAR CHARACTER SET utf8mb4), '%m/%d/%Y'), '%m/%d/%Y') AS 'Exp Date',
IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.CancellationDate')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.CancellationDate')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.CancellationDate')), CHAR CHARACTER SET utf8mb4)) AS 'Cancel Date',
IF(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.CancellationType')), CHAR CHARACTER SET utf8mb4) = 'Flat Rate', 'Yes', 'No') AS 'Flat Cancel Indicator',

IF(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].Type')), CHAR CHARACTER SET utf8mb4) = 'Individual', 
CONCAT(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].FirstName1')), CHAR CHARACTER SET utf8mb4), ' ',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].LastName2')), CHAR CHARACTER SET utf8mb4)),
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].InsuredName')), CHAR CHARACTER SET utf8mb4)) AS 'Insured Name',

CASE
WHEN CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].AdditionalInsured[0].FirstName1')), CHAR CHARACTER SET utf8mb4) = "" THEN "N/A"
WHEN CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].AdditionalInsured[0].LastName2')), CHAR CHARACTER SET utf8mb4) = "" THEN "N/A"
ELSE
CONCAT(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].AdditionalInsured[0].FirstName1')), CHAR CHARACTER SET utf8mb4), ' ',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].AdditionalInsured[0].LastName2')), CHAR CHARACTER SET utf8mb4))
END AS 'Additional Named Insured',

CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].Location[0].StreetNumberAddress1')), CHAR CHARACTER SET utf8mb4) AS 'Insured Address1',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].Location[0].City')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].Location[0].City')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].Location[0].City')), CHAR CHARACTER SET utf8mb4)) AS 'Insured City',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Zipcode1')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Zipcode1')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Zipcode1')), CHAR CHARACTER SET utf8mb4)) AS 'Insured Zipcode',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].Location[0].County')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].Location[0].County')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].Location[0].County')), CHAR CHARACTER SET utf8mb4)) AS 'Insured County',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].Location[0].StateRegionCode')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].Location[0].StateRegionCode')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].Location[0].StateRegionCode')), CHAR CHARACTER SET utf8mb4)) AS 'Insured State',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.GeneralAgency.Agency[0].Name')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.GeneralAgency.Agency[0].Name')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.GeneralAgency.Agency[0].Name')), CHAR CHARACTER SET utf8mb4)) AS 'Broker',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.GeneralAgency.Agency[0].AgencyNumber')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.GeneralAgency.Agency[0].AgencyNumber')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.GeneralAgency.Agency[0].AgencyNumber')), CHAR CHARACTER SET utf8mb4)) AS 'Broker Code',

CONCAT(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.GeneralAgency.Agency[0].Agent[0].FirstName1')), CHAR CHARACTER SET utf8mb4), ' ',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.GeneralAgency.Agency[0].Agent[0].LastName2')), CHAR CHARACTER SET utf8mb4)) AS 'Broker Contact',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.GeneralAgency.Agency[0].Agent[0].AgentCommunication[0].EmailAddress')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.GeneralAgency.Agency[0].Agent[0].AgentCommunication[0].EmailAddress')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.GeneralAgency.Agency[0].Agent[0].AgentCommunication[0].EmailAddress')), CHAR CHARACTER SET utf8mb4)) AS 'Broker Contact Email',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.SublineDisplayName')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.SublineDisplayName')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.SublineDisplayName')), CHAR CHARACTER SET utf8mb4)) AS 'Form',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].DwellingCoverage')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].DwellingCoverage')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].DwellingCoverage')), SIGNED)) AS 'Coverage A',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].OtherStructureCovadjAmount')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].OtherStructureCovadjAmount')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].OtherStructureCovadjAmount')), SIGNED)) AS 'Coverage B',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].PersonalPropertyAmount')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].PersonalPropertyAmount')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].PersonalPropertyAmount')), SIGNED)) AS 'Coverage C',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].LossOfUseCovadjAmount')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].LossOfUseCovadjAmount')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].LossOfUseCovadjAmount')), SIGNED)) AS 'Coverage D',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].OtherStructureCovadjAmount')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].OtherStructureCovadjAmount')), CHAR CHARACTER SET utf8mb4) IS NULL AND 
TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].PersonalPropertyAmount')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].PersonalPropertyAmount')), CHAR CHARACTER SET utf8mb4) IS NULL AND 
TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].LossOfUseCovadjAmount')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].LossOfUseCovadjAmount')), CHAR CHARACTER SET utf8mb4) IS NULL, 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].DwellingCoverage')), CHAR CHARACTER SET utf8mb4), 
(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].DwellingCoverage')), CHAR CHARACTER SET utf8mb4)+
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].OtherStructureCovadjAmount')), CHAR CHARACTER SET utf8mb4) + 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].PersonalPropertyAmount')), CHAR CHARACTER SET utf8mb4)+ 
 CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].LossOfUseCovadjAmount')), CHAR CHARACTER SET utf8mb4))) AS 'TIV',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].WindCoverage')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].WindCoverage')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].WindCoverage')), CHAR CHARACTER SET utf8mb4)) AS 'Wind Cov Included',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].AopPolicyDeductibleAmount')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].AopPolicyDeductibleAmount')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].AopPolicyDeductibleAmount')), CHAR CHARACTER SET utf8mb4)) AS 'AOP Deductible',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].WindDeductibleAmount')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].WindDeductibleAmount')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].WindDeductibleAmount')), CHAR CHARACTER SET utf8mb4)) AS 'Wind Deductible $',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].DeductiblePercentage')), CHAR CHARACTER SET utf8mb4)) = '' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].DeductiblePercentage')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A', 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].DeductiblePercentage')), CHAR CHARACTER SET utf8mb4)) AS 'Wind Deductible %',

CONVERT(JSON_UNQUOTE(JSON_EXTRACT(QOT.`_DATA`,_cp850'$.TotalBasePremium')), CHAR CHARACTER SET utf8mb4) AS 'Basepremium',


CONVERT(JSON_UNQUOTE(JSON_EXTRACT(QOT.`_DATA`,_cp850'$.TotalPremium')), CHAR CHARACTER SET utf8mb4) AS 'Written Premium',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].PersonalLiabilityPremium')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].PersonalLiabilityPremium')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].PersonalLiabilityPremium')), CHAR CHARACTER SET utf8mb4)) AS 'Personal Liability Premium',

IF(
    JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2._DATA, '$.MarketType')) = 'Brokerage','N/A',
    IF(
        CONVERT(
            JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2._DATA, _cp850'$.CarrierDisplayName')),
            CHAR CHARACTER SET utf8mb4
        ) IN ("Lloyds_Canopius", "Transverse 2 MSTO"),
        IFNULL(
            CONVERT(
                JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2._DATA, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].TotalOptionalCoveragePremium')),
                CHAR CHARACTER SET utf8mb4
            ),
            'N/A'
        ),
        '0.00'
    )
) AS 'Total Optional Coverages Premium',

IF(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.CarrierDisplayName')), CHAR CHARACTER SET utf8mb4) IN ("Lloyds_Canopius","Transverse 2 MSTO"),
    'N/A',
    CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].MiscSurchargeAmount')), CHAR CHARACTER SET utf8mb4)
) AS 'Misc. Surcharge',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].LossAssessment')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].LossAssessment')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].LossAssessment')), CHAR CHARACTER SET utf8mb4)) AS 'Loss Assessment',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].EarthquakeDeductible')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].EarthquakeDeductible')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].EarthquakeDeductible')), CHAR CHARACTER SET utf8mb4)) AS 'Earthquake Deductible',

CASE 
    WHEN JSON_UNQUOTE(JSON_EXTRACT(QOT.`_DATA`, '$.MarketType')) = 'Brokerage' THEN 'N/A'
    WHEN CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.CarrierDisplayName')), CHAR CHARACTER SET utf8mb4) IN("Lloyds_Canopius","Transverse 2 MSTO")
    THEN CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].ExtendedReplacementCostCanopius')), CHAR CHARACTER SET utf8mb4)
    ELSE CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].IncreasedReplacementCost')), CHAR CHARACTER SET utf8mb4)
END AS 'Extended Replacement Cost',

CASE 
    WHEN JSON_UNQUOTE(JSON_EXTRACT(QOT.`_DATA`, '$.MarketType')) = 'Brokerage' THEN 'N/A'
    WHEN TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].PrimaryFloodDeductible')), CHAR CHARACTER SET utf8mb4)) = ''
    OR CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].PrimaryFloodDeductible')), CHAR CHARACTER SET utf8mb4) IS NULL THEN 'N/A'
	ELSE CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].PrimaryFloodDeductible')), CHAR CHARACTER SET utf8mb4)
END AS 'Primary Flood Deductible',

IF(JSON_UNQUOTE(JSON_EXTRACT(QOT._DATA,'$.MarketType')) = 'Brokerage', 'N/A', IF(
(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.CarrierDisplayName')), CHAR CHARACTER SET utf8mb4) IN("Lloyds_Canopius","Transverse 2 MSTO","Vave Underwriting Agency, Inc.")),
IF(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].WaterDamageSublimitCanopius')), CHAR CHARACTER SET  utf8mb4) ='' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].WaterDamageSublimitCanopius')), CHAR CHARACTER SET  utf8mb4) IS NULL,"N/A",
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].WaterDamageSublimitCanopius')), CHAR CHARACTER SET  utf8mb4))
,IF(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].WaterDamageSublimit')), CHAR CHARACTER SET utf8mb4) ='' OR 
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].WaterDamageSublimit')), CHAR CHARACTER SET utf8mb4) IS NULL,"N/A",
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].WaterDamageSublimit')), CHAR CHARACTER SET utf8mb4)))) AS 'Water Damage Sub-Limit',


IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].TermInMonths')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].TermInMonths')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Coverage[0].TermInMonths')), CHAR CHARACTER SET utf8mb4)) AS 'Policy Term',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].CoastalWaterDistance')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].CoastalWaterDistance')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].CoastalWaterDistance')), CHAR CHARACTER SET utf8mb4)) AS 'Distance from Coastal Waters',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].ProtectionClass')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].ProtectionClass')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].ProtectionClass')), CHAR CHARACTER SET utf8mb4)) AS 'Protection Class',


IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].SquareFt')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].SquareFt')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].SquareFt')), CHAR CHARACTER SET utf8mb4)) AS 'Square Footage',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].DateBuilt')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].DateBuilt')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].DateBuilt')), CHAR CHARACTER SET utf8mb4)) AS 'Year Built',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].RoofUpdated')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].RoofUpdated')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].RoofUpdated')), CHAR CHARACTER SET utf8mb4)) AS 'Roof Fully Updated',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].NumberOfStories')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].NumberOfStories')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].NumberOfStories')), CHAR CHARACTER SET utf8mb4)) AS 'Number Of Stories',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].FireAlarm')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].FireAlarm')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].FireAlarm')), CHAR CHARACTER SET utf8mb4)) AS 'Central Station Fire Alarm',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].BurglarAlarm')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].BurglarAlarm')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].BurglarAlarm')), CHAR CHARACTER SET utf8mb4)) AS 'Central Station Burglar Alarm',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].InteriorSprinkler')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].InteriorSprinkler')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].InteriorSprinkler')), CHAR CHARACTER SET utf8mb4)) AS 'Sprinklers',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Occupancy')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Occupancy')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].Occupancy')), CHAR CHARACTER SET utf8mb4)) AS 'Occupancy Type',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].ConstructionType')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].ConstructionType')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].ConstructionType')), CHAR CHARACTER SET utf8mb4)) AS 'Construction Type',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].MitigationOpenings')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].MitigationOpenings')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].MitigationOpenings')), CHAR CHARACTER SET utf8mb4)) AS 'Opening Protection',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].RoofToWallConnection')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].RoofToWallConnection')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].RoofToWallConnection')), CHAR CHARACTER SET utf8mb4)) AS 'Roof Anchor',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].RoofMaterial')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].RoofMaterial')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].RoofMaterial')), CHAR CHARACTER SET utf8mb4)) AS 'Roof Covering',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].RoofShape')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].RoofShape')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].RoofShape')), CHAR CHARACTER SET utf8mb4)) AS 'Roof Shape',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].HeatingUpdated')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].HeatingUpdated')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].HeatingUpdated')), CHAR CHARACTER SET utf8mb4)) AS 'Heating Type Year of Update',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].PlumbingType')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].PlumbingType')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].PlumbingType')), CHAR CHARACTER SET utf8mb4)) AS 'Plumbing Type',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].PlumbingUpdated')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].PlumbingUpdated')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].PlumbingUpdated')), CHAR CHARACTER SET utf8mb4)) AS 'Plumbing Type Year of Update',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].ElectricServiceType')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].ElectricServiceType')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].ElectricServiceType')), CHAR CHARACTER SET utf8mb4)) AS 'Electric Type',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].ElectricUpdated')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].ElectricUpdated')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].ElectricUpdated')), CHAR CHARACTER SET utf8mb4)) AS 'Electric Type Year of Update',

IF(TRIM(CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].FloodZone')), CHAR CHARACTER SET utf8mb4)) = '' OR
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].FloodZone')), CHAR CHARACTER SET utf8mb4) IS NULL, 'N/A',
CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`, _cp850'$.Account.Insured[0].Location[0].Building[0].FloodZone')), CHAR CHARACTER SET utf8mb4)) AS 'Flood Zone'

FROM POL_POLICY_V2
INNER JOIN POL_POLICY_VER_V2 ON POL_POLICY_V2.VER_ID = POL_POLICY_VER_V2.VER_ID
INNER JOIN QOT_QUOTE_V2 QOT ON QOT.ID = POL_POLICY_VER_V2.QUOTE_ID AND  QOT.OWNER_ID = POL_POLICY_VER_V2.OWNER_ID
INNER JOIN REF_CARRIER_MAPPING ON REF_CARRIER_MAPPING.REF_CARRIER_MAPPING_ID =CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.CarrierID')), CHAR CHARACTER SET utf8mb4)
AND  REF_CARRIER_MAPPING.OWNER_ID = 4742
WHERE 
POL_POLICY_V2.ACTIVE='Y'
AND POL_POLICY_VER_V2.ACTIVE='Y' 
AND REF_CARRIER_MAPPING.ACTIVE='Y'
AND POL_POLICY_VER_V2.OWNER_ID = 4742 
AND POL_POLICY_VER_V2.POLICY_STATUS IN('Issued','Bound')
AND POL_POLICY_VER_V2.POLICY_TYPE IN ('Policy','Renewal','RENEWAL TYPE') 
AND 
( JSON_UNQUOTE(JSON_EXTRACT(QOT.`_DATA`,_cp850'$.Account.SelectedLineOfBusiness[0].InsuranceType')) NOT IN ('Flood', 'Jewelry')
OR JSON_UNQUOTE(JSON_EXTRACT(QOT.`_DATA`,_cp850'$.Account.SelectedLineOfBusiness[0].InsuranceType')) IS NULL )

AND ('AL'='ALL' OR CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].Location[0].StateRegionCode')), CHAR CHARACTER SET utf8mb4)= 'AL')
AND ('MONTGOMERY'='ALL' OR CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.Account.Insured[0].Location[0].County')), CHAR CHARACTER SET utf8mb4) ='MONTGOMERY')
AND IF('AGY6787'='ALL',1=1,CONVERT(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.GeneralAgency.Agency[0].AgencyNumber')), CHAR CHARACTER SET utf8mb4)='AGY6787')
AND ('ALL'='ALL' OR IF('ALL'='Policy',POL_POLICY_VER_V2.POLICY_TYPE='Policy',POL_POLICY_VER_V2.POLICY_TYPE='Renewal'))
AND ("Transverse 2 MSTO"='ALL' OR REF_CARRIER_MAPPING.CARRIER_DESCRIPTION= "Transverse 2 MSTO")

AND IF(POL_POLICY_VER_V2.POLICY_TYPE='ENDORSEMENT',DATE_FORMAT(STR_TO_DATE(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.EndorsementEffectiveDate')), '%m/%d/%Y'), '%Y-%m-%d'),DATE_FORMAT(STR_TO_DATE(JSON_UNQUOTE(JSON_EXTRACT(POL_POLICY_VER_V2.`_DATA`,_cp850'$.PolicyEffectiveDate')), '%m/%d/%Y'), '%Y-%m-%d'))
BETWEEN DATE_FORMAT('2026-01-01','%Y-%m-%d') 
AND IF(DATE_FORMAT('2026-01-30','%Y-%m-%d')>DATE(NOW()),DATE(NOW()),DATE_FORMAT('2026-01-30','%Y-%m-%d'))
;
