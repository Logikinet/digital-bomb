import { Game2048Level, Game2048MoveResult, Game2048Tile } from '../../model/Game2048Types';

export class Game2048Helper {
  static getRandomNumber(): number {
    let numbers: Array<number> = [2, 2, 2, 4];
    let index: number = Math.floor(Math.random() * numbers.length);
    return numbers[index];
  }

  static buildTwoDimensionalArray(row: number, col: number): number[][] {
    let result: number[][] = [];
    let i: number = 0;
    while (i < row) {
      result[i] = [];
      let j: number = 0;
      while (j < col) {
        result[i][j] = 0;
        j++;
      }
      i++;
    }
    return result;
  }

  static cloneBoard(board: number[][], row: number = 4, col: number = 4): number[][] {
    let result: number[][] = [];
    let i: number = 0;
    while (i < row) {
      result[i] = [];
      let j: number = 0;
      while (j < col) {
        result[i][j] = board[i][j];
        j++;
      }
      i++;
    }
    return result;
  }

  static createInitialBoard(level: number, row: number = 4, col: number = 4): number[][] {
    let board: number[][] = Game2048Helper.buildTwoDimensionalArray(row, col);
    let randomCount: number = 1;
    if (level === Game2048Level.HARD) {
      randomCount = 2;
    }
    board = Game2048Helper.addRandomNumbers(board, randomCount, row, col);
    return board;
  }

  static addRandomNumbers(board: number[][], randomCount: number = 1, row: number = 4, col: number = 4): number[][] {
    let result: number[][] = Game2048Helper.cloneBoard(board, row, col);
    let emptyCount: number = Game2048Helper.calcEmptyPosCount(result, row, col);

    if (emptyCount <= 0) {
      return result;
    }

    if (randomCount > emptyCount) {
      randomCount = emptyCount;
    }

    let index: number = 0;
    while (index < randomCount) {
      let currentEmpty: Array<number[]> = Game2048Helper.getEmptyPositions(result, row, col);
      if (currentEmpty.length <= 0) {
        break;
      }

      let randomPos: number = Math.floor(Math.random() * currentEmpty.length);
      let pos: number[] = currentEmpty[randomPos];
      result[pos[0]][pos[1]] = Game2048Helper.getRandomNumber();
      index++;
    }

    return result;
  }

  static getEmptyPositions(board: number[][], row: number = 4, col: number = 4): Array<number[]> {
    let result: Array<number[]> = [];
    let i: number = 0;
    while (i < row) {
      let j: number = 0;
      while (j < col) {
        if (board[i][j] === 0) {
          result.push([i, j]);
        }
        j++;
      }
      i++;
    }
    return result;
  }

  static calcEmptyPosCount(board: number[][], row: number = 4, col: number = 4): number {
    let count: number = 0;
    let i: number = 0;
    while (i < row) {
      let j: number = 0;
      while (j < col) {
        if (board[i][j] === 0) {
          count++;
        }
        j++;
      }
      i++;
    }
    return count;
  }

  static move(board: number[][], direction: string, level: number, row: number = 4, col: number = 4): Game2048MoveResult {
    let result: Game2048MoveResult = new Game2048MoveResult();
    let workingBoard: number[][] = Game2048Helper.cloneBoard(board, row, col);
    let movedBoard: number[][] = Game2048Helper.buildTwoDimensionalArray(row, col);
    let totalScore: number = 0;

    if (direction === 'left') {
      let i: number = 0;
      while (i < row) {
        let lineResult: LineMergeResult = Game2048Helper.processLineLeft(workingBoard[i]);
        movedBoard[i] = lineResult.line;
        totalScore += lineResult.score;
        i++;
      }
    } else if (direction === 'right') {
      let i: number = 0;
      while (i < row) {
        let reversed: Array<number> = Game2048Helper.reverseArray(workingBoard[i]);
        let lineResult: LineMergeResult = Game2048Helper.processLineLeft(reversed);
        movedBoard[i] = Game2048Helper.reverseArray(lineResult.line);
        totalScore += lineResult.score;
        i++;
      }
    } else if (direction === 'up') {
      let j: number = 0;
      while (j < col) {
        let column: Array<number> = Game2048Helper.getColumn(workingBoard, j, row);
        let lineResult: LineMergeResult = Game2048Helper.processLineLeft(column);
        Game2048Helper.setColumn(movedBoard, j, lineResult.line, row);
        totalScore += lineResult.score;
        j++;
      }
    } else if (direction === 'down') {
      let j: number = 0;
      while (j < col) {
        let column: Array<number> = Game2048Helper.getColumn(workingBoard, j, row);
        let reversed: Array<number> = Game2048Helper.reverseArray(column);
        let lineResult: LineMergeResult = Game2048Helper.processLineLeft(reversed);
        Game2048Helper.setColumn(movedBoard, j, Game2048Helper.reverseArray(lineResult.line), row);
        totalScore += lineResult.score;
        j++;
      }
    } else {
      movedBoard = Game2048Helper.cloneBoard(board, row, col);
    }

    let changed: boolean = JSON.stringify(board) !== JSON.stringify(movedBoard);
    if (changed) {
      let randomCount: number = 1;
      if (level === Game2048Level.HARD) {
        randomCount = 2;
      }
      movedBoard = Game2048Helper.addRandomNumbers(movedBoard, randomCount, row, col);
    }

    result.board = movedBoard;
    result.scoreGain = totalScore;
    result.changed = changed;
    return result;
  }

