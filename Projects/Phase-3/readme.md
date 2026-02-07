# 🎧 SpotifyDB – Phase 3: Advanced SQL Queries

## 📌 Overview
**Phase 3** of the SpotifyDB project focuses on **advanced SQL querying techniques** used in real-world, production-scale databases.  
This phase goes beyond basic CRUD operations and demonstrates strong command over:

- Complex joins
- Correlated and nested subqueries
- Built-in SQL functions
- User-Defined Functions (UDFs)
- Analytical and business-driven queries

This phase is designed to reflect **mid-to-advanced SQL skills**, suitable for **Data Analyst, BI, and Backend roles**.

---

## 📂 Project Structure



---

## 🧠 Learning Objectives
By completing this phase, the project demonstrates the ability to:

- Work with **multi-table relational data**
- Write **performance-aware joins**
- Use **correlated subqueries**
- Apply **business logic inside SQL**
- Build reusable **User-Defined Functions**
- Handle **vendor-specific SQL features** (MySQL)

---

## 🧩 Query Classification (100 Queries)

### 🔹 A. JOINS (25 Queries)
Covers **all major join types** and real-life join scenarios:

**Included Concepts**
- `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`
- Simulated `FULL JOIN` using `UNION`
- `SELF JOIN`
- `CROSS JOIN`
- Multi-table joins
- Join + aggregation
- Join with filtering & NULL checks
- Window functions with joins (rank per album)

**Real-World Examples**
- Tracks with primary artists
- Mutual followers
- Playlist analytics
- Ad revenue per advertiser
- Concert attendees
- Contributor credits per track

---

### 🔹 B. SUBQUERIES (25 Queries)
Demonstrates **scalar, correlated, nested, and derived subqueries**:

**Included Concepts**
- Scalar subqueries in `SELECT`
- Correlated subqueries in `WHERE`
- `IN`, `EXISTS`, `NOT EXISTS`
- Subqueries with `HAVING`
- Subqueries in `FROM`
- `ANY` / `ALL`
- Percentile-based analytics (with fallback logic)

**Business Use Cases**
- Lifetime value per user
- Top listeners
- High-performing albums
- Tracks above album averages
- Artists with recent releases
- Advertisers with strong ROI

---

### 🔹 C. BUILT-IN FUNCTIONS (25 Queries)
Uses **MySQL built-in functions** for transformation and analytics:

**Function Categories**
- String: `UPPER`, `CONCAT`, `SUBSTRING`, `TRIM`
- Numeric: `ROUND`, `CEIL`, `FLOOR`, `POWER`
- Date/Time: `DATEDIFF`, `TIMESTAMPDIFF`, `DATE_FORMAT`
- Aggregates: `AVG`, `SUM`, `COUNT`
- JSON: `JSON_OBJECT`, `JSON_ARRAYAGG`
- Window functions: `SUM() OVER()`
- Regex & formatting utilities

**Examples**
- User age calculation
- Running totals
- JSON user summaries
- Playlist track arrays
- Artist name normalization

---

### 🔹 D. USER-DEFINED FUNCTIONS (UDFs) & USAGE (25 Queries)
Shows ability to **extend SQL using custom functions**, a key advanced skill.

**UDFs Created**
- `GetAnnualCost()` – annual subscription pricing
- `GetUserAge()` – age from DOB
- `PlatformShare()` – revenue split
- `PopTier()` – popularity classification
- `GetLifetimeValue()` – total user spend
- `RecommendScore()` – recommendation scoring
- `SafeDiv()` – division safety
- `PercentShare()` – percentage calculations
- `IsHighValueUser()` – business segmentation
- `NormalizeName()` – data cleaning

**Why This Matters**
- Demonstrates reusable logic
- Cleaner queries
- Business logic inside the database
- Production-ready SQL thinking

---

## 🛠️ Technologies & Compatibility
- **SQL (MySQL-style syntax)**
- Uses:
  - Window functions
  - JSON functions
  - Stored functions
- Notes:
  - `FULL JOIN` is simulated
  - Some queries are **vendor-specific**
  - Clearly commented fallbacks included

---

## 🎯 Skills Demonstrated
- Advanced joins & relational modeling
- Complex subquery patterns
- Analytical SQL
- Data transformation
- Custom SQL function development
- Business-oriented querying
- Performance-aware query design

---

## 🚀 How to Run
1. Ensure **Phase-2 schema** exists and is populated.
2. Use MySQL 8+ (recommended).
3. Execute queries **section by section**.
4. Review outputs for analytics insights.

---

## 💼 Ideal For
- SQL Portfolio Projects
- Data Analyst / BI Roles
- Backend Developer Interviews
- Advanced SQL Practice
- Academic Final Projects

---

## 👤 Author
**Mahak Sharma**  
Skills: SQL, Advanced Excel, Power BI, Frontend Development, AI Fundamentals  

---

## ⭐ Final Note
Phase 3 elevates this project from **“SQL practice”** to **“real-world database engineering”**.  
Together with Phase 2, this forms a **complete, end-to-end SQL portfolio** suitable for interviews and GitHub showcasing.
