// server/client/src/components/NovelProjectForm.tsx

import React, { useState } from 'react';
import { Project } from '../types/novel';

interface NovelProjectFormProps {
  onSubmit: (projectData: Omit<Project, 'path' | 'metadata'>) => void;
  onCancel?: () => void;
}

const NovelProjectForm: React.FC<NovelProjectFormProps> = ({ onSubmit, onCancel }) => {
  const [name, setName] = useState('');
  const [chapterCount, setChapterCount] = useState<number>(100);
  const [genre, setGenre] = useState('novel');

  const genres = [
    { value: 'novel', label: '小说' },
    { value: 'fantasy', label: '奇幻' },
    { value: 'sci-fi', label: '科幻' },
    { value: 'romance', label: '言情' },
    { value: 'mystery', label: '悬疑' },
  ];

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!name.trim()) {
      alert('请输入项目名称');
      return;
    }

    onSubmit({
      name: name.trim(),
      metadata: {
        title: name.trim(),
        chapterCount,
        createdAt: new Date().toISOString(),
        lastModified: new Date().toISOString(),
        status: 'initialized',
        currentChapter: 0,
        totalWords: 0,
        genre
      }
    });
  };

  return (
    <div className="max-w-md mx-auto p-6 bg-white rounded-lg shadow-md">
      <h2 className="text-2xl font-bold mb-6 text-gray-800">创建新项目</h2>
      
      <form onSubmit={handleSubmit}>
        <div className="mb-4">
          <label htmlFor="name" className="block text-gray-700 text-sm font-bold mb-2">
            项目名称
          </label>
          <input
            type="text"
            id="name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
            placeholder="输入项目名称"
          />
        </div>

        <div className="mb-4">
          <label htmlFor="chapterCount" className="block text-gray-700 text-sm font-bold mb-2">
            章节数量
          </label>
          <input
            type="number"
            id="chapterCount"
            value={chapterCount}
            onChange={(e) => setChapterCount(Number(e.target.value))}
            min="1"
            max="1000"
            className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
          />
        </div>

        <div className="mb-6">
          <label htmlFor="genre" className="block text-gray-700 text-sm font-bold mb-2">
            小说类型
          </label>
          <select
            id="genre"
            value={genre}
            onChange={(e) => setGenre(e.target.value)}
            className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
          >
            {genres.map((g) => (
              <option key={g.value} value={g.value}>
                {g.label}
              </option>
            ))}
          </select>
        </div>

        <div className="flex items-center justify-between">
          {onCancel && (
            <button
              type="button"
              onClick={onCancel}
              className="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
            >
              取消
            </button>
          )}
          <button
            type="submit"
            className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
          >
            创建项目
          </button>
        </div>
      </form>
    </div>
  );
};

export default NovelProjectForm;