  static canMove(board: number[][], row: number = 4, col: number = 4): boolean {
    if (Game2048Helper.calcEmptyPosCount(board, row, col) > 0) {
      return true;
    }

    let directions: Array<string> = ['left', 'right', 'up', 'down'];
    let i: number = 0;
    while (i < directions.length) {
      let moveResult: Game2048MoveResult = Game2048Helper.moveWithoutRandom(board, directions[i], row, col);
      if (moveResult.changed) {
        return true;
      }
      i++;
    }

    return false;
  }

  static hasTarget(board: number[][], target: number = 2048, row: number = 4, col: number = 4): boolean {
    let i: number = 0;
    while (i < row) {
      let j: number = 0;
      while (j < col) {
        if (board[i][j] >= target) {
          return true;
        }
        j++;
      }
      i++;
    }
    return false;
  }

  static buildTiles(board: number[][], theme: number, row: number = 4, col: number = 4): Game2048Tile[][] {
    let result: Game2048Tile[][] = [];
    let i: number = 0;
    while (i < row) {
      result[i] = [];
      let j: number = 0;
      while (j < col) {
        result[i][j] = new Game2048Tile(board[i][j], theme);
        j++;
      }
      i++;
    }
    return result;
  }

  private static processLineLeft(line: Array<number>): LineMergeResult {
    let compressed: Array<number> = [];
    let i: number = 0;
    while (i < line.length) {
      if (line[i] !== 0) {
        compressed.push(line[i]);
      }
      i++;
    }

    let merged: Array<number> = [];
    let score: number = 0;
    let index: number = 0;

    while (index < compressed.length) {
      if (index < compressed.length - 1 && compressed[index] === compressed[index + 1]) {
        let value: number = compressed[index] * 2;
        merged.push(value);
        score += value;
        index += 2;
      } else {
        merged.push(compressed[index]);
        index++;
      }
    }

    while (merged.length < 4) {
      merged.push(0);
    }

    let result: LineMergeResult = new LineMergeResult();
    result.line = merged;
    result.score = score;
    return result;
  }

  private static reverseArray(line: Array<number>): Array<number> {
    let result: Array<number> = [];
    let i: number = line.length - 1;
    while (i >= 0) {
      result.push(line[i]);
      i--;
    }
    return result;
  }

  private static getColumn(board: number[][], colIndex: number, row: number = 4): Array<number> {
    let result: Array<number> = [];
    let i: number = 0;
    while (i < row) {
      result.push(board[i][colIndex]);
      i++;
    }
    return result;
  }

  private static setColumn(board: number[][], colIndex: number, column: Array<number>, row: number = 4): void {
    let i: number = 0;
    while (i < row) {
      board[i][colIndex] = column[i];
      i++;
    }
  }

  private static moveWithoutRandom(board: number[][], direction: string, row: number = 4, col: number = 4): Game2048MoveResult {
    let result: Game2048MoveResult = new Game2048MoveResult();
    let workingBoard: number[][] = Game2048Helper.cloneBoard(board, row, col);
    let movedBoard: number[][] = Game2048Helper.buildTwoDimensionalArray(row, col);
    let totalScore: number = 0;

    if (direction === 'left') {
      let i: number = 0;
      while (i < row) {
        let lineResult: LineMergeResult = Game2048Helper.processLineLeft(workingBoard[i]);
        movedBoard[i] = lineResult.line;
        totalScore += lineResult.score;
        i++;
      }
    } else if (direction === 'right') {
      let i: number = 0;
      while (i < row) {
        let reversed: Array<number> = Game2048Helper.reverseArray(workingBoard[i]);
        let lineResult: LineMergeResult = Game2048Helper.processLineLeft(reversed);
        movedBoard[i] = Game2048Helper.reverseArray(lineResult.line);
        totalScore += lineResult.score;
        i++;
      }
    } else if (direction === 'up') {
      let j: number = 0;
      while (j < col) {
        let column: Array<number> = Game2048Helper.getColumn(workingBoard, j, row);
        let lineResult: LineMergeResult = Game2048Helper.processLineLeft(column);
        Game2048Helper.setColumn(movedBoard, j, lineResult.line, row);
        totalScore += lineResult.score;
        j++;
      }
    } else if (direction === 'down') {
      let j: number = 0;
      while (j < col) {
        let column: Array<number> = Game2048Helper.getColumn(workingBoard, j, row);
        let reversed: Array<number> = Game2048Helper.reverseArray(column);
        let lineResult: LineMergeResult = Game2048Helper.processLineLeft(reversed);
        Game2048Helper.setColumn(movedBoard, j, Game2048Helper.reverseArray(lineResult.line), row);
        totalScore += lineResult.score;
        j++;
      }
    } else {
      movedBoard = Game2048Helper.cloneBoard(board, row, col);
    }

    result.board = movedBoard;
    result.scoreGain = totalScore;
    result.changed = JSON.stringify(board) !== JSON.stringify(movedBoard);
    return result;
  }
}

class LineMergeResult {
  line: Array<number> = [0, 0, 0, 0];
  score: number = 0;
}