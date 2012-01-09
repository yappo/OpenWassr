CREATE TABLE IF NOT EXISTS sessions (
    id           CHAR(72) PRIMARY KEY,
    session_data TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `favorite` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `tweet_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `from_user_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`,`created_at`),
  KEY `tweet_favorite` (`tweet_id`,`created_at`) USING BTREE,
  KEY `my_favorite` (`from_user_id`),
  KEY `given_favorite` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `friend` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `from_user_id` int(10) unsigned NOT NULL,
  `to_user_id` int(10) unsigned NOT NULL,
  `status` enum('accepted','requested') NOT NULL DEFAULT 'accepted',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED;

CREATE TABLE IF NOT EXISTS `message` (
  `id` int(10) unsigned NOT NULL,
  `created_at` datetime NOT NULL,
  `from_user_id` int(10) unsigned NOT NULL,
  `to_user_id` int(10) unsigned NOT NULL,
  `is_read` enum('no','yes') NOT NULL DEFAULT 'no',
  `body` varchar(255) NOT NULL,
  PRIMARY KEY (`id`,`created_at`),
  KEY `my_unread` (`to_user_id`,`is_read`),
  KEY `my_message` (`from_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `tweet` (
  `id` bigint(20) NOT NULL,
  `created_at` datetime NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `status` enum('deleted','friend','private','public') NOT NULL,
  `body` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`id`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `user` (
  `id` bigint(20) unsigned NOT NULL,
  `created_at` datetime NOT NULL,
  `username_hash` int(10) unsigned NOT NULL,
  `username` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `password_hash` int(10) unsigned NOT NULL,
  `password` varchar(255) NOT NULL,
  `email_hash` int(10) unsigned NOT NULL,
  `email` varchar(255) NOT NULL,
  `status` enum('unauthorized','registered','deleted') NOT NULL DEFAULT 'unauthorized',
  `full_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `profile` text NOT NULL,
  PRIMARY KEY (`id`,`created_at`),
  KEY `email_hash` (`email_hash`),
  KEY `user_hash` (`username_hash`,`password_hash`,`status`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

