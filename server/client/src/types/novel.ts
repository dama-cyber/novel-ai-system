// server/client/src/types/novel.ts

export interface Project {
  name: string;
  path: string;
  metadata: {
    title: string;
    chapterCount: number;
    createdAt: string;
    lastModified: string;
    status: 'initialized' | 'outline_created' | 'chapters_writing' | 'completed';
    currentChapter: number;
    totalWords: number;
    genre: string;
  };
}

export interface Chapter {
  number: number;
  title: string;
  content: string;
  wordCount: number;
  createdAt: string;
  updatedAt: string;
}

export interface User {
  id: string;
  username: string;
}

export interface TokenUsage {
  used: number;
  available: number;
  limit: number;
  safetyMargin: number;
}

export interface Outline {
  projectName: string;
  chapters: Array<{
    number: number;
    title: string;
    summary: string;
    keyEvents: string[];
  }>;
}