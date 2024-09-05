import express from "express";
import cors from "cors";
import bodyParser from "body-parser";
import * as dotenv from "dotenv";
import { connectToDatabase } from "./database";
import { NoteRouter } from "./routes";

dotenv.config();

const PORT = process.env.PORT || 3030;

connectToDatabase(() => {
  const app = express();
  app.use(cors());
  app.use(bodyParser.json());
  app.use("/", NoteRouter);

  // Khởi động server
  app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
  });
});
