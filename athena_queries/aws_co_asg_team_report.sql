SELECT "accountid" ,
         autoscalinggroupname as "instance name",
         autoscalinggrouparn as "instance arn",
         "finding",
FROM ${Database_Value}."compute_optimizer_auto_scale"
WHERE  "finding" != 'OPTIMIZED'
GROUP BY  accountid, instanautoscalinggroupnamecename, autoscalinggrouparn, "finding", "recommendationoptions"
ORDER BY finding desc