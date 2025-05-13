-- Library Management System Database
-- A comprehensive database for managing a library's operations

-- Drop database if it exists and create a new one
DROP DATABASE IF EXISTS library_management;
CREATE DATABASE library_management;
USE library_management;

-- Members table
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    date_of_birth DATE,
    join_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    membership_expiry DATE,
    status ENUM('active', 'suspended', 'expired') DEFAULT 'active' NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_email CHECK (email REGEXP '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$'),
    CONSTRAINT chk_phone CHECK (phone REGEXP '^[0-9\\-\\+\\(\\)\\s]{10,15}$')
);

-- Publishers table
CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    website VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Books table
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    subtitle VARCHAR(255),
    publication_date DATE,
    publication_year INT GENERATED ALWAYS AS (YEAR(publication_date)),
    edition VARCHAR(50),
    language VARCHAR(50) DEFAULT 'English',
    pages INT,
    description TEXT,
    publisher_id INT,
    cover_image_url VARCHAR(255),
    available_copies INT NOT NULL DEFAULT 0,
    total_copies INT NOT NULL DEFAULT 0,
    shelf_location VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON DELETE SET NULL,
    CONSTRAINT chk_copies CHECK (available_copies <= total_copies),
    CONSTRAINT chk_isbn CHECK (isbn REGEXP '^[0-9\\-]{10,17}$')
);

-- Authors table
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    biography TEXT,
    birth_date DATE,
    death_date DATE,
    nationality VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_dates CHECK (death_date IS NULL OR birth_date IS NULL OR death_date > birth_date)
);

-- Book-Author relationship (M:M)
CREATE TABLE book_authors (
    book_id INT,
    author_id INT,
    role ENUM('primary', 'co-author', 'editor', 'translator', 'illustrator') DEFAULT 'primary',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);

-- Categories table
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    parent_category_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id) ON DELETE SET NULL
);

-- Book-Category relationship (M:M)
CREATE TABLE book_categories (
    book_id INT,
    category_id INT,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (book_id, category_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE
);

-- Loans table
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    staff_id INT,
    loan_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    due_date DATE NOT NULL,
    return_date DATE,
    status ENUM('borrowed', 'returned', 'overdue', 'lost', 'damaged') DEFAULT 'borrowed' NOT NULL,
    renewal_count INT DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE RESTRICT,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE RESTRICT,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL,
    CONSTRAINT chk_loan_dates CHECK (due_date >= loan_date),
    CONSTRAINT chk_return_date CHECK (return_date IS NULL OR return_date >= loan_date)
);

-- Fines table
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    member_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    reason ENUM('late_return', 'damaged', 'lost', 'other') NOT NULL,
    description TEXT,
    issue_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    due_date DATE,
    paid BOOLEAN DEFAULT FALSE,
    payment_date DATE,
    payment_method ENUM('cash', 'credit_card', 'debit_card', 'online', 'waived') DEFAULT NULL,
    staff_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL,
    CONSTRAINT chk_payment_date CHECK (payment_date IS NULL OR payment_date >= issue_date)
);

-- Staff table
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    role ENUM('librarian', 'assistant', 'admin', 'manager', 'it_support') NOT NULL,
    department VARCHAR(50),
    hire_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    termination_date DATE,
    salary DECIMAL(10,2),
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_staff_email CHECK (email REGEXP '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$'),
    CONSTRAINT chk_staff_phone CHECK (phone REGEXP '^[0-9\\-\\+\\(\\)\\s]{10,15}$'),
    CONSTRAINT chk_staff_dates CHECK (termination_date IS NULL OR termination_date >= hire_date)
);

-- Reservations table
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    staff_id INT,
    reservation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expiry_date DATETIME,
    fulfillment_date DATETIME,
    cancellation_date DATETIME,
    cancellation_reason TEXT,
    status ENUM('pending', 'fulfilled', 'cancelled', 'expired') DEFAULT 'pending' NOT NULL,
    notification_sent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL,
    CONSTRAINT chk_reservation_dates CHECK (
        (fulfillment_date IS NULL OR fulfillment_date >= reservation_date) AND
        (cancellation_date IS NULL OR cancellation_date >= reservation_date) AND
        (expiry_date IS NULL OR expiry_date >= reservation_date)
    )
);

-- Library Branches table
CREATE TABLE library_branches (
    branch_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    manager_id INT,
    opening_hours TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (manager_id) REFERENCES staff(staff_id) ON DELETE SET NULL
);

