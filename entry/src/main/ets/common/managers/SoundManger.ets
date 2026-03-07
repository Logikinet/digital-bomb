import { audio } from '@kit.AudioKit';
import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { resourceManager } from '@kit.LocalizationKit';

export class SoundManger {
  soundPool: media.SoundPool | undefined = undefined;

  defaultPlayParameters: media.PlayParameters = {
    loop: 0,
    rate: audio.AudioRendererRate.RENDER_RATE_NORMAL,
    leftVolume: 0.5,
    rightVolume: 0.5,
    priority: 0,
  };

  isMute: boolean = false;

  soundIdMap: Map<string, number> = new Map<string, number>();
  streamIdMap: Map<string, number> = new Map<string, number>();

  createSoundPool(): void {
    let audioRendererInfo: audio.AudioRendererInfo = {
      usage: audio.StreamUsage.STREAM_USAGE_GAME,
      rendererFlags: 1
    };

    media.createSoundPool(5, audioRendererInfo).then((soundPool: media.SoundPool) => {
      this.soundPool = soundPool;

      this.soundPool.on('loadComplete', (soundId_: number) => {
        console.info('soundPool loadComplete, soundId: ' + soundId_);
      });

      this.soundPool.on('playFinished', () => {
        console.info('soundPool.play receive play finished message');
      });

      this.soundPool.on('error', (error: BusinessError) => {
        console.error('soundPool error happened, message is: ' + error.message + ', code: ' + error.code);
      });
    }).catch((error: BusinessError) => {
      console.error('create SoundPool failed: ' + error.message);
    });
  }

  loadAudios(audioNames: Array<string>, suffix: string = '.mp3'): void {
    let i: number = 0;
    while (i < audioNames.length) {
      this.loadAudio(audioNames[i], suffix);
      i++;
    }
  }

  loadAudio(audioName: string, suffix: string = '.mp3'): void {
    let context = getContext(this);
    context.resourceManager.getRawFd(audioName + suffix, (error: BusinessError, value: resourceManager.RawFileDescriptor) => {
      if (error) {
        console.error('getRawFd failed, code: ' + error.code + ', message: ' + error.message);
        return;
      }

      let fd: number = value.fd;
      let offset: number = value.offset;
      let length: number = value.length;

      this.soundPool?.load(fd, offset, length).then((soundIdRet: number) => {
        this.soundIdMap.set(audioName, soundIdRet);
      }).catch((err: BusinessError) => {
        console.error('loadAudio failed: ' + err.message);
      });
    });
  }

  playSound(soundKey: string, playParameters: media.PlayParameters = this.defaultPlayParameters): void {
    if (this.isMute) {
      return;
    }

    let soundIdValue: number | undefined = this.soundIdMap.get(soundKey);
    if (soundIdValue === undefined) {
      console.error('Sound ID for ' + soundKey + ' not found.');
      return;
    }

    this.soundPool?.play(soundIdValue, playParameters, (error: BusinessError, streamID: number) => {
      if (error) {
        console.error('play sound error, code: ' + error.code + ', message: ' + error.message);
        return;
      }
      this.streamIdMap.set(soundKey, streamID);
    });
  }

  async stopSound(soundKey: string): Promise<void> {
    let streamIdValue: number | undefined = this.streamIdMap.get(soundKey);
    if (streamIdValue === undefined) {
      return;
    }

    try {
      await this.soundPool?.stop(streamIdValue);
      this.streamIdMap.delete(soundKey);
    } catch (error) {
      console.error('stopSound failed');
    }
  }

  stopSoundAll(): void {
    this.streamIdMap.forEach((value: number) => {
      this.soundPool?.stop(value);
    });
    this.streamIdMap.clear();
  }

  unloadAll(): void {
    this.soundIdMap.forEach((value: number) => {
      this.soundPool?.unload(value);
    });
    this.soundIdMap.clear();
  }

  async releaseSoundPool(): Promise<void> {
    this.stopSoundAll();
    this.unloadAll();
    this.soundPool?.off('loadComplete');
    this.soundPool?.off('playFinished');
    this.soundPool?.off('error');
    await this.soundPool?.release();
  }
}