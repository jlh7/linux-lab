import mysql from "mysql2";

export const MySQL_DB = mysql.createConnection({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "d3v",
  password: process.env.DB_PASSWORD || "devops2024",
  database: process.env.DB_NAME || "note_app",
  port: parseInt(process.env.DB_PORT || "33066"),
});

// Tạo hàm connectToDatabase để kết nối tới MySQL
export async function connectToDatabase(func: Function) {
  // Kết nối tới MySQL
  MySQL_DB.connect((err) => {
    if (err) {
      console.error("Error connecting to MySQL: ");
      console.error(err.stack);
      console.error(err.message);
      return;
    }
    console.log("Connected to MySQL as id " + MySQL_DB.threadId);
    // Tạo bảng notes nếu chưa tồn tại
    MySQL_DB.query(
      "CREATE TABLE IF NOT EXISTS notes (id INT AUTO_INCREMENT PRIMARY KEY, title VARCHAR(255) NOT NULL, content TEXT)",
      (error) => {
        if (error) {
          console.error('Error creating table "Notes": ' + error.stack);
        } else {
          console.log('Table "Notes" created successfully');
        }
      }
    );
  });

  func();
}
