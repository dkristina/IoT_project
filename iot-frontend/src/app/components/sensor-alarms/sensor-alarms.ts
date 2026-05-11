import { Component, Input, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button'; // Dodaj ovo
import { FormsModule } from '@angular/forms'; // OBAVEZNO za editovanje
import { Store } from '@ngrx/store';
import { AlarmActions } from '../../store/alarm/alarm.action';
import { AuthService } from '../../core/services/auth';


@Component({
  selector: 'app-sensor-alarms',
  standalone: true,
  imports: [CommonModule, MatIconModule, MatCardModule, MatButtonModule, FormsModule],
  templateUrl: './sensor-alarm.html', // Preporučujem da odvojiš HTML
  styleUrls: ['./sensor-alarm.scss']
})
export class SensorAlarmsComponent {
  @Input() alarms: any[] = [];
  @Input() unit: string = '';
  
  private store = inject(Store);
  public authService = inject(AuthService);

  // Stanje za editovanje
  editId: number | null = null;
  tempLow: number = 0;
  tempHigh: number = 0;

  startEdit(rule: any) {
    this.editId = rule.id;
    this.tempLow = rule.lowThreshold;
    this.tempHigh = rule.highThreshold;
  }

  cancelEdit() {
    this.editId = null;
  }

  saveEdit(rule: any) {
    // Osiguravamo da su vrednosti brojevi (pomoću Number() ili + operacije)
    const changes = {
      lowThreshold: Number(this.tempLow),
      highThreshold: Number(this.tempHigh)
    };

    console.log('Šaljem izmene:', changes); // Proveri u konzoli da li su vrednosti 30

    this.store.dispatch(AlarmActions.updateAlarm({
      id: rule.id,
      changes: changes
    }));

    this.editId = null;
  }

  deleteAlarm(id: number) {
    if (confirm('Da li ste sigurni da želite da obrišete ovo pravilo?')) {
      this.store.dispatch(AlarmActions.deleteAlarm({ id }));
    }
  }
}