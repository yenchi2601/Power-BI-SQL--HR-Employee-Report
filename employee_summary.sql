SELECT
    dj.staff_member                                AS [Staff Number],
    TRY_CONVERT(DATE, dj.joined, 103)              AS [Joined Date],
    UPPER(LTRIM(RTRIM(dj.surname)))                AS [Surname],
    UPPER(LTRIM(RTRIM(dj.first_name)))             AS [Firstname],
    UPPER(LTRIM(RTRIM(dj.first_name))) + ', ' + UPPER(LTRIM(RTRIM(dj.surname))) AS [Full Name],
    TRY_CONVERT(DATE, dj.birth_date, 103)          AS [DOB],

    -- Calculate Age
    DATEDIFF(YEAR, TRY_CONVERT(DATE, dj.birth_date, 103), GETDATE()) 
        - CASE 
            WHEN MONTH(GETDATE()) < MONTH(TRY_CONVERT(DATE, dj.birth_date, 103))
              OR (MONTH(GETDATE()) = MONTH(TRY_CONVERT(DATE, dj.birth_date, 103)) 
                  AND DAY(GETDATE()) < DAY(TRY_CONVERT(DATE, dj.birth_date, 103)))
            THEN 1 
            ELSE 0 
          END AS [Age],

    -- Age Group by Decade (e.g., 20s, 30s, etc.)
    CAST(
        (
            (
                DATEDIFF(YEAR, TRY_CONVERT(DATE, dj.birth_date, 103), GETDATE())
                - CASE 
                    WHEN MONTH(GETDATE()) < MONTH(TRY_CONVERT(DATE, dj.birth_date, 103))
                      OR (MONTH(GETDATE()) = MONTH(TRY_CONVERT(DATE, dj.birth_date, 103)) 
                          AND DAY(GETDATE()) < DAY(TRY_CONVERT(DATE, dj.birth_date, 103)))
                    THEN 1 
                    ELSE 0 
                  END
            ) / 10 * 10
        ) AS VARCHAR
    ) + 's' AS [Age Group],

    dj.gender                                       AS [Gender],
    TRY_CONVERT(DATE, pd.position_start, 103)      AS [Position Start Date],
    TRY_CONVERT(DATE, pd.position_end, 103)        AS [Position End Date],
    TRY_CONVERT(DATE, t.last_date_worked, 103)     AS [Last Day Worked],
    pd.position_number                              AS [Position Number],
    UPPER(LTRIM(RTRIM(pt.title)))                   AS [Title],
    pt.branch                                       AS [Branch],
    pd.employment_type                              AS [Employment Type],
    pd.employment_status                            AS [Employment Status],
    -- EMPLOYMENT STATUS 
    CASE 
        WHEN pd.employment_status IN ('P','PT') THEN 'PART-TIME'
        WHEN pd.employment_status IN ('F','FT') THEN 'FULL-TIME'
        WHEN pd.employment_status IN ('C','CA') THEN 'CASUAL'
        ELSE 'OTHER'
    END AS [Employment Status Group],
    pd.occupancy_status                             AS [Occupancy Status]
FROM bronze_chris.date_joined dj
LEFT JOIN bronze_chris.position_detail pd ON dj.staff_member = pd.staff_member
LEFT JOIN bronze_chris.position_table pt  ON pd.position_number = pt.position_number
LEFT JOIN bronze_chris.termination t ON dj.staff_member = t.staff_member
where [Position End Date] = [Position start Date] 
   or 
ORDER BY    [Surname],
            [Firstname],
            [Staff Number]
;
