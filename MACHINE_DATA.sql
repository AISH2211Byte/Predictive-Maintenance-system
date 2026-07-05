CREATE TABLE machine_data (
    udi INT,
    product_id VARCHAR(20),
    type CHAR(1),
    air_temperature_k DECIMAL(5,2),
    process_temperature_k DECIMAL(5,2),
    rotational_speed_rpm INT,
    torque_nm DECIMAL(5,2),
    tool_wear_min INT,
    machine_failure INT,
    twf INT,
    hdf INT,
    pwf INT,
    osf INT,
    rnf INT
);
SELECT * FROM MACHINE_DATA;
SELECT COUNT(*) AS TOTAL_MACHINES,SUM(machine_failure) AS TOTAL_FAILURES,ROUND(100.0* SUM(machine_failure)/count (*),2) as failure_rate FROM MACHINE_DATA;

-- Count the number of machines in each machine category (L, M, H)
SELECT
    type,
    COUNT(*) AS machine_count
FROM machine_data
GROUP BY type
ORDER BY machine_count DESC;

-- Calculate failure statistics for each machine type

SELECT
    type,                                           -- Machine category (L, M, H)

    COUNT(*) AS total_machines,                     -- Total machines in each category

    SUM(machine_failure) AS failures,              -- Total failed machines

    ROUND(
        100.0 * SUM(machine_failure) / COUNT(*),
        2
    ) AS failure_rate                              -- Failure percentage

FROM machine_data

GROUP BY type                                      -- Analyze each machine type separately

ORDER BY failure_rate DESC;                        -- Highest failure rate first

-- Count occurrences of each failure type

SELECT
    SUM(twf) AS tool_wear_failures,
    SUM(hdf) AS heat_dissipation_failures,
    SUM(pwf) AS power_failures,
    SUM(osf) AS overstrain_failures,
    SUM(rnf) AS random_failures

FROM machine_data;

-- Failure type distribution across machine categories

SELECT
    type,

    SUM(twf) AS tool_wear_failures,

    SUM(hdf) AS heat_dissipation_failures,

    SUM(pwf) AS power_failures,

    SUM(osf) AS overstrain_failures,

    SUM(rnf) AS random_failures

FROM machine_data

GROUP BY type

ORDER BY type;

-- Failure rate by Tool Wear Range

SELECT

    CASE

        WHEN tool_wear_min BETWEEN 0 AND 50
        THEN '0-50'

        WHEN tool_wear_min BETWEEN 51 AND 100
        THEN '51-100'

        WHEN tool_wear_min BETWEEN 101 AND 150
        THEN '101-150'

        WHEN tool_wear_min BETWEEN 151 AND 200
        THEN '151-200'

        ELSE '200+'

    END AS wear_range,

    COUNT(*) AS total_machines,

    SUM(machine_failure) AS failures,

    ROUND(
        100.0 * SUM(machine_failure) / COUNT(*),
        2
    ) AS failure_rate

FROM machine_data

GROUP BY wear_range

ORDER BY wear_range; --Preventive maintenance should be scheduled before tool wear exceeds 200 minutes, as failure rates increase significantly beyond this threshold
-- Power Failure occurrence across RPM ranges

SELECT

    CASE

        WHEN rotational_speed_rpm BETWEEN 1000 AND 1400
        THEN '1000-1400'

        WHEN rotational_speed_rpm BETWEEN 1401 AND 1800
        THEN '1401-1800'

        WHEN rotational_speed_rpm BETWEEN 1801 AND 2200
        THEN '1801-2200'

        WHEN rotational_speed_rpm BETWEEN 2201 AND 2600
        THEN '2201-2600'

        ELSE '2600+'

    END AS rpm_range,

    COUNT(*) AS total_machines,

    SUM(pwf) AS power_failures

FROM machine_data

GROUP BY rpm_range

ORDER BY rpm_range;

-- OSF occurrence across torque ranges

SELECT

    CASE

        WHEN torque_nm BETWEEN 0 AND 20
        THEN '0-20'

        WHEN torque_nm BETWEEN 21 AND 40
        THEN '21-40'

        WHEN torque_nm BETWEEN 41 AND 60
        THEN '41-60'

        ELSE '60+'

    END AS torque_range,

    COUNT(*) AS total_machines,

    SUM(osf) AS overstrain_failures

FROM machine_data

GROUP BY torque_range

ORDER BY torque_range;
SELECT
    AVG(tool_wear_min) AS avg_tool_wear
FROM machine_data
WHERE twf = 1;
SELECT
    AVG(rotational_speed_rpm) AS avg_rpm
FROM machine_data
WHERE pwf = 1;
SELECT
    AVG(torque_nm) AS avg_torque
FROM machine_data
WHERE osf = 1;
SELECT
    AVG(air_temperature_k) AS avg_air_temp,
    AVG(process_temperature_k) AS avg_process_temp
FROM machine_data
WHERE hdf = 1;

-- Contribution of each failure type
SELECT 'TWF' AS failure_type, SUM(twf) AS failures
FROM machine_data

UNION ALL

SELECT 'HDF', SUM(hdf)
FROM machine_data

UNION ALL

SELECT 'PWF', SUM(pwf)
FROM machine_data

UNION ALL

SELECT 'OSF', SUM(osf)
FROM machine_data

UNION ALL

SELECT 'RNF', SUM(rnf)
FROM machine_data

ORDER BY failures DESC;
---contri by %
SELECT

    ROUND(100.0 * SUM(twf) /
        (SUM(twf)+SUM(hdf)+SUM(pwf)+SUM(osf)+SUM(rnf)),2)
        AS twf_percent,

    ROUND(100.0 * SUM(hdf) /
        (SUM(twf)+SUM(hdf)+SUM(pwf)+SUM(osf)+SUM(rnf)),2)
        AS hdf_percent,

    ROUND(100.0 * SUM(pwf) /
        (SUM(twf)+SUM(hdf)+SUM(pwf)+SUM(osf)+SUM(rnf)),2)
        AS pwf_percent,

    ROUND(100.0 * SUM(osf) /
        (SUM(twf)+SUM(hdf)+SUM(pwf)+SUM(osf)+SUM(rnf)),2)
        AS osf_percent,

    ROUND(100.0 * SUM(rnf) /
        (SUM(twf)+SUM(hdf)+SUM(pwf)+SUM(osf)+SUM(rnf)),2)
        AS rnf_percent

FROM machine_data;

-- High-risk operating condition

SELECT

    COUNT(*) AS total_high_risk_machines,

    SUM(machine_failure) AS failed_machines,

    ROUND(
        100.0 * SUM(machine_failure) / COUNT(*),
        2
    ) AS failure_rate

FROM machine_data

WHERE tool_wear_min > 200
AND torque_nm > 50;

-- Machine types operating in high-risk zone

SELECT

    type,

    COUNT(*) AS machine_count
	 SUM(machine_failure) AS failures,

    ROUND(
       
        100.0 * SUM(machine_failure) / COUNT(*),
        2
    ) 
FROM machine_data

WHERE tool_wear_min > 200
AND torque_nm > 50

GROUP BY type

ORDER BY machine_count DESC;

---- Compare average values for failed vs non-failed machines

SELECT

    machine_failure,

    ROUND(AVG(air_temperature_k),2) AS avg_air_temp,

    ROUND(AVG(process_temperature_k),2) AS avg_process_temp,

    ROUND(AVG(rotational_speed_rpm),2) AS avg_rpm,

    ROUND(AVG(torque_nm),2) AS avg_torque,

    ROUND(AVG(tool_wear_min),2) AS avg_tool_wear

FROM machine_data

GROUP BY machine_failure;