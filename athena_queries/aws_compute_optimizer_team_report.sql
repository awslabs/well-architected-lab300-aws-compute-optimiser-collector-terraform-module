SELECT 
         accountid,
         instancename AS "resource name",
         instancearn AS "resource arn",
         'ec2' AS "resource type", currentinstancetype AS "current instance type", "finding", recommendationoptions[1].instancetype AS "recommended instance size", '' AS "recommended desired capacity", '' AS "recommended minsize", '' AS "recommended maxsize"
FROM ${Database_Value}."compute_optimizer_ec2"
WHERE if((date_format(current_timestamp , '%M') = 'January'),month = '12', month = CAST ((month (now ())-1) AS VARCHAR) )
        AND if((date_format(current_timestamp , '%M') = 'January'), year = CAST ((year (now ())-1) AS VARCHAR) ,year = CAST (year (now ()) AS VARCHAR))
        AND "finding" != 'OPTIMIZED'
UNION
SELECT 
         accountid,
         autoscalinggroupname AS "resource name",
         autoscalinggrouparn AS "resource arn",
         'autoscaling group' AS "resource type", currentconfiguration.instancetype AS "current instance type", "finding", recommendationoptions[1].configuration.instancetype AS "recommended instance size", CAST(recommendationoptions[1].configuration.desiredcapacity AS varchar) AS "recommended desired capacity", CAST(recommendationoptions[1].configuration.minsize AS varchar) AS "recommended minsize", CAST(recommendationoptions[1].configuration.maxsize AS VARCHAR) AS "recommended maxsize"
FROM ${Database_Value}."compute_optimizer_auto_scale"
WHERE if((date_format(current_timestamp , '%M') = 'January'),month = '12', month = CAST ((month (now ())-1) AS VARCHAR) )
        AND if((date_format(current_timestamp , '%M') = 'January'), year = CAST ((year (now ())-1) AS VARCHAR) ,year = CAST (year (now ()) AS VARCHAR))
        AND "service team" = ${Team_Value}
        AND "finding" != 'OPTIMIZED'
GROUP BY  accountid, 2, 3, autoscalinggroupname, autoscalinggrouparn, "finding",  8, 9, 10, 11, recommendationoptions[1].configuration.instancetype, recommendationoptions[1].configuration.desiredcapacity, recommendationoptions[1].configuration.minsize, recommendationoptions[1].configuration.maxsize, project, currentconfiguration.instancetype
ORDER BY  finding DESC