-- Book Copies table (to track individual copies of books)
CREATE TABLE book_copies (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    branch_id INT NOT NULL,
    acquisition_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    acquisition_price DECIMAL(10,2),
    condition ENUM('new', 'good', 'fair', 'poor', 'damaged', 'lost') DEFAULT 'new',
    status ENUM('available', 'on_loan', 'on_hold', 'in_repair', 'lost', 'discarded') DEFAULT 'available',
    barcode VARCHAR(50) UNIQUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (branch_id) REFERENCES library_branches(branch_id) ON DELETE CASCADE
);

-- Events table (for library events like book clubs, readings, etc.)
CREATE TABLE events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    start_datetime DATETIME NOT NULL,
    end_datetime DATETIME NOT NULL,
    branch_id INT,
    max_attendees INT,
    current_attendees INT DEFAULT 0,
    organizer_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (branch_id) REFERENCES library_branches(branch_id) ON DELETE SET NULL,
    FOREIGN KEY (organizer_id) REFERENCES staff(staff_id) ON DELETE SET NULL,
    CONSTRAINT chk_event_dates CHECK (end_datetime > start_datetime),
    CONSTRAINT chk_attendees CHECK (current_attendees <= max_attendees)
);

-- Event Registrations table
CREATE TABLE event_registrations (
    registration_id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    member_id INT NOT NULL,
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    attendance_status ENUM('registered', 'attended', 'no_show', 'cancelled') DEFAULT 'registered',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    UNIQUE KEY (event_id, member_id)
);

-- Create triggers to update available_copies when books are borrowed or returned
DELIMITER //

CREATE TRIGGER after_loan_insert
AFTER INSERT ON loans
FOR EACH ROW
BEGIN
    IF NEW.status = 'borrowed' THEN
        UPDATE books SET available_copies = available_copies - 1
        WHERE book_id = NEW.book_id AND available_copies > 0;
    END IF;
END //

CREATE TRIGGER after_loan_update
AFTER UPDATE ON loans
FOR EACH ROW
BEGIN
    IF OLD.status = 'borrowed' AND (NEW.status = 'returned' OR NEW.status = 'lost' OR NEW.status = 'damaged') THEN
        IF NEW.status = 'returned' THEN
            UPDATE books SET available_copies = available_copies + 1
            WHERE book_id = NEW.book_id;
        END IF;

        -- Automatically create a fine for overdue books
        IF NEW.status = 'returned' AND NEW.return_date > NEW.due_date THEN
            INSERT INTO fines (loan_id, member_id, amount, reason, issue_date)
            VALUES (NEW.loan_id, NEW.member_id,
                   (DATEDIFF(NEW.return_date, NEW.due_date) * 0.50), -- $0.50 per day
                   'late_return', CURRENT_DATE);
        END IF;

        -- Automatically create a fine for lost books
        IF NEW.status = 'lost' THEN
            INSERT INTO fines (loan_id, member_id, amount, reason, issue_date)
            VALUES (NEW.loan_id, NEW.member_id,
                   (SELECT COALESCE(
                       (SELECT acquisition_price FROM book_copies WHERE book_id = NEW.book_id LIMIT 1),
                       25.00) -- Default replacement fee if acquisition price not available
                   ),
                   'lost', CURRENT_DATE);
        END IF;

        -- Automatically create a fine for damaged books
        IF NEW.status = 'damaged' THEN
            INSERT INTO fines (loan_id, member_id, amount, reason, issue_date)
            VALUES (NEW.loan_id, NEW.member_id, 10.00, 'damaged', CURRENT_DATE);
        END IF;
    END IF;
END //

-- Trigger to update event attendee count
CREATE TRIGGER after_registration_insert
AFTER INSERT ON event_registrations
FOR EACH ROW
BEGIN
    UPDATE events SET current_attendees = current_attendees + 1
    WHERE event_id = NEW.event_id AND current_attendees < max_attendees;
END //

CREATE TRIGGER after_registration_update
AFTER UPDATE ON event_registrations
FOR EACH ROW
BEGIN
    IF OLD.attendance_status = 'registered' AND NEW.attendance_status = 'cancelled' THEN
        UPDATE events SET current_attendees = current_attendees - 1
        WHERE event_id = NEW.event_id AND current_attendees > 0;
    END IF;

    IF OLD.attendance_status = 'cancelled' AND NEW.attendance_status = 'registered' THEN
        UPDATE events SET current_attendees = current_attendees + 1
        WHERE event_id = NEW.event_id AND current_attendees < max_attendees;
    END IF;
END //

