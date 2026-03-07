import Game2048PageTest from './Game2048Page.test'
import GamepageTest from './Gamepage.test'
import abilityTest from './Ability.test';

export default function testsuite() {
  abilityTest();
  GamepageTest()
  Game2048PageTest()
}