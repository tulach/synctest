SELECT `rt`.`id`,`rt`.`rc_plan`,`rt`.`date`,`rt`.`rc_update_time`, `rt`.`rc_vehicle`, ST_AsBinary(`rt`.`geometry`) AS `geometry`,
    `rt`.`leave_depot`, `rt`.`arrive_depot`, `rt`.`rc_job`,
    `rt`.`status`,`rt`.`plan_status`, `rt`.`break_start`,`rt`.`break_finish`,
    `rt`.`break_reason`,`rt`.`break_estimate`,`rc_leave_depot_utc`,`rc_arrive_depot_utc`,`departure_depot`,
    `rt`.`tracking_id`,
    (SELECT(SELECT SUM(`t`.`cnt`) FROM (
        SELECT `v_id`,`rc_plan`,(COUNT(DISTINCT CONCAT(`rc_stop`,' ', (IF(`p`.`g_name` IS NOT NULL AND NOT (`p`.`g_name` = ''),`p`.`g_name`,IF(`p`.`name` IS NOT NULL AND NOT (`p`.`name` = ''),`p`.`name`,`p`.`trk`)))))) AS `cnt`
        FROM `v_rc_packages` as `p` WHERE (`p`.`p_type` = 'PICKUP'OR `p`.`state` IS NULL OR `p`.`state` IN ('LOADED','INPROCESS','UNLOADED')) GROUP BY `rc_stop`) `t`
        WHERE `v_routes`.`vehicle` =  `t`.`v_id` AND `v_routes`.`rc_plan` = `t`.`rc_plan`)
        FROM `v_routes` WHERE `v_routes`.`route_id` = `rt`.`id` GROUP BY `v_routes`.`route_id`
    ) AS `stops_no`,
    (SELECT(SELECT SUM(`t`.`pcs_cnt`) FROM (
        SELECT `v_id`,`rc_plan`,COUNT(trk) AS `pcs_cnt`
        FROM `v_rc_packages` as `p` WHERE ( p_type NOT IN ('PICKUP')AND (`p`.`state` IS NULL OR `p`.`state` IN ('LOADED','INPROCESS','UNLOADED'))) GROUP BY `v_id`) `t`
          WHERE `v_routes`.`vehicle` = `t`.`v_id` AND `v_routes`.`rc_plan` = `t`.`rc_plan`)
        FROM `v_routes` WHERE `v_routes`.`route_id` = `rt`.`id` GROUP BY `v_routes`.`route_id`
    ) AS `pcs_no`,
    (SELECT(SELECT SUM(`t`.`kgs_cnt`) FROM (
      SELECT `v_id`,`rc_plan`,SUM(`p`.`weight`) AS `kgs_cnt`
      FROM `v_rc_packages` as `p` WHERE ( p_type NOT IN ('PICKUP')AND (`p`.`state` IS NULL OR `p`.`state` IN ('LOADED','INPROCESS','UNLOADED'))) GROUP BY `v_id`) `t`
        WHERE `v_routes`.`vehicle` =  `t`.`v_id` AND `v_routes`.`rc_plan` = `t`.`rc_plan`)
      FROM `v_routes` WHERE `v_routes`.`route_id` = `rt`.`id` GROUP BY `v_routes`.`route_id`
    ) AS `kgs_no`,
    (SELECT(SELECT SUM(`t`.`m3_cnt`) FROM (
        SELECT `v_id`,`rc_plan`,SUM(IF(`p`.`length` IS NOT NULL AND `p`.`width` IS NOT NULL AND `p`.`height` IS NOT NULL,
        `p`.`length`*`p`.`width`*`p`.`height`,0)) AS `m3_cnt`
        FROM `v_rc_packages` as `p` WHERE ( p_type NOT IN ('PICKUP')AND (`p`.`state` IS NULL OR `p`.`state` IN ('LOADED','INPROCESS','UNLOADED'))) GROUP BY `v_id`) `t`
          WHERE `v_routes`.`vehicle` =  `t`.`v_id` AND `v_routes`.`rc_plan` = `t`.`rc_plan`)
        FROM `v_routes` WHERE `v_routes`.`route_id` = `rt`.`id` GROUP BY `v_routes`.`route_id`
    ) AS `m3_no`
FROM `rc_routes` AS `rt`
JOIN `rc_plans` `rcpl` ON `rt`.`rc_plan` = `rcpl`.`id`
JOIN `rc_vehicles` `vehicle` ON (`vehicle`.`id`,`vehicle`.`rc_plan`) = (`rt`.`rc_vehicle`,`rt`.`rc_plan`)
JOIN `plans` AS `pl` ON `rcpl`.`id_plan` = `pl`.`id`
WHERE `pl`.`id` = 117939 AND `rt`.`id` NOT IN ('30193')
    AND `rt`.`leave_depot` IS NULL AND `rt`.`arrive_depot` IS NULL AND `rt`.`plan_status` NOT IN ('COMPLETED','CLOSED','DISCARDED') AND `vehicle`.`cash` = '1'
ORDER BY `rt`.`id`;
