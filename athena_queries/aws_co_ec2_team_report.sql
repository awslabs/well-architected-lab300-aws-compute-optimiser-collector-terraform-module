SELECT   accountid,
         instancename as "instance name",
         instancearn as "instance arn",
         "finding",
FROM ${Database_Value}."compute_optimizer_ec2"
WHERE "finding" != 'OPTIMIZED'
GROUP BY  accountid, instancename, instancearn, "finding", "recommendationoptions"
ORDER BY finding desc