SELECT
    ps.PatientId,
    ps.Hospital,
    ps.Ward,
    DATEADD(WEEK, -2, ps.AdmittedDate) AS ReminderDate,
    ps.AdmittedDate,
    ps.Tariff
FROM
    PatientStay ps
WHERE
    ps.Hospital IN ('Kingston', 'PRUH')
    AND ps.Ward LIKE '%Surgery'
    AND ps.AdmittedDate BETWEEN '2024-02-27' AND '2024-02-29';

SELECT
    ps.PatientId,
    h.Hospital,
    h.HospitalType
FROM
    PatientStay ps
    JOIN DimHospital h ON ps.Hospital = h.Hospital;

SELECT
    DISTINCT
    ps.PatientId,
    ps.Hospital,
    ps.Ward,
    ps.AdmittedDate,
    ps.Tariff
FROM
    PatientStay ps
    JOIN DimHospital h ON ps.Hospital = h.Hospital
WHERE
    h.HospitalType = 'Small'
    AND ps.AdmittedDate >= DATEADD(DAY, -30, GETDATE())
ORDER BY
    ps.AdmittedDate DESC;

SELECT
    *
FROM
    DimHospital h;

-- View: Long-stay patients (automatically calculates current stay length)
IF OBJECT_ID('dbo.vw_LongStayPatients', 'V') IS NOT NULL
    DROP VIEW dbo.vw_LongStayPatients;
GO
CREATE VIEW dbo.vw_LongStayPatients
AS
    SELECT
        ps.PatientId,
        ps.Hospital,
        ps.Ward,
        ps.AdmittedDate,
        ps.DischargeDate,
        ps.Tariff,
        DATEDIFF(DAY, ps.AdmittedDate, ISNULL(ps.DischargeDate, GETDATE())) AS StayDays
    FROM
        PatientStay ps
    WHERE
        DATEDIFF(DAY, ps.AdmittedDate, ISNULL(ps.DischargeDate, GETDATE())) >= 30;
GO

-- Example: select from the view (newest long stays first)
SELECT
    *
FROM
    dbo.vw_LongStayPatients
ORDER BY
    StayDays DESC;

SELECT
    p.PatientId,
    p.Name,
    ps.Hospital,
    ps.Ward,
    ps.AdmittedDate,
    ps.Tariff,
    p.Diagnosis
FROM
    Patient p
    JOIN PatientStay ps ON p.PatientId = ps.PatientId
WHERE
    LOWER(p.Diagnosis) LIKE '%terminal%';

-- Average hospital stay length by hospital
SELECT
    ps.Hospital,
    AVG(CAST(DATEDIFF(DAY, ps.AdmittedDate, ISNULL(ps.DischargeDate, GETDATE())) AS FLOAT)) AS AvgStayDays,
    COUNT(*) AS StayCount
FROM
    PatientStay ps
GROUP BY
    ps.Hospital
ORDER BY
    AvgStayDays DESC;

-- Comprehensive patient stay report
SELECT
    p.PatientId,
    p.Name,
    p.Diagnosis,
    ps.Hospital,
    h.HospitalType,
    ps.Ward,
    ps.AdmittedDate,
    ps.DischargeDate,
    DATEDIFF(DAY, ps.AdmittedDate, ISNULL(ps.DischargeDate, GETDATE())) AS StayDays,
    ps.Tariff
FROM
    Patient p
    JOIN PatientStay ps ON p.PatientId = ps.PatientId
    LEFT JOIN DimHospital h ON ps.Hospital = h.Hospital
ORDER BY
    p.PatientId,
    ps.AdmittedDate;
