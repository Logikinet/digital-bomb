export class DinoRole {
  x: number = 80;
  y: number = 300;
  width: number = 90;
  height: number = 96;
  velocityY: number = 0;
  isJumping: boolean = false;
  frameIndex: number = 0;
}

export class DinoObstacle {
  x: number = 454;
  y: number = 300;
  width: number = 50;
  height: number = 100;
  passed: boolean = false;
  type: string = 'cactus';
}

export enum DinoGameStatus {
  READY = 0,
  RUNNING = 1,
  OVER = 2
}