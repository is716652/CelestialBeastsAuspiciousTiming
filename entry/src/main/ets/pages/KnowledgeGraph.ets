import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { buffer, JSON as ArkJSON } from '@kit.ArkTS';

// ============== 接口定义 ==============

interface NodePosition {
  x: number;
  y: number;
}

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
  position: NodePosition;
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

interface Connection {
  from: string;
  to: string;
  type: string;
  label: string;
}

interface Category {
  name: string;
  color: string;
  icon: string;
}

interface MetaInfo {
  version: string;
  last_update: string;
  total_nodes: number;
  description: string;
}

interface MainAxis {
  start_x: number;
  start_y: number;
  end_x: number;
  end_y: number;
}

interface GraphLayout {
  type: string;
  main_axis: MainAxis;
  branch_spacing: number;
}

interface GraphConfig {
  meta: MetaInfo;
  graph_layout: GraphLayout;
  nodes: Array<GraphNode>;
  connections: Array<Connection>;
  categories: Record<string, Category>;
}

@Entry
@Component
struct KnowledgeGraph {
  private context = getContext(this) as common.Context;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  @State graphConfig: GraphConfig | null = null;
  @State hasLoaded: boolean = false;

  // 用户学习进度（实际应从本地存储读取）
  @State userProgress: Record<string, string> = {
    'node_001': 'completed',
    'node_002': 'in_progress'
  };

  aboutToAppear(): void {
    this.loadGraphConfig();
  }

  private async loadGraphConfig(): Promise<void> {
    const config = await this.loadJsonFromRaw<GraphConfig>('knowledge_graph_config.json');
    if (config) {
      this.graphConfig = config;
      this.hasLoaded = true;
    }
  }

  private async loadJsonFromRaw<T>(fileName: string): Promise<T | null> {
    try {
      const value = await this.context.resourceManager.getRawFileContent(fileName);
      const str = buffer.from(value.buffer).toString();
      return ArkJSON.parse(str) as T;
    } catch (err) {
      console.error('Failed to load: ' + fileName + ', error: ' + JSON.stringify(err));
      return null;
    }
  }

  private getNodeStatus(nodeId: string): string {
    if (this.userProgress[nodeId]) {
      return this.userProgress[nodeId];
    }
    const node = this.graphConfig?.nodes.find((n: GraphNode) => n.id === nodeId);
    return node?.status || 'locked';
  }

  private getNodeColor(node: GraphNode): string {
    const status = this.getNodeStatus(node.id);
    if (status === 'completed') return '#2d8a4e'; // 金色已完成
    if (status === 'in_progress') return '#0284c7'; // 蓝色学习中
    if (status === 'unlocked') return node.color; // 类别颜色
    return '#999999'; // 灰色锁定
  }

  private drawGraph(): void {
    if (!this.graphConfig || !this.canvasContext) return;

    const ctx = this.canvasContext;
    const width = 400; // 适应屏幕宽度
    const height = 2400;

    // 清空画布
    ctx.clearRect(0, 0, width, height);

    // 绘制主干线（竖向主轴）
    ctx.strokeStyle = '#d4af37';
    ctx.lineWidth = 4;
    ctx.beginPath();
    ctx.moveTo(180, 50);
    ctx.lineTo(180, 2350);
    ctx.stroke();

    // 绘制连接线
    this.graphConfig.connections.forEach((conn: Connection) => {
      const fromNode = this.graphConfig!.nodes.find((n: GraphNode) => n.id === conn.from);
      const toNode = this.graphConfig!.nodes.find((n: GraphNode) => n.id === conn.to);
      if (fromNode && toNode) {
        this.drawConnection(ctx, fromNode, toNode, conn);
      }
    });

    // 绘制节点
    this.graphConfig.nodes.forEach((node: GraphNode) => {
      this.drawNode(ctx, node);
    });
  }

