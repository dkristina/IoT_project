import { Component, Input, OnChanges, OnInit, SimpleChanges, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button'; // Dodaj ovo
import { FormBuilder, FormGroup, FormsModule, ReactiveFormsModule, Validators } from '@angular/forms'; // OBAVEZNO za editovanje
import { Store } from '@ngrx/store';
import { AlarmActions } from '../../store/alarm/alarm.action';
import { AuthService } from '../../core/services/auth';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';

@Component({
  selector: 'app-sensor-alarms',
  standalone: true,
  imports: [CommonModule, MatIconModule, MatCardModule, MatButtonModule, FormsModule, ReactiveFormsModule],
  templateUrl: './sensor-alarm.html', 
  styleUrls: ['./sensor-alarm.scss']
})
export class SensorAlarmsComponent implements OnInit, OnChanges{
  @Input() unit: string = '';
  @Input() sensorId!: number;

  alarms$: Observable<any[]> | null = null;
  
  private store = inject(Store);
  public authService = inject(AuthService);
  private dialog = inject(MatDialog);

  // Stanje za editovanje
  editId: number | null = null;
  tempLow: number = 0;
  tempHigh: number = 0;

  ngOnInit() {
    this.store.dispatch(AlarmActions.loadAlarms());
  }

  ngOnChanges(changes: SimpleChanges) {
    if (changes['sensorId'] && this.sensorId) {
      this.alarms$ = this.store.select(selectAlarmsBySensorId(Number(this.sensorId)));
    }
  }
  
  startEdit(rule: any) {
    this.editId = rule.id;
    this.tempLow = rule.lowThreshold;
    this.tempHigh = rule.highThreshold;
  }

  cancelEdit() {
    this.editId = null;
  }

  saveEdit(rule: any) {
    // Osiguravamo da su vrednosti brojevi
    const changes = {
      lowThreshold: Number(this.tempLow),
      highThreshold: Number(this.tempHigh)
    };

    console.log('Šaljem izmene:', changes); 

    this.store.dispatch(AlarmActions.updateAlarm({
      id: rule.id,
      changes: changes
    }));

    this.editId = null;
  }

  deleteAlarm(id: number) {
    const dialogRef = this.dialog.open(DeleteAlarmConfirmationDialog);

    dialogRef.afterClosed().subscribe(confirmed => {
      if (confirmed) {
        this.store.dispatch(AlarmActions.deleteAlarm({ id }));
      }
    });
  }

  openAddAlarmDialog() {
    const dialogRef = this.dialog.open(AddAlarmDialog, {
      data: { unit: this.unit }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        // Kreiramo objekat koji backend očekuje
        const newAlarm = {
          lowThreshold: Number(result.lowThreshold),
          highThreshold: Number(result.highThreshold),
          severity: result.severity,
          sensorId: Number(this.sensorId)
        };
        
        // Ispali akciju za kreiranje 
        this.store.dispatch(AlarmActions.addAlarm({ alarm: newAlarm }));
      }
    });
  }
}


@Component({
  standalone: true,
  imports: [MatDialogModule],
  template: `
    <div class="custom-dialog-container danger-border">
      <div class="dialog-header">
        <h2 mat-dialog-title>🗑️ Brisanje pravila</h2>
      </div>
      
      <mat-dialog-content class="dialog-body">
        Da li ste sigurni da želite trajno da obrišete ovo alarmno pravilo?
      </mat-dialog-content>
      
      <mat-dialog-actions align="end" class="dialog-actions">
        <button [mat-dialog-close]="false" class="btn-secondary">Prekini</button>
        <button [mat-dialog-close]="true" class="btn-danger">Da, obriši</button>
      </mat-dialog-actions>
    </div>
  `,
  styles: [`
    .custom-dialog-container {
      background-color: #1e293b;
      color: #f8fafc;
      padding: 24px;
      border-radius: 12px;
      border: 1px solid #334155;
      font-family: inherit;
      max-width: 400px;
    }
    .danger-border {
      border-top: 4px solid #f44336; /* Crvena linija na vrhu za opasnost */
    }
    h2[mat-dialog-title] {
      margin: 0 0 12px 0;
      color: #f44336;
      font-size: 1.25rem;
      font-weight: 600;
    }
    .dialog-body {
      color: #cbd5e1;
      font-size: 0.95rem;
      line-height: 1.5;
      padding: 0 0 24px 0 !important;
    }
    .dialog-actions {
      padding: 0;
      gap: 12px;
    }
    .btn-secondary {
      background: transparent;
      color: #94a3b8;
      border: 1px solid #334155;
      border-radius: 6px;
      padding: 10px 18px;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.2s;
    }
    .btn-secondary:hover {
      background: #334155;
      color: #fff;
    }
    .btn-danger {
      background: #f44336;
      color: #fff;
      border: none;
      border-radius: 6px;
      padding: 10px 18px;
      font-weight: 600;
      cursor: pointer;
      transition: background 0.2s;
    }
    .btn-danger:hover {
      background: #d32f2f;
    }
  `]
})
export class DeleteAlarmConfirmationDialog {}


