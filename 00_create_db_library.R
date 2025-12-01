# ==============================================================================
#              PROMPT LIBRARY - CREATION OF INITIAL DATABASE SCHEMA  
# ==============================================================================
# File: ./00_create_db_library.R
# Title: Step 00: Creation of Initial Database Schema for the library
# Author: Erica Ambrosio
# Purpose: Defines and executes the initial schema creation (tables and columns)
#          for the Prompt Library, using SQLite for local storage.
# Date: 2025-11-30
# R version: 4.5.1
# Note: Script created with the aid of Gemini.
# ==============================================================================

# --------------------------- 0. Environment Setup  ---------------------------- 

rm(list = ls()) 
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

options(encoding = "UTF-8")
options(scipen = 999)

library(DBI)
library(RSQLite)

# ----------------------- 1. Establish SQLite Connection ----------------------- 

# The file will be created in your working directory if it doesn't exist yet.
db_file <- "prompt_library.db" 

# The 'con' object (connection) will be used for all database operations.
con <- dbConnect(RSQLite::SQLite(), db_file)

# -------------------- 2. Define and Create Database Tables -------------------- 

# Executes DDL (Data Definition Language) to create the four necessary tables.
# The IF NOT EXISTS clause prevents errors if the script is run multiple times.

# 2.1. Lookup Table: Categories ------------------------------------------------
# Purpose: Stores unique categories (e.g., 'R Code Generation', 'Data
# Cleaning').
dbExecute(con, "
    CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY,
        category_name TEXT NOT NULL UNIQUE
    );
")

# 2.2. Lookup Table: Tags ------------------------------------------------------
# Purpose: Stores unique tags for granular searching (e.g., 'ggplot2',
# 'regression', 'translation').
dbExecute(con, "
    CREATE TABLE IF NOT EXISTS tags (
        id INTEGER PRIMARY KEY,
        tag_name TEXT NOT NULL UNIQUE
    );
")

# 2.3. Core Data Table: Prompts Library ----------------------------------------
# Purpose: Stores the main prompt data. Links to 'categories' via 'category_id'.
dbExecute(con, "
    CREATE TABLE IF NOT EXISTS prompts_library (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        prompt_text TEXT NOT NULL,
        category_id INTEGER,
        use_case TEXT,
        date_created TEXT,
        source TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id)
    );
")

# 2.4. Junction Table (Many-to-Many) -------------------------------------------
# Purpose: Maps prompts to multiple tags (and tags to multiple prompts). Ensures
# each prompt/tag combination is unique.
dbExecute(con, "
    CREATE TABLE IF NOT EXISTS prompt_tags (
        prompt_id INTEGER,
        tag_id INTEGER,
        PRIMARY KEY (prompt_id, tag_id),
        FOREIGN KEY (prompt_id) REFERENCES prompts_library(id),
        FOREIGN KEY (tag_id) REFERENCES tags(id)
    );
")

# --------------------------- 3. Save and Disconnect --------------------------- 

# !!! CRUCIAL STEP !!!
# This finalizes all transactions and releases the lock on the
# 'prompt_library.db' file.
# ALWAYS ensure this command runs at the end of the script to guarantee data
# is written and the database can be accessed by future sessions.

dbDisconnect(con)
rm(con)

# ---------------------------------- Outputs -----------------------------------
#
# Creates/Modifies: ./prompt_library.db
# Date Generated: 2025-11-30
#

# --------------------------------- Next Steps ---------------------------------
# 
# Proceed to 01_insert_prompts.R to insert data to the prompt library. 
# Note: That script will source the utility file located at
# functions/add_prompt.R.

# ------------------------------------------------------------------------------