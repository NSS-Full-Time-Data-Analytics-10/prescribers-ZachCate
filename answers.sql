SELECT *
FROM prescription;



SELECT *
FROM prescriber;


--1a
SELECT prescriber.npi, total_claim_count
FROM prescription
INNER JOIN prescriber
	USING(npi)
ORDER BY total_claim_count DESC;


--1b
SELECT nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, total_claim_count
FROM prescription
INNER JOIN prescriber
	USING(npi)
ORDER BY total_claim_count DESC;


--2a
SELECT specialty_description, SUM(total_claim_count) AS total_claim_count
FROM prescription
INNER JOIN prescriber 
	USING (npi)
GROUP BY specialty_description
ORDER BY total_claim_count DESC;



SELECT *
FROM drug;


--2b
SELECT specialty_description, SUM(total_claim_count) AS opioid_claims
FROM prescription
INNER JOIN prescriber 
	USING (npi)
INNER JOIN drug 
	USING (drug_name)
WHERE drug.opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY opioid_claims DESC;


--3a
SELECT generic_name, SUM(total_drug_cost) AS total_drug_cost
FROM prescription
INNER JOIN drug
	USING (drug_name)
GROUP BY generic_name
ORDER BY total_drug_cost DESC;


--3b
SELECT generic_name, ROUND(SUM(total_drug_cost)/1825, 2) AS cost_per_day
FROM prescription
INNER JOIN drug
	USING (drug_name)
GROUP BY generic_name
ORDER BY cost_per_day DESC;


--4a
SELECT drug_name, 
CASE
	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'
	END AS drug_type
FROM drug;


--4b
SELECT 
	SUM(CASE WHEN opioid_drug_flag = 'Y' THEN total_drug_cost ELSE 0 END)::money AS opioid_total,
	SUM(CASE WHEN antibiotic_drug_flag = 'Y' THEN total_drug_cost ELSE 0 END)::money AS antibiotic_total
FROM prescription
INNER JOIN drug
	USING (drug_name);


--5a
SELECT state, COUNT(cbsa) AS cbsa_count
FROM cbsa AS cb
INNER JOIN fips_county AS f
	USING (fipscounty)
WHERE state = 'TN'
GROUP BY state
ORDER BY cbsa_count DESC;


--5b
SELECT cbsaname, SUM(p.population) AS total_population
FROM cbsa AS cb
INNER JOIN population AS p
	USING (fipscounty)
GROUP BY cbsaname
ORDER BY total_population DESC;


SELECT *
FROM cbsa;


SELECT *
FROM population;


--5c
SELECT f.county, p.population
FROM population AS p
INNER JOIN fips_county AS f
	USING (fipscounty)
LEFT JOIN cbsa AS cb
	USING (fipscounty)
WHERE cb.cbsa IS NULL
ORDER BY p.population DESC
LIMIT 1;


--6a
SELECT drug_name, total_claim_count
FROM prescription AS p
WHERE total_claim_count >= 3000;


--6b
SELECT drug_name, total_claim_count, opioid_drug_flag AS opioid
FROM prescription AS p
INNER JOIN drug
	USING (drug_name)
WHERE total_claim_count >= 3000;


--6c
SELECT nppes_provider_first_name AS first_name, nppes_provider_last_org_name AS last_name, drug_name, total_claim_count, opioid_drug_flag AS opioid
FROM prescription AS p
INNER JOIN drug
	USING (drug_name)
INNER JOIN prescriber
	USING (npi)
WHERE total_claim_count >= 3000;


--7a
SELECT p.npi, d.drug_name
FROM prescription AS pr
JOIN prescriber AS p
	USING (npi)
JOIN drug AS d
	USING (drug_name)
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y';
	

--7b & 7c
SELECT p.npi, d.drug_name, COALESCE(SUM(pr.total_claim_count), 0) AS claims
FROM (
	SELECT DISTINCT npi
    FROM prescriber
    WHERE specialty_description = 'Pain Management'
    AND nppes_provider_city = 'NASHVILLE'
) AS p
CROSS JOIN (
	SELECT DISTINCT drug_name
	FROM drug
	WHERE opioid_drug_flag = 'Y'
) AS d
LEFT JOIN prescription AS pr 
	ON p.npi = pr.npi AND d.drug_name = pr.drug_name
GROUP BY p.npi, d.drug_name
ORDER BY claims DESC;













