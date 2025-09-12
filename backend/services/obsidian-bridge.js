/**
 * Clintest Desktop 학습 루프 v1 - Obsidian 브리지 서비스
 * 
 * 역할: Obsidian Vault 폴더 감시 및 개념 노트 동기화
 * 원칙: 개념은 Obsidian 전용, DB는 메타데이터만 미러링
 */

const chokidar = require('chokidar');
const fs = require('fs').promises;
const path = require('path');
const crypto = require('crypto');
const yaml = require('js-yaml');
const { getDB } = require('../config/database');

class ObsidianBridge {
  constructor() {
    this.watcher = null;
    this.vaultPath = null;
    this.isWatching = false;
    this.activeUsers = new Map(); // 사용자별 설정 저장
  }

  /**
   * 사용자별 Obsidian Vault 경로 설정 및 감시 시작
   */
  async setupUserVault(uid, vaultPath) {
    try {
      // 경로 유효성 검사
      await this.validateVaultPath(vaultPath);
      
      // 사용자 설정 저장
      this.activeUsers.set(uid, {
        vaultPath: vaultPath,
        lastScan: new Date(),
        fileCount: 0
      });
      
      // 기존 감시자 중지
      if (this.watcher) {
        await this.watcher.close();
      }
      
      // 새 감시자 시작
      await this.startWatching();
      
      console.log(`✅ Obsidian Vault 설정 완료: ${vaultPath} (사용자: ${uid})`);
      
      // 초기 스캔 실행
      await this.performInitialScan(uid, vaultPath);
      
      return {
        success: true,
        vaultPath: vaultPath,
        isWatching: true,
        message: 'Obsidian Vault 연결이 설정되었습니다'
      };
      
    } catch (error) {
      console.error('Obsidian vault setup error:', error);
      throw new Error(`Vault 설정 실패: ${error.message}`);
    }
  }

  /**
   * Vault 경로 유효성 검사
   */
  async validateVaultPath(vaultPath) {
    try {
      const stats = await fs.stat(vaultPath);
      
      if (!stats.isDirectory()) {
        throw new Error('유효한 디렉토리가 아닙니다');
      }
      
      // .obsidian 폴더 존재 확인 (선택적)
      const obsidianDir = path.join(vaultPath, '.obsidian');
      try {
        await fs.stat(obsidianDir);
        console.log('📁 Obsidian 설정 폴더 확인됨');
      } catch {
        console.log('⚠️ .obsidian 폴더가 없습니다. 일반 폴더로 처리합니다.');
      }
      
    } catch (error) {
      if (error.code === 'ENOENT') {
        throw new Error('경로가 존재하지 않습니다');
      }
      throw error;
    }
  }

  /**
   * 파일 감시 시작
   */
  async startWatching() {
    const allVaultPaths = Array.from(this.activeUsers.values()).map(u => u.vaultPath);
    
    if (allVaultPaths.length === 0) {
      console.log('감시할 Vault 경로가 없습니다');
      return;
    }
    
    this.watcher = chokidar.watch(allVaultPaths, {
      ignored: [
        '**/node_modules/**',
        '**/.obsidian/**',
        '**/.git/**',
        '**/.*', // 숨김 파일
        '**/*.tmp',
        '**/*.log'
      ],
      persistent: true,
      ignoreInitial: true, // 초기 스캔은 별도로 처리
      followSymlinks: false,
      awaitWriteFinish: {
        stabilityThreshold: 500,
        pollInterval: 100
      }
    });
    
    // 이벤트 핸들러 등록
    this.watcher
      .on('add', (filePath) => this.handleFileAdd(filePath))
      .on('change', (filePath) => this.handleFileChange(filePath))
      .on('unlink', (filePath) => this.handleFileDelete(filePath))
      .on('error', (error) => {
        console.error('Obsidian watcher error:', error);
      });
    
    this.isWatching = true;
    console.log(`🔍 Obsidian 파일 감시 시작 (${allVaultPaths.length}개 Vault)`);
  }

  /**
   * 파일 추가 처리
   */
  async handleFileAdd(filePath) {
    if (!this.isMarkdownFile(filePath)) return;
    
    console.log(`📄 새 파일 감지: ${filePath}`);
    await this.processMarkdownFile(filePath, 'add');
  }