-- Create views for common queries
CREATE VIEW vw_book_details AS
SELECT
    b.book_id,
    b.title,
    b.subtitle,
    b.isbn,
    b.publication_date,
    b.publication_year,
    b.edition,
    b.language,
    b.pages,
    b.description,
    p.name AS publisher_name,
    GROUP_CONCAT(DISTINCT CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ') AS authors,
    GROUP_CONCAT(DISTINCT c.name SEPARATOR ', ') AS categories,
    b.total_copies,
    b.available_copies,
    b.shelf_location
FROM
    books b
LEFT JOIN publishers p ON b.publisher_id = p.publisher_id
LEFT JOIN book_authors ba ON b.book_id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.author_id
LEFT JOIN book_categories bc ON b.book_id = bc.book_id
LEFT JOIN categories c ON bc.category_id = c.category_id
GROUP BY b.book_id;

CREATE VIEW vw_overdue_loans AS
SELECT
    l.loan_id,
    b.title AS book_title,
    b.isbn,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    m.email AS member_email,
    m.phone AS member_phone,
    l.loan_date,
    l.due_date,
    DATEDIFF(CURRENT_DATE, l.due_date) AS days_overdue,
    DATEDIFF(CURRENT_DATE, l.due_date) * 0.50 AS estimated_fine
FROM
    loans l
JOIN books b ON l.book_id = b.book_id
JOIN members m ON l.member_id = m.member_id
WHERE
    l.status = 'borrowed'
    AND l.due_date < CURRENT_DATE
ORDER BY days_overdue DESC;

CREATE VIEW vw_member_loan_history AS
SELECT
    m.member_id,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    b.title AS book_title,
    b.isbn,
    l.loan_date,
    l.due_date,
    l.return_date,
    l.status,
    CASE
        WHEN l.status = 'borrowed' AND l.due_date < CURRENT_DATE THEN 'overdue'
        WHEN l.status = 'borrowed' THEN 'active'
        ELSE l.status
    END AS loan_status,
    CASE
        WHEN l.status = 'borrowed' AND l.due_date < CURRENT_DATE
        THEN DATEDIFF(CURRENT_DATE, l.due_date) * 0.50
        ELSE 0
    END AS potential_fine
FROM
    members m
JOIN loans l ON m.member_id = l.member_id
JOIN books b ON l.book_id = b.book_id
ORDER BY m.member_id, l.loan_date DESC;

-- Create stored procedures for common operations
DELIMITER //

-- Procedure to check out a book
CREATE PROCEDURE sp_check_out_book(
    IN p_book_id INT,
    IN p_member_id INT,
    IN p_staff_id INT,
    IN p_loan_days INT
)
BEGIN
    DECLARE v_available_copies INT;
    DECLARE v_member_status VARCHAR(20);
    DECLARE v_active_loans INT;
    DECLARE v_has_overdue BOOLEAN DEFAULT FALSE;
    DECLARE v_has_unpaid_fines BOOLEAN DEFAULT FALSE;

    -- Check if book is available
    SELECT available_copies INTO v_available_copies FROM books WHERE book_id = p_book_id;

    -- Check member status
    SELECT status INTO v_member_status FROM members WHERE member_id = p_member_id;

    -- Count active loans for this member
    SELECT COUNT(*) INTO v_active_loans FROM loans
    WHERE member_id = p_member_id AND status = 'borrowed';

    -- Check for overdue books
    SELECT EXISTS(
        SELECT 1 FROM loans
        WHERE member_id = p_member_id
        AND status = 'borrowed'
        AND due_date < CURRENT_DATE
    ) INTO v_has_overdue;

    -- Check for unpaid fines
    SELECT EXISTS(
        SELECT 1 FROM fines
        WHERE member_id = p_member_id
        AND paid = FALSE
    ) INTO v_has_unpaid_fines;

    -- Validate conditions
    IF v_available_copies <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book is not available for checkout';
    ELSEIF v_member_status != 'active' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Member account is not active';
    ELSEIF v_active_loans >= 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Member has reached maximum number of loans';
    ELSEIF v_has_overdue = TRUE THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Member has overdue books';
    ELSEIF v_has_unpaid_fines = TRUE THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Member has unpaid fines';
    ELSE
        -- Create the loan
        INSERT INTO loans (book_id, member_id, staff_id, loan_date, due_date, status)
        VALUES (p_book_id, p_member_id, p_staff_id, CURRENT_DATE,
                DATE_ADD(CURRENT_DATE, INTERVAL p_loan_days DAY), 'borrowed');

        -- Update book copy status if using individual copies
        -- This would be handled by the after_loan_insert trigger

        SELECT 'Book checked out successfully' AS message;
    END IF;
END //

-- Procedure to return a book
CREATE PROCEDURE sp_return_book(
    IN p_loan_id INT,
    IN p_condition VARCHAR(20)
)
BEGIN
    DECLARE v_book_id INT;
    DECLARE v_current_status VARCHAR(20);
    DECLARE v_due_date DATE;
    DECLARE v_is_overdue BOOLEAN DEFAULT FALSE;

    -- Get loan information
    SELECT book_id, status, due_date INTO v_book_id, v_current_status, v_due_date
    FROM loans WHERE loan_id = p_loan_id;

    -- Check if loan exists and is active
    IF v_current_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loan not found';
    ELSEIF v_current_status != 'borrowed' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book is not currently borrowed';
    ELSE
        -- Check if book is overdue
        SET v_is_overdue = (v_due_date < CURRENT_DATE);

        -- Update loan status based on condition
        IF p_condition = 'good' THEN
            UPDATE loans
            SET status = 'returned', return_date = CURRENT_DATE
            WHERE loan_id = p_loan_id;
        ELSEIF p_condition = 'damaged' THEN
            UPDATE loans
            SET status = 'damaged', return_date = CURRENT_DATE
            WHERE loan_id = p_loan_id;
        ELSEIF p_condition = 'lost' THEN
            UPDATE loans
            SET status = 'lost', return_date = CURRENT_DATE
            WHERE loan_id = p_loan_id;
        ELSE
            UPDATE loans
            SET status = 'returned', return_date = CURRENT_DATE
            WHERE loan_id = p_loan_id;
        END IF;

        -- Fines are handled by the after_loan_update trigger

        SELECT 'Book returned successfully' AS message;
    END IF;
END //

-- Procedure to renew a loan
CREATE PROCEDURE sp_renew_loan(
    IN p_loan_id INT,
    IN p_extension_days INT
)
BEGIN
    DECLARE v_current_status VARCHAR(20);
    DECLARE v_due_date DATE;
    DECLARE v_is_overdue BOOLEAN DEFAULT FALSE;
    DECLARE v_renewal_count INT;

    -- Get loan information
    SELECT status, due_date, IFNULL(renewal_count, 0)
    INTO v_current_status, v_due_date, v_renewal_count
    FROM loans WHERE loan_id = p_loan_id;

    -- Check if loan exists and is active
    IF v_current_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loan not found';
    ELSEIF v_current_status != 'borrowed' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book is not currently borrowed';
    ELSEIF v_renewal_count >= 2 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Maximum renewal limit reached';
    ELSE
        -- Check if book is overdue
        SET v_is_overdue = (v_due_date < CURRENT_DATE);

        IF v_is_overdue THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Overdue loans cannot be renewed';
        ELSE
            -- Update due date
            UPDATE loans
            SET due_date = DATE_ADD(due_date, INTERVAL p_extension_days DAY),
                renewal_count = IFNULL(renewal_count, 0) + 1
            WHERE loan_id = p_loan_id;

            SELECT 'Loan renewed successfully' AS message;
        END IF;
    END IF;
END //

-- Procedure to search books
CREATE PROCEDURE sp_search_books(
    IN p_search_term VARCHAR(255),
    IN p_category_id INT,
    IN p_author_id INT,
    IN p_available_only BOOLEAN
)
BEGIN
    SELECT
        b.book_id,
        b.title,
        b.isbn,
        b.publication_year,
        GROUP_CONCAT(DISTINCT CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ') AS authors,
        GROUP_CONCAT(DISTINCT c.name SEPARATOR ', ') AS categories,
        b.available_copies,
        b.total_copies
    FROM
        books b
    LEFT JOIN book_authors ba ON b.book_id = ba.book_id
    LEFT JOIN authors a ON ba.author_id = a.author_id
    LEFT JOIN book_categories bc ON b.book_id = bc.book_id
    LEFT JOIN categories c ON bc.category_id = c.category_id
    WHERE
        (p_search_term IS NULL OR
         b.title LIKE CONCAT('%', p_search_term, '%') OR
         b.isbn LIKE CONCAT('%', p_search_term, '%') OR
         CONCAT(a.first_name, ' ', a.last_name) LIKE CONCAT('%', p_search_term, '%'))
        AND (p_category_id IS NULL OR c.category_id = p_category_id)
        AND (p_author_id IS NULL OR a.author_id = p_author_id)
        AND (p_available_only = FALSE OR b.available_copies > 0)
    GROUP BY b.book_id
    ORDER BY b.title;
END //

DELIMITER ;