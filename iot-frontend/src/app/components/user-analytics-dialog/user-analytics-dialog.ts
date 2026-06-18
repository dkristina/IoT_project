import { Component, Inject, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { Store } from '@ngrx/store';

import { Observable } from 'rxjs';
import { User } from '../../core/models/user.model';
import { selectUserAnalytics } from '../../store/incident/incident.selector';

@Component({
  selector: 'app-user-analytics-dialog',
  standalone: true,
  imports: [CommonModule, MatDialogModule],
  template: `
    <div class="analytics-dialog-container">
      <div class="dialog-header">
        <div class="header-title-group">
          <h2>📊 Analitika rada: <span class="user-highlight">{{ data.user.fullName }}</span></h2>
          <span class="username-sub">@{{ data.user.username }}</span>
        </div>
        <button class="btn-close" (click)="close()">✕</button>
      </div>

      <div class="dialog-body" *ngIf="stats$ | async as s; else loading">
        
        <h3 class="section-title">📉 Osnovni učinak operatera</h3>
        <div class="stats-cards-grid">
          <div class="stat-card">
            <span class="card-label">Zaduženih<br>incidenata</span>
            <span class="card-value">{{ s.totalAssigned }}</span>
          </div>
          <div class="stat-card success">
            <span class="card-label">Uspešno<br>rešeno</span>
            <span class="card-value">{{ s.resolvedCount }}</span>
          </div>
          <div class="stat-card pending">
            <span class="card-label">Trenutno<br>aktivno</span>
            <span class="card-value">{{ s.openOrInProgressCount }}</span>
          </div>
          <div class="stat-card abandoned">
            <span class="card-label">Odustao/la od<br>zadatka</span>
            <span class="card-value">{{ s.abandonedCount }}</span>
          </div>
          <div class="stat-card percentage">
            <span class="card-label">Procenat<br>uspeha</span>
            <span class="card-value">{{ s.resolutionPercentage }}%</span>
          </div>
        </div>

        <h3 class="section-title">⏱️ Brzina aktivnog rešavanja (vreme rada)</h3>
        <div class="time-cards-grid">
          <div class="time-card">
            <span class="card-label">⚡ Prosečno vreme rada</span>
            <span class="card-value">{{ formatTime(s.avgResolutionTimeMin) }}</span>
          </div>
          <div class="time-card">
            <span class="card-label">🎯 Medijana rada (srednja vrednost)</span>
            <span class="card-value">{{ formatTime(s.medianResolutionTimeMin) }}</span>
          </div>
          <div class="time-card alert">
            <span class="card-label">🐢 Najduži rad na jednom incidentu</span>
            <span class="card-value">{{ formatTime(s.longestResolutionTimeMin) }}</span>
          </div>
        </div>

        <h3 class="section-title">🛡️ Struktura rešenih incidenata po ozbiljnosti alarama</h3>
        <div class="severity-bars-container">
          <div class="severity-bar low">
            <span class="sev-name">LOW</span>
            <span class="sev-count">{{ s.severityStats.LOW }}</span>
          </div>
          <div class="severity-bar medium">
            <span class="sev-name">MEDIUM</span>
            <span class="sev-count">{{ s.severityStats.MEDIUM }}</span>
          </div>
          <div class="severity-bar high">
            <span class="sev-name">HIGH</span>
            <span class="sev-count">{{ s.severityStats.HIGH }}</span>
          </div>
          <div class="severity-bar critical">
            <span class="sev-name">CRITICAL</span>
            <span class="sev-count">{{ s.severityStats.CRITICAL }}</span>
          </div>
        </div>

      </div>

      <ng-template #loading>
        <div class="dialog-loading">
          <div class="spinner"></div>
          <p>Obračunavanje analitike iz baze...</p>
        </div>
      </ng-template>
    </div>
  `,
  styles: [`
    :host {
      display: block;
      background: #1e293b;
      border-radius: 20px;
    }

    .analytics-dialog-container {
      background: #1e293b; 
      color: #e2e8f0;
      padding: 25px;
      border-radius: 20px;
      border: 1px solid #334155;
      font-family: inherit;
      box-sizing: border-box;
      /* 🚀 Rešenje za širinu: Širimo kontejner maksimalno do 820px bez fiksnog min-width buba */
      width: 100%;
      max-width: 820px; 
    }

    .dialog-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      border-bottom: 1px solid #334155;
      padding-bottom: 15px;
      margin-bottom: 20px;
      h2 { margin: 0; font-size: 1.3rem; color: white; font-weight: 700; }
      .user-highlight { color: #38bdf8; }
      .username-sub { color: #64748b; font-size: 0.85rem; }
    }

    .btn-close {
      background: #0f172a;
      border: 1px solid #334155;
      color: #94a3b8;
      border-radius: 8px;
      width: 32px;
      height: 32px;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: all 0.2s;
      &:hover { background: #ef4444; color: white; border-color: #ef4444; }
    }

    .section-title {
      font-size: 0.75rem;
      letter-spacing: 0.08em;
      color: #94a3b8;
      text-transform: uppercase;
      margin: 25px 0 12px 0;
    }

    .stats-cards-grid {
      display: grid;
      grid-template-columns: repeat(5, 1fr);
      gap: 10px;
    }

    .time-cards-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 12px;
    }

    .stat-card, .time-card {
      background: #0f172a;
      border: 1px solid #334155;
      padding: 12px 6px;
      border-radius: 12px;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: space-between; /* 🚀 Poravnava labelu gore, a vrednost uvek dole */
      text-align: center;
      min-height: 85px; /* 🚀 Drži sve kartice u istoj visini bez obzira na redove teksta */
      box-sizing: border-box;

      .card-label { 
        font-size: 0.65rem; 
        color: #64748b; 
        text-transform: uppercase; 
        font-weight: 600; 
        line-height: 1.3;
        display: block;
      }
      .card-value { font-size: 1.3rem; font-weight: 800; color: white; margin-top: auto; }
    }

    .stat-card.success { border-color: rgba(34, 197, 94, 0.3); .card-value { color: #22c55e; } }
    .stat-card.pending { border-color: rgba(234, 179, 8, 0.3); .card-value { color: #eab308; } }
    .stat-card.percentage { border-color: rgba(56, 189, 248, 0.3); .card-value { color: #38bdf8; } }
    .stat-card.abandoned { border-color: rgba(239, 68, 68, 0.3); .card-value { color: #ef4444; } }

    .time-card {
      align-items: flex-start;
      text-align: left;
      padding: 15px;
      min-height: auto;
      .card-value { font-size: 1.05rem; margin-top: 4px; color: #f1f5f9; }
      &.alert { border-color: rgba(239, 68, 68, 0.2); }
    }

    .severity-bars-container { display: flex; gap: 10px; }
    .severity-bar {
      flex: 1;
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 10px 14px;
      border-radius: 8px;
      background: #0f172a;
      font-size: 0.75rem;
      font-weight: 700;
      border: 1px solid #334155;
      &.low { color: #22c55e; border-color: rgba(34, 197, 94, 0.15); }
      &.medium { color: #eab308; border-color: rgba(234, 179, 8, 0.15); }
      &.high { color: #f97316; border-color: rgba(249, 115, 22, 0.15); }
      &.critical { color: #ef4444; border-color: rgba(239, 68, 68, 0.15); }
      .sev-count { background: rgba(255, 255, 255, 0.05); padding: 2px 8px; border-radius: 6px; color: white; }
    }

    .dialog-loading {
      text-align: center;
      padding: 30px 0;
      color: #94a3b8;
      .spinner {
        width: 30px;
        height: 30px;
        border: 3px solid #334155;
        border-top-color: #38bdf8;
        border-radius: 50%;
        margin: 0 auto 15px auto;
        animation: spin 0.8s linear infinite;
      }
    }
    @keyframes spin { to { transform: rotate(360deg); } }
  `]
})
export class UserAnalyticsDialogComponent implements OnInit {
  private store = inject(Store);
  private dialogRef = inject(MatDialogRef<UserAnalyticsDialogComponent>);
  public stats$!: Observable<any>;

  constructor(@Inject(MAT_DIALOG_DATA) public data: { user: User }) {}

  ngOnInit(): void {
    this.stats$ = this.store.select(selectUserAnalytics(this.data.user));
  }

  formatTime(minutes: number): string {
    if (!minutes || minutes === 0) return '0 min';
    if (minutes < 60) return `${minutes} min`;
    const hours = Math.floor(minutes / 60);
    const remMinutes = minutes % 60;
    return remMinutes > 0 ? `${hours}h ${remMinutes}m` : `${hours}h`;
  }

  close(): void {
    this.dialogRef.close();
  }
}