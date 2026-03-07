export class Game2048Tile {
  value: number = 0;
  text: string = '';
  textColor: string = '#776E65';
  bgColor: string = '#CDC1B4';
  fontSize: number = 28;
  themeMode: number = 0;

  constructor(value: number = 0, themeMode: number = 0) {
    this.value = value;
    this.themeMode = themeMode;
    this.text = buildTileText(value, themeMode);

    if (value === 0) {
      this.textColor = '#776E65';
      this.bgColor = '#CDC1B4';
      this.fontSize = 28;
      return;
    }

    if (value === 2) {
      this.textColor = '#776E65';
      this.bgColor = '#EEE4DA';
      this.fontSize = 28;
    } else if (value === 4) {
      this.textColor = '#776E65';
      this.bgColor = '#EDE0C8';
      this.fontSize = 28;
    } else if (value === 8) {
      this.textColor = '#F9F6F2';
      this.bgColor = '#F2B179';
      this.fontSize = 28;
    } else if (value === 16) {
      this.textColor = '#F9F6F2';
      this.bgColor = '#F59563';
      this.fontSize = 26;
    } else if (value === 32) {
      this.textColor = '#F9F6F2';
      this.bgColor = '#F67C5F';
      this.fontSize = 26;
    } else if (value === 64) {
      this.textColor = '#F9F6F2';
      this.bgColor = '#F65E3B';
      this.fontSize = 26;
    } else if (value === 128) {
      this.textColor = '#F9F6F2';
      this.bgColor = '#EDCF72';
      this.fontSize = 24;
    } else if (value === 256) {
      this.textColor = '#F9F6F2';
      this.bgColor = '#EDCC61';
      this.fontSize = 24;
    } else if (value === 512) {
      this.textColor = '#F9F6F2';
      this.bgColor = '#EDC850';
      this.fontSize = 24;
    } else if (value === 1024) {
      this.textColor = '#F9F6F2';
      this.bgColor = '#EDC53F';
      this.fontSize = 20;
    } else if (value === 2048) {
      this.textColor = '#F9F6F2';
      this.bgColor = '#EDC22E';
      this.fontSize = 20;
    } else if (value === 4096) {
      this.textColor = '#F9F6F2';
      this.bgColor = '#3C3A32';
      this.fontSize = 20;
    } else {
      this.textColor = '#F9F6F2';
      this.bgColor = '#3C3A32';
      this.fontSize = 18;
    }

    if (themeMode !== 0) {
      this.fontSize = Math.max(16, this.fontSize - 6);
    }
  }
}

export class Game2048MoveResult {
  board: number[][] = [];
  scoreGain: number = 0;
  changed: boolean = false;
}

export enum Game2048Level {
  NORMAL = 0,
  HARD = 1,
  SPEED = 2
}

export enum Game2048Theme {
  CLASSIC = 0,
  DYNASTY = 1,
  SCHOLAR = 2,
  MILITARY = 3
}

function buildTileText(value: number, themeMode: number): string {
  if (value === 0) {
    return '';
  }

  if (themeMode === 0) {
    return value.toString();
  }

  if (themeMode === 1) {
    return getDynastyText(value);
  }

  if (themeMode === 2) {
    return getScholarText(value);
  }

  return getMilitaryText(value);
}

function getDynastyText(value: number): string {
  const map = new Map<number, string>([
    [2, '夏'],
    [4, '商'],
    [8, '周'],
    [16, '秦'],
    [32, '汉'],
    [64, '三国'],
    [128, '晋'],
    [256, '南北'],
    [512, '隋'],
    [1024, '唐'],
    [2048, '五代'],
    [4096, '宋'],
    [8192, '元'],
    [16384, '明'],
    [32768, '清'],
    [65536, '中华']
  ]);
  return map.get(value) ?? value.toString();
}

function getScholarText(value: number): string {
  const map = new Map<number, string>([
    [2, '白丁'],
    [4, '童生'],
    [8, '秀才'],
    [16, '举人'],
    [32, '解元'],
    [64, '贡士'],
    [128, '会员'],
    [256, '进士'],
    [512, '探花'],
    [1024, '榜眼'],
    [2048, '状元'],
    [4096, '翰林'],
    [8192, '中书'],
    [16384, '学士'],
    [32768, '尚书'],
    [65536, '宰相']
  ]);
  return map.get(value) ?? value.toString();
}

function getMilitaryText(value: number): string {
  const map = new Map<number, string>([
    [2, '列兵'],
    [4, '士官'],
    [8, '少尉'],
    [16, '中尉'],
    [32, '上尉'],
    [64, '少校'],
    [128, '中校'],
    [256, '上校'],
    [512, '大校'],
    [1024, '少将'],
    [2048, '中将'],
    [4096, '上将'],
    [8192, '大将'],
    [16384, '元帅'],
    [32768, '主席']
  ]);
  return map.get(value) ?? value.toString();
}