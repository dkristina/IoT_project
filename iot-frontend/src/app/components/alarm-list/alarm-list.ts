import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Store } from '@ngrx/store';
import { AlarmActions } from '../../store/alarm/alarm.action';
import { AlarmFilterComponent } from '../alarm-filter/alarm-filter';
import { selectAllAlarms } from '../../store/alarm/alarm.selector';
import { BehaviorSubject, combineLatest, map } from 'rxjs';
import { AuthService } from '../../core/services/auth';

@Component({
  selector: 'app-alarms-list',
  standalone: true,
  templateUrl: './alarm-list.html',
  styleUrls: ['./alarm-list.scss'],
  imports: [CommonModule, AlarmFilterComponent]
})
export class AlarmsListComponent implements OnInit {
  private store = inject(Store);
  public authService = inject(AuthService);
  
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
    if (confirm('Obriši alarm?')) {
      this.store.dispatch(AlarmActions.deleteAlarm({ id }));
    }
  }
}