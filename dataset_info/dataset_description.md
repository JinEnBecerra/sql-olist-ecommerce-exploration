# Dataset Description

## Overview
This project uses the Brazilian E-commerce Public Dataset (Olist), which contains real-world marketplace data from multiple sellers and customers across Brazil.  
The dataset includes information on orders, payments, products, sellers, reviews, and customer geographic information, making it suitable for exploring business performance, customer behavior, and operational patterns.

---

## Dataset Source
- Source: Kaggle — Olist Brazilian E-commerce Public Dataset
- Link: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

---

## Tables Used in This Project
The analysis focuses on the following core tables:

- `orders` — Order-level information, including timestamps and delivery status  
- `order_items` — Product-level details for each order  
- `payments` — Payment methods and transaction values  
- `customers` — Customer identifiers and geographic information  
- `products` — Product attributes and categories  
- `reviews` — Customer review scores and comments  
- `sellers` — Seller information and location data  


---

## Dataset Scope

The dataset contains **99,441 orders** placed between 2016 and 2018.

It consists of multiple relational tables representing different aspects of the marketplace, including order transactions, customer information, product details, seller data, payments, and customer reviews.

---

## Data Preparation

Prior to analysis:

- Joining multiple relational tables using SQL
- Data cleaning, including converting timestamp columns in the `orders` table from strings to proper datetime data types
- Creating derived metrics such as revenue, monthly sales, and other business performance metrics
