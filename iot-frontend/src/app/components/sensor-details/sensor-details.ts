import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterModule } from '@angular/router'; 
import { Store } from '@ngrx/store';
import { Observable } from 'rxjs';
import { filter, map, switchMap, take, tap } from 'rxjs/operators';

import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip'; // Dodato za tooltip-ove u HTML-u


import { SensorHistoryComponent } from '../sensor-history/sensor-history'; 
import { selectLoading, selectSensorById } from '../../store/sensors/sensor.selector';
import * as SensorActions from '../../store/sensors/sensor.actions'; 
import { SensorAlarmsComponent } from '../sensor-alarms/sensor-alarms';
import { IncidentActions } from '../../store/incident/incident.actions';
import { IncidentStatus } from '../../core/models/incident.model';
import { AlarmSeverity } from '../../core/models/alarm.model';
import { AuthService } from '../../core/services/auth';
import { WebsocketService } from '../../core/services/websocket.service';
import { selectSensorIncidentHistory } from '../../store/incident/incident.selector';
import { SensorIncidentComponent } from '../sensor-incident/sensor-incident';

@Component({
  selector: 'app-sensor-details',
  standalone: true,
  templateUrl: './sensor-details.html',
  styleUrl: './sensor-details.scss',
  imports: [
    CommonModule, 
    RouterModule, 
    MatProgressSpinnerModule, 
    MatCardModule, 
    MatIconModule, 
    MatButtonModule,
    MatTooltipModule, 
    SensorHistoryComponent,
    SensorAlarmsComponent,
    SensorIncidentComponent
  ]
})
export class SensorDetailsComponent implements OnInit {
  private store = inject(Store);
  private route = inject(ActivatedRoute);
  public authService = inject(AuthService); 
  private wsService = inject(WebsocketService);
  
  currentSensor: any = null;
  
  
  sensor$: Observable<any> = this.route.paramMap.pipe(
    map(params => Number(params.get('id'))),
    switchMap(id => this.store.select(selectSensorById(id))),
    tap(sensor => this.currentSensor = sensor)
  );

  //Prati istoriju incidenata za ovaj sensor 
  incidents$ = this.route.paramMap.pipe(
    map(params => Number(params.get('id'))),
    switchMap(id => this.store.select(selectSensorIncidentHistory(id)))
  );

  loading$ = this.store.select(selectLoading);

  ngOnInit() {
    // 1. Inicijalno ucitavanje
    this.route.paramMap.pipe(
      map(params => params.get('id')),
      filter(id => !!id),
      map(id => Number(id)),
      tap(id => {
        // Ucitavamo i senzor i njegove incidente
        this.store.dispatch(SensorActions.loadSensorById({ id }));
        this.store.dispatch(IncidentActions.loadIncidentsBySensor({ sensorId: id }));
      })
    ).subscribe();

    // 2. LIVE REFRESH
    this.wsService.listenToMeasurements().subscribe((newMeasurement) => {
      // Ako merenje pripada ovom senzoru koji trenutno gledamo
      if (this.currentSensor && Number(newMeasurement.sensorId) === Number(this.currentSensor.id)) {
        console.log('Stiglo merenje, osvežavam tabelu...');
        
        // Ponovo pozivamo loadSensorById da bi NgRx povukao novu istoriju sa beka
        this.store.dispatch(SensorActions.loadSensorById({ id: this.currentSensor.id }));
      }
    });
  }

  reportManualIncident() {
    if (!this.currentSensor) return;

    const reason = window.prompt('Opišite problem:');
    if (!reason) return;

    // LOGIKA ZA SEVERITY: 
    let suggestedSeverity = AlarmSeverity.MEDIUM; 
    
    if (this.currentSensor.alarms && this.currentSensor.alarms.length > 0) {
      const hasCritical = this.currentSensor.alarms.some((a: any) => a.severity === AlarmSeverity.CRITICAL);
      const hasHigh = this.currentSensor.alarms.some((a: any) => a.severity === AlarmSeverity.HIGH);
      const hasLow = this.currentSensor.alarms.some((a: any) => a.severity === AlarmSeverity.LOW);

      if (hasCritical) suggestedSeverity = AlarmSeverity.CRITICAL;
      else if (hasHigh) suggestedSeverity = AlarmSeverity.HIGH;
      else if(hasLow) suggestedSeverity = AlarmSeverity.LOW; 
    }

    this.authService.currentUser$.pipe(take(1)).subscribe(user => {
      const creatorName = user?.username || 'Admin';

      const newIncident = {
        description: `[RUČNA PRIJAVA - ${creatorName}]: ${reason}`, 
        severity: suggestedSeverity, // Ovde sada ide prepisana vrednost iz pravila alarma
        sensorId: Number(this.currentSensor.id),
        status: IncidentStatus.NEW 
      }

      this.store.dispatch(IncidentActions.createIncident({ incident: newIncident }));
      console.log(`Kreiran incident sa ozbiljnošću: ${suggestedSeverity}`);
    });
}
}