/**
 * NavigationService - Global navigation state management
 */

export class NavigationService {
  private static instance: NavigationService;
  pageInfos: NavPathStack = new NavPathStack();

  private constructor() {}

  static getInstance(): NavigationService {
    if (!NavigationService.instance) {
      NavigationService.instance = new NavigationService();
    }
    return NavigationService.instance;
  }

  pushPath(name: string, param?: object): void {
    this.pageInfos.pushPath({ name: name, param: param });
  }

  replacePath(name: string, param?: object): void {
    this.pageInfos.replacePath({ name: name, param: param });
  }

  pop(): void {
    this.pageInfos.pop();
  }

  clear(): void {
    this.pageInfos.clear();
  }
}
