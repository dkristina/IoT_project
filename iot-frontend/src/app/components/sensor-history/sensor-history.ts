import {
  Component,
  EventEmitter,
  Input,
  OnChanges,
  Output,
  SimpleChanges,
  ViewChild
} from '@angular/core';

import { CommonModule } from '@angular/common';
import { BaseChartDirective } from 'ng2-charts';

import {
  ChartConfiguration,
  ChartType
} from 'chart.js';

@Component({
  selector: 'app-sensor-history',
  standalone: true,
  imports: [CommonModule, BaseChartDirective],
  template: `
    <div class="history-container">

      <div *ngIf="sortedMeasurements.length > 0"
           class="real-time-chart-box">
        <canvas
          baseChart
          #myChart
          [data]="lineChartData"
          [options]="lineChartOptions"
          [type]="lineChartType"
          (chartClick)="onChartClick($event)">
        </canvas>
      </div>

      <table>
        <thead>
          <tr>
            <th>Vreme</th>
            <th>Vrednost očitavanja</th>
          </tr>
        </thead>
        <tbody>
          <tr *ngFor="let m of sortedMeasurements; trackBy: trackById">
            <td>{{ m.timestamp | date:'HH:mm:ss' }}</td>
            <td><strong>{{ m.value }} {{ unit }}</strong></td>
          </tr>
        </tbody>
      </table>

    </div>
  `,
  styles: [`
    .history-container {
      width: 100%;
      max-height: 750px;
      overflow-y: auto;
    }

    .real-time-chart-box {
      height: 220px;
      width: 100%;
      margin-bottom: 20px;
      padding: 10px;
      background: #1e293b;
      border-radius: 8px;
      border: 1px solid rgba(255, 255, 255, 0.05);
    }

    table {
      width: 100%;
      border-collapse: collapse;
      background: transparent;
    }

    th {
      position: sticky;
      top: 0;
      background: #253248;
      z-index: 2;
      padding: 12px;
      text-align: left;
      border-bottom: 1px solid #374151;
    }

    td {
      padding: 12px;
      border-bottom: 1px solid rgba(31, 41, 55, 0.5);
      color: #e5e7eb;
    }
  `]
})
export class SensorHistoryComponent implements OnChanges {

  @ViewChild(BaseChartDirective) chart?: BaseChartDirective;

  @Input() measurements: any[] = [];
  @Input() unit: string = '';
  @Input() alarmRules: any[] = [];
  @Output() alarmPointClicked = new EventEmitter<any>();

