CREATE DATABASE tourism_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE tourism_db;

CREATE TABLE customers (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE,
  phone VARCHAR(30),
  country VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Таблица-справочник: destinations (странаё/город/регион
-- Тут храним места
CREATE TABLE destinations (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  country VARCHAR(100) NOT NULL,
  city VARCHAR(100) NOT NULL,
  region VARCHAR(100),
  description TEXT,
  UNIQUE KEY ux_destination_country_city (country, city)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Таблица-справочник: providers (туроператоры / агентства
CREATE TABLE providers (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  contact_email VARCHAR(255),
  contact_phone VARCHAR(30),
  website VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Таблица-справочник: services (виды услг
CREATE TABLE services (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  description TEXT,
  destination_id INT UNSIGNED NOT NULL,
  provider_id INT UNSIGNED,
  base_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  currency CHAR(3) NOT NULL DEFAULT 'EUR',
  duration_days INT UNSIGNED DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_services_destination FOREIGN KEY (destination_id) REFERENCES destinations(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_services_provider FOREIGN KEY (provider_id) REFERENCES providers(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Таблица переменных (транзакций): bookings — заказы/бронирования туров.
-- Здесь хранятся сами брони: кто, что, когда и т.д.
CREATE TABLE bookings (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  booking_code VARCHAR(50) NOT NULL UNIQUE,
  customer_id BIGINT UNSIGNED NOT NULL,
  service_id INT UNSIGNED NOT NULL,
  provider_id INT UNSIGNED, -- денормализовано для быстрого доступа (должно совпадать с service.provider_id)
  destination_id INT UNSIGNED, -- денормализовано для быстрого доступа (должно совпадать с service.destination_id)
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  people_count SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  total_price DECIMAL(12,2) NOT NULL,
  currency CHAR(3) NOT NULL DEFAULT 'EUR',
  status ENUM('pending','confirmed','cancelled','completed') NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_bookings_customer FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_bookings_service FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_bookings_provider FOREIGN KEY (provider_id) REFERENCES providers(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_bookings_destination FOREIGN KEY (destination_id) REFERENCES destinations(id) ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX ix_bookings_customer (customer_id),
  INDEX ix_bookings_service (service_id),
  INDEX ix_bookings_dates (start_date, end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Пример данных- можно вставить для теста и чтоб было с чем работать:
INSERT INTO destinations (country, city, region, description) VALUES
  ('Spain','Barcelona','Catalonia','Побережный город, известный архитектурой'),
  ('Russia','Moscow','Western Russia','Столица с музеями и достопримечательностями'),
  ('Greece','Santorini','Cyclades','Живописные острова');

INSERT INTO providers (name, contact_email, contact_phone, website) VALUES
  ('SunTravel Ltd','info@suntravel.example','+34 600000001','https://suntravel.example'),
  ('EuroTours S.A.','contact@eurotours.example','+33 700000002','https://eurotours.example');

INSERT INTO services (name, description, destination_id, provider_id, base_price, currency, duration_days) VALUES
  ('City sightseeing tour','Guided 1-day city tour with highlights', 1, 1, 65.00, 'EUR', 1),
  ('Romantic Paris package','3-day stay with city tour and dinner', 2, 2, 450.00, 'EUR', 3),
  ('Santorini honeymoon','5-day island package with boat trip', 3, 1, 1200.00, 'EUR', 5);

INSERT INTO customers (first_name, last_name, email, phone, country) VALUES
  ('Ivan','Petrov','ivan.petrov@example.com','+38160000001','Serbia'),
  ('Anna','Smirnova','anna.smirnova@example.com','+38160000002','Serbia');

INSERT INTO bookings (booking_code, customer_id, service_id, provider_id, destination_id, start_date, end_date, people_count, total_price, currency, status) VALUES
  ('BKG-20250901-001', 1, 1, 1, 1, '2025-09-01','2025-09-01', 2, 130.00, 'EUR', 'confirmed'),
  ('BKG-20251010-002', 2, 2, 2, 2, '2025-10-10','2025-10-13', 2, 900.00, 'EUR', 'pending');
