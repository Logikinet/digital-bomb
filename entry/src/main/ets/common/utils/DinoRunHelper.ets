import { DinoObstacle, DinoRole } from '../../model/DinoRunTypes';

export class DinoRunHelper {
  static readonly GROUND_Y: number = 300;
  static readonly ROLE_X: number = 80;
  static readonly ROLE_WIDTH: number = 90;
  static readonly ROLE_HEIGHT: number = 96;
  static readonly OBSTACLE_WIDTH: number = 50;
  static readonly OBSTACLE_HEIGHT: number = 100;

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

  static createObstacle(x: number): DinoObstacle {
    let obstacle: DinoObstacle = new DinoObstacle();
    obstacle.x = x;
    obstacle.y = DinoRunHelper.GROUND_Y;
    obstacle.width = DinoRunHelper.OBSTACLE_WIDTH;
    obstacle.height = DinoRunHelper.OBSTACLE_HEIGHT;
    obstacle.passed = false;
    return obstacle;
  }

  static getRandomGap(): number {
    return 260 + Math.floor(Math.random() * 180);
  }

  // 第一次点击：起跳
  static jump(role: DinoRole): DinoRole {
    let next: DinoRole = DinoRunHelper.copyRole(role);
    if (!next.isJumping && next.y >= DinoRunHelper.GROUND_Y) {
      next.isJumping = true;
      next.velocityY = -16;
    }
    return next;
  }

  // 第二次点击：下坠
  static fastDrop(role: DinoRole): DinoRole {
    let next: DinoRole = DinoRunHelper.copyRole(role);
    if (next.isJumping && next.y < DinoRunHelper.GROUND_Y) {
      if (next.velocityY < 10) {
        next.velocityY = 10;
      }
    }
    return next;
  }

  static updateRole(role: DinoRole): DinoRole {
    let next: DinoRole = DinoRunHelper.copyRole(role);

    if (next.isJumping || next.y < DinoRunHelper.GROUND_Y) {
      next.y = next.y + next.velocityY;
      next.velocityY = next.velocityY + 1.0;

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

  static recycleObstacleIfNeeded(obstacle: DinoObstacle, sceneWidth: number): DinoObstacle {
    let next: DinoObstacle = DinoRunHelper.copyObstacle(obstacle);
    if (next.x + next.width < 0) {
      next.x = sceneWidth + DinoRunHelper.getRandomGap();
      next.passed = false;
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
    let roleLeft: number = role.x + 12;
    let roleRight: number = role.x + role.width - 12;
    let roleTop: number = role.y + 12;
    let roleBottom: number = role.y + role.height - 8;

    let obsLeft: number = obstacle.x + 8;
    let obsRight: number = obstacle.x + obstacle.width - 8;
    let obsTop: number = obstacle.y + 10;
    let obsBottom: number = obstacle.y + obstacle.height;

    let horizontalHit: boolean = roleRight > obsLeft && roleLeft < obsRight;
    let verticalHit: boolean = roleBottom > obsTop && roleTop < obsBottom;

    return horizontalHit && verticalHit;
  }

  static nextSpeed(score: number): number {
    let speed: number = 7 + Math.floor(score / 12);
    if (speed > 15) {
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
    return next;
  }
}