  private drawConnection(
    ctx: CanvasRenderingContext2D,
    fromNode: GraphNode,
    toNode: GraphNode,
    conn: Connection
  ): void {
    const fromPos = fromNode.position;
    const toPos = toNode.position;

    ctx.strokeStyle = '#cccccc';
    ctx.lineWidth = 2;

    if (conn.type === 'sequential' || conn.type === 'prerequisite') {
      ctx.setLineDash([]);
    } else if (conn.type === 'branch') {
      ctx.setLineDash([5, 5]);
    } else {
      ctx.setLineDash([2, 2]);
    }

    ctx.beginPath();
    // 使用贝塞尔曲线绘制连接
    const midX = (fromPos.x + toPos.x) / 2;
    const midY = (fromPos.y + toPos.y) / 2;
    ctx.moveTo(fromPos.x, fromPos.y);
    ctx.quadraticCurveTo(midX, fromPos.y, midX, midY);
    ctx.quadraticCurveTo(midX, toPos.y, toPos.x, toPos.y);
    ctx.stroke();

    ctx.setLineDash([]);
  }

  private drawNode(ctx: CanvasRenderingContext2D, node: GraphNode): void {
    const pos = node.position;
    const radius = 50; // 增大节点半径
    const color = this.getNodeColor(node);

    // 绘制节点圆圈
    ctx.fillStyle = color;
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 4;
    ctx.beginPath();
    ctx.arc(pos.x, pos.y, radius, 0, Math.PI * 2);
    ctx.fill();
    ctx.stroke();

    // 绘制节点图标（使用文本模拟）
    ctx.fillStyle = '#ffffff';
    ctx.font = '60px sans-serif'; // 从40px放大到60px（1.5倍）
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(node.icon, pos.x, pos.y);

    // 绘制节点标题
    ctx.fillStyle = '#333333';
    ctx.font = 'bold 30px sans-serif'; // 从20px放大到30px（1.5倍）
    ctx.fillText(node.title, pos.x, pos.y + radius + 35);
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

        Text('演禽研习路径')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        // 图例按钮
        Button('图例')
          .fontSize(14)
          .backgroundColor('#f0f0f0')
          .fontColor('#333333')
          .borderRadius(8)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .onClick(() => {
            // 显示图例弹窗
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 12 })
      .backgroundColor('#ffffff')
      .border({ width: { bottom: 1 }, color: '#e0e0e0' })

      if (this.hasLoaded && this.graphConfig) {
        // Scroll容器支持竖向滚动
        Scroll() {
          Stack() {
            Canvas(this.canvasContext)
              .width('100%')
              .height(2400)
              .backgroundColor('#f8f8f8')
              .onReady(() => {
                this.drawGraph();
              })

            // 节点点击检测层（透明覆盖层）
            Column() {
              ForEach(this.graphConfig.nodes, (node: GraphNode) => {
                Row()
                  .width(120) // 适配50px半径
                  .height(120)
                  .position({
                    x: node.position.x - 60,
                    y: node.position.y - 60
                  })
                  .onClick(() => {
                    this.navigateToNodeDetail(node);
                  })
              }, (node: GraphNode) => node.id)
            }
            .width('100%')
            .height(2400)
          }
          .width('100%')
          .height(2400)
        }
        .width('100%')
        .height('100%')
        .scrollable(ScrollDirection.Vertical) // 仅支持竖向滚动
        .scrollBar(BarState.Off) // 隐藏滚动条
        .edgeEffect(EdgeEffect.Spring)
        .layoutWeight(1)

      } else {
        // 加载中状态
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#3d6b4f')
          Text('加载知识图谱...')
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

  private navigateToNodeDetail(node: GraphNode): void {
    const status = this.getNodeStatus(node.id);
    if (status === 'locked') {
      // 显示提示：需要先完成前置节点
      return;
    }

    router.pushUrl({
      url: 'pages/NodeDetail',
      params: {
        nodeId: node.id,
        nodeData: JSON.stringify(node)
      }
    });
  }
}
