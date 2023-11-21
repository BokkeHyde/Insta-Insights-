use ig_clone;

#User Engagement Analysis:
#1 Identify the top 10 users with the highest number of photos and likes.
select 
	u.username,
    count(distinct p.id) as photos_count,
    count(distinct l.user_id) as likes_count
from users u
join photos p on p.user_id = u.id
join likes l on l.photo_id = p.id
group by u.username
order by photos_count desc
limit 10;

#2 average number of likes and comments per photo for each user
select 
	u.username,
    round(avg(likes_per_photo), 1) as average_likes,
    round(avg(comments_per_photo), 1) as average_comments
from users u
left join
	 (select p.user_id, p.id as photo_id, 
      count(distinct l.user_id) as likes_per_photo, 
      count(distinct c.id) as comments_per_photo
      from photos p
      left join likes l on l.photo_id = p.id
      left join comments c on c.photo_id = p.id
      group by p.user_id, p.id
      ) stats
on stats.user_id = u.id
group by u.username
order by average_likes desc;

#3. Determine the most popular tags based on the number of photos and likes.
select 
	t.tag_name, 
    count(p.id) as photos_count, 
    count(distinct l.user_id) as likes_count
from photos p 
join likes l on l.photo_id = p.id
join photo_tags pt on pt.photo_id = p.id
join tags t on t.id = pt.tag_id
group by t.tag_name
order by photos_count desc;

#User Interaction and Relationships:
#4 Find the users who have the highest number of followers
select 
	u.username, f.followers_count
from users u
join    
	(select followee_id, 
			count(follower_id) as followers_count
	from follows
	group by followee_id) f
on f.followee_id = u.id
group by u.username
order by f.followers_count desc;
 
 #Tag Analysis:
 #5 Find the most commonly used tags and analyze their popularity.
select 
	t.tag_name, tg.tags_count
from tags t
join    
	(select tag_id, count(photo_id) as tags_count
	from photo_tags
	group by tag_id
	order by tags_count desc) tg
on tg.tag_id = t.id
group by t.tag_name, tg.tags_count
order by tg.tags_count desc;

#6 Identify tags that are frequently used together and suggest tag bundles.
select
	t1.id as tag1_id,
    t1.tag_name as tag1_name,
    t2.id as tag2_id,
    t2.tag_name as tag2_name,
    count(pt1.photo_id) as co_occurrence_count
from photo_tags pt1
join photo_tags pt2 on pt1.photo_id = pt2.photo_id 
					and pt1.tag_id < pt2.tag_id
join tags t1 on t1.id = pt1.tag_id
join tags t2 on t2.id = pt2.tag_id
group by tag1_id, tag1_name, tag2_id, tag2_name
having co_occurrence_count >= 2
order by co_occurrence_count desc;

