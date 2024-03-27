import express, { Express, Request, Response } from "express";
import dotenv from "dotenv";
import path from 'path';
import fs from 'fs';
import { log } from "console";

dotenv.config();

const app: Express = express();
const port = process.env.PORT || 3000;

// Enable CORS
app.use((req: Request, res: Response, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET');
    res.header('Access-Control-Allow-Headers', 'Content-Type');
    next();
  });

// disable caching
app.disable('etag');

app.get("/", (req: Request, res: Response) => {
  res.send("Express + TypeScript Server!!!");
});

app.get('/lang/:langId', (req: Request, res: Response) => {
    const langId: string = req.params.langId;
    console.info('Request received for langId: ', langId);
  
    // Check if the langId parameter is provided
    if (!langId) {
      return res.status(400).json({ error: 'langId parameter is required' });
    }
  
    // Construct the file path based on langId
    const filePath = path.join(__dirname, 'languages', `${langId}.arb`);
    console.info('Requesting file: ', filePath)
    
    // Check if the file exists
    fs.stat(filePath, (err: NodeJS.ErrnoException | null, stats: fs.Stats | undefined) => {
        if (err || !stats || !stats.isFile()) {
          return res.status(404).json({ error: 'Translation file not found' });
        }
    
        // Read the JSON file and send it as response
        fs.readFile(filePath, 'utf8', (err: NodeJS.ErrnoException | null, data: string) => {
          if (err) {
            return res.status(500).json({ error: 'Error reading file' });
          }
          res.status(200).json(JSON.parse(data));
        });
      });
  });

app.listen(port, () => {
  console.log(`[server]: Server is running at http://localhost:${port}`);
}); 