  /**
   * 파일 변경 처리
   */
  async handleFileChange(filePath) {
    if (!this.isMarkdownFile(filePath)) return;
    
    console.log(`✏️ 파일 변경 감지: ${filePath}`);
    await this.processMarkdownFile(filePath, 'change');
  }

  /**
   * 파일 삭제 처리
   */
  async handleFileDelete(filePath) {
    if (!this.isMarkdownFile(filePath)) return;
    
    console.log(`🗑️ 파일 삭제 감지: ${filePath}`);
    
    try {
      const db = getDB();
      const uid = this.getUidFromFilePath(filePath);
      
      if (!uid) {
        console.log('파일 경로에서 사용자를 찾을 수 없습니다');
        return;
      }
      
      const obsidianPath = this.getRelativePathFromVault(uid, filePath);
      
      // DB에서 개념 노트 메타데이터 삭제
      const deleteResult = await db.collection('concept_notes').deleteOne({
        ownerUid: uid,
        obsidianPath: obsidianPath
      });
      
      if (deleteResult.deletedCount > 0) {
        console.log(`✅ 개념 노트 메타데이터 삭제 완료: ${obsidianPath}`);
      }
      
    } catch (error) {
      console.error('File delete processing error:', error);
    }
  }

  /**
   * 마크다운 파일 처리
   */
  async processMarkdownFile(filePath, operation = 'change') {
    try {
      const uid = this.getUidFromFilePath(filePath);
      
      if (!uid) {
        console.log('파일 경로에서 사용자를 찾을 수 없습니다');
        return;
      }
      
      // 파일 내용 읽기
      const fileContent = await fs.readFile(filePath, 'utf-8');
      const fileHash = this.calculateFileHash(fileContent);
      
      // Front-matter 파싱
      const { metadata, content } = this.parseFrontMatter(fileContent);
      
      // Obsidian 상대 경로 계산
      const obsidianPath = this.getRelativePathFromVault(uid, filePath);
      
      // 제목 추출 (Front-matter 또는 파일명)
      const title = metadata.title || 
                   path.basename(filePath, '.md') || 
                   'Untitled';
      
      // 태그 추출
      const tags = this.extractTags(metadata, content);
      
      // DB 업데이트
      await this.updateConceptNote(uid, {
        obsidianPath: obsidianPath,
        title: title,
        tags: tags,
        hash: fileHash,
        metadata: metadata,
        operation: operation
      });
      
    } catch (error) {
      console.error('Markdown file processing error:', error);
    }
  }

  /**
   * 개념 노트 메타데이터 DB 업데이트
   */
  async updateConceptNote(uid, conceptData) {
    try {
      const db = getDB();
      
      const updateResult = await db.collection('concept_notes').updateOne(
        {
          ownerUid: uid,
          obsidianPath: conceptData.obsidianPath
        },
        {
          $set: {
            ownerUid: uid,
            obsidianPath: conceptData.obsidianPath,
            title: conceptData.title,
            tags: conceptData.tags,
            hash: conceptData.hash,
            lastSyncAt: new Date(),
            metadata: conceptData.metadata || {}
          }
        },
        { upsert: true }
      );
      
      const action = updateResult.upsertedCount > 0 ? '생성' : '업데이트';
      console.log(`✅ 개념 노트 ${action} 완료: ${conceptData.title}`);
      
    } catch (error) {
      console.error('Concept note update error:', error);
    }
  }

  /**
   * 초기 스캔 실행
   */
  async performInitialScan(uid, vaultPath) {
    try {
      console.log(`🔍 초기 스캔 시작: ${vaultPath}`);
      
      const markdownFiles = await this.findAllMarkdownFiles(vaultPath);
      console.log(`📄 발견된 마크다운 파일: ${markdownFiles.length}개`);
      
      // 파일들을 순차적으로 처리 (병렬 처리 시 DB 부하 방지)
      for (const filePath of markdownFiles) {
        await this.processMarkdownFile(filePath, 'initial_scan');
        
        // 짧은 대기 시간 (DB 부하 방지)
        await new Promise(resolve => setTimeout(resolve, 50));
      }
      
      // 사용자 설정 업데이트
      const userConfig = this.activeUsers.get(uid);
      if (userConfig) {
        userConfig.fileCount = markdownFiles.length;
        userConfig.lastScan = new Date();
      }
      
      console.log(`✅ 초기 스캔 완료: ${markdownFiles.length}개 파일 처리`);
      
    } catch (error) {
      console.error('Initial scan error:', error);
    }
  }

