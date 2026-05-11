import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { AuthService } from '../../core/services/auth';
import { Store } from '@ngrx/store';
import * as DashboardActions from '../../store/dashboard/dashboard.actions';
import { Observable } from 'rxjs';
import { selectDashboardStats, DashboardStats } from '../../store/dashboard/dashboard.selectors';
import { BaseChartDirective } from 'ng2-charts';
import * as DashboardSelectors from '../../store/dashboard/dashboard.selectors';
import { ChartData, ChartType, ChartConfiguration } from 'chart.js';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule, BaseChartDirective],
  templateUrl: './dashboard.html',
  styleUrls: ['./dashboard.scss']
})
export class DashboardComponent implements OnInit {
  public authService = inject(AuthService);
  private store = inject(Store);
  today: Date = new Date();

  public stats$: Observable<DashboardStats> = this.store.select(selectDashboardStats) as Observable<DashboardStats>;
  public recentIncidents$ = this.store.select(DashboardSelectors.selectRecentIncidents);

  // FIX ZA ERROR TS2551: Ova linija mora postojati da bi HTML radio
  public doughnutChartType: ChartType = 'doughnut';

  public doughnutChartOptions: ChartConfiguration['options'] = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        display: true,
        position: 'bottom',
        labels: { color: '#94a3b8', font: { size: 11 } }
      }
    }
  };

  public doughnutChartData: ChartData<'doughnut'> = {
    labels: ['Low', 'Medium', 'High', 'Critical'],
    datasets: [{ 
      data: [0, 0, 0, 0], 
      backgroundColor: ['#28a745', '#ffc107', '#fd7e14', '#dc3545'],
      hoverOffset: 4,
      borderWidth: 0,
      // @ts-ignore
      cutout: '75%' 
    }]
  };
  
  ngOnInit() {
    this.store.dispatch(DashboardActions.loadDashboard());

    this.store.select(DashboardSelectors.selectAllIncidents).subscribe(incidents => {
      if (incidents) {
        const active = incidents.filter(i => i.status !== 'RESOLVED');
        const low = active.filter(i => i.severity === 'LOW').length;
        const medium = active.filter(i => i.severity === 'MEDIUM').length;
        const high = active.filter(i => i.severity === 'HIGH').length;
        const critical = active.filter(i => i.severity === 'CRITICAL').length;

        this.doughnutChartData = {
          labels: ['Low', 'Medium', 'High', 'Critical'],
          datasets: [{ 
            data: [low, medium, high, critical],
            backgroundColor: ['#28a745', '#ffc107', '#fd7e14', '#dc3545'],
            hoverOffset: 4,
            borderWidth: 0,
            // @ts-ignore
            cutout: '75%' 
          }]
        };
      }
    });
  }

  getUnitIcon(unit: string | undefined): string {
    if (!unit) return '📟'; 
    switch (unit.toUpperCase()) {
      case 'CELSIUS': case '°C': return '🌡️';
      case 'VOLT': case 'V': return '⚡';
      case 'BAR': return '⏲️';
      case 'PERCENTAGE': case '%': return '💧';
      default: return '📟'; 
    }
  }
}