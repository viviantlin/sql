/*SQL Case: Yammer Dip in Engagement
By: Vivian Lin
*/

-- Weekly Active Users
SELECT DATE_TRUNC('week', occurred_at) AS week,
              COUNT(DISTINCT user_id) as weekly_active_users
FROM tutorial.yammer_events
WHERE event_type = 'engagement' AND
              event_name = 'login'
GROUP BY 1
ORDER BY 1;

-- Daily Sign-Up and Activation Rate
SELECT DATE_TRUNC('day', created_at) AS day,
       COUNT(*) AS all_users,
       COUNT(CASE WHEN state = 'active' THEN user_id ELSE NULL END) 
AS activated_users
FROM tutorial.yammer_users
WHERE created_at >= '2014-06-01'
GROUP BY 1
ORDER BY 1;

-- Engagement by Device Type
SELECT DATE_TRUNC('week', occurred_at) AS week,
      COUNT(DISTINCT user_id) AS weekly_active_users,
      COUNT(DISTINCT CASE WHEN device IN ('macbook pro','lenovo thinkpad', 'macbook air', 'dell inspiron notebook', 
			'asus chromebook', 'dell inspiron desktop', 'acer aspire notebook', 'hp pavilion desktop', 'acer aspire desktop','mac mini')
                    THEN user_id ELSE NULL END) AS computer,
       COUNT(DISTINCT CASE WHEN device IN ('iphone 5','samsung galaxy s4', 'nexus 5', 'iphone 5s', 'iphone 4s', 'nokia lumia 635',
			'htc one','samsung galaxy note','amazon fire phone') 
                     THEN user_id ELSE NULL END) AS phone,
        COUNT(DISTINCT CASE WHEN device IN ('ipad air','nexus 7','ipad mini','nexus 10', 'kindle fire', 'windows surface','samsumg galaxy tablet') 
                      THEN user_id ELSE NULL END) AS tablet
FROM tutorial.yammer_events
WHERE event_type = 'engagement'
     AND event_name = 'login'
GROUP BY 1
ORDER BY 1;
 
-- Weekly Email Actions
SELECT DATE_TRUNC('week', occurred_at) as week,
       COUNT(CASE WHEN action = 'email_open' THEN user_id ELSE NULL END) AS email_open,
       COUNT(CASE WHEN action = 'email_clickthrough' THEN user_id ELSE NULL END) AS email_clickthroughs,
       COUNT(CASE WHEN action = 'sent_weekly_digest' THEN user_id ELSE NULL END) AS weekly_email,
       COUNT(CASE WHEN action = 'sent_reengagement_email' THEN user_id ELSE NULL END) AS reengagement_email
FROM tutorial.yammer_emails
GROUP BY 1
ORDER BY 1;

-- Weekly Email Open Rate & Email Clickthrough Rate
SELECT week,
       weekly_opens/CASE WHEN weekly_emails = 0 THEN 1 ELSE weekly_emails END::FLOAT AS weekly_open_rate,
       weekly_ctr/CASE WHEN weekly_opens = 0 THEN 1 ELSE weekly_opens END::FLOAT AS weekly_ctr,
       retain_opens/CASE WHEN retain_emails = 0 THEN 1 ELSE retain_emails END::FLOAT AS retain_open_rate,
       retain_ctr/CASE WHEN retain_opens = 0 THEN 1 ELSE retain_opens END::FLOAT AS retain_ctr
  FROM (
SELECT DATE_TRUNC('week',e1.occurred_at) AS week,
       COUNT(CASE WHEN e1.action = 'sent_weekly_digest' THEN e1.user_id ELSE NULL END) AS weekly_emails,
       COUNT(CASE WHEN e1.action = 'sent_weekly_digest' THEN e2.user_id ELSE NULL END) AS weekly_opens,
       COUNT(CASE WHEN e1.action = 'sent_weekly_digest' THEN e3.user_id ELSE NULL END) AS weekly_ctr,
       COUNT(CASE WHEN e1.action = 'sent_reengagement_email' THEN e1.user_id ELSE NULL END) AS retain_emails,
       COUNT(CASE WHEN e1.action = 'sent_reengagement_email' THEN e2.user_id ELSE NULL END) AS retain_opens,
       COUNT(CASE WHEN e1.action = 'sent_reengagement_email' THEN e3.user_id ELSE NULL END) AS retain_ctr
  FROM tutorial.yammer_emails e1
  LEFT JOIN tutorial.yammer_emails e2
    ON e2.occurred_at >= e1.occurred_at
   AND e2.occurred_at < e1.occurred_at + INTERVAL '5 MINUTE'
   AND e2.user_id = e1.user_id
   AND e2.action = 'email_open'
  LEFT JOIN tutorial.yammer_emails e3
    ON e3.occurred_at >= e2.occurred_at
   AND e3.occurred_at < e2.occurred_at + INTERVAL '5 MINUTE'
   AND e3.user_id = e2.user_id
   AND e3.action = 'email_clickthrough'
 WHERE e1.occurred_at >= '2014-06-01'
   AND e1.occurred_at < '2014-09-01'
   AND e1.action IN ('sent_weekly_digest','sent_reengagement_email')
 GROUP BY 1
       ) a
 ORDER BY 1
