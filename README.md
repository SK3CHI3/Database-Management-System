# Library Management System Database

A comprehensive MySQL database for managing a library's operations, including books, members, loans, and more.

## Description

This Library Management System database provides a complete solution for managing all aspects of a library's operations. It includes functionality for:

- Managing books, authors, publishers, and categories
- Tracking library members and their borrowing history
- Processing book loans, returns, and renewals
- Managing reservations for books
- Tracking fines for late returns, damaged books, or lost items
- Managing library branches and individual book copies
- Organizing library events and member registrations
- Generating reports on overdue books, member activity, and more

The database is designed with proper relationships (one-to-one, one-to-many, many-to-many) and includes constraints to maintain data integrity. It also includes views for common queries and stored procedures for common operations.

## Database Schema (ERD)

![Library Management System ERD](library_management_system_erd.png)

You can view the ERD diagram by opening the image file in the repository. The ERD shows the relationships between all tables in the database.

## Setup Instructions

1. Clone this repository:
```bash
git clone https://github.com/SK3CHI3/Database-Management-System.git
cd Database-Management-System
```

2. Import the SQL file into MySQL:
```bash
mysql -u username -p < library_management_system.sql
```

Or using MySQL Workbench:
- Open MySQL Workbench
- Connect to your MySQL server
- Go to File > Open SQL Script
- Select the library_management_system.sql file
- Execute the script (lightning bolt icon)

3. Verify the database was created:
```bash
mysql -u username -p
USE library_management;
SHOW TABLES;
```

## Features

### Tables
- **members**: Library patrons/users
- **books**: Book inventory
- **authors**: Book authors
- **publishers**: Book publishers
- **categories**: Book categories/genres
- **book_authors**: Junction table for many-to-many relationship between books and authors
- **book_categories**: Junction table for many-to-many relationship between books and categories
- **loans**: Records of books borrowed by members
- **reservations**: Book reservations by members
- **staff**: Library staff information
- **fines**: Fines for late returns
- **library_branches**: Different library locations
- **book_copies**: Individual copies of books
- **events**: Library events like book clubs, readings
- **event_registrations**: Member registrations for events

### Relationships
- **One-to-Many**: Publishers to Books, Members to Loans, Staff to Members, etc.
- **Many-to-Many**: Books to Authors, Books to Categories
- **Self-referencing**: Categories can have parent categories

### Advanced Features
1. **Constraints**: Primary keys, foreign keys, NOT NULL, UNIQUE, and CHECK constraints
2. **Triggers**: Automatic updates for book availability, fine generation, and event attendance
3. **Views**: Pre-defined views for common queries like overdue loans and book details
4. **Stored Procedures**: Functions for common operations like checking out books, returning books, and searching

### Data Integrity Features
1. **Validation**: Email format validation, phone number format validation, date validation
2. **Business Rules**: Enforced through constraints and triggers (e.g., available copies ≤ total copies)
3. **Automatic Timestamps**: Created and updated timestamps for audit trails