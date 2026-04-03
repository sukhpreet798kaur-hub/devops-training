USE trainingdb;

-- Seed users
INSERT INTO users (name, email) VALUES
  ('Rohan Admin', 'rohan@example.com'),
  ('Sohan User',   'sohan@example.com');

-- Seed tickets
INSERT INTO tickets (user_id, title, description, status) VALUES
  (1, 'Cannot login', 'I forgot my password and cannot login.', 'open'),
  (2, 'Page loads slowly', 'Dashboard takes more than 5 seconds to load.', 'in_progress');
