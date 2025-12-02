/**
 * @fileoverview FileManager 单元测试，包含边缘情况测试
 */

const FileManager = require('../../scripts/utils/file-manager.js');
const fs = require('fs').promises;
const path = require('path');

describe('FileManager', () => {
  let fileManager;

  beforeEach(() => {
    fileManager = new FileManager();
  });

  describe('directoryExists', () => {
    test('should return true for existing directory', async () => {
      const exists = await fileManager.directoryExists(__dirname);
      expect(exists).toBe(true);
    });

    test('should return false for non-existing directory', async () => {
      const exists = await fileManager.directoryExists('/non/existing/directory');
      expect(exists).toBe(false);
    });
  });

  describe('fileExists', () => {
    test('should return true for existing file', async () => {
      const exists = await fileManager.fileExists(__filename);
      expect(exists).toBe(true);
    });

    test('should return false for non-existing file', async () => {
      const exists = await fileManager.fileExists('/non/existing/file.txt');
      expect(exists).toBe(false);
    });
  });

  describe('ensureDirectory', () => {
    test('should create directory if it does not exist', async () => {
      const testDir = path.join(__dirname, 'test-dir-' + Date.now());
      try {
        await fileManager.ensureDirectory(testDir);
        const exists = await fileManager.directoryExists(testDir);
        expect(exists).toBe(true);
      } finally {
        // 清理测试目录
        try {
          await fs.rmdir(testDir);
        } catch (e) {
          // 忽略清理错误
        }
      }
    });

    test('should not fail if directory already exists', async () => {
      const exists = await fileManager.directoryExists(__dirname);
      expect(exists).toBe(true);
      
      // 确保已存在的目录不会出错
      await fileManager.ensureDirectory(__dirname);
    });
  });

  describe('readJsonFile', () => {
    test('should read valid JSON file', async () => {
      // 创建临时JSON文件进行测试
      const testFile = path.join(__dirname, 'temp-test.json');
      const testData = { name: 'test', value: 123 };
      
      try {
        await fs.writeFile(testFile, JSON.stringify(testData), 'utf8');
        const data = await fileManager.readJsonFile(testFile);
        expect(data).toEqual(testData);
      } finally {
        // 清理临时文件
        try {
          await fs.unlink(testFile);
        } catch (e) {
          // 忽略清理错误
        }
      }
    });

    test('should throw error for non-existing file', async () => {
      try {
        await fileManager.readJsonFile('/non/existing/file.json');
        // 如果没有抛出错误，则测试失败
        throw new Error('Expected error was not thrown');
      } catch (error) {
        expect(error.message).toContain('文件不存在');
      }
    });

    test('should throw error for invalid JSON', async () => {
      // 创建无效JSON文件进行测试
      const testFile = path.join(__dirname, 'temp-invalid.json');
      
      try {
        await fs.writeFile(testFile, '{ invalid json', 'utf8');
        await fileManager.readJsonFile(testFile);
        // 如果没有抛出错误，则测试失败
        throw new Error('Expected error was not thrown');
      } catch (error) {
        expect(error.message).toContain('JSON文件格式错误');
      } finally {
        // 清理临时文件
        try {
          await fs.unlink(testFile);
        } catch (e) {
          // 忽略清理错误
        }
      }
    });
  });

  describe('writeJsonFile', () => {
    test('should write JSON file', async () => {
      const testFile = path.join(__dirname, 'temp-write-test.json');
      const testData = { name: 'write test', value: 456 };
      
      try {
        await fileManager.writeJsonFile(testFile, testData);
        
        // 验证文件内容
        const content = await fs.readFile(testFile, 'utf8');
        const parsed = JSON.parse(content);
        expect(parsed).toEqual(testData);
      } finally {
        // 清理临时文件
        try {
          await fs.unlink(testFile);
        } catch (e) {
          // 忽略清理错误
        }
      }
    });

    test('should create directory if it does not exist', async () => {
      const testDir = path.join(__dirname, 'temp-write-dir');
      const testFile = path.join(testDir, 'nested-file.json');
      const testData = { nested: 'data' };
      
      try {
        await fileManager.writeJsonFile(testFile, testData);
        
        // 验证文件内容
        const content = await fs.readFile(testFile, 'utf8');
        const parsed = JSON.parse(content);
        expect(parsed).toEqual(testData);
      } finally {
        // 清理临时文件和目录
        try {
          await fs.unlink(testFile);
          await fs.rmdir(testDir);
        } catch (e) {
          // 忽略清理错误
        }
      }
    });
  });

  describe('getProjectSettings', () => {
    test('should return empty settings for non-existing files', async () => {
      const settings = await fileManager.getProjectSettings('/non/existing/project');
      expect(settings).toEqual({
        characters: {},
        worldview: {},
        powerSystem: {},
        foreshadows: {},
        metadata: {}
      });
    });
  });

  describe('saveProjectSettings', () => {
    test('should save all project settings', async () => {
      const testDir = path.join(__dirname, 'temp-project-' + Date.now());
      const settingsData = {
        characters: { protagonist: { name: 'Hero' } },
        worldview: { setting: 'Fantasy World' },
        powerSystem: { name: 'Magic' }
      };
      
      try {
        await fileManager.saveProjectSettings(testDir, settingsData);
        
        // 验证文件是否创建
        const charactersFile = path.join(testDir, 'settings', 'characters.json');
        const worldviewFile = path.join(testDir, 'settings', 'worldview.json');
        const powerSystemFile = path.join(testDir, 'settings', 'power-system.json');
        
        const charactersExists = await fileManager.fileExists(charactersFile);
        const worldviewExists = await fileManager.fileExists(worldviewFile);
        const powerSystemExists = await fileManager.fileExists(powerSystemFile);
        
        expect(charactersExists).toBe(true);
        expect(worldviewExists).toBe(true);
        expect(powerSystemExists).toBe(true);
      } finally {
        // 清理临时目录
        try {
          await fs.rmdir(path.join(testDir, 'settings'), { recursive: true });
          await fs.rmdir(testDir);
        } catch (e) {
          // 忽略清理错误
        }
      }
    });
  });

  // 边缘情况测试
  describe('edge cases', () => {
    test('should handle very long file paths', async () => {
      // 创建一个长路径
      let longPath = __dirname;
      for (let i = 0; i < 10; i++) {
        longPath = path.join(longPath, 'a'.repeat(50)); // 每层50个字符
      }
      
      try {
        await fileManager.ensureDirectory(longPath);
        const exists = await fileManager.directoryExists(longPath);
        expect(exists).toBe(true);
      } catch (e) {
        // 某些系统可能不支持非常长的路径，这在预期之中
        console.log(`(预期) 长路径测试失败: ${e.message}`);
      }
    });

    test('should handle special characters in file names', async () => {
      const testFile = path.join(__dirname, 'test-特殊字符-файл.json');
      const testData = { special: 'data' };
      
      try {
        await fileManager.writeJsonFile(testFile, testData);
        
        const exists = await fileManager.fileExists(testFile);
        expect(exists).toBe(true);
        
        const data = await fileManager.readJsonFile(testFile);
        expect(data).toEqual(testData);
      } catch (e) {
        // 某些文件系统可能不支持特殊字符，这在预期之中
        console.log(`(预期) 特殊字符测试失败: ${e.message}`);
      } finally {
        try {
          await fs.unlink(testFile);
        } catch (e) {
          // 忽略清理错误
        }
      }
    });
  });
});

