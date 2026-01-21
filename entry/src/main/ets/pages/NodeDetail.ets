import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { buffer } from '@kit.ArkTS';

// ============== 接口定义 ==============

interface Document {
  file: string;
  title: string;
  type: string;
  display_order: number;
  highlight_sections?: Array<string>;
}

interface GraphNode {
  id: string;
  title: string;
  level: number;
  category: string;
  icon: string;
  color: string;
  status: string;
  estimated_time: string;
  prerequisites: Array<string>;
  documents: Array<Document>;
  summary: string;
  key_points: Array<string>;
  caution?: string;
}

@Entry
@Component
struct NodeDetail {
  private context = getContext(this) as common.Context;

  @State nodeData: GraphNode | null = null;
  @State hasLoaded: boolean = false;
  @State completedDocs: Set<string> = new Set();
  @State expandedDocs: Set<string> = new Set();
  @State documentContents: Record<string, string> = {};

  aboutToAppear(): void {
    this.loadNodeData();
  }

  private loadNodeData(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params && params['nodeData']) {
      try {
        this.nodeData = JSON.parse(params['nodeData'] as string) as GraphNode;
        this.hasLoaded = true;
        // 加载文档内容
        this.loadDocumentContents();
      } catch (err) {
        console.error('Failed to parse node data: ' + JSON.stringify(err));
      }
    }
  }

  private async loadDocumentContents(): Promise<void> {
    if (!this.nodeData) return;

    for (const doc of this.nodeData.documents) {
      const content = await this.loadDocument(doc.file);
      if (content) {
        this.documentContents[doc.file] = content;
      }
    }
  }

  private async loadDocument(fileName: string): Promise<string | null> {
    try {
      // 注意：实际文档应放在 rawfile/study_docs/ 目录下
      const value = await this.context.resourceManager.getRawFileContent(`study_docs/${fileName}`);
      const str = buffer.from(value.buffer).toString();
      return this.optimizeMarkdownContent(str);
    } catch (err) {
      console.error('Failed to load document: ' + fileName + ', error: ' + JSON.stringify(err));
      return '文档内容加载失败，请检查文件路径。';
    }
  }

  private optimizeMarkdownContent(markdown: string): string {
    // 简化版优化：提取核心内容
    // 实际项目中可以使用 Markdown 解析库
    let optimized = markdown;

    // 移除过多空行
    optimized = optimized.replace(/\n{3,}/g, '\n\n');

    // 高亮核心口诀（以 > 开头的引用块）
    optimized = optimized.replace(/^> (.+)$/gm, '**【口诀】** $1');

    return optimized;
  }

  private toggleDocExpand(fileName: string): void {
    if (this.expandedDocs.has(fileName)) {
      this.expandedDocs.delete(fileName);
    } else {
      this.expandedDocs.add(fileName);
    }
  }

  private markDocCompleted(fileName: string): void {
    this.completedDocs.add(fileName);
    // 实际应保存到本地存储
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.app_icon'))
          .width(32)
          .height(32)
          .margin({ right: 12 })
          .onClick(() => {
            router.back();
          })

        Column() {
          Text(this.nodeData?.title || '节点详情')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Text(`预计学习：${this.nodeData?.estimated_time || ''}`)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 12 })
      .backgroundColor('#ffffff')
      .border({ width: { bottom: 1 }, color: '#e0e0e0' })

      if (this.hasLoaded && this.nodeData) {
        Scroll() {
          Column() {
            // 学习进度卡片
            Column() {
              Row() {
                Text('📊 学习进度')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')

                Blank()

                Text(`${this.completedDocs.size}/${this.nodeData.documents.length} 文档已完成`)
                  .fontSize(14)
                  .fontColor('#2d8a4e')
              }
              .width('100%')

              Progress({
                value: this.completedDocs.size,
                total: this.nodeData.documents.length,
                type: ProgressType.Linear
              })
                .width('100%')
                .color('#2d8a4e')
                .margin({ top: 12 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#ffffff')
            .borderRadius(12)
            .shadow({ radius: 4, color: '#00000010' })

            // 节点摘要
            Column() {
              Text('📝 核心摘要')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .margin({ bottom: 12 })

              Text(this.nodeData.summary)
                .fontSize(14)
                .fontColor('#666666')
                .lineHeight(22)
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#ffffff')
            .borderRadius(12)
            .margin({ top: 16 })
            .shadow({ radius: 4, color: '#00000010' })

            // 关键要点
            Column() {
              Text('🔑 关键要点')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .margin({ bottom: 12 })

              ForEach(this.nodeData.key_points, (point: string, index: number) => {
                Row() {
                  Text(`${index + 1}.`)
                    .fontSize(14)
                    .fontColor('#3d6b4f')
                    .fontWeight(FontWeight.Bold)
                    .margin({ right: 8 })

                  Text(point)
                    .fontSize(14)
                    .fontColor('#666666')
                    .layoutWeight(1)
                    .lineHeight(22)
                }
                .width('100%')
                .alignItems(VerticalAlign.Top)
                .margin({ bottom: index < this.nodeData!.key_points.length - 1 ? 8 : 0 })
              }, (point: string, index: number) => `key_point_${index}`)
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#ffffff')
            .borderRadius(12)
            .margin({ top: 16 })
            .shadow({ radius: 4, color: '#00000010' })

            // 警示提示（如果有）
            if (this.nodeData.caution) {
              Column() {
                Row() {
                  Text('⚠️')
                    .fontSize(20)
                    .margin({ right: 8 })

                  Text(this.nodeData.caution)
                    .fontSize(14)
                    .fontColor('#b45309')
                    .layoutWeight(1)
                    .lineHeight(22)
                }
                .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#fff3e0')
              .borderRadius(12)
              .margin({ top: 16 })
              .border({ width: 1, color: '#b45309' })
            }

            // 文档列表
            Column() {
              Text('📚 学习文档')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .margin({ bottom: 16 })

              ForEach(this.nodeData.documents, (doc: Document) => {
                this.DocumentCard(doc)
              }, (doc: Document) => doc.file)
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#ffffff')
            .borderRadius(12)
            .margin({ top: 16, bottom: 20 })
            .shadow({ radius: 4, color: '#00000010' })

          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)

      } else {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#3d6b4f')
          Text('加载节点详情...')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8f8f8')
  }

  @Builder
  DocumentCard(doc: Document) {
    Column() {
      // 文档标题栏
      Row() {
        Text(this.getDocTypeIcon(doc.type))
          .fontSize(20)
          .margin({ right: 8 })

        Column() {
          Text(doc.title)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')

          Text(doc.type === 'rule' ? '规则' : doc.type === 'formula' ? '口诀' : '理论')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 展开/收起按钮
        Text(this.expandedDocs.has(doc.file) ? '▲' : '▼')
          .fontSize(14)
          .fontColor('#666666')
      }
      .width('100%')
      .padding(12)
      .backgroundColor(this.completedDocs.has(doc.file) ? '#e8f5e9' : '#f5f5f5')
      .borderRadius(8)
      .onClick(() => {
        this.toggleDocExpand(doc.file);
      })

      // 文档内容（展开时显示）
      if (this.expandedDocs.has(doc.file)) {
        Column() {
          if (this.documentContents[doc.file]) {
            Text(this.documentContents[doc.file])
              .fontSize(14)
              .fontColor('#555555')
              .lineHeight(24)
              .margin({ top: 12, bottom: 12 })
          } else {
            Text('加载中...')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: 12, bottom: 12 })
          }

          // 操作按钮
          Row() {
            Button(this.completedDocs.has(doc.file) ? '✓ 已完成' : '标记已学')
              .fontSize(14)
              .backgroundColor(this.completedDocs.has(doc.file) ? '#2d8a4e' : '#3d6b4f')
              .fontColor('#ffffff')
              .borderRadius(8)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .onClick(() => {
                this.markDocCompleted(doc.file);
              })

            Button('📝 添加笔记')
              .fontSize(14)
              .backgroundColor('#f0f0f0')
              .fontColor('#333333')
              .borderRadius(8)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .margin({ left: 12 })
              .onClick(() => {
                // 打开笔记编辑器
              })
          }
          .width('100%')
        }
        .width('100%')
        .padding(12)
      }
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  private getDocTypeIcon(type: string): string {
    if (type === 'rule') return '📋';
    if (type === 'formula') return '📿';
    if (type === 'theory') return '📖';
    if (type === 'method') return '🔧';
    if (type === 'classic') return '📜';
    if (type === 'reference') return '📚';
    if (type === 'special') return '⭐';
    return '📄';
  }
}
