

drop table if exists open_id_authentication_associations;
create table open_id_authentication_associations (
    id int not null auto_increment,
    server_url BLOB,
    handle VARCHAR(255),
    secret BLOB,
    issued INT(11),
    lifetime INT(11),
    assoc_type VARCHAR(255),
    primary key(id)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;;
 


drop table if exists open_id_authentication_settings;
create table open_id_authentication_settings (
    id int not null auto_increment,
    setting VARCHAR(255),
    value  BLOB,
    primary key(id)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;;



drop table if exists open_id_authentication_nonces;
create table open_id_authentication_nonces (
    nonce VARCHAR(255),
    created  INT(11),
    id int not null auto_increment,
    primary key(id)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;;
 
 




drop table if exists user_images;
create table user_images (
    id int not null auto_increment,
    user_id int not null,
    is_set char(1) null,
    extension varchar(4) null,
    constraint fk_user foreign key (user_id) references users(id),
    primary key(id)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;;


drop table if exists openid_logins;

create table openid_logins (
id int not null auto_increment,
open_id_url varchar(256)not null ,
persistent_login int null,
primary key(id)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;


ALTER TABLE users ADD INDEX ( open_id_url );


drop table if exists user_channels;
create table user_channels (
id int not null auto_increment,
user_id int,
user_screen_name varchar(50),
order_by varchar(50),
limit_popular_by varchar(50),
name varchar(128) not null,
tags_operator varchar(4),
filter_tags varchar(512),
user_groups text,
permalink varchar(256),
where_clause text,
order_clause text,
created_at DATETIME,
primary key(id)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

ALTER TABLE user_channels ADD INDEX ( user_id );

drop table if exists user_preferences;
create table user_preferences (
id int not null auto_increment,
user_id int not null,
view_order int null,
tag_cloud_order TINYINT NULL,
tag_cloud_type TINYINT NULL,
fp_ordering TINYINT NULL,
include_my_posts TINYINT NULL,
nw_post_order TINYINT NULL,
constraint fk_up_users foreign key (user_id) references users(id),
primary key(id)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;


drop table if exists categories;
create table categories (
id int not null auto_increment,
name varchar(100) not null,
description text not null,
appear_order int not null,
primary key(id)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

INSERT INTO `categories` ( `id` , `name` , `description` , `appear_order` )VALUES (NULL , 'Tecnologia', 'Tecnologia', '1');
INSERT INTO `categories` ( `id` , `name` , `description` , `appear_order` )VALUES (NULL , 'Economia', 'Economia', '2');
INSERT INTO `categories` ( `id` , `name` , `description` , `appear_order` )VALUES (NULL , 'Internacional', 'Internacional', '3');


drop table if exists posts;
create table posts (
id int not null auto_increment,
link_url varchar(255) not null,
description text null,
title varchar(255) not null,
created_at datetime null,
updated_at datetime null,
user_id int not null,
user_labelled varchar(600),
url_domain varchar(256) null,
original char null,
saved_by int null,
post_id int null,
votes int not null,
permalink varchar(260) not null,
constraint fk_posts_p foreign key (post_id) references posts(id),
constraint fk_posts foreign key (user_id) references users(id),
primary key(id)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

ALTER TABLE posts ADD INDEX ( link_url );
ALTER TABLE posts ADD INDEX ( permalink );

drop table if exists comments;
create table comments (
id int not null auto_increment,
comment text not null,
post_id int not null,
user_id int not null,
created_at datetime null,
votes int null,
constraint fk_comments_p foreign key (post_id) references posts(id),
constraint fk_comments_u foreign key (user_id) references users(id),
primary key(id)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;


drop table if exists comment_answers;
create table comment_answers (
id int not null auto_increment,
answer text not null,
comment_id int not null,
user_id int not null,
created_at datetime not null,
votes int not null,
constraint fk_comments_a_c foreign key (comment_id) references comments(id),
constraint fk_comments_a_u foreign key (user_id) references users(id),
primary key(id)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

drop table if exists answer_votes;

create table answer_votes (
answer_id int not null,
user_id int not null,
vote int not null,
voted_at datetime not null,
constraint fk_comments_answ_a foreign key (answer_id) references comment_answers(id),
constraint fk_comments_answ_u foreign key (user_id) references users(id),
primary key(answer_id,user_id)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;



drop table if exists comment_votes;
create table comment_votes (
comment_id int not null,
user_id int not null,
vote int not null,
voted_at datetime not null,
constraint fk_comments_votes_c foreign key (comment_id) references comments(id),
constraint fk_comments_votes_u foreign key (user_id) references users(id),
primary key(comment_id,user_id)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;


ALTER TABLE posts ADD INDEX ( comment_id );
ALTER TABLE posts ADD INDEX ( user_id );

drop table if exists labels;
create table labels (
id int not null auto_increment,
name varchar(256) not null,
label_count int not null,
created_at datetime null,
updated_at datetime null,
primary key(id)
)ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

ALTER TABLE labels ADD INDEX ( name );

drop table if exists user_votes;
create table user_votes (
user_id int not null,
post_id int not null,
voted_at datetime not null,
vote TINYINT NULL, 
constraint fk_user_votes foreign key (user_id) references users(id),
constraint fk_user_votes foreign key (post_id) references posts(id),
primary key(user_id,post_id)
)ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;



drop table if exists original_post_labels;
create table original_post_labels (
post_id int not null,
label_id int not null,
label_count int not null,
constraint fk_o_posts foreign key (post_id) references posts(id),
constraint fk_o_label foreign key (label_id) references labels(id),
primary key(post_id,label_id)
)ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

drop table if exists labels_posts;
create table labels_posts (
label_id int not null,
post_id int not null,
constraint fk_posts foreign key (post_id) references posts(id),
constraint fk_label foreign key (label_id) references labels(id),
primary key(post_id,label_id)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;


drop table if exists user_tags;
create table user_tags (
id int not null auto_increment,
user_id int not null,
name varchar(100) not null,
tag_count int not null,
constraint fk_user foreign key (user_id) references users(id),
primary key(id)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

ALTER TABLE user_tags ADD INDEX(name);



drop table if exists categories_posts;
create table categories_posts (
category_id int not null,
post_id int not null,
constraint fk_cp_category foreign key (category_id) references categories(id),
constraint fk_cp_post foreign key (post_id) references posts(id),
primary key(category_id,post_id)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;



drop table if exists user_friends;
create table user_friends (
    user_id INT not null,
    friend_id INT not null,
    is_fan TINYINT not null,
    fan_since DATETIME NULL ,
    friend_since DATETIME NULL,
    constraint fk_cp_user_friends_f foreign key (friend_id) references users(id),
	constraint fk_cp_user_friends_u foreign key (user_id) references userts(id),
	primary key(user_id,friend_id)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;


#drop table if exists usernetworks;
#create table usernetworks (
#id int not null auto_increment,
#user_id int not null,
#constraint fk_un_u foreign key (user_id) references users(id),
#primary key(id)
#)ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;


#drop table if exists usernetworks_users;
#create table usernetworks_users (
#    user_id int not null,
#    usernetwork_id int not null,
#    constraint fk_un_u3 foreign key (user_id) references users(id),
#    constraint fk_u_un foreign key (usernetwork_id) references usernetworks(id),
#    primary key(user_id,usernetwork_id)
#)ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;



drop table if exists rss_channels;
create table rss_channels (
id int not null auto_increment,
user_id int null,
name varchar(200) not null,
url varchar(256) not null,
created_at DATETIME not null,
where_clause varchar(256),
order_clause varchar(256),
primary key(id)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;


drop table if exists configurations;

create table configurations (
id int not null auto_increment,
posts_per_page int not null,
primary key(id)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

INSERT INTO configurations values(1,10);
INSERT INTO `users` (`id`, `email`, `first_name`, `last_name`, `screen_name`, `password_hash`, `password_salt`, `is_admin`) VALUES 
(4, 'joaomiguel.pereira@gmail.com', 'joaomrp', 'pereira', 'joaomp', 'c07f146000459ed8038e95be6b218e72405f7f47c2a1c39071069482cb7f852a', 'F4HqP93Q', '0'),
(3, 'jonas@jonas.com', 'jonas', 'jonas', 'jonas', 'a6a605b28b94a5eade62ea7912ddb064c0d51a0b00b0215b19f0d833a548e6c4', '4FKCa4X1', '1');


drop table if exists user_contacts;
create table user_contacts (
    id INT not null auto_increment,
    user_id INT not null,
    contact_email varchar(256) not null,
    constraint fk_user_contacts_user foreign key (user_id) references users(id),
	primary key(id)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;


DROP FUNCTION IF EXISTS count_comments;
--Utilizar o delimitador $ no phpMySql
CREATE FUNCTION `count_comments`(post_id INT) RETURNS int(11)
BEGIN
	DECLARE test INT;
	DECLARE is_original varchar(1);
	declare parent_post int;
	select original from posts p where p.id = post_id into is_original;
	if is_original = "1" then
		select count(*) from comments c where c.post_id = post_id into test;
		
	else 
		select p.post_id from posts p where p.id = post_id into parent_post; 
		select count(*) from comments c where c.post_id = parent_post into test;
		
	end if;
	
	RETURN test;
END$

-- *******

CREATE FUNCTION count_votes (post_id INT) RETURNS INT
BEGIN
	declare parent_post INT;
	declare votes INT;
	declare is_original varchar(1);
	select p.original from posts p where p.id = post_id into is_original;
	
	if is_original = "1" then
		select p.votes from posts p where p.id = post_id into votes;
	else
		select p.post_id from posts p where p.id = post_id into parent_post;
		select p.votes from posts p where p.id = parent_post into votes;
	end if;
	RETURN votes;
END$

-- *******************
CREATE FUNCTION count_saved_by (post_id INT) RETURNS INT
BEGIN
	declare saved_by INT;
	declare the_link_url varchar(256);
	select p.link_url from posts p where p.id = post_id into the_link_url;
	
	select count(*) from posts p where p.link_url = the_link_url into saved_by;
	
	RETURN saved_by-1;
END$

CREATE FUNCTION count_labels_applied(label_id int, link_url varchar(256)) RETURNS INT
BEGIN
	declare label_count int;
	select count(*) from labels_posts lp join posts p on (lp.post_id=p.id) where lp.label_id=label_id and p.link_url=link_url into label_count; 
	RETURN label_count;
END$


drop function has_label;

CREATE FUNCTION has_label (post_id INT, label VARCHAR(256)) RETURNS BOOLEAN
BEGIN
	DECLARE what_post INT;
	set what_post = -1;
	select alv.post_id from all_labels_v alv where UPPER(alv.name)=UPPER(label) and alv.post_id = post_id into what_post;
	
	if what_post <> -1 then
		RETURN true;
	else
		RETURN false;
	end if;
	
END$

drop function has_category;
CREATE FUNCTION has_category (id INT, cat_name VARCHAR(256)) RETURNS BOOLEAN
BEGIN
	DECLARE what_post INT;
	set what_post = -1;
	
	select cp.post_id from categories_posts cp left join categories c on (c.id=cp.category_id) where UPPER(c.name)=UPPER(cat_name) and cp.post_id=id into what_post;
	
	if what_post <> -1 then
		RETURN true;
	else
		RETURN false;
	end if;
	
	
END$

CREATE FUNCTION url_has_label (url varchar(256), label varchar(256)) RETURNS BOOLEAN
BEGIN
	declare cnt INT;
	select count(*) from labels_posts lp join posts p on (lp.post_id=p.id) join labels ll on (lp.label_id = ll.id) where lp.label_id=label_id  and upper(ll.name)=upper(label) and p.link_url=url into cnt;

	if cnt > 0 then
		return true;
	else
		return false;
	end if;
	
END$

drop function if exists is_friend;


CREATE function is_friend(the_friend_id INT, the_user_id INT, include_my_posts BOOLEAN) RETURNS BOOLEAN
BEGIN
	DECLARE the_friend INT;
	set the_friend = 0;
	
	IF the_friend_id = the_user_id and include_my_posts then
		RETURN TRUE;
	END IF;

	IF the_friend_id = the_user_id and include_my_posts=FALSE then
		RETURN FALSE;
	END IF;


	select count(user_id) from user_friends uf where uf.user_id=the_user_id and is_fan=0 and uf.friend_id=the_friend_id into the_friend;
	
	IF the_friend > 0 THEN
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;
	
	RETURN FALSE;
	
END$

drop function user_rank;

CREATE FUNCTION user_rank (user_id INT) RETURNS BIGINT
BEGIN
	declare posts INT;
	declare friends INT;
	declare votes_his_links INT;
	declare votes INT;
	declare comments INT;
	
	select count(*) from posts p where p.user_id = user_id into posts;
	select count(*) from user_friends p where p.user_id=user_id into friends;
	select count(*) from user_votes where post_id in (select id from posts p where p.user_id = user_id) into votes_his_links;
	select count(*) from user_votes uv where uv.user_id= user_id into votes;
	select count(*) from comments c where c.user_id = user_id into comments;
	RETURN (posts*3+friends*2+votes_his_links+votes+comments)/8;
END$


drop function last_activity;

CREATE FUNCTION last_activity (user_id INT) RETURNS DATETIME
BEGIN
	declare max_created_post DATETIME;
	declare max_created_comment DATETIME;
	declare max_voted_vote DATETIME;
	declare max DATETIME;
	select max(created_at) from posts p where p.user_id=user_id into max_created_post;

	select max(created_at) from comments c where c.user_id=user_id into max_created_comment;
	
	select max(voted_at) from user_votes uv where uv.user_id=user_id into max_voted_vote;
	set max = max_created_post;
	
	if (max_created_post > max_created_comment and max_created_post > max_voted_vote) then
		set max = max_created_post;
	end if;

	if (max_created_comment > max_created_post and max_created_comment > max_voted_vote) then
		set max = max_created_comment;
	end if;
	
	if (max_voted_vote > max_created_post and max_voted_vote > max_created_comment) then
		set max = max_voted_vote;
	end if;
	RETURN max;
END;


-- VIEWS
-- select p.id id, p.user_id, p.created_at, p.description, p.link_url, p.title title, count_comments(p.id) comments, count_votes(p.id) votes, count_saved_by(p.id) saved_by, ((count_comments(p.id)*3+count_votes(p.id)*4+count_saved_by(p.id)*5)/12) rank from posts p group by title 
drop VIEW user_v;

CREATE VIEW user_v AS
  select *, user_rank(id) as rank, last_activity(id) as last_activity from users;


drop view if exists user_posts_v; 
CREATE VIEW user_posts_v AS
  select p.id id,p.permalink, p.user_id, p.url_domain, p.original, p.created_at, p.description, p.link_url, p.title title, count_comments(p.id) comments, count_votes(p.id) votes, count_saved_by(p.id) saved_by, ((count_comments(p.id)*3+count_votes(p.id)*4+count_saved_by(p.id)*5)/12) rank from posts p;

drop view if exists all_labels_v;
CREATE VIEW all_labels_v AS
  select post_id, l.name from labels_posts lp join labels l on (l.id = lp.label_id);



drop view if exists labels_per_url_v;
CREATE VIEW labels_per_url_v AS
select l.name, lp.post_id post_id, lp.label_id label_id, p.link_url, count_labels_applied(lp.label_id,p.link_url) label_count from labels_posts lp join posts p on (p.id=lp.post_id) join labels l on (l.id=lp.label_id);

drop view if exists categories_per_url_v;
CREATE VIEW categories_per_url_v AS
select cp.category_id, c.name, p.id post_id, p.link_url from categories_posts cp join posts p on (p.id = cp.post_id) join categories c on (c.id = cp.category_id);
