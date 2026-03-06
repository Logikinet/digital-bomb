import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';

export default class EntryAbility extends UIAbility {
  onCreate(): void {
    console.info('EntryAbility onCreate');
  }

  onDestroy(): void {
    console.info('EntryAbility onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        console.error(`loadContent failed, code: ${err.code}, msg: ${err.message}`);
        return;
      }
      console.info('loadContent success');
    });
  }

  onWindowStageDestroy(): void {
    console.info('Window stage destroyed');
  }
}