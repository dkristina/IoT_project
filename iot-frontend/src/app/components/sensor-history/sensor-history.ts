import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-sensor-history',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="history-container">
      <table *ngIf="sortedMeasurements.length > 0; else noData">
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

      <ng-template #noData>
        <div class="no-data">Nema zabeleženih merenja.</div>
      </ng-template>
    </div>
  `,
  styles: [`
    .history-container {
      width: 100%;
      max-height: 600px; /* Ograničava visinu same tabele */
      overflow-y: auto;   /* Dodaje scroll samo unutar tabele */
    }

    table {
      width: 100%;
      border-collapse: collapse;
      background: transparent;
    }

    th {
      position: sticky;
      top: 0;
      background: #1f2937;
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

    .no-data { padding: 20px; text-align: center; color: #9ca3af; }
  `]
})
export class SensorHistoryComponent {
  @Input() measurements: any[] = [];
  @Input() unit: string = '';

  get sortedMeasurements() {
    if (!this.measurements) return [];
    // Sortira od najnovijeg i uzima samo prvih 20
    return [...this.measurements]
      .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime())
      .slice(0, 20); 
  }

  trackById(index: number, item: any) {
    return item.id || index;
  }
}