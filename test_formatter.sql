-- Test SQL file to verify formatter
select u.id,u.name,u.email,o.order_id,o.total from users u inner join orders o on u.id=o.user_id where u.active=1 and o.status='completed' order by o.created_at desc limit 10;

insert into users(name,email,created_at)values('John Doe','john@example.com',now());

update users set last_login=now(),login_count=login_count+1 where id=123;
