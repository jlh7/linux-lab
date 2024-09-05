const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
require("dotenv").config();
const mysql = require("mysql2");

const app = express();
app.use(cors());
app.use(bodyParser.json());
// Middleware để parse JSON
app.use(express.json());
const PORT = process.env.PORT || 3030;

// Tạo kết nối tới MySQL
const db = mysql.createConnection({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "d3v",
  password: process.env.DB_PASSWORD || "devops2024",
  database: process.env.DB_NAME || "note_app",
  port: process.env.DB_PORT || 3306,
});

// Kết nối tới MySQL
db.connect((err) => {
  if (err) {
    console.error("Error connecting to MySQL: ");
    console.error(err.stack);
    console.error(err.message);
    return;
  }
  console.log("Connected to MySQL as id " + db.threadId);
  // Tạo bảng notes nếu chưa tồn tại
  db.query(
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

// Lấy tất cả các ghi chú
app.get("/", (req, res) => {
  db.query("SELECT * FROM notes", (error, results) => {
    if (error) {
      res.status(500).json({ message: error.message });
    } else {
      res.json(results);
    }
  });
});

// Lấy một ghi chú theo id
app.get("/:id", (req, res) => {
  const { id } = req.params;
  db.query("SELECT * FROM notes WHERE id = ?", [id], (error, results) => {
    if (error) {
      res.status(500).json({ message: error.message });
    } else if (results.length === 0) {
      res.status(404).json({ message: "Note not found" });
    } else {
      res.json(results[0]);
    }
  });
});

// Thêm một ghi chú mới
app.post("/", (req, res) => {
  const { title, content } = req.body;
  db.query(
    "INSERT INTO notes (title, content) VALUES (?, ?)",
    [title, content],
    (error, results) => {
      if (error) {
        res.status(500).json({ message: error.message });
      } else {
        res.status(201).json({ message: "Note created", id: results.insertId });
      }
    }
  );
});

// Cập nhật một ghi chú
app.put("/:id", (req, res) => {
  const { id } = req.params;
  const { title, content } = req.body;
  db.query(
    "UPDATE notes SET title = ?, content = ? WHERE id = ?",
    [title, content, id],
    (error, results) => {
      if (error) {
        res.status(500).json({ message: error.message });
      } else {
        res.json({ message: "Note updated" });
      }
    }
  );
});

// Xóa một ghi chú
app.delete("/:id", (req, res) => {
  const { id } = req.params;
  db.query("DELETE FROM notes WHERE id = ?", [id], (error, results) => {
    if (error) {
      res.status(500).json({ message: error.message });
    } else {
      res.json({ message: "Note deleted" });
    }
  });
});

// Khởi động server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
