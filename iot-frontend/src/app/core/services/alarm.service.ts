import { HttpClient, HttpParams, HttpHeaders } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, Subject } from 'rxjs';
import { take, takeUntil, map } from 'rxjs/operators'; // USLOV: RxJS operatori
import { Alarm, AlarmSeverity } from '../models/alarm.model';

@Injectable({
  providedIn: 'root'
})
export class AlarmsService {
  private http = inject(HttpClient);
  private apiUrl = 'http://localhost:3000/alarms';
  

  private getHeaders(): HttpHeaders {
    const token = localStorage.getItem('access_token');
    return new HttpHeaders().set('Authorization', `Bearer ${token}`);
  }

  // 1. Dobijanje svih alarma uz opcioni filter (GET /alarms?sensorId=X)
  // USLOV: Rad sa parametrima upita (Query params)
 findAll(sensorId?: number): Observable<Alarm[]> {
    let params = new HttpParams();
    if (sensorId) {
      params = params.append('sensorId', sensorId.toString());
    }

    return this.http.get<Alarm[]>(this.apiUrl, { 
      headers: this.getHeaders(), 
      params 
    }).pipe(
      map(alarms => {
        const priority = { [AlarmSeverity.CRITICAL]: 4, [AlarmSeverity.HIGH]: 3, [AlarmSeverity.MEDIUM]: 2, [AlarmSeverity.LOW]: 1 };
        return alarms.sort((a, b) => priority[b.severity] - priority[a.severity]);
      })
    );
  }

  // 2. Dobijanje jednog alarma (GET /alarms/:id)
  // USLOV: take(1) - uzmi podatak jednom i odmah zatvori stream (efikasnost)
  findOne(id: number): Observable<Alarm> {
    return this.http.get<Alarm>(`${this.apiUrl}/${id}`, { headers: this.getHeaders() })
      .pipe(take(1));
  }

  // 3. Kreiranje alarma (POST /alarms) - Samo ADMIN
  create(alarmData: Partial<Alarm>): Observable<Alarm> {
    return this.http.post<Alarm>(this.apiUrl, alarmData, { headers: this.getHeaders() });
  }

  // 4. Ažuriranje alarma (PATCH /alarms/:id) - Samo ADMIN
  update(id: number, alarmData: Partial<Alarm>): Observable<Alarm> {
    return this.http.patch<Alarm>(`${this.apiUrl}/${id}`, alarmData, { headers: this.getHeaders() });
  }

  // 5. Brisanje alarma (DELETE /alarms/:id) - Samo ADMIN
  remove(id: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/${id}`, { headers: this.getHeaders() });
  }

  
}