  /**
   * 모든 마크다운 파일 찾기
   */
  async findAllMarkdownFiles(vaultPath) {
    const markdownFiles = [];
    
    async function scanDirectory(dirPath) {
      try {
        const entries = await fs.readdir(dirPath, { withFileTypes: true });
        
        for (const entry of entries) {
          const fullPath = path.join(dirPath, entry.name);
          
          if (entry.isDirectory()) {
            // 제외할 디렉토리 확인
            if (!entry.name.startsWith('.') && 
                entry.name !== 'node_modules' &&
                entry.name !== '__pycache__') {
              await scanDirectory(fullPath);
            }
          } else if (entry.isFile() && entry.name.endsWith('.md')) {
            markdownFiles.push(fullPath);
          }
        }
      } catch (error) {
        console.error(`Directory scan error: ${dirPath}`, error);
      }
    }
    
    await scanDirectory(vaultPath);
    return markdownFiles;
  }

  // === Utility Functions ===

  isMarkdownFile(filePath) {
    return path.extname(filePath).toLowerCase() === '.md';
  }

  getUidFromFilePath(filePath) {
    // 파일 경로로부터 사용자 UID 찾기
    for (const [uid, config] of this.activeUsers.entries()) {
      if (filePath.startsWith(config.vaultPath)) {
        return uid;
      }
    }
    return null;
  }

  getRelativePathFromVault(uid, filePath) {
    const userConfig = this.activeUsers.get(uid);
    if (!userConfig) return filePath;
    
    return path.relative(userConfig.vaultPath, filePath).replace(/\\/g, '/');
  }

  calculateFileHash(content) {
    return crypto.createHash('md5').update(content).digest('hex');
  }

  parseFrontMatter(content) {
    const frontMatterRegex = /^---\s*\n([\s\S]*?)\n---\s*\n([\s\S]*)$/;
    const match = content.match(frontMatterRegex);
    
    if (match) {
      try {
        const metadata = yaml.load(match[1]) || {};
        const markdownContent = match[2];
        return { metadata, content: markdownContent };
      } catch (error) {
        console.error('YAML parsing error:', error);
        return { metadata: {}, content: content };
      }
    }
    
    return { metadata: {}, content: content };
  }

  extractTags(metadata, content) {
    const tags = new Set();
    
    // Front-matter에서 태그 추출
    if (metadata.tags) {
      if (Array.isArray(metadata.tags)) {
        metadata.tags.forEach(tag => tags.add(tag));
      } else if (typeof metadata.tags === 'string') {
        metadata.tags.split(',').forEach(tag => tags.add(tag.trim()));
      }
    }
    
    // 본문에서 해시태그 추출
    const hashtagRegex = /#([a-zA-Z0-9_가-힣]+)/g;
    let match;
    while ((match = hashtagRegex.exec(content)) !== null) {
      tags.add(match[1]);
    }
    
    return Array.from(tags).filter(tag => tag.length > 0);
  }

  /**
   * 감시 중지
   */
  async stopWatching() {
    if (this.watcher) {
      await this.watcher.close();
      this.watcher = null;
    }
    
    this.isWatching = false;
    this.activeUsers.clear();
    console.log('🛑 Obsidian 파일 감시 중지');
  }

  /**
   * 현재 상태 조회
   */
  getStatus() {
    return {
      isWatching: this.isWatching,
      activeUsers: Array.from(this.activeUsers.entries()).map(([uid, config]) => ({
        uid: uid,
        vaultPath: config.vaultPath,
        fileCount: config.fileCount,
        lastScan: config.lastScan
      }))
    };
  }
}

// 싱글톤 인스턴스
const obsidianBridge = new ObsidianBridge();

module.exports = obsidianBridge;