import { GameSnapshot, GuessResult, RuleType, ScanHint } from './GameTypes';
import { RandomUtil } from '../common/utils/RandomUtil';

export class RuleEngine {
  static buildGame(ruleType: RuleType): GameSnapshot {
    let snapshot: GameSnapshot = new GameSnapshot();
    snapshot.min = 1;
    snapshot.max = 100;
    snapshot.ruleType = ruleType;

    if (ruleType === RuleType.DOUBLE_BOMB) {
      snapshot.bombs = RandomUtil.randomUniqueInts(1, 100, 2);
    } else {
      snapshot.bombs = RandomUtil.randomUniqueInts(1, 100, 1);
    }

    return snapshot;
  }

  static evaluateGuess(guess: number, snapshot: GameSnapshot): GuessResult {
    let result: GuessResult = new GuessResult();
    let explodedInfo: ExplodeCheckResult = RuleEngine.isExploded(guess, snapshot);

    if (explodedInfo.exploded) {
      result.exploded = true;
      result.hitReason = explodedInfo.reason;
      result.newMin = snapshot.min;
      result.newMax = snapshot.max;
      result.message = 'Boom！' + explodedInfo.reason;
      return result;
    }

    let nearestBomb: number = RuleEngine.getNearestBomb(guess, snapshot.bombs);
    let newMin: number = snapshot.min;
    let newMax: number = snapshot.max;

    if (guess < nearestBomb && guess > snapshot.min) {
      newMin = guess;
    } else if (guess > nearestBomb && guess < snapshot.max) {
      newMax = guess;
    }

    result.exploded = false;
    result.hitReason = '';
    result.newMin = newMin;
    result.newMax = newMax;
    result.message = '安全，区间更新为 ' + newMin + ' ~ ' + newMax;

    return result;
  }

  static isExploded(guess: number, snapshot: GameSnapshot): ExplodeCheckResult {
    let result: ExplodeCheckResult = new ExplodeCheckResult();

    if (snapshot.ruleType === RuleType.NORMAL) {
      if (guess === snapshot.bombs[0]) {
        result.exploded = true;
        result.reason = '猜中了炸弹数字';
      }
      return result;
    }

    if (snapshot.ruleType === RuleType.DOUBLE_BOMB) {
      if (snapshot.bombs.indexOf(guess) !== -1) {
        result.exploded = true;
        result.reason = '猜中了双炸弹之一';
      }
      return result;
    }

    if (snapshot.ruleType === RuleType.NEAR_DANGER) {
      let bomb: number = snapshot.bombs[0];
      if (guess >= bomb - 1 && guess <= bomb + 1) {
        result.exploded = true;
        result.reason = '触发了连号危险区（炸弹±1）';
      }
      return result;
    }

    return result;
  }

  static getNearestBomb(guess: number, bombs: Array<number>): number {
    let nearest: number = bombs[0];
    let minGap: number = Math.abs(guess - nearest);

    let i: number = 1;
    while (i < bombs.length) {
      let gap: number = Math.abs(guess - bombs[i]);
      if (gap < minGap) {
        minGap = gap;
        nearest = bombs[i];
      }
      i++;
    }

    return nearest;
  }

  static scanHint(snapshot: GameSnapshot): ScanHint {
    let hint: ScanHint = new ScanHint();
    let target: number = snapshot.bombs[0];
    let hintType: number = RandomUtil.randomInt(1, 3);

    if (hintType === 1) {
      if (target > 50) {
        hint.text = '扫描结果：炸弹大于 50';
      } else {
        hint.text = '扫描结果：炸弹小于等于 50';
      }
      return hint;
    }

    if (hintType === 2) {
      if (target % 2 === 0) {
        hint.text = '扫描结果：炸弹更像偶数';
      } else {
        hint.text = '扫描结果：炸弹更像奇数';
      }
      return hint;
    }

    let left: number = target - 10;
    let right: number = target + 10;

    if (left < 1) {
      left = 1;
    }
    if (right > 100) {
      right = 100;
    }

    hint.text = '扫描结果：炸弹大概率在 ' + left + ' ~ ' + right + ' 之间';
    return hint;
  }

  static aiGuess(snapshot: GameSnapshot): number {
    let mid: number = Math.floor((snapshot.min + snapshot.max) / 2);
    let offset: number = RandomUtil.randomInt(-8, 8);
    let guess: number = mid + offset;

    if (guess <= snapshot.min) {
      guess = snapshot.min + 1;
    }

    if (guess >= snapshot.max) {
      guess = snapshot.max - 1;
    }

    return guess;
  }
}

class ExplodeCheckResult {
  exploded: boolean = false;
  reason: string = '';
}