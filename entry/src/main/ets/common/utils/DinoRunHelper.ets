import { DinoObstacle, DinoRole } from '../../model/DinoRunTypes';

export class DinoRunHelper {
  static readonly GROUND_Y: number = 300;
  static readonly ROLE_X: number = 80;
  static readonly ROLE_WIDTH: number = 90;
  static readonly ROLE_HEIGHT: number = 96;

  static resetRole(): DinoRole {
    let role: DinoRole = new DinoRole();
    role.x = DinoRunHelper.ROLE_X;
    role.y = DinoRunHelper.GROUND_Y;
    role.width = DinoRunHelper.ROLE_WIDTH;
    role.height = DinoRunHelper.ROLE_HEIGHT;
    role.velocityY = 0;
    role.isJumping = false;
    role.frameIndex = 0;
    return role;
  }

  static createRandomObstacle(x: number, score: number = 0): DinoObstacle {
    let obstacle: DinoObstacle = new DinoObstacle();
    obstacle.x = x;
    obstacle.passed = false;

    let birdChance: number = 35;
    if (score >= 10) {
      birdChance = 40;
    }
    if (score >= 25) {
      birdChance = 45;
    }

    let randomValue: number = Math.floor(Math.random() * 100);
    if (randomValue < birdChance) {
      obstacle.type = 'bird';
      obstacle.width = 72;
      obstacle.height = 52;

      let birdHeightMode: number = Math.floor(Math.random() * 3);
      if (birdHeightMode === 0) {
        obstacle.y = 318;
      } else if (birdHeightMode === 1) {
        obstacle.y = 270;
      } else {
        obstacle.y = 235;
      }
    } else {
      obstacle.type = 'cactus';
      let cactusMode: number = Math.floor(Math.random() * 3);
      if (cactusMode === 0) {
        obstacle.width = 46;
        obstacle.height = 92;
      } else if (cactusMode === 1) {
        obstacle.width = 58;
        obstacle.height = 108;
      } else {
        obstacle.width = 72;
        obstacle.height = 92;
      }
      obstacle.y = DinoRunHelper.GROUND_Y + (100 - obstacle.height);
    }

    return obstacle;
  }

  static getRandomGap(score: number = 0): number {
    let baseGap: number = 220;

    if (score >= 10) {
      baseGap = 205;
    }
    if (score >= 22) {
      baseGap = 190;
    }
    if (score >= 38) {
      baseGap = 175;
    }
    if (score >= 60) {
      baseGap = 165;
    }

    return baseGap + Math.floor(Math.random() * 60);
  }

  static jump(role: DinoRole): DinoRole {
    let next: DinoRole = DinoRunHelper.copyRole(role);
    if (!next.isJumping && next.y >= DinoRunHelper.GROUND_Y) {
      next.isJumping = true;
      next.velocityY = -15.5;
    }
    return next;
  }

  static fastDrop(role: DinoRole): DinoRole {
    let next: DinoRole = DinoRunHelper.copyRole(role);
    if (next.isJumping && next.y < DinoRunHelper.GROUND_Y) {
      if (next.velocityY < 12) {
        next.velocityY = 12;
      }
    }
    return next;
  }

  static updateRole(role: DinoRole): DinoRole {
    let next: DinoRole = DinoRunHelper.copyRole(role);

    if (next.isJumping || next.y < DinoRunHelper.GROUND_Y) {
      next.y = next.y + next.velocityY;
      next.velocityY = next.velocityY + 0.92;

      if (next.y >= DinoRunHelper.GROUND_Y) {
        next.y = DinoRunHelper.GROUND_Y;
        next.velocityY = 0;
        next.isJumping = false;
      }
    }

    return next;
  }

  static updateRunFrame(role: DinoRole, tick: number): DinoRole {
    let next: DinoRole = DinoRunHelper.copyRole(role);
    if (!next.isJumping) {
      next.frameIndex = tick % 2;
    } else {
      next.frameIndex = 2;
    }
    return next;
  }

  static updateObstacle(obstacle: DinoObstacle, speed: number): DinoObstacle {
    let next: DinoObstacle = DinoRunHelper.copyObstacle(obstacle);
    next.x = next.x - speed;
    return next;
  }

  static recycleObstacleIfNeeded(obstacle: DinoObstacle, sceneWidth: number, score: number): DinoObstacle {
    let next: DinoObstacle = DinoRunHelper.copyObstacle(obstacle);
    if (next.x + next.width < 0) {
      next = DinoRunHelper.createRandomObstacle(sceneWidth + DinoRunHelper.getRandomGap(score), score);
    }
    return next;
  }

  static isPassed(role: DinoRole, obstacle: DinoObstacle): boolean {
    return !obstacle.passed && (obstacle.x + obstacle.width < role.x);
  }

  static markPassed(obstacle: DinoObstacle): DinoObstacle {
    let next: DinoObstacle = DinoRunHelper.copyObstacle(obstacle);
    next.passed = true;
    return next;
  }

  static isCollision(role: DinoRole, obstacle: DinoObstacle): boolean {
    let roleLeft: number = role.x + 16;
    let roleRight: number = role.x + role.width - 16;
    let roleTop: number = role.y + 14;
    let roleBottom: number = role.y + role.height - 8;

    let obsLeft: number = obstacle.x + 8;
    let obsRight: number = obstacle.x + obstacle.width - 8;
    let obsTop: number = obstacle.y + 6;
    let obsBottom: number = obstacle.y + obstacle.height - 2;

    if (obstacle.type === 'bird') {
      obsLeft = obstacle.x + 10;
      obsRight = obstacle.x + obstacle.width - 10;
      obsTop = obstacle.y + 10;
      obsBottom = obstacle.y + obstacle.height - 8;
    }

    let horizontalHit: boolean = roleRight > obsLeft && roleLeft < obsRight;
    let verticalHit: boolean = roleBottom > obsTop && roleTop < obsBottom;

    return horizontalHit && verticalHit;
  }

  static nextSpeed(score: number): number {
    let speed: number = 8;

    if (score >= 4) {
      speed = 9;
    }
    if (score >= 8) {
      speed = 10;
    }
    if (score >= 12) {
      speed = 10.5;
    }
    if (score >= 16) {
      speed = 11;
    }
    if (score >= 22) {
      speed = 11.5;
    }
    if (score >= 28) {
      speed = 12;
    }
    if (score >= 36) {
      speed = 12.5;
    }
    if (score >= 48) {
      speed = 13;
    }
    if (score >= 64) {
      speed = 14;
    }
    if (score >= 84) {
      speed = 15;
    }

    return speed;
  }

  static copyRole(role: DinoRole): DinoRole {
    let next: DinoRole = new DinoRole();
    next.x = role.x;
    next.y = role.y;
    next.width = role.width;
    next.height = role.height;
    next.velocityY = role.velocityY;
    next.isJumping = role.isJumping;
    next.frameIndex = role.frameIndex;
    return next;
  }

  static copyObstacle(obstacle: DinoObstacle): DinoObstacle {
    let next: DinoObstacle = new DinoObstacle();
    next.x = obstacle.x;
    next.y = obstacle.y;
    next.width = obstacle.width;
    next.height = obstacle.height;
    next.passed = obstacle.passed;
    next.type = obstacle.type;
    return next;
  }
}