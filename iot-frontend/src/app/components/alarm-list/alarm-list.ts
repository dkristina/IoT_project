import { Component, Inject, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Store } from '@ngrx/store';
import { AlarmActions } from '../../store/alarm/alarm.action';
import { AlarmFilterComponent } from '../alarm-filter/alarm-filter';
import { selectAllAlarms } from '../../store/alarm/alarm.selector';
import { BehaviorSubject, combineLatest, map } from 'rxjs';
import { AuthService } from '../../core/services/auth';
import { MatDialog, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';

@Component({
  selector: 'app-alarms-list',
  standalone: true,
  templateUrl: './alarm-list.html',
  styleUrls: ['./alarm-list.scss'],
  imports: [CommonModule, AlarmFilterComponent, MatDialogModule]
})
export class AlarmsListComponent implements OnInit {
  private store = inject(Store);
  public authService = inject(AuthService);
  private dialog = inject(MatDialog);
  
  // 1. Originalni podaci iz store-a
  private allAlarms$ = this.store.select(selectAllAlarms);
  
  // 2. Subject koji prati sta je korisnik ukucao u filter
  private filterId$ = new BehaviorSubject<number | null>(null);

  
  filteredAlarms$ = combineLatest([this.allAlarms$, this.filterId$]).pipe(
    map(([alarms, filterId]) => {
      if (!filterId) return alarms; 
      
      return alarms.filter(a => a.sensor?.id === filterId || a.sensor?.id === filterId);
    })
  );

  ngOnInit() {
    this.loadAlarms();
  }

  loadAlarms() {
    this.store.dispatch(AlarmActions.loadAlarms());
  }

  // 4. Ova metoda se poziva kad dete (filter) emituje vrednost
  onFilterApply(sensorId: number) {
    this.filterId$.next(sensorId > 0 ? sensorId : null);
  }

  deleteAlarm(id: number) {
    const dialogRef = this.dialog.open(ConfirmDeleteDialog, {
      width: '380px',
      data: { 
        title: 'Obriši pravilo', 
        message: 'Da li ste sigurni da želite da obrišete ovaj alarm?' 
      }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result === true) {
        this.store.dispatch(AlarmActions.deleteAlarm({ id }));
      }
    });
  }
}


import { Component as DialogComponent } from '@angular/core';
import { MatIconModule } from '@angular/material/icon';
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
        Da li ste sigurni da želite trajno da obrišete ovaj alarm / pravilo? Ova akcija se ne može poništiti.
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
