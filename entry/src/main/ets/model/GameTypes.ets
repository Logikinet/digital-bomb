export enum RuleType {
  NORMAL = 'NORMAL',
  DOUBLE_BOMB = 'DOUBLE_BOMB',
  NEAR_DANGER = 'NEAR_DANGER'
}

export enum PlayerType {
  HUMAN = 'HUMAN',
  AI = 'AI'
}

export class Player {
  id: number = 0;
  name: string = '';
  hp: number = 3;
  type: PlayerType = PlayerType.HUMAN;
  scannerCount: number = 1;
}

export class GuessResult {
  exploded: boolean = false;
  hitReason: string = '';
  newMin: number = 1;
  newMax: number = 100;
  message: string = '';
}

export class ScanHint {
  text: string = '';
}

export class GameSnapshot {
  min: number = 1;
  max: number = 100;
  bombs: Array<number> = [];
  ruleType: RuleType = RuleType.NORMAL;
}