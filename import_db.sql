CREATE TABLE users  (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id TEXT NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  question_id INTEGER
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT NOT NULL,
  question_id INTEGER,
  user_id INTEGER,
  reply_id INTEGER,

  FOREIGN KEY(question_id) REFERENCES questions(id),
  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(reply_id) REFERENCES replies(id)
);

CREATE TABLE question_likes (
  user_id INTEGER,
  question_id INTEGER,

  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(question_id) REFERENCES questions(id)
);

INSERT INTO
  users(fname, lname)
VALUES
  ("Aivy", "Tran"),
  ("Brandon", "Hill");

INSERT INTO
  questions(title, body, user_id)
VALUES
  ("Question 1", "What''s your name?", 2),
  ("Question 2", "Where do you live?", 1);

INSERT INTO
  question_follows(user_id, question_id)
VALUES
  (1, 2),
  (2, 1);

INSERT INTO
  replies(body, question_id, user_id, reply_id)
VALUES
  ("Aivy!", 1, 2, NULL),
  ("My lasy name is Tran!", 1, 2, 1),
  ("Daly City", 2, 1, NULL),
  ("But I am from Vietnam", 2, 1, 3);

INSERT INTO
  question_likes(user_id, question_id)
VALUES
  (1, 1),
  (2, 1);
