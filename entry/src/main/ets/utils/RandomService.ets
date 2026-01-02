import { cryptoFramework } from '@kit.CryptoArchitectureKit';

export function getRandomValue(): number {
  try {
    const random = cryptoFramework.createRandom();
    const randomBytes = random.generateRandomSync(4);
    const view = new DataView(randomBytes.data.buffer);
    const randomUint32 = view.getUint32(0, false);
    return randomUint32 / 4294967296;
  } catch (error) {
    console.error('Random generation error:', error);
    return 1
  }
}