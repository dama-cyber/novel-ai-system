#!/usr/bin/env python3
"""
novelwriter_exporter.py - NovelWriter格式导出工具
对应EdwardAThomson/NovelWriter项目的导出功能
"""

import os
import json
import re
from pathlib import Path
from typing import Dict, List, Optional
import argparse
import markdown
from xml.etree.ElementTree import Element, SubElement, tostring
import xml.dom.minidom


class NovelWriterExporter:
    """NovelWriter项目导出器"""
    
    def __init__(self, project_path: str):
        self.project_path = Path(project_path)
        self.chapters_dir = self.project_path / "chapters"
        self.settings_dir = self.project_path / "settings"
        
        # 加载项目设置
        self.load_project_settings()
    
    def load_project_settings(self):
        """加载项目设置"""
        self.project_settings = {}
        
        if self.settings_dir.exists():
            for settings_file in self.settings_dir.glob("*.json"):
                try:
                    with open(settings_file, 'r', encoding='utf-8') as f:
                        self.project_settings[settings_file.stem] = json.load(f)
                except Exception as e:
                    print(f"警告: 无法加载设置文件 {settings_file}: {e}")
    
    def get_chapters(self) -> List[Dict]:
        """获取所有章节信息"""
        chapters = []
        
        if not self.chapters_dir.exists():
            return chapters
            
        for chapter_file in sorted(self.chapters_dir.glob("*.md")):
            match = re.match(r"chapter_(\d{3})_(.*)\.md", chapter_file.name)
            if match:
                chapter_num = int(match.group(1))
                title = match.group(2).replace('_', ' ')
                
                with open(chapter_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                chapters.append({
                    'number': chapter_num,
                    'title': title,
                    'content': content,
                    'word_count': len(content.split()),
                    'file_path': str(chapter_file)
                })
        
        return sorted(chapters, key=lambda x: x['number'])
    
    def export_to_novelwriter_format(self, output_path: str):
        """导出为NovelWriter兼容格式"""
        print(f"导出为NovelWriter格式到: {output_path}")
        
        # 创建导出目录
        output_dir = Path(output_path)
        output_dir.mkdir(parents=True, exist_ok=True)
        
        # 创建content目录
        content_dir = output_dir / "content"
        content_dir.mkdir(exist_ok=True)
        
        # 创建缓存和设置
        self._create_cache_files(output_dir)
        
        # 导出所有章节
        chapters = self.get_chapters()
        handle_mapping = {}
        
        for i, chapter in enumerate(chapters):
            # 生成一个唯一的句柄（基于章节号）
            handle = f"{i+1:06x}"
            handle_mapping[chapter['number']] = handle
            
            # 创建章节文件
            self._create_novelwriter_file(content_dir, handle, chapter)
        
        # 创建项目文件
        self._create_project_file(output_dir)
        
        # 创建选项文件
        self._create_options_file(output_dir)
        
        print(f"✅ NovelWriter格式导出完成: {output_path}")
    
    def _create_cache_files(self, output_dir: Path):
        """创建缓存和元数据文件"""
        # 创建meta目录
        meta_dir = output_dir / "meta"
        meta_dir.mkdir(exist_ok=True)
        
        # 创建重要性等级文件
        status_file = meta_dir / "status.json"
        status_data = {
            "novelStatus": {
                "New": {"level": 0, "icon": "1"},
                "Draft": {"level": 1, "icon": "2"},
                "Finished": {"level": 2, "icon": "3"}
            },
            "noteImportance": {
                "None": {"level": 0, "icon": "1"},
                "Minor": {"level": 1, "icon": "2"},
                "Major": {"level": 2, "icon": "3"},
                "Main": {"level": 3, "icon": "4"}
            }
        }
        
        with open(status_file, 'w', encoding='utf-8') as f:
            json.dump(status_data, f, ensure_ascii=False, indent=2)
    
    def _create_novelwriter_file(self, content_dir: Path, handle: str, chapter: Dict):
        """创建单个NovelWriter格式的文件"""
        file_content = []
        
        # 添加标题
        file_content.append(f"@title: {chapter['title']}")
        file_content.append("@level: 1")
        file_content.append("@label: Chapter")
        
        # 添加内容
        file_content.append("")
        file_content.append(chapter['content'])
        
        # 写入文件
        file_path = content_dir / f"{handle}.nwd"
        with open(file_path, 'w', encoding='utf-8', newline='\n') as f:
            f.write('\n'.join(file_content))
    
    def _create_project_file(self, output_dir: Path):
        """创建项目文件"""
        project_data = {
            "project": {
                "name": self.project_path.name,
                "author": self.project_settings.get('metadata', {}).get('author', ''),
                "description": f"由超长篇小说AI创作系统 v16.0 生成的项目",
                "title": self.project_path.name,
                "language": "zh_CN",
                "authors": []
            },
            "options": {
                "autoOutline": 1,
                "stopWhen": 300,
                "statusIcons": {
                    "New": "white",
                    "Draft": "yellow",
                    "Finished": "green"
                },
                "importIcons": {
                    "New": "white",
                    "Minor": "white",
                    "Major": "yellow",
                    "Main": "red"
                }
            }
        }
        
        project_file = output_dir / "nwProject.nwx"
        with open(project_file, 'w', encoding='utf-8') as f:
            json.dump(project_data, f, ensure_ascii=False, indent=2)
    
    def _create_options_file(self, output_dir: Path):
        """创建选项文件"""
        # 创建GUI设置文件
        gui_settings = {
            "GuiMain": {
                "winWidth": 1200,
                "winHeight": 800,
                "showRefPanel": True,
                "viewComments": True,
                "viewSynopsis": True
            }
        }
        
        options_file = output_dir / "GuiSettings.json"
        with open(options_file, 'w', encoding='utf-8') as f:
            json.dump(gui_settings, f, ensure_ascii=False, indent=2)


def main():
    parser = argparse.ArgumentParser(description='NovelWriter格式导出工具')
    parser.add_argument('project_path', help='项目路径')
    parser.add_argument('output_path', help='输出路径')
    parser.add_argument('--format', choices=['novelwriter', 'odt', 'rtf'], 
                       default='novelwriter', help='导出格式')
    
    args = parser.parse_args()
    
    exporter = NovelWriterExporter(args.project_path)
    
    if args.format == 'novelwriter':
        exporter.export_to_novelwriter_format(args.output_path)
    elif args.format == 'odt':
        print("ODT格式导出功能待实现")
    elif args.format == 'rtf':
        print("RTF格式导出功能待实现")


if __name__ == "__main__":
    main()