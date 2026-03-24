/*
delimiter ;
*/

/*
DROP DATABASE sh_skill_configs;

*/

CREATE DATABASE sh_skill_configs;

use sh_skill_configs;

drop function `num_configs_client`;
drop table `sh_config_heroes`;
drop table `sh_player_configs`;


CREATE TABLE IF NOT EXISTS `sh_player_configs` (
  `SH_KEY` varchar(64) binary NOT NULL default '',
  `PLAYER_NAME` varchar(64) NOT NULL default '',
  `CONFIG_ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`CONFIG_ID`)
) ENGINE = InnoDB COMMENT = 'SUPERHERO player configs table';

CREATE TABLE IF NOT EXISTS `sh_config_heroes` (
  `CONFIG_ID` int(10) unsigned NOT NULL,
  `HERO_NAME` varchar(25) NOT NULL default '',
  PRIMARY KEY (`CONFIG_ID`),
  CONSTRAINT FK_config_exists
  FOREIGN KEY (`CONFIG_ID`) REFERENCES `sh_player_configs`(`CONFIG_ID`)
) ENGINE = InnoDB COMMENT = 'SUPERHERO configs heroes table';

SET GLOBAL log_bin_trust_function_creators = 1;
delimiter //
CREATE FUNCTION `num_configs_client`(client_key varchar(64)) RETURNS int(10)
READS SQL DATA
BEGIN
DECLARE num int;
SELECT COUNT(*) into num
from `sh_player_configs`
where `sh_player_configs`.`SH_KEY`= client_key;
RETURN num;
END//

delimiter ;
SET GLOBAL log_bin_trust_function_creators = 0;
/*
 MyISAM engine will ignore any foreign key constraints. Always use InnoDB to create tables that use foreign keys between eachother
*/


/*

for include file:


CREATE TABLE IF NOT EXISTS `sh_savexp` (   `SH_KEY` varchar(32) binary NOT NULL default '',   `PLAYER_NAME` varchar(32) NOT NULL default '',   `LAST_PLAY_DATE` timestamp NOT NULL,   `XP` int(10) NOT NULL default 0,   `HUDHELP` tinyint (3) unsigned NOT NULL default 1,   `SKILL_COUNT` tinyint (3) unsigned NOT NULL default 0,   PRIMARY KEY (`SH_KEY`) ) ENGINE=MyISAM COMMENT='SUPERHERO experience Saving Table'

CREATE TABLE IF NOT EXISTS `sh_saveskills` (   `SH_KEY` varchar(32) binary NOT NULL default '',   `SKILL_NUMBER` tinyint(3) unsigned NOT NULL default 0,   `HERO_NAME` varchar(25) NOT NULL default '',   PRIMARY KEY  (`SH_KEY`,`SKILL_NUMBER`) ) ENGINE=MyISAM COMMENT='SUPERHERO Skill Saving Table'


*/
