CREATE TABLE IF NOT EXISTS simhyti_guidebook_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    label VARCHAR(120) NOT NULL,
    sort_order INT NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS simhyti_guidebook_pages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    title VARCHAR(160) NOT NULL,
    content LONGTEXT,
    page_type VARCHAR(40) NOT NULL DEFAULT 'text',
    sort_order INT NOT NULL DEFAULT 0,
    enabled TINYINT(1) NOT NULL DEFAULT 1,
    FOREIGN KEY (category_id) REFERENCES simhyti_guidebook_categories(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS simhyti_guidebook_points (
    id INT AUTO_INCREMENT PRIMARY KEY,
    page_id INT NOT NULL,
    label VARCHAR(160) NOT NULL,
    x DOUBLE NOT NULL,
    y DOUBLE NOT NULL,
    z DOUBLE NOT NULL,
    FOREIGN KEY (page_id) REFERENCES simhyti_guidebook_pages(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
