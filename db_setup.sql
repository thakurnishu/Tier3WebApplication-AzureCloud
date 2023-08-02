-- Create webappdb DATABASE
CREATE DATABASE webappdb;

-- Select webappdb DATABASE
USE webappdb;

-- Create Transactions Table
CREATE TABLE IF NOT EXISTS transactions(id INT NOT NULL
AUTO_INCREMENT, amount DECIMAL(10,2), description
VARCHAR(100), PRIMARY KEY(id));    

-- Insert Test Data in Table Transactions
INSERT INTO transactions (amount,description) VALUES ('400','groceries');   
