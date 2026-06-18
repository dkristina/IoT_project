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
import { AuthService } from '../../core/services/auth';
import { MatDialog, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { ManualIncidentDialogComponent } from '../../components/manual-incident-dialog/manual-incident-dialog';


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
    MatDialogModule
  
  ]
})
export class SensorsComponent implements OnInit {
  private store = inject(Store);
  private router = inject(Router);
  public authService = inject(AuthService);
  private dialog = inject(MatDialog);
  
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

  
 public deleteSensor(id: number): void {
    
    const dialogRef = this.dialog.open(ConfirmDeleteDialog, {
      width: '400px',
      disableClose: false
    });


    dialogRef.afterClosed().subscribe(result => {
      if (result === true) {
        this.store.dispatch(SensorActions.deleteSensor({ id }));
      }
    });
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

// ==========================================
// Pomocna komponenta za moderan dijalog brisanja
// ==========================================
import { Component as DialogComponent } from '@angular/core';
@DialogComponent({
  selector: 'confirm-delete-dialog',
  standalone: true,
  imports: [MatDialogModule, MatButtonModule, MatIconModule],
  template: `
    <div style="background: #161f2e; color: white; padding: 1.5rem; border-radius: 15px;">
      <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 1rem; color: #ef4444;">
        <mat-icon>delete_forever</mat-icon>
        <h3 style="margin: 0; font-weight: 600; font-size: 1.2rem; color: white;">Potvrda brisanja</h3>
      </div>
      
      <mat-dialog-content style="padding: 0; margin-bottom: 1.5rem; color: #9ca3af;">
        Da li ste sigurni da želite trajno da obrišete ovaj senzor? Ova akcija se ne može poništiti.
      </mat-dialog-content>

      <mat-dialog-actions align="end" style="padding: 0; gap: 10px;">
        <button mat-button style="color: #9ca3af;" (click)="dialogRef.close(false)">Otkaži</button>
        <button mat-raised-button style="background-color: #ef4444 !important; color: white !important; font-weight: 600; border-radius: 8px;" (click)="dialogRef.close(true)">
          Obriši
        </button>
      </mat-dialog-actions>
    </div>
  `
})
export class ConfirmDeleteDialog {
  constructor(public dialogRef: MatDialogRef<ConfirmDeleteDialog>) {}
}


