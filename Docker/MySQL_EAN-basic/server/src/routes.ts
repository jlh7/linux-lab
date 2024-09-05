import * as express from "express";
import * as mysql from "mysql2";
import { MySQL_DB } from "./database";

export const NoteRouter = express.Router();

NoteRouter.use(express.json());

// Lấy tất cả các ghi chú
NoteRouter.get("/", (req, res) => {
  MySQL_DB.query("SELECT * FROM notes", (error, results) => {
    if (error) {
      res.status(500).json({ message: error.message });
    } else {
      res.json(results);
    }
  });
});

// Lấy một ghi chú theo id
NoteRouter.get("/:id", (req, res) => {
  const { id } = req.params;
  MySQL_DB.query(
    "SELECT * FROM notes WHERE id = ?",
    [id],
    (error, results: mysql.RowDataPacket[]) => {
      if (error) {
        res.status(500).json({ message: error.message });
      } else if (Array.isArray(results) && results.length === 0) {
        res.status(404).json({ message: "Note not found" });
      } else {
        res.json(results[0]);
      }
    }
  );
});

// Thêm một ghi chú mới
NoteRouter.post("/", (req, res) => {
  const { title, content } = req.body;
  MySQL_DB.query(
    "INSERT INTO notes (title, content) VALUES (?, ?)",
    [title, content],
    (error, results: mysql.OkPacket) => {
      if (error) {
        res.status(500).json({ message: error.message });
      } else {
        res.status(201).json({ message: "Note created", id: results.insertId });
      }
    }
  );
});

// Cập nhật một ghi chú
NoteRouter.put("/:id", (req, res) => {
  const { id } = req.params;
  const { title, content } = req.body;
  MySQL_DB.query(
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
NoteRouter.delete("/:id", (req, res) => {
  const { id } = req.params;
  MySQL_DB.query("DELETE FROM notes WHERE id = ?", [id], (error, results) => {
    if (error) {
      res.status(500).json({ message: error.message });
    } else {
      res.json({ message: "Note deleted" });
    }
  });
});