  public lineChartType: ChartType = 'line';
  public lineChartData!: ChartConfiguration['data'];
  public lineChartOptions!: any;

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['measurements'] || changes['alarmRules'] || changes['unit']) {
      this.generateChartData();
    }
  }

  private generateChartData(): void {
    const chartMeasurements = [...this.sortedMeasurements].reverse();
    const values = chartMeasurements.map(m => Number(m.value));
    const labels = chartMeasurements.map(m =>
      new Date(m.timestamp).toLocaleTimeString([], {
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
      })
    );

    const severityColors: any = {
      LOW: '#4caf50',      
      MEDIUM: '#ffeb3b',   
      HIGH: '#ff9800',     
      CRITICAL: '#f44336'  
    };

    // 1. DINAMICKO RACUNANJE BOJA ZA SVAKU TACKICU 
    const pointBackgroundColors = values.map(val => {
      let finalColor = '#00d2d3'; 
      let currentHighestWeight = 0;

      if (this.alarmRules && this.alarmRules.length > 0) {
        this.alarmRules.forEach(rule => {
          const minBoundary = rule.lowThreshold !== undefined && rule.lowThreshold !== null ? Number(rule.lowThreshold) : null;
          const maxBoundary = rule.highThreshold !== undefined && rule.highThreshold !== null ? Number(rule.highThreshold) : null;
          
          const severityStr = String(rule.severity).toUpperCase();
          
          let weight = 0;
          if (severityStr === 'LOW') weight = 1;
          if (severityStr === 'MEDIUM') weight = 2;
          if (severityStr === 'HIGH') weight = 3;
          if (severityStr === 'CRITICAL') weight = 4;

          let isBreached = false;

          if (minBoundary !== null && maxBoundary !== null) {
            if (val < minBoundary || val > maxBoundary) {
              isBreached = true;
            }
          } 
          else if (minBoundary !== null && val < minBoundary) {
            isBreached = true;
          } 
          else if (maxBoundary !== null && val > maxBoundary) {
            isBreached = true;
          }

          if (isBreached && weight > currentHighestWeight) {
            currentHighestWeight = weight;
            finalColor = severityColors[severityStr] || '#f44336';
          }
        });
      }

      return finalColor;
    });

    
    this.lineChartOptions = {
      responsive: true,
      maintainAspectRatio: false,
      animation: {
        duration: 0 
      },
      plugins: {
        legend: { display: false },
        customAlarmLinesPlugin: {
          id: 'customAlarmLinesPlugin'
        }
      },
      scales: {
        x: {
          grid: { color: 'rgba(255, 255, 255, 0.02)' },
          ticks: { display: false }
        },
        y: {
          grid: { color: 'rgba(255, 255, 255, 0.02)' },
          ticks: {
            color: '#9ca3af',
            font: { size: 10 }
          }
        }
      }
    };

    const currentRules = this.alarmRules || [];
    const currentUnit = this.unit || '';
    
    this.lineChartOptions.plugins.customAlarmLinesPlugin.afterDraw = (chart: any) => {
      const { ctx, scales: { y }, chartArea: { left, right } } = chart;
      
      currentRules.forEach((rule: any) => {
        const severityStr = String(rule.severity).toUpperCase();
        const color = severityColors[severityStr] || '#f44336';

        // Crtanje donje granice (lowThreshold)
        if (rule.lowThreshold !== undefined && rule.lowThreshold !== null) {
          const yPos = y.getPixelForValue(Number(rule.lowThreshold));
          if (yPos >= chart.chartArea.top && yPos <= chart.chartArea.bottom) {
            ctx.save();
            ctx.strokeStyle = color;
            ctx.lineWidth = 1.5;
            ctx.setLineDash([6, 4]);
            ctx.beginPath();
            ctx.moveTo(left, yPos);
            ctx.lineTo(right, yPos);
            ctx.stroke();

            ctx.fillStyle = color;
            ctx.font = 'bold 10px sans-serif';
            ctx.fillText(`PRAG MIN: ${rule.lowThreshold} ${currentUnit}`, left + 10, yPos - 4);
            ctx.restore();
          }
        }

        // Crtanje gornje granice (highThreshold)
        if (rule.highThreshold !== undefined && rule.highThreshold !== null) {
          const yPos = y.getPixelForValue(Number(rule.highThreshold));
          if (yPos >= chart.chartArea.top && yPos <= chart.chartArea.bottom) {
            ctx.save();
            ctx.strokeStyle = color;
            ctx.lineWidth = 1.5;
            ctx.setLineDash([6, 4]);
            ctx.beginPath();
            ctx.moveTo(left, yPos);
            ctx.lineTo(right, yPos);
            ctx.stroke();

            ctx.fillStyle = color;
            ctx.font = 'bold 10px sans-serif';
            ctx.fillText(`PRAG MAX: ${rule.highThreshold} ${currentUnit}`, left + 10, yPos - 4);
            ctx.restore();
          }
        }
      });
    };

   
    this.lineChartData = {
      labels,
      datasets: [
        {
          data: values,
          label: `Očitavanje (${this.unit})`,
          borderColor: '#00d2d3', 
          fill: false,
          tension: 0.1,
          pointBackgroundColor: pointBackgroundColors, 
          pointBorderColor: pointBackgroundColors,
          pointRadius: 6, 
          pointHoverRadius: 9,
          pointBorderWidth: 1
        }
      ]
    };

   
    if (this.chart) {
      this.chart.update();
    }
  }

  onChartClick(event: any): void {
    const points = event.active;
    if (!points.length) return;

    const index = points[0].index;
    const measurement = [...this.sortedMeasurements].reverse()[index];
    const value = Number(measurement.value);

    let isAlarm = false;
    this.alarmRules?.forEach(rule => {
      const min = rule.lowThreshold !== null ? Number(rule.lowThreshold) : null;
      const max = rule.highThreshold !== null ? Number(rule.highThreshold) : null;
      if ((min !== null && value < min) || (max !== null && value > max)) {
        isAlarm = true;
      }
    });

    if (!isAlarm) return;
    this.alarmPointClicked.emit(measurement);
  }

  get sortedMeasurements() {
    if (!this.measurements) return [];
    return [...this.measurements]
      .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime())
      .slice(0, 20);
  }

  trackById(index: number, item: any) {
    return item.id || index;
  }
}