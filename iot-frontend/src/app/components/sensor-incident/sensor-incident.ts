import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { BaseChartDirective } from 'ng2-charts'; 
import { ChartConfiguration, ChartData, ChartType } from 'chart.js';
import { Incident } from '../../core/models/incident.model';
import { Component, Input, OnInit, OnChanges, SimpleChanges, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-sensor-incident',
  standalone: true,
  imports: [CommonModule, MatCardModule, BaseChartDirective, FormsModule],
  templateUrl: './sensor-incident.html',
  styleUrl: './sensor-incident.scss'
})
export class SensorIncidentComponent implements OnInit, OnChanges {
  // Služi kao inicijalni backup, ali sada podatke primarno vučemo na osnovu filtera
  @Input() incidents: Incident[] | null = [];
  @Input() sensorId!: number; 

  private http = inject(HttpClient);

  // Filteri za vreme
  selectedPeriod: string = '24h';
  customFromDate: string = '';
  customToDate: string = '';

 
  filteredIncidents: Incident[] = [];

 
  public doughnutChartOptions: ChartConfiguration['options'] = {
    responsive: true,
    maintainAspectRatio: false,
    // @ts-ignore
    cutout: '75%', // Pravi krofnu tanjom i elegantnijom
    plugins: { 
      legend: { 
        position: 'bottom', 
        labels: { color: '#fff', boxWidth: 12, font: { size: 11 } } 
      } 
    }
  };

  public doughnutChartData: ChartData<'doughnut'> = {
    labels: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'],
    datasets: [{ data: [0, 0, 0, 0], backgroundColor: ['#4caf50', '#ffeb3b', '#ff9800', '#f44336'] }]
  };

  public doughnutChartType: ChartType = 'doughnut';

  ngOnInit() {
    this.loadHistoricalIncidents();
  }

  ngOnChanges(changes: SimpleChanges) {
    
    if (changes['incidents'] || changes['sensorId']) {
    this.loadHistoricalIncidents();
    }
  }

  onPeriodChange() {
    this.loadHistoricalIncidents();
  }

  // Funkcija koja vuce incidente iz baze za izabrani period
  loadHistoricalIncidents() {
    if (!this.incidents || !this.sensorId) {
      this.filteredIncidents = [];
      this.updateChartData();
      return;
    }

    // 1. Prvo uzimamo samo incidente koji pripadaju OVOM senzoru
    let sensorIncidents = this.incidents.filter(inc => {
      const targetSensorId = inc.sensor?.id || (inc as any).sensorId;
      return Number(targetSensorId) === Number(this.sensorId);
    });

    if (this.selectedPeriod === 'all') {
      this.filteredIncidents = sensorIncidents;
      this.updateChartData();
      return;
    }

    
    let fromDate = new Date();
    let toDate = new Date();

    if (this.selectedPeriod === '24h') {
      fromDate.setHours(fromDate.getHours() - 24);
    } else if (this.selectedPeriod === '7d') {
      fromDate.setDate(fromDate.getDate() - 7);
    } else if (this.selectedPeriod === '30d') {
      fromDate.setDate(fromDate.getDate() - 30);
    } else if (this.selectedPeriod === '1y') {
      fromDate.setFullYear(fromDate.getFullYear() - 1);
    } else if (this.selectedPeriod === 'custom' && this.customFromDate && this.customToDate) {
      fromDate = new Date(this.customFromDate);
      toDate = new Date(this.customToDate);
    }

    const fromTime = fromDate.getTime();
    const toTime = toDate.getTime();

   
    this.filteredIncidents = sensorIncidents.filter(inc => {
      const incDate = new Date(inc.createdAt).getTime();
      return incDate >= fromTime && incDate <= toTime;
    });

    // Osvežavamo grafikon
    this.updateChartData();
  }
 
  private updateChartData() {
    const counts = { LOW: 0, MEDIUM: 0, HIGH: 0, CRITICAL: 0 };
    
    this.filteredIncidents.forEach(inc => {
      const sev = inc.severity?.toUpperCase(); 
      if (counts.hasOwnProperty(sev)) {
        counts[sev as keyof typeof counts]++;
      }
    });

    this.doughnutChartData = {
      labels: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'],
      datasets: [{
        ...this.doughnutChartData.datasets[0],
        data: [counts.LOW, counts.MEDIUM, counts.HIGH, counts.CRITICAL]
      }]
    };
  }
}