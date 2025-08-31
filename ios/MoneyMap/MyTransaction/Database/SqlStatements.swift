//
//  SqlStatements.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 08/08/25.
//

struct SqlStatements{
    
    static func isTableExistsSQL(tableName: String) -> String {
        return """
            SELECT count(*) 
            FROM sqlite_master 
            WHERE type='table' AND name='\(tableName)'
            """
    }
    
    static func isViewExistsSQL(viewName: String) -> String {
        return """
            SELECT count(*) 
            FROM sqlite_master 
            WHERE type='view' AND name='\(viewName)'
            """
    }

    // tables
    static let create_transaction = """
            CREATE TABLE IF NOT EXISTS transactions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT NOT NULL,
              description TEXT,
              amount REAL NOT NULL,
              category TEXT DEFAULT 'NA',
              mode TEXT NOT NULL DEFAULT 'Online'
            )
            """
    
    static let create_wallet_transaction = """
            CREATE TABLE IF NOT EXISTS wallet (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              amount REAL NOT NULL,
              description TEXT NOT NULL DEFAULT 'NA',
              date TEXT NOT NULL,
              creation_date DATETIME DEFAULT (CURRENT_TIMESTAMP)
            );
            """
    
    static let create_inflow_transaction = """
            CREATE TABLE inflow (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                income_type TEXT NOT NULL,
                amount REAL NOT NULL,
                date TEXT NOT NULL,
                description TEXT DEFAULT 'NA',
                creation_date DATETIME DEFAULT CURRENT_TIMESTAMP
            );
            """

    // views
    
    static let create_current_balance_view = """
                CREATE VIEW IF NOT EXISTS current_balance AS
                SELECT ROUND((inflow_total - expense_total), 2) AS Current_Balance,
                inflow_total,
                expense_total
                FROM (
                    SELECT
                        (SELECT IFNULL(SUM(amount), 0) FROM inflow) AS inflow_total,
                        (SELECT IFNULL(SUM(amount), 0) FROM transactions) AS expense_total
                );
            """

    static let create_combine_balance_view = """
                  CREATE VIEW IF NOT EXISTS combine_balance AS
                   SELECT DATE('now') AS date,
                    cb.Current_Balance AS online,
                    (IFNULL((SELECT SUM(amount) FROM wallet), 0) * -1) AS wallet,
                    (cb.Current_Balance + (IFNULL((SELECT SUM(amount) FROM wallet), 0) * -1)) AS total_bal
                    FROM current_balance AS cb;
               """
    
    // insertion statements
    static let insert_transaction_records = """
            INSERT INTO transactions ('date','category','amount','description')
            VALUES ('1/5/25','Cash Withdrawal',1500,'Cash from ATM')
            """
    
    static let insert_wallet_transaction_records = """
            INSERT INTO wallet ('date','amount','description')
            VALUES ('1/5/25',-1500,'Initial Balance at the starting of the month')
            """
    
    static let insert_inflow_transaction_records = """
            INSERT INTO inflow ('date','income_type','amount','description')
            VALUES ('30/04/25','Salary',44424.00,'NA')
            """
}
