export class RandomUtil {
  static randomInt(min: number, max: number): number {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }

  static randomUniqueInts(min: number, max: number, count: number): Array<number> {
    let result: Array<number> = [];
    while (result.length < count) {
      let value: number = RandomUtil.randomInt(min, max);
      if (result.indexOf(value) === -1) {
        result.push(value);
      }
    }
    result.sort((a: number, b: number) => a - b);
    return result;
  }
}