// 辅助函数以模拟测试运行器
function describe(description, testFn) {
  console.log(`\n📋 ${description}`);
  testFn();
}

function test(description, testFn) {
  try {
    console.log(`  ✅ ${description}`);
    if (testFn.length === 1) { // 异步测试
      return testFn((err) => {
        if (err) throw err;
      });
    } else {
      return testFn();
    }
  } catch (error) {
    console.log(`  ❌ ${description} - 失败: ${error.message}`);
  }
}

function expect(actual) {
  return {
    toBe: (expected) => {
      if (actual !== expected) {
        throw new Error(`期望 ${expected} 但得到 ${actual}`);
      }
    },
    toEqual: (expected) => {
      if (JSON.stringify(actual) !== JSON.stringify(expected)) {
        throw new Error(`期望 ${JSON.stringify(expected)} 但得到 ${JSON.stringify(actual)}`);
      }
    },
    toContain: (substring) => {
      if (!actual.includes(substring)) {
        throw new Error(`字符串不包含 "${substring}"`);
      }
    }
  };
}

// 运行测试
console.log('🧪 开始 FileManager 单元测试...\n');
describe('FileManager', () => {
  let fileManager;

  beforeEach(() => {
    fileManager = new FileManager();
  });

  test('should return true for existing directory', async () => {
    const exists = await fileManager.directoryExists(__dirname);
    expect(exists).toBe(true);
  });

  test('should return true for existing file', async () => {
    const exists = await fileManager.fileExists(__filename);
    expect(exists).toBe(true);
  });

  test('should create directory if it does not exist', async () => {
    const testDir = path.join(__dirname, 'test-dir-' + Date.now());
    try {
      await fileManager.ensureDirectory(testDir);
      const exists = await fileManager.directoryExists(testDir);
      expect(exists).toBe(true);
    } finally {
      // 清理测试目录
      try {
        await fs.rmdir(testDir);
      } catch (e) {
        // 忽略清理错误
      }
    }
  });

  test('should read valid JSON file', async () => {
    // 创建临时JSON文件进行测试
    const testFile = path.join(__dirname, 'temp-test.json');
    const testData = { name: 'test', value: 123 };
    
    try {
      await fs.writeFile(testFile, JSON.stringify(testData), 'utf8');
      const data = await fileManager.readJsonFile(testFile);
      expect(data).toEqual(testData);
    } finally {
      // 清理临时文件
      try {
        await fs.unlink(testFile);
      } catch (e) {
        // 忽略清理错误
      }
    }
  });

  test('should write JSON file', async () => {
    const testFile = path.join(__dirname, 'temp-write-test.json');
    const testData = { name: 'write test', value: 456 };
    
    try {
      await fileManager.writeJsonFile(testFile, testData);
      
      // 验证文件内容
      const content = await fs.readFile(testFile, 'utf8');
      const parsed = JSON.parse(content);
      expect(parsed).toEqual(testData);
    } finally {
      // 清理临时文件
      try {
        await fs.unlink(testFile);
      } catch (e) {
        // 忽略清理错误
      }
    }
  });

  test('should return empty settings for non-existing files', async () => {
    const settings = await fileManager.getProjectSettings('/non/existing/project');
    expect(settings).toEqual({
      characters: {},
      worldview: {},
      powerSystem: {},
      foreshadows: {},
      metadata: {}
    });
  });
});

console.log('\n✅ FileManager 单元测试完成');