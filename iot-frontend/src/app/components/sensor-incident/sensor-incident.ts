
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { BaseChartDirective } from 'ng2-charts'; // Import za grafikon
import { ChartConfiguration, ChartData, ChartType } from 'chart.js';
import { Incident } from '../../core/models/incident.model';
import { Component, Input, OnChanges, SimpleChanges } from '@angular/core';

@Component({
  selector: 'app-sensor-incident',
  standalone: true,
  imports: [CommonModule, MatCardModule, BaseChartDirective],
  templateUrl: './sensor-incident.html',
  styleUrl: './sensor-incident.scss'
})
export class SensorIncidentComponent implements OnChanges {
  @Input() incidents: Incident[] | null = [];

  public doughnutChartOptions: ChartConfiguration['options'] = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: { legend: { position: 'bottom' } }
  };

  public doughnutChartData: ChartData<'doughnut'> = {
    labels: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'],
    datasets: [{ data: [0, 0, 0, 0], backgroundColor: ['#4caf50', '#ffeb3b', '#ff9800', '#f44336'] }]
  };

  public doughnutChartType: ChartType = 'doughnut';

  // Svaki put kada se lista incidenata promeni, azuriramo grafikon
  ngOnChanges(changes: SimpleChanges) {
    if (changes['incidents'] && this.incidents) {
      this.updateChartData();
    }
  }


  private updateChartData() {
    if (!this.incidents) {
      // Ako nema podataka, resetuj grafikon na nule
      this.doughnutChartData.datasets[0].data = [0, 0, 0, 0];
      this.doughnutChartData = { ...this.doughnutChartData };
      return;
    }

    const counts = { LOW: 0, MEDIUM: 0, HIGH: 0, CRITICAL: 0 };
    
    this.incidents.forEach(inc => {
      // Provera severity-ja
      const sev = inc.severity?.toUpperCase(); 
      if (counts.hasOwnProperty(sev)) {
        counts[sev as keyof typeof counts]++;
      }
    });

    // KLJUČNO: Kreiramo POTPUNO NOVI objekat za datasets da bi Chart.js detektovao promenu
    this.doughnutChartData = {
      labels: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'],
      datasets: [{
        ...this.doughnutChartData.datasets[0],
        data: [counts.LOW, counts.MEDIUM, counts.HIGH, counts.CRITICAL]
      }]
    };
  }
}