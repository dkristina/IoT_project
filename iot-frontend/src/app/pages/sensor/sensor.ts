import { Component, OnInit, inject } from '@angular/core';
import { Store } from '@ngrx/store';
import { BehaviorSubject, combineLatest, map } from 'rxjs';
import * as SensorActions from '../../store/sensors/sensor.actions';
import * as SensorSelectors from '../../store/sensors/sensor.selector';

// Angular Material imports
import { MatTableModule } from '@angular/material/table';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { AsyncPipe, CommonModule } from '@angular/common';
import { Sensor } from '../../core/models/sensor.model';
import { RouterModule } from '@angular/router';
import { Router } from '@angular/router';
import { AddSensorComponent } from '../../components/add-sensor/add-sensor';
import { EditSensorComponent } from '../../components/edit-sensor/edit-sensor';
import { AuthService } from '../../core/services/auth';


@Component({
  selector: 'app-sensors',
  standalone: true,
  templateUrl: './sensor.html',
  styleUrls: ['./sensor.scss'],
  imports: [
    CommonModule,
    AsyncPipe,
    RouterModule,
    MatTableModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatIconModule,
    MatProgressSpinnerModule,
  
  ]
})
export class SensorsComponent implements OnInit {
  private store = inject(Store);
  private router = inject(Router);
  public authService = inject(AuthService);

  
  // Lokalni stream za filter (inicijalno prazan string)
  private filter$ = new BehaviorSubject<string>('');

  displayedColumns = ['id', 'name', 'location', 'unit', 'actions'];
  loading$ = this.store.select(SensorSelectors.selectLoading);

  // Kombinujemo sve senzore iz Store-a sa filterom
  filteredSensors$ = combineLatest([
    this.store.select(SensorSelectors.selectAll),
    this.filter$
  ]).pipe(
    map(([sensors, filterTerm]) => 
      sensors.filter(s => 
        s.name.toLowerCase().includes(filterTerm) || 
        s.location.toLowerCase().includes(filterTerm)
      )
    )
  );

  ngOnInit() {
    this.store.dispatch(SensorActions.loadSensors());
  }

  applyFilter(event: Event) {
    const value = (event.target as HTMLInputElement).value.trim().toLowerCase();
    this.filter$.next(value); // Samo saljem novu vrednost u filter stream
  }

  deleteSensor(id: number) {
    if (confirm('Da li ste sigurni?')) {
      this.store.dispatch(SensorActions.deleteSensor({ id }));
    }
  }

  openAddSensor() {
  this.router.navigate(['/sensors/new']);
}

  getLastMeasurement(sensor: Sensor): string {
    if (!sensor.measurements || sensor.measurements.length === 0) {
        return 'Nema podataka';
    }
    // Uzimamo poslednje merenje iz niza
    const last = sensor.measurements[sensor.measurements.length - 1];
    return `${last.value} ${sensor.unit}`;
  }

  openEditDialog(sensor: Sensor) {
    this.router.navigate(['/sensors/edit', sensor.id]);
  }
}