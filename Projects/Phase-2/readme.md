# 🎵 SpotifyDB – SQL Project (100 Queries)

## 📌 Project Overview
This project is a **comprehensive SQL database practice project** inspired by a real-world music streaming platform like **Spotify**.  
It demonstrates my ability to work with **DDL, DML, DQL, constraints, clauses, operators, and advanced SQL concepts** using a well-structured relational database.

The project contains **100 SQL queries** organized into logical sections to showcase database design, data manipulation, data analysis, and optimization skills.

---

## 🧱 Database Concept
The database simulates a **music streaming ecosystem**, including:

- Users & subscriptions  
- Artists, albums, tracks & genres  
- Playlists & playlist statistics  
- Listening history  
- Payments, ads & advertisers  
- Concerts & ticketing  
- Reviews, devices & analytics  

It is designed to closely resemble **real production-level schemas**.

---



---

## 🧩 Query Breakdown

### 🔹 A. DDL – Data Definition Language (20 Queries)
Focuses on **schema design and database objects**:
- Creating tables, views, indexes
- Altering tables & adding constraints
- Triggers, stored procedures
- Temporary tables & audit logs

Examples:
- Schema audit logging
- Playlist statistics table
- Triggers for delete tracking
- Indexes for performance optimization

---

### 🔹 B. DML – Data Manipulation Language (20 Queries)
Handles **data insertion, updates, and deletion**:
- Insert users, artists, subscriptions, payments
- Update premium status, prices, followers
- Delete obsolete or test data

Examples:
- Upgrading users to premium
- Recording ad revenue
- Managing playlist lifecycle

---

### 🔹 C. DQL – Data Query Language (20 Queries)
Advanced **data retrieval and reporting**:
- Joins across multiple tables
- Aggregations & analytics
- Business insights

Examples:
- Top artists & tracks
- Revenue by subscription plan
- Playlist popularity analysis
- Listening history reports

---

### 🔹 D. Clauses & Constraints (20 Queries)
Demonstrates **SQL clauses and data integrity rules**:
- `WHERE`, `GROUP BY`, `HAVING`
- `ORDER BY`, `LIMIT`, `OFFSET`
- `CHECK`, `FOREIGN KEY`, `ON DELETE`
- Subqueries & conditional logic

Examples:
- Country-wise user distribution
- Genre analysis per track
- Constraint-based validations

---

### 🔹 E. Operators & Advanced SQL (20 Queries)
Covers **operators and advanced querying techniques**:
- Arithmetic & logical operators
- `IN`, `BETWEEN`, `LIKE`, `IS NULL`
- `CASE`, `COALESCE`
- `EXISTS`, `ANY`, `ALL`
- `UNION`, window functions

Examples:
- Popularity ranking using `RANK()`
- Revenue share calculations
- Categorizing tracks by popularity tier

---

## 🛠️ Technologies Used
- **SQL (MySQL-compatible syntax)**
- Relational Database Design
- Window Functions & Aggregations

> ⚠️ Some queries are **DB-vendor specific** (e.g., MySQL features like `AUTO_INCREMENT`, `DELIMITER`, `JSON`, window functions).

---

## 🎯 Skills Demonstrated
- Database schema design
- Query optimization & indexing
- Real-world business logic
- Data analytics using SQL
- Advanced joins & subqueries
- Constraints & data validation

---

## 🚀 How to Use
1. Create a database (example):
   ```sql
   CREATE DATABASE spotifydb;
   USE spotifydb;

## 📂 Project Structure