// NOVI DIJALOG ZA DODAVANJE ALARMA
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { Observable } from 'rxjs';
import { selectAlarmsBySensorId } from '../../store/alarm/alarm.selector';

@Component({
  standalone: true,
  imports: [CommonModule, MatDialogModule, ReactiveFormsModule],
  template: `
    <div class="custom-dialog-container primary-border">
      <h2 mat-dialog-title>➕ Novo Alarm Pravilo</h2>
      
      <form [formGroup]="alarmForm" (ngSubmit)="onSubmit()">
        <mat-dialog-content class="dialog-body-form">
          
          <div class="form-row">
            <div class="form-group">
              <label>Donja granica (Low)</label>
              <div class="input-with-unit">
                <input type="number" formControlName="lowThreshold" placeholder="0">
                <span class="unit">{{ data.unit }}</span>
              </div>
            </div>

            <div class="form-group">
              <label>Gornja granica (High)</label>
              <div class="input-with-unit">
                <input type="number" formControlName="highThreshold" placeholder="100">
                <span class="unit">{{ data.unit }}</span>
              </div>
            </div>
          </div>

          <div class="form-group" style="margin-top: 15px;">
            <label>Nivo ozbiljnosti (Severity)</label>
            <select formControlName="severity" class="custom-select">
              <option value="LOW">LOW</option>
              <option value="MEDIUM">MEDIUM</option>
              <option value="HIGH">HIGH</option>
              <option value="CRITICAL">CRITICAL</option>
            </select>
          </div>

        </mat-dialog-content>
        
        <mat-dialog-actions align="end" class="dialog-actions">
          <button type="button" (click)="onCancel()" class="btn-secondary">Otkaži</button>
          <button type="submit" [disabled]="alarmForm.invalid" class="btn-primary">Sačuvaj pravilo</button>
        </mat-dialog-actions>
      </form>
    </div>
  `,
  styles: [`
    .custom-dialog-container { background-color: #1e293b; color: #f8fafc; padding: 24px; border-radius: 12px; border: 1px solid #334155; width: 420px; }
    .primary-border { border-top: 4px solid #3b82f6; }
    h2 { margin: 0 0 20px 0; color: #3b82f6; font-size: 1.3rem; font-weight: 600; }
    .form-row { display: flex; gap: 15px; }
    .form-group { display: flex; flex-direction: column; flex: 1; gap: 5px; }
    label { color: #94a3b8; font-size: 12px; font-weight: 600; text-transform: uppercase; }
    
    .input-with-unit {
      position: relative;
      display: flex;
      align-items: center;
      input {
        width: 100%; background: #0f172a; border: 1px solid #334155; border-radius: 6px; color: #fff; padding: 10px 40px 10px 12px; font-size: 14px; outline: none;
        &:focus { border-color: #3b82f6; }
      }
      .unit { position: absolute; right: 12px; color: #64748b; font-size: 13px; font-weight: 500; }
    }

    .custom-select {
      background: #0f172a; border: 1px solid #334155; border-radius: 6px; color: #fff; padding: 10px; font-size: 14px; outline: none; cursor: pointer;
      &:focus { border-color: #3b82f6; }
    }

    .dialog-actions { gap: 12px; padding-top: 20px; }
    .btn-secondary { background: transparent; color: #94a3b8; border: 1px solid #334155; padding: 10px 18px; border-radius: 6px; cursor: pointer; }
    .btn-primary { background: #3b82f6; color: white; border: none; padding: 10px 18px; border-radius: 6px; font-weight: 600; cursor: pointer; transition: background 0.2s; }
    .btn-primary:hover { background: #2563eb; }
    .btn-primary:disabled { background: #1e293b; color: #475569; border: 1px solid #334155; cursor: not-allowed; }
  `]
})
export class AddAlarmDialog {
  private fb = inject(FormBuilder);
  private dialogRef = inject(MatDialogRef<AddAlarmDialog>);
  public data = inject(MAT_DIALOG_DATA);

  alarmForm: FormGroup = this.fb.group({
    lowThreshold: [0, [Validators.required]],
    highThreshold: [100, [Validators.required]],
    severity: ['LOW', [Validators.required]]
  });

  onSubmit() {
    if (this.alarmForm.valid) {
      this.dialogRef.close(this.alarmForm.value);
    }
  }

  onCancel() {
    this.dialogRef.close(null);
  }
}