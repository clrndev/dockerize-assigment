USE blog;
CREATE TABLE IF NOT EXISTS blog_posts (
    idblog_posts INT AUTO_INCREMENT PRIMARY KEY,
    title TEXT NOT NULL,
    post_text TEXT NOT NULL,
    date VARCHAR(255) NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    tags TEXT
);
INSERT INTO blog_posts (title, post_text, date, image_url, tags) 
VALUES (
    'First Post', 
    'This is the first post on the blog.', 
    '2024-09-17', 
    'https://lh5.googleusercontent.com/proxy/d5djxRXQzHOBRqUv2IEIjapejnA-UsaGRTwjTofpZbHvDAdPHKx_LkfZ3SQDZPPZiCFdKzrwQ26br8odn5nAdu9CHMw', 
    'first, post'
);
