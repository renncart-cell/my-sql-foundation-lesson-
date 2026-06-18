\.





SELECT
	ps.PatientId
    
	,ps.Hospital
    
	,ps.Ward
    
	,DATEADD(WEEK, -2, ps.AdmittedDate) AS ReminderDate
    
	,ps.AdmittedDate
   -- , ps.DischargeDate
    
	,ps.Tariff
FROM
	PatientStay ps
WHERE ps.Hospital IN ('Kingston', 'PRUH')
	AND ps.Ward LIKE '%Surgery'
	AND ps.AdmittedDate BETWEEN '2024-02-27' AND '2